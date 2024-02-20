# https://www.youtube.com/watch?v=aolI_Rz0ZqY
# Apply some useful defaults
# git my-defaults
#
# Give me all my pull requests as local refs
# git config remote.origin.fetch '+refs/pull/*:refs/remotes/origin/pull/*'
# Conditional ~/.gitconfig
#
# [includelf "gitdir:~/projects/work/"]
#   path = ~/src/work/.gitconfig
# [includelf "gitdir:~/src/oss/"]
#   path = ~/projects/oss/.gitconfig
#
# git maintenance start

use git-worktree.nu *
use git-pr.nu *
use git-misc.nu *

# apply my defaults
export def "git my-defaults" [] {
  # REuse REordered REsolution, tells git to remember conflicts so if it sees them again he won't ask about it.
  git config --global rerere.enabted true
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
  git config core.untrackedcache true
  git config core.fsmonitor true
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

export def "git difft" [...rest] {
    with-env [GIT_EXTERNAL_DIFF 'difft'] { git diff ...$rest }
}

export def "git branches" [first: int = 5] { git branch --sort=-committerdate | lines | first $first }

# aliases
# -------
export alias gbb = git branches
# open git ui
export alias gui = lazygit
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
export alias gl = git log --graph --pretty=format:'%C(auto)%h -%d %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
export alias gl5 = gl -n5
export alias gl10 = gl -n10
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


# git cd to root (bare or worktree)
export alias groot = if ((git worktree bare-path) == null) { cd (git rev-parse --show-toplevel) } else { cd (git worktree bare-path) }
# git cd to root (bare or worktree)
export alias cdroot = groot 
