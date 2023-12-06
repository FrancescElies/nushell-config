# https://www.nushell.sh/blog/2023-09-19-nushell_0_85_0.html#improvements-to-parse-time-evaluation
# useful for conditional source (parse time evaluation)
#
#
# const WINDOWS_CONFIG =  "~/src/nushell-config/my-windows-config.nu"
# const UNIX_CONFIG = "~/src/nushell-config/empty.nu"
#
# const ACTUAL_CONFIG = if $nu.os-info.name == "windows" {
#     $WINDOWS_CONFIG
# } else {
#     $UNIX_CONFIG
# }
#
# source $ACTUAL_CONFIG
