# worktree
# --------

# git worktree
alias gw = git worktree 
# git worktree list
export def gwl [] {
  ^git worktree list | lines | parse --regex `(?P<path>.+?) +(?P<commit>\w+) \[(?P<branch>.+)\]`
}

alias gwa = git worktree add

def "nu-complete git worktree paths" [] { gwl | get path }

# git worktree add
export def --env "gwcd" [
  path?: string@"nu-complete git worktree paths"  # branch to create or checkout
] {
  cd ( (git worktree bare-path)| path join $path | str replace `\\` `/` )
}

export def --env "gwstart" [
  branch?: string@"nu-complete git worktree paths"  # branch to create or checkout
  --startingat(-@): string = "master"  # create a new branch starting at <commit-ish>, 
] {
  cd (git worktree bare-path)
  let repo_name = pwd | path basename | str replace ".git" ""
  let branch = if $branch == null { input "target branch: " } else { $branch }
  # make sure path has no slashes coming from branch name
  let branch_folder = $branch | str replace -a -r `[\\/]` "-"
  let path = ".." | path join $"($repo_name)-($branch_folder)"

  # create a new branch named $branch starting at <commit-ish>, 
  # e.g.
  # git worktree add -b emergency-fix ./mycheckouts/emergency-fix master
  echo $"git worktree add -B ($branch) ($path) ($startingat)"
  git worktree add -B $branch $path $startingat 
  cd $path
  # git push --set-upstream $upstream $branch

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
  branch: string@"nu-complete git worktree paths"
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
