# edit .gitignore

# start a new topic
export def "git topic-begin" [
  ...topic: string 
  --startingat(-@): string = "master"  # create a new branch starting at <commit-ish>, 
] {
    let newbranch = $topic | str join "-"
    let newbranch = $"cesc/($newbranch)"
    git checkout $startingat
    git pull --ff-only
    git checkout -b $newbranch $startingat
    git push -u origin $newbranch
}
alias gtb = git topic-begin

# edit .gitignore
export def "git ignore-edit" [] {
    nvim $"(git rev-parse --show-toplevel)/.gitignore"
}

export def "git difft" [...rest] {
    with-env [GIT_EXTERNAL_DIFF 'difft'] { git diff ...$rest }
}


# Pull requests

def "pr create" [
  --target-branch (-t): string = 'master'  
] {
  git push
  az repos pr create --draft --open --auto-complete -t $target_branch -o table
}

def "git cm" [ 
  title: string 
  body: string = ""
] {
 let branch = (git rev-parse --abbrev-ref HEAD)
 let story = ($branch | parse -r '[Ss]tory(?<story>\d+)' | get story.0 )
 git commit --message $"($title)" --message $"($body)" --message $"story #($story)"
}


# Repack repositories in current folder
def "git repack-repos" [] {
    ls . | where type == dir | each { |folder|
        print $"Repacking ($folder.name)"
        cd $folder.name
        git pruner
        git repacker
    }
}

# Delete git merged branches (loal and remote)
def "git gone" [] {
    git branch -vl  
      | lines  
      | split column " " BranchName Hash Status --collapse-empty 
      | where Status == '[gone]' 
      | each { |it| git branch -D $it.BranchName }
}

#  View git committer activity as a histogram
def "git activity" [
  --path: path = .
  --since: string = '1 year ago'  
] {
  git log --since $'"($since)"' --pretty=%h»¦«%aN»¦«%s»¦«%aD  -- $path
  | lines 
  | split column "»¦«" sha1 committer_name desc merged_at 
  | histogram committer_name merger 
  | sort-by merger 
  | reverse
}


def "pr diff" [path: path = .] {
  let this_branch = (git rev-parse --abbrev-ref HEAD)
  git diff $this_branch ( git merge-base $this_branch origin/master ) 
}

# opens files modified by pr in nvim
def "pr files" [
  path: path = .
  --extension: string = ""  # ts, py, rs ... (no dot), default matches everything
  --target_branch: string = "origin/master"  # pr's target branch (normally main, master, ...)
] {
  let this_branch = (git rev-parse --abbrev-ref HEAD)
  let files = ( git diff --name-only $this_branch ( git merge-base $this_branch $target_branch ) | lines )
  if ($extension| is-empty) { 
    $files
  } else {
    let filtered_files = ( $files | filter { |x| ($x | path parse).extension == $extension} )
    $filtered_files
  }

}

# Opens current branch and target branch maxpats to comparison
def "pr review-maxpats" [
  --target_branch: string = "origin/master"  # pr's target branch (normally main, master, ...)
] {
  echo $"target branch: ($target_branch)"
  let open_files = pr files --extension maxpat | each { |x| (
    git show $"($target_branch):($x)" 
    | save -f $"($x | path expand | path dirname)/tmp-target-($x | path basename)" 
    ; start $x 
    ; start $"($x | path expand | path dirname)/tmp-target-($x | path basename)" 
    ; echo $x 
  ) }

  let untracked_maxpats = ( 
    (git ls-files . --exclude-standard --others) 
    | lines 
    | path parse 
    | filter {|x| $x.extension == "maxpat"} 
    | path join
  )
  echo "untracked maxpats:"
  echo $untracked_maxpats

  if (input "remove untracked maxpat files (y/n)?") == "y" {  
    $untracked_maxpats | each { || rm $in }
  } 
  echo "Once done cleanup: rm tmp_*maxpat"

}

# https://stackoverflow.com/questions/46704572/git-error-encountered-7-files-that-should-have-been-pointers-but-werent
def git-lfs-fix-everything [] {
  git lfs migrate import --fixup --everything
}

# https://stackoverflow.com/questions/46704572/git-error-encountered-7-files-that-should-have-been-pointers-but-werent
# This "migrates" files to git lfs which should be in lfs as per .gitattributes, but aren't at the moment (which is the reason for your error message).
#
# --no-rewrite prevents git from applying this to older commits, it creates a single new commit instead.
#
# Use -m "commitmessage" to set a commitmessage for that commit.
def git-lfs-fix [...paths: path] {
  git lfs migrate import --no-rewrite $paths
}

# work

def "git work new-branch" [
  story: number
  title: string 
  based_on: string = "origin/master"
] {
  let title = $title | str replace --all " " "-"  
  git topic-begin $"cesc/story($story)-($title)" $based_on 

  let pr_target = $based_on | str replace -r '(origin/)(.+)' '$2'
  pr create --target-branch $pr_target
}

# open git ui
alias gui = lazygit
# git diff
alias gd = git difft
# git add 
alias ga = git add
# git add all
alias gaa = git add --all
# git status
alias gs = git status
# git short log
alias gsl = git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
# git log
alias gl = git log --graph --pretty=format:'%C(auto)%h -%d %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
# git log all
alias gla = git log --graph --topo-order --date=short --abbrev-commit --decorate --all --boundary --pretty=format:'%Cgreen%ad %Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%cn]%Creset %Cblue%G?%Creset'
# git fetch all, prune remote branches
alias gfa = git fetch --all --prune
# git commit amend 
alias gca = git commit --amend 
# git commit amend, don't edit meesage
alias gcane = git commit --amend --no-edit
# git commit
alias gcm = git cm
# git checkout
alias gco = git checkout
# git cherry pick 
alias gcp = git cherry-pick
# git cherry pick abort
alias gcpa = git cherry-pick --abort
# git cherry pick continue
alias gcpc = git cherry-pick --continue
# git reset hard
alias gresethard = git reset --hard
# git uncommit
alias guncommit = git reset --soft HEAD~1
# git unadd files
alias gunadd = git reset HEAD
# Discard changes in path
alias gdiscard = git checkout --
# git clean into a pristine working directory 
alias gcleanest = git clean -dffx
# Clean (also untracked) and checkout.
def gcleanout [] = {git clean -df ; git checkout -- .}
# git push
alias gp = git push 
# git push force-with-lease
alias gpushy = git push --force-with-lease
# git pull
alias gpull = git pull
# git rebase 
alias grb = git rebase 
# git rebase interactive
alias grba = git rebase --interactive
# git rebase abort
alias grba = git rebase --abort
# git rebase continue
alias grbc = git rebase --continue

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

def "nu-complete git worktree list" [] {
  gwl | get path | path relative-to (git worktree bare-path)
}

# git worktree add
export def --env "gwstart" [
  branch?: string@"nu-complete git worktree list"  # branch to create or checkout
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
    git worktree add -B $branch $path $startingat
    cd $path
  }
  # cheap HACK
  if not (ls | where type == file | find "prepare" | is-empty) { ./prepare }
}

# git worktree remove
export def --env "gwr" [
  branch: string@"nu-complete git worktree list"
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

# git cd to root (bare or worktree)
alias groot = if ((git worktree bare-path) == null) { cd (git rev-parse --show-toplevel) } else { cd (git worktree bare-path) }
# git cd to root (bare or worktree)
alias cdroot = groot 
