# Create a symlink
export def symlink [
    existing: path   # The existing file
    new_link_name: path  # The name of the symlink
    --force(-f)     # if target exists moves it to
] {
    echo $"(ansi purple_bold)Creating symlink(ansi reset) ($existing) --> ($new_link_name)"
    let existing = ($existing | path expand --strict | path split | path join)
    let $new_link_name = ($new_link_name | path expand --no-symlink | path split | path join)

    if ($force and ($new_link_name | path exists)) { 
       echo $"Moving ($new_link_name) to trash"
       rm --trash --recursive $new_link_name
    }

    if $nu.os-info.family == 'windows' {
        if ($existing | path type) == 'dir' {
            echo $"mklink dir ($new_link_name)"
            mklink /D $new_link_name $existing
        } else {
            echo $"mklink ($new_link_name)"
            mklink $new_link_name $existing
        }
    } else {
        echo $"ln ($new_link_name)"
        ln -s $existing $new_link_name | ignore
    }
}
