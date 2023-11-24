source ~/src/nushell-config/symlink.nu

let config_folder = match $nu.os-info.name { 
  "windows" => "~/AppData/Roaming/nushell", 
  "macos" => "~/Library/Application Support/nushell", 
  _ => "not implemented"
}

ls $config_folder | where ($it.name) =~ `.nu$` | each {|x| rm $x.name } 
[~/src/nushell-config/env.nu, ~/src/nushell-config/config.nu] | each {|x| symlink $x $config_folder } 
