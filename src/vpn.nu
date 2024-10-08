# https://wiki.debian.org/WireGuard#Installation
# https://www.wireguard.com/netns/

# sudo systemctl enable/disable wg-quick@wg0
# sudo systemctl restart/start/stop wg-quick@wg0
# sudo journalctl -xeu wg-quick@wg0.service

# Put private key in /et/wireguard/wg-xx.conf
# wg genkey | save private
# open private
# open private | wg pubkey

# Config file needed for these functions to work
# /etc/wireguard/wg-xx.conf
#
# [Interface]
# # To get pubkey save privatekey in file and run `open private | wg pubkey`
# PrivateKey = AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
#
# [Peer]
# PublicKey = BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=
# AllowedIPs = 0.0.0.0/0, ::/0
# Endpoint = CCC.CCC.CCC.CCC:51820

use utils.nu print_purple

export module container {
    export def up [
      --addr: string = "10.14.0.2/16",
      --conf: path = /etc/wireguard/wg-ch.conf
    ] {

        print_purple create netns called container
        sudo ip netns add container

        print_purple create wireguard interface in init namespace
        sudo ip link add wg0 type wireguard

        # needs to be done before moving wg0 to container otherwise dns resolution won't work
        print_purple setconf wg0
        sudo wg setconf wg0 $conf

        print_purple move it to container netns
        sudo ip link set wg0 netns container

        print_purple configure wg0
        sudo ip -n container addr add $addr dev wg0

        print_purple wg0 up
        sudo ip -n container link set wg0 up

        print_purple bring up loopback interface for container netns
        sudo ip netns exec container ip link set dev lo up

        print_purple adding default route
        sudo ip -n container route add default dev wg0
    }

    export def down [ ] {
        print_purple "delete wg0"
        try { sudo ip -n container link del wg0 }

        print_purple "removing container netns"
        try { sudo ip netns del container }
    }

    # run app's traffic throughvpn
    #
    # Examples:
    #   Get ip and geolocation of vpn
    #   > vpn container exec curl https://ipinfo.io
    export def exec [...command: string] {
            sudo -E ip netns exec container sudo -E -u $"#(id -u)" -g $"#(id -g)" ...$command
    }
}

export module route-all-traffic {

    # ensures all traffic goes through vpn
    export def up [
      --iface_eth: string = "eno1",
      --iface_wlan: string = "wlp2s0",
      --addr: string = "10.14.0.2/16",
	  --conf: path = /etc/wireguard/wg-ch.conf
    ] {
        print_purple "killing wpa_supplicant & dhcpd"
        try { sudo killall wpa_supplicant dhcpcd }

        print_purple "adding physical netns"
        sudo ip netns add physical

        print_purple "creating wg0"
        # The birthplace is now the "physical" namespace,
        # which means the wireguard ciphertext UDP sockets will be assigned to devices like eth0 and wlan0
        sudo ip -n physical link add wg0 type wireguard
        # We can now move it into the "init" (1) namespace and it will still remember its birthplace for the sockets.
        sudo ip -n physical link set wg0 netns 1

        print_purple "configuring wg0"
        sudo wg setconf wg0 $conf
        sudo ip addr add $addr dev wg0

        print_purple $"moving ($iface_eth) to netns"
        sudo ip link set $iface_eth down
        sudo ip link set $iface_eth netns physical

        print_purple $"bringing up ($iface_eth)"
        sudo ip -n physical link set $iface_eth up

        print_purple $"moving ($iface_wlan) to netns"
        sudo ip link set $iface_wlan down
        sudo iw phy phy0 set netns name physical

        #print_purple $"bringing up ($iface_wlan)"
        #sudo ip -n physical link set $iface_wlan up

        print_purple $"start dhcpcd for ($iface_eth)"
        # add "export PATH=$PATH:/sbin:/usr/sbin" to .bashrc if dhcpcd not found
        sudo ip netns exec physical dhcpcd -b $iface_eth
        # sudo ip netns exec physical dhcpcd -b $iface_wlan
        # sudo ip netns exec physical wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant-wlan0.conf -i$iface_wlan

        print_purple $"setting wg0 up"
        sudo ip link set wg0 up
        sudo ip route add default dev wg0
    }

    export def down [
      iface_eth: string = "eno1",
      iface_wlan: string = "wlp2s0",
    ] {
        print_purple "killing processes"
        try { killall wpa_supplicant dhcpcd }

        print_purple "removing eth from physical netns"
        try { sudo ip -n physical link set $iface_eth down }
        try { sudo ip -n physical link set $iface_eth netns 1 }

        print_purple "removing wlan from physical netns"
        try { sudo ip -n physical link set $iface_wlan down }
        try { sudo ip netns exec physical iw phy phy0 set netns 1 }

        print_purple "delete wg0"
        try { sudo ip link del wg0 }

        print_purple "removing physical netns"
        try { sudo ip netns del physical }

        print_purple $"start dhcpcd for ($iface_eth)"
        sudo dhcpcd -b $iface_eth
        # dhcpcd -b $iface_wlan
        # wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant-wlan0.conf -i$iface_wlan
    }

    # run command bypassing vpn (goes directly to physical device)
    #
    # Examples:
    #
    # curl https://ipinfo.io
    # vpn routing-all-traffic bypass curl https://ipinfo.io
    export def bypass [...command: string] {
        sudo -E ip netns exec physical sudo -E -u $"#(id -u)" -g $"#(id -g)" ...$command
    }

}
