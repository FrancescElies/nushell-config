def "config broot" [] {
  if $nu.os-info.name == "windows" {
    nvim $"($env.APPDATA)/dystroy/broot/config/conf.hjson" $"($env.APPDATA)/dystroy/broot/config/verbs.hjson"
  } else {
    nvim "~/.config/broot/config/conf.hjson" "~/.config/broot/config/verbs.hjson"
  }
}


# https://dystroy.org/broot/tricks/
# A generic fuzzy finder
# The goal here is to have a function you can use in shell to give you a path.
#
# Example:
# echo $(bo)
def bo [] {
  let os = (sys | get host.name)
  let select_hjson = (if $os == "Windows" {
    $"($env.APPDATA)/dystroy/broot/config/select.hjson"
  } else {
    $"~/.config/broot/config/select.hjson"
  } | path expand)
  if not ($select_hjson | path exists) {
    echo '
      # select.hjson
      verbs: [
          {
              invocation: "ok"
              key: "enter"
              leave_broot: true
              execution: ":print_path"
              apply_to: "file"
          }
      ]' | save $select_hjson
  }
  ^broot --conf $select_hjson
}

def tree [path: path = .] {
  ^broot -c :pt $path
}

