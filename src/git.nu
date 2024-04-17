# https://www.youtube.com/watch?v=aolI_Rz0ZqY
# Apply some useful defaults
# git my-defaults
#
# Give me all my pull requests as local refs
# git config remote.origin.fetch '+refs/pull/*:refs/remotes/origin/pull/*'
#
# Conditional ~/.gitconfig
#
# [includelf "gitdir:~/projects/work/"]
#   path = ~/src/work/.gitconfig
# [includelf "gitdir:~/src/oss/"]
#   path = ~/projects/oss/.gitconfig
#
# Accidentally cloned http repo version?
# [url "git@github.com:"]
#   insteadOf = "https://github.com/"
# git maintenance start

# apply my defaults
export def "git my-defaults" [] {
  # https://jvns.ca/blog/2024/02/16/popular-git-config-options/#help-autocorrect-10
  git config --global push.autosetupremote true
  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global merge.conflictstyle zdiff3
  git config --global rebase.autosquash true
  git config --global push.default current
  git config --global help.autocorrect 10
  git config --global interactive.diffFilter delta --color-only
  git config --global diff.algorithm histogram
  git config --global branch.sort -committerdate
  git config --global fetch.prune true
  git config --global log.date iso
  git config --global rebase.missingCommitsCheck error
  git config --global rebase.updateRefs true

  # Avoid data corruption
  git config --global transfer.fsckobjects true
  git config --global fetch.fsckobjects true
  git config --global receive.fsckObjects true

  # REuse REordered REsolution, tells git to remember conflicts so if it sees them again he won't ask about it.
  git config --global rerere.enabled true
  git config --global branch.sort -committerdate
  # git config gpg.format ssh
  # git config user.signingkey ~/.ssh/id_ed25519
  
  # Big repository stuff
  #
  # git clone filters:
  # git clone --fitter=blob:none
  # git clone --fitter=tree:zero
  #
  # See multipack indexes, reachability bitmaps and geometric repacking
  # https://github.blog/2021-04-29-scaling-monorepo-maintenance
  # git maintenance start will also write the commit-graph
  git config --global fetch.writeCommitGraph true
  # file system monitory
  git config --global core.untrackedcache true
  git config --global core.fsmonitor true
}

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
    git pull -u origin $newbranch
    # git pull -u origin $newbranch
}
export alias gtb = git topic-begin

# edit .gitignore
export def "git ignore-edit" [] {
    nvim $"(git rev-parse --show-toplevel)/.gitignore"
}

export def --wrapped "git difft" [...rest] {
    with-env [GIT_EXTERNAL_DIFF 'difft'] { git diff ...$rest }
}

export def "git branches" [first: int = 5] { git branch --sort=-committerdate | lines | first $first }

# aliases
# -------
export alias gbb = git branches
# git difft
export alias gd = git difft
# git add 
export alias ga = git add
# git add all
export alias gaa = git add --all
# git status
export alias gs = git status
# git log search
export alias gls = git log -p -S
# git short log
export alias gsl = git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
# git blame ignore whitespace, deted lines moved/copied, or any commit
export alias gblame = git blame -w -C -C -C
# git log
export alias gl_ = git log --graph --pretty=format:'%C(auto)%h -%d %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
export alias gl = gl_ -n5
export alias gl10 = gl_ -n10
# git log with blame a little: glL :FunctionName:path/to/file, glL 15,26:path/to/file
export alias glL = git log -L
# git log all
export alias gla = git log --graph --topo-order --date=short --abbrev-commit --decorate --all --boundary --pretty=format:'%Cgreen%ad %Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%cn]%Creset %Cblue%G?%Creset'
# git fetch all, prune remote branches
export alias gf = git fetch 
export alias gfa = git fetch --all --prune
# git commit amend 
export alias gca = git commit --amend 
# git commit amend, don't edit meesage
export alias gcane = git commit --amend --no-edit
# git commit
export alias gcm = git commit -m
# git checkout
export alias gco = git checkout
# git cherry pick 
export alias gcp = git cherry-pick
# git cherry pick abort
export alias gcpa = git cherry-pick --abort
# git cherry pick continue
export alias gcpc = git cherry-pick --continue
# git reset hard
export alias gresethard = git reset --hard
# git uncommit
export alias guncommit = git reset --soft HEAD~1
# git unadd files
export alias gunadd = git reset HEAD
# Discard changes in path
export alias gdiscard = git checkout --
# git clean into a pristine working directory 
export alias gcleanest = git clean -dffx
# Clean (also untracked) and checkout.
def gcleanout [] = {git clean -df ; git checkout -- .}
# git push
export def gpush [
  --upstream(-u): string = "origin"
  --force-with-lease(-f)  # force-with-lease
  --force(-F)           # force
] {
  mut args = []
  if $force_with_lease != null { $args = ($args | append $'--force-with-lease') }
  if $force != null { $args = ($args | append $'--force') }
  git push ...$args --set-upstream $upstream (git rev-parse --abbrev-ref HEAD) 
}
export def gpull [--upstream(-u): string = "origin"] {
  git pull --set-upstream $upstream (git rev-parse --abbrev-ref HEAD) 
}
# git rebase 
export alias grb = git rebase 
# git rebase interactive
export alias grbi = git rebase --interactive
# git rebase abort
export alias grba = git rebase --abort
# git rebase continue
export alias grbc = git rebase --continue


use ~/src/nushell-config/src/git-worktree.nu 'git worktree bare-path'
# git cd to root (bare or worktree)
def --env groot [] {
 if ((git worktree bare-path) == null) { 
   cd (git rev-parse --show-toplevel) 
 } else {
   cd (git worktree bare-path) 
 } 
}
# git cd to root (bare or worktree)
export alias cdroot = groot 
