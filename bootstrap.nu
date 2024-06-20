use src/symlinks.nu symlink
use src/utils.nu ask_yes_no

# debian/ubuntu: https://omakub.org/ opinionated setup

export def main [] {
    mkdir ~/src/work
    mkdir ~/src/oss

    let broot_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\broot' ,
        _ => "~/.config/broot" ,
    }
    if not ($broot_dir | path exists) { mkdir $broot_dir }
    symlink --force ~/src/nushell-config/broot-config/conf.hjson ($broot_dir | path join "config" "verbs.hjson")
    symlink --force ~/src/nushell-config/broot-config/verbs.hjson ($broot_dir | path join "config" "conf.hjson")

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
    if (ask_yes_no "Install python (rye)?") { install python }
    if (ask_yes_no "Install rust basics?") { install rust }
    if (ask_yes_no "Install rust dev tools? (might take long)") {  install rust-devtools  }
}
