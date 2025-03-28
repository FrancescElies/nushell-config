use src/symlinks.nu symlink
use src/utils.nu ask_yes_no

# debian/ubuntu: https://omakub.org/ opinionated setup

export def main [] {
    mkdir ~/src/work
    mkdir ~/src/oss

    let yt_dlp = "~/bin/yt-dlp" | path expand
    if (not ($yt_dlp | path exists)) { http get https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp | save -f $yt_dlp }

    let broot_config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\broot' ,
        _ => "~/.config/broot" ,
    }
    if not ($broot_config_dir | path exists) { mkdir $broot_config_dir }
    symlink --force ~/src/nushell-config/broot-config $broot_config_dir

    let bacon_config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\bacon\config' ,
        "macos" => '~/Library/Application Support/org.dystroy.bacon' ,
        _ => "~/.config/bacon" ,
    }
    if not ($bacon_config_dir | path exists) { mkdir $bacon_config_dir }
    symlink --force ~/src/nushell-config/bacon-config $bacon_config_dir

    let nushell_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\nushell' ,
        "macos" => "~/Library/Application Support/nushell" ,
        _ => "~/.config/nushell" ,
    }
    if not ($nushell_dir | path exists) { mkdir $nushell_dir }
    symlink --force ~/src/nushell-config/env.nu ($nushell_dir | path join "env.nu")
    symlink --force ~/src/nushell-config/config.nu ($nushell_dir | path join "config.nu")


    use src/install-basics.nu *

    match $nu.os-info.name {
        "windows" => {
            if (ask_yes_no "Install winget packages?") { install for-windows }
        },
        "macos" => {
            if (ask_yes_no "Install brew packages?") { install for-mac }
        },
        _ => {
            # debian
            if ("/etc/debian_version" | path exists) {
                if (ask_yes_no "Install custom pkgs (wezterm, localsend)?") { install custom-pkgs for-debian }
                if (ask_yes_no "Install apt packages?") { install pkgs for-debian }
            }
        },
    }

    # cross platform
    config python
    if (ask_yes_no "Install rust basics?") { install-or-upgrade rust }
    if (ask_yes_no "Install rust dev tools? (might take long)") {  install rust-devtools  }
}
