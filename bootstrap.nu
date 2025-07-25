use src/symlinks.nu symlink
use src/utils.nu ask_yes_no


# broken on windows, using workaround
# YAZI_CONFIG_HOME=~/src/nushell-config/config/yazi/
def config-glazewm [] {
    let config_dir = '~/.glzr/glazewm'
    symlink --force ~/src/nushell-config/config/glazewm/ $config_dir
}

def config-foot [] {
    let config_dir = '~/.config/foot'
    symlink --force ~/src/nushell-config/config/foot/ $config_dir
}

def config-sway [] {
    let config_dir = '~/.config/sway'
    symlink --force ~/src/nushell-config/config/sway/ $config_dir
}

# broken on windows, using workaround
# YAZI_CONFIG_HOME=~/src/nushell-config/config/yazi/
def config-yazi [] {
    let config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\yazi' ,
        _ => "~/.config/yazi" ,
    }
    symlink --force ~/src/nushell-config/config/yazi/ $config_dir
}

def config-flowlauncher [] {
    let config_dir = '~\AppData\Roaming\FlowLauncher'
    symlink --force ~/src/nushell-config/config/flowlauncher/ $config_dir
}

def config-pueue [] {
    let config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\pueue' ,
        "macos" => '~/Library/Application Support/pueue' ,
        _ => "~/.config/pueue" ,
    }
    symlink --force ~/src/nushell-config/config/pueue/ $config_dir
}

def config-broot-bacon [] {
    # broot
    let broot_config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\broot' ,
        _ => "~/.config/broot" ,
    }
    if not ($broot_config_dir | path exists) { mkdir $broot_config_dir }
    symlink --force ~/src/nushell-config/broot-config $broot_config_dir

    # bacon
    let bacon_config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\bacon\config' ,
        "macos" => '~/Library/Application Support/org.dystroy.bacon' ,
        _ => "~/.config/bacon" ,
    }
    if not ($bacon_config_dir | path exists) { mkdir $bacon_config_dir }
    symlink --force ~/src/nushell-config/bacon-config $bacon_config_dir
}

export def main [] {
    mkdir ~/src/work
    mkdir ~/src/oss

    symlink --force ~/src/nushell-config/.inputrc ~/.inputrc

    # yt-dlp
    let yt_dlp = "~/bin/yt-dlp" | path expand
    if (not ($yt_dlp | path exists)) { http get https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp | save -f $yt_dlp }

    config-broot-bacon
    config-pueue
    config-yazi
    if $nu.os-info.name == "linux" {
        config-sway
        config-foot
    }
    if $nu.os-info.name == "windows" {
        config-glazewm
        config-flowlauncher
    }

    # uv
    if (which ^uv | is-empty ) {
        match $nu.os-info.name {
            "windows" => { powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex" }
            _ => { curl -LsSf https://astral.sh/uv/install.sh | sh },
        }
    }

    # nushell
    let nushell_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\nushell' ,
        "macos" => "~/Library/Application Support/nushell" ,
        _ => "~/.config/nushell" ,
    }
    if not ($nushell_dir | path exists) { mkdir $nushell_dir }
    symlink --force ~/src/nushell-config/env.nu ($nushell_dir | path join "env.nu")
    symlink --force ~/src/nushell-config/config.nu ($nushell_dir | path join "config.nu")

    # python
    config python

    if $nu.os-info.name == 'linux' { linux-key-remap }
}

def "config python" [] {
  mkdir ~/.pip/

  # prevent pip from installing packages in the global installation
  "
  [install]
  require-virtualenv = true
  [uninstall]
  require-virtualenv = true
  " | save -f ~/.pip/pip.conf
}

def linux-key-remap [] {
    if (not ('~/src/oss/keyd' | path exists)) {
        git clone https://github.com/rvaiya/keyd ~/src/oss/keyd
        cd ~/src/oss/keyd
        make
        sudo make install
        "
[ids]

*

[main]

# Maps capslock to escape when pressed and control when held.
capslock = overload(control, esc)

# Remaps the escape key to capslock
esc = capslock
" | sudo tee /etc/keyd/default.conf

        sudo systemctl enable --now keyd
    }


}
