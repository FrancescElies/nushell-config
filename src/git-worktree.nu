use utils.nu print_purple
use az.nu *

# worktree
# --------

# git worktree list
export def gwtl [] {
  ^git worktree list | lines | parse --regex `(?P<path>.+?) +(?P<commit>\w+) \[(?P<branch>.+)\]`
}


def "nu-complete git worktree paths" [] { gwtl | get path }


def "nu-complete my-tasks" [] {
  (az my-tasks) | rename -c {System.Id: value,  System.Title: description} | select value description
}

def "nu-complete my-stories" [] {
  (az my-stories) | rename -c {System.Id: value,  System.Title: description} | select value description
}


# git worktree change directory
export def --env "gwtcd" [
  path?: string@"nu-complete git worktree paths"  # branch to create or checkout
] {
  cd $path
}

export def "git map-branch-with-task" [
  --branch(-b): string  # branch name
  --story(-s): int@"nu-complete my-stories"  # story number
  --task(-t): int@"nu-complete my-tasks"   # task number
] {
  let file = ("~/.gitconfig-branch-tickets.toml" | path expand)
  if not ($file | path exists) { touch $file }

  let branch_name = if ($branch | is-empty) { (git rev-parse --abbrev-ref HEAD) } else { $branch }

  print_purple $"mapping ($branch_name) to story=($story) task=($task) in ($file)"
  let branches = (open $file
  | get --ignore-errors branches
  | append [{name: $branch_name, story: $story, task: $task}]
  | uniq)
  {branches: $branches} | save -f $file
}

# git worktree add, convenience wrapper around git worktree add -b emergency-fix ../emergency-fix master
export def "gwtadd" [
  branch: string # branch to create or checkout, e.g. cesc/1234-my-description
  --upstream(-u): string = "origin"  # sets upstream
  --startingat(-@): string = ""  # create a new branch starting at <commit-ish> e.g. master,
  # custom stuff
  --story(-s): int@"nu-complete my-stories"  # story number
  --task(-t): int@"nu-complete my-tasks"   # task number
] {
  git map-branch-with-task -b $branch -s $story -t $task

  let repo_name = pwd | path basename | str replace ".git" ""
  # make sure path has no slashes coming from branch name
  let branch_folder = $branch | str replace -a -r `[\\/]` "-"
  let path = (".." | path join $"($repo_name)-($branch_folder)")

  git fetch --all
  if $startingat == "" {
    print_purple $"git worktree add -B ($branch) ($path)"
    git worktree add -B $branch $path
  } else {
    print_purple $"git worktree add -B ($branch) ($path) ($startingat)"
    git worktree add -B $branch $path $startingat
    print_purple $"set-upstream ($upstream) for ($branch)"
    cd $path
    git pull --set-upstream $upstream $branch
  }

  print_purple "gl -n 3"
  gl -n 3
}

# git worktree remove
export def --env "gwtr" [
  path: string@"nu-complete git worktree paths"
  --force(-f)
] {
  if $force { git clean -fdx; git worktree remove --force $path } else { git worktree remove $path }
}

# git worktree prune
export alias gwtprune = git worktree prune
# git worktree repair
export alias gwtrepair = git worktree repair

export def "git worktree bare-path" [] {
  ^git worktree list | parse --regex `(?P<path>.+?) +\(bare\)` | get 0?.path?
}
