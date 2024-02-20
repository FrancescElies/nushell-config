# worktree
# --------

# git worktree
alias gw = git worktree 
# git worktree list
export def gwl [] {
  ^git worktree list | lines | parse --regex `(?P<path>.+?) +(?P<commit>\w+) \[(?P<branch>.+)\]`
}

# gwa -B emergency-fix ../emergency-fix master
alias gwa = git worktree add

def "nu-complete git worktree paths" [] { gwl | get path }

# git worktree add
export def --env "gwcd" [
  path?: string@"nu-complete git worktree paths"  # branch to create or checkout
] {
  cd $path
}

export def --env "gwstart" [
  branch?: string@"nu-complete git worktree paths"  # branch to create or checkout
  --upstream(-u): string = "origin"  # sets upstream
  --startingat(-@): string = ""  # create a new branch starting at <commit-ish> e.g. master, 
] {
  let repo_name = pwd | path basename | str replace ".git" ""
  let branch = if $branch == null { input "target branch: " } else { $branch }
  # make sure path has no slashes coming from branch name
  let branch_folder = $branch | str replace -a -r `[\\/]` "-"
  let path = ".." | path join $"($repo_name)-($branch_folder)"

  # create a new branch named $branch starting at <commit-ish>, 
  # e.g.
  # git worktree add -b emergency-fix ../emergency-fix master
  echo $"branch ($branch), path ($path), startingat ($startingat)"
  if $startingat == "" { 
    git worktree add -B $branch $path 
  } else { 
    git worktree add -B $branch $path $startingat 
  }
  cd $path
  git pull --set-upstream $upstream $branch
}

# git worktree remove
export def --env "gwremove" [
  path: string@"nu-complete git worktree paths"
  --force(-f)
] {
  if $force { git worktree remove --force $path } else { git worktree remove $path }
}

alias gwprune = git worktree prune 
# git worktree repair
alias gwrepair = git worktree repair

export def "git worktree bare-path" [] {
  ^git worktree list | parse --regex `(?P<path>.+?) +\(bare\)` | get 0?.path?
}
