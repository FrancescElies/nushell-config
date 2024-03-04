mkdir ~/src/work
mkdir ~/src/oss

use src/symlinks.nu symlink

let target = match $nu.os-info.name {
    "windows" => "~/AppData/Roaming/nushell" ,
    "macos" => "~/Library/Application Support/nushell" ,
    _ => "~/.config/nushell" ,
}

symlink --force ~/src/nushell-config/ $target


use src/install-basics.nu *

if ("/etc/debian_version" | path exists) { install for-debian }
install rust
