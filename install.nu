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
install python
install rust
match (input $"(ansi purple_bold)Install rust dev tools?(ansi reset) This might take long [y/n]") {
    "y" | "yes" | "Y" => { install rust-devtools },
    _ => {}
}
