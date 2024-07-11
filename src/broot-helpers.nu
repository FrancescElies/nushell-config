# https://dystroy.org/broot/tricks/

# broot: list only dirs and cd into it
export def --env brd [] {
  let dir = ^broot --only-folders --conf ~/src/nushell-config/broot-config/selectdir.hjson
  cd $dir
}

# broot: list only dirs and cd into it
export alias d = brd

# broot: select a file and print to stdout
# A generic fuzzy finder
# The goal here is to have a function you can use in shell to give you a path.
#
# Example:
# echo $(bro)
export def bro [] { ^broot --conf ~/src/nushell-config/broot-config/select.hjson }

# broot: select a file and print to stdout
export alias s = bro

# print files tree structure with broot
export def tree [path: path = .] { ^broot -c :pt $path }

