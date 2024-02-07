source git-worktree.nu
source git-pr.nu
source git-misc.nu

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


# aliases
# -------

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
alias gcm = git commit
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
alias gpush = git push 
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


# git cd to root (bare or worktree)
alias groot = if ((git worktree bare-path) == null) { cd (git rev-parse --show-toplevel) } else { cd (git worktree bare-path) }
# git cd to root (bare or worktree)
alias cdroot = groot 
