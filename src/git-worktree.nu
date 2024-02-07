# worktree
# --------

# git worktree
alias gw = git worktree 
# git worktree list
export def "git worktree list" [] {
  ^git worktree list | parse --regex `(?P<path>.+?) +(?P<commit>\w+) \[(?P<branch>.+)\]`
}
# git worktree list
alias gwl = git worktree list
alias gwa = git worktree add

def "nu-complete git worktree list-paths" [] {
  gwl | get path | path relative-to (git worktree bare-path)
}



# git worktree add
export def --env "gwcd" [
  path?: string@"nu-complete git worktree list-paths"  # branch to create or checkout
] {
  cd ( (git worktree bare-path)| path join $path | str replace `\\` `/` )
}

export def --env "gwstart" [
  branch?: string@"nu-complete git worktree list-paths"  # branch to create or checkout
  --startingat(-@): string = "master"  # create a new branch starting at <commit-ish>, 
] {
  cd (git worktree bare-path)
  let branch = if $branch == null { input "target branch: " } else { $branch }
  # make sure path has no slashes coming from branch name
  let branch_folder = $branch | str replace -a -r `[\\/]` "-"
  let path = "worktrees" | path join $branch_folder
  if ($path | path exists) { 
    cd $path
  } else {
    # create a new branch named $branch starting at <commit-ish>, 
    # e.g.
    # git worktree add -b emergency-fix ./worktrees/emergency-fix master
    mkdir worktrees
    echo $"git worktree add -B ($branch) ($path) ($startingat)"
    git worktree add -B $branch $path $startingat --guess-remote
    cd $path
    # git push --set-upstream $upstream $branch
  }
  # cheap HACK
  if not (ls | where type == file | find "prepare" | is-empty) { ./prepare }
}

export def --env "gwpushy" [--upstream(-u): string = "origin"] {
  git push --set-upstream $upstream (git rev-parse --abbrev-ref HEAD) --force-with-lease
}

export def --env "gwpull" [--upstream(-u): string = "origin"] {
  git pull --set-upstream $upstream (git rev-parse --abbrev-ref HEAD) --force-with-lease
}

# git worktree remove
export def --env "gwr" [
  branch: string@"nu-complete git worktree list-paths"
  --force(-f)
] {
  cd (git worktree bare-path)
  if $force { git worktree remove --force $branch } else { git worktree remove $branch }
}

alias gwprune = git worktree prune 
# git worktree repair
alias gwrepair = git worktree repair

export def "git worktree bare-path" [] {
  ^git worktree list | parse --regex `(?P<path>.+?) +\(bare\)` | get 0?.path?
}
