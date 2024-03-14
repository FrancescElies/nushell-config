mkdir ~/src/work
mkdir ~/src/oss

use src/symlinks.nu symlink
use src/utils.nu ask_yes_no

let target = match $nu.os-info.name {
    "windows" => '~\AppData\Roaming\nushell' ,
    "macos" => "~/Library/Application Support/nushell" ,
    _ => "~/.config/nushell" ,
}

if not ($target | path exists) { mkdir $target }
symlink --force ~\src\nushell-config\env.nu ($target | path join "env.nu")
symlink --force ~\src\nushell-config\config.nu ($target | path join "config.nu")


use src/install-basics.nu *

# debian
if ("/etc/debian_version" | path exists) { 
    if (ask_yes_no "Install apt packages?", "rye") { install for-debian }
}

# cross platform
if (ask_yes_no "Install python?", "rye") { install python }
if (ask_yes_no "Install rustup?") { install rust }
if (ask_yes_no "Install rust dev tools?", "This might take long") {  install rust-devtools  }
