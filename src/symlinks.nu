# Create a symlink
export def symlink [
    existing: path   # The existing file
    link_name: path  # The name of the symlink
    --force(-f)     # if target exists moves it to
] {
    let existing = ($existing | path expand --strict | path split | path join)
    let link_name = ($link_name | path expand --strict --no-symlink | path split | path join)

    if ($force and ($link_name | path exists)) { 
       rm --trash --recursive $link_name
       echo $"($link_name) moved to trash"
    }

    if $nu.os-info.family == 'windows' {
        if ($existing | path type) == 'dir' {
            mklink /D $link_name $existing
        } else {
            mklink $link_name $existing
        }
    } else {
        ln -s $existing $link_name | ignore
    }
}
