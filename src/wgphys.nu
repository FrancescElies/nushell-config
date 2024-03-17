# https://wiki.debian.org/WireGuard#Installation
# https://www.wireguard.com/netns/

# sudo systemctl enable/disable wg-quick@wg0
# sudo systemctl restart/start/stop wg-quick@wg0
# sudo journalctl -xeu wg-quick@wg0.service

# Put private key in /et/wireguard/wg0.conf
# wg genkey | save private
# open private
# open private | wg pubkey

export def up [
  iface_eth: string = "eno1",
  iface_wlan: string = "wlp2s0",
] {
    echo "killing sensitive processes"
    try { sudo killall wpa_supplicant dhcpcd }

    echo "adding physical netns"
    try { sudo ip netns add physical }
    try { sudo ip -n physical link add wgvpn0 type wireguard }
    try { sudo ip -n physical link set wgvpn0 netns 1 }
    # sudo wg setconf wgvpn0 /etc/wireguard/wgvpn0.conf
    # sudo ip addr add 192.168.178.33/32 dev wgvpn0

    echo $"moving ($iface_eth) to netns"
    sudo ip link set $iface_eth down
    sudo ip link set $iface_eth netns physical

    echo $"moving ($iface_wlan) to netns"
    sudo ip link set $iface_wlan down
    sudo iw phy phy0 set netns name physical

    # sudo ip netns exec physical dhcpcd -b $iface_eth
    # sudo ip netns exec physical dhcpcd -b $iface_wlan
    # sudo ip netns exec physical wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant-wlan0.conf -i$iface_wlan

    echo "running wg-quick up wgvpn0"
    sudo wg-quick up /etc/wireguard/wgvpn0.conf
    # sudo ip link set wgvpn0 up
    # sudo ip route add default dev wgvpn0
}

export def down [
  iface_eth: string = "eno1",
  iface_wlan: string = "wlp2s0",
] {
    echo "killing processes"
    try { killall wpa_supplicant dhcpcd }
    echo "removing eth from physical netns"
    sudo ip -n physical link set $iface_eth down
    sudo ip -n physical link set $iface_eth netns 1
    echo "removing wlan from physical netns"
    sudo ip -n physical link set $iface_wlan down
    sudo ip netns exec physical iw phy phy0 set netns 1

    echo "wg-quick down wgvpn0"
    sudo wg-quick down /etc/wireguard/wgvpn0.conf
    # sudo ip link del wgvpn0

    echo "removing physical netns"
    sudo ip netns del physical

    # dhcpcd -b $iface_eth
    # dhcpcd -b $iface_wlan
    # wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant-wlan0.conf -i$iface_wlan
}
