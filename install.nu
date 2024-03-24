use src/symlinks.nu symlink
use src/utils.nu ask_yes_no

export def all [] {
    mkdir ~/src/work
    mkdir ~/src/oss

    let target = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\nushell' ,
        "macos" => "~/Library/Application Support/nushell" ,
        _ => "~/.config/nushell" ,
    }

    if not ($target | path exists) { mkdir $target }
    symlink --force ~/src/nushell-config/env.nu ($target | path join "env.nu")
    symlink --force ~/src/nushell-config/config.nu ($target | path join "config.nu")


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
    if (ask_yes_no "Install rustup?") { install rust }
    if (ask_yes_no "Install rust dev tools? (might take long)") {  install rust-devtools  }
}
