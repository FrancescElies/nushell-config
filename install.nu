use src/symlinks.nu symlink

let target = match $nu.os-info.name {
    "windows" => "~/AppData/Roaming/nushell" ,
    "macos" => "~/Library/Application Support/nushell" ,
    _ => "~/.config/nushell" ,
}

symlink --force ~/src/nushell-config/ $target
