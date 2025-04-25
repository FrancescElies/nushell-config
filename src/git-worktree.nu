use utils.nu print_purple

# worktree
# --------

# git worktree list as table
export def --wrapped "git worktree listt" [...rest] {
  ^git worktree list ...$rest | lines | parse --regex `(?P<path>.+?) +(?P<commit>\w+) \[(?P<branch>.+)\]`
}

def "nu-complete gw-paths" [] { git worktree listt | get path }

# git worktree change directory
export def --env "git worktree cd" [
  path?: string@"nu-complete gw-paths"  # branch to create or checkout
] {
  cd $path
}

# git worktree remove
export def --env "git worktree remove-with-force" [path: string@"nu-complete gw-paths"] {
  git clean -fdx; git worktree remove --force $path
}

export def "git worktree bare-path" [] {
  ^git worktree list | parse --regex `(?P<path>.+?) +\(bare\)` | get 0?.path?
}
