use utils.nu print_purple

# worktree
# --------

# git worktree
export alias gw = git worktree
# git worktree list
export def gwl [] {
  ^git worktree list | lines | parse --regex `(?P<path>.+?) +(?P<commit>\w+) \[(?P<branch>.+)\]`
}

# gwa -B emergency-fix ../emergency-fix master
export alias gwa = git worktree add

def "nu-complete git worktree paths" [] { gwl | get path }

# git worktree add
export def --env "gwcd" [
  path?: string@"nu-complete git worktree paths"  # branch to create or checkout
] {
  cd $path
}

# git worktree add, convenience wrapper around
export def "gwadd" [
  branch: string@"nu-complete git worktree paths"  # branch to create or checkout
  path?: string  # path to create worktree, e.g. ../emergency-fix
  --upstream(-u): string = "origin"  # sets upstream
  --startingat(-@): string = ""  # create a new branch starting at <commit-ish> e.g. master,
] {
  let repo_name = pwd | path basename | str replace ".git" ""
  # make sure path has no slashes coming from branch name
  let branch_folder = $branch | str replace -a -r `[\\/]` "-"
  let path = if $path == null {
    ".." | path join $"($repo_name)-($branch_folder)"
  } else {
    $path
  }

  # create a new branch named $branch starting at <commit-ish>,
  # e.g.
  # git worktree add -b emergency-fix ../emergency-fix master
  if $startingat == "" {
    print_purple $"git worktree add -B ($branch) ($path)"
    git worktree add -B $branch $path
  } else {
    print_purple $"git worktree add -B ($branch) ($path) ($startingat)"
    git worktree add -B $branch $path $startingat
  }

  print_purple "set-upstream"
  cd $path
  git pull --set-upstream $upstream $branch
  print_purple "gl -n 3"
  gl -n 3
}

# git worktree remove
export def --env "gwr" [
  path: string@"nu-complete git worktree paths"
  --force(-f)
] {
  if $force { git clean -fdx; git worktree remove --force $path } else { git worktree remove $path }
}

export alias gwprune = git worktree prune
# git worktree repair
export alias gwrepair = git worktree repair

export def "git worktree bare-path" [] {
  ^git worktree list | parse --regex `(?P<path>.+?) +\(bare\)` | get 0?.path?
}
