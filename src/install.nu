use ~/src/nushell-config/symlink.nu *


let config_folder = if $nu.os-info.name == "windows" {
  "~/AppData/Roaming/nushell" 
} else if $nu.os-info.name == "macos" {
  "~/Library/Application Support/nushell"
} else if $nu.os-info.name == "linux" {
  "~/.config/nushell"
} else {
  error make {msg: "not implemented", }
}

ls $config_folder | where ($it.name) =~ `.nu$` | each {|x| rm $x.name } 
[~/src/nushell-config/env.nu, ~/src/nushell-config/config.nu] | each {|x| symlink $x $config_folder } 
touch this-machine.nu
