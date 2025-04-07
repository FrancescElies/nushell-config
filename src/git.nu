use utils.nu print_purple
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

# edit .gitignore
export def "gig" [] {
    nvim $"(git rev-parse --show-toplevel)/.gitignore"
}

export def --wrapped "git difft" [...rest] {
    with-env {GIT_EXTERNAL_DIFF: difft} { git diff ...$rest }
}

export def "git branches" [first: int = 5] { git branch --sort=-committerdate | lines | first $first }

# aliases
# -------
# git whatchanged
export alias gwch = git whatchanged -p --abbrev-commit --pretty=medium
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
export def "gcommit" [
  title: string
  body: string = ""
] {
  let current_branch = (git rev-parse --abbrev-ref HEAD)
  print_purple $"current_branch ($current_branch)"
  let tickets = (open ~\.gitconfig-branch-tickets.toml)
  print_purple "~/.gitconfig-branch-tickets.toml 👀"

  mut rest = []
  if $body != "" { $rest = ($rest | append [-m $"($body)"]) }

  try {
    let story = ( $tickets
                | get branches
                | where name == $current_branch
                | get story.0 )
    let task = ( $tickets
               | get branches
               | where name == $current_branch
               | get task.0 )

    if $story != "<Nothing>" { $rest = ($rest | append [-m $"story #($story)"]) }
    if $task != "<Nothing>" { $rest = ($rest | append [-m $"task #($task)"]) }
  }

  git commit --message $title ...$rest
}
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
# git clean into a pristine working directory (-ff removes untracked directories)
export alias gcleanest = git clean -dffx
# Clean (also untracked) and checkout.
def gcleanout [] { git clean -df ; git checkout -- . }
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

# Repack repositories in current folder
# repacker: repack a repo the way Linus recommends.
#
# This command takes a long time to run, perhaps even overnight.
#
# It does the equivalent of "git gc --aggressive"
# but done *properly*,  which is to do something like:
#
#     git repack -a -d --depth=250 --window=250
#
# The depth setting is about how deep the delta chains can be;
# make them longer for old history - it's worth the space overhead.
#
# The window setting is about how big an object window we want
# each delta candidate to scan.
#
# And here, you might well want to add the "-f" flag (which is
# the "drop all old deltas", since you now are actually trying
# to make sure that this one actually finds good candidates.
#
# And then it's going to take forever and a day (ie a "do it overnight"
# thing). But the end result is that everybody downstream from that
# repository will get much better packs, without having to spend any effort
# on it themselves.
#
# http://metalinguist.wordpress.com/2007/12/06/the-woes-of-git-gc-aggressive-and-how-git-deltas-work/
#
# We also add the --window-memory limit of 1 gig, which helps protect
# us from a window that has very large objects such as binary blobs.
#
export def "git repack-repos" [
  path: path = .
  --prune
] {
    ls $path | where type == dir | each { |folder|
        print $"Repacking ($folder.name)"
        cd $folder.name
        if $prune {
          ^git prune --expire=now
          ^git reflog expire --expire-unreachable=now --rewrite --all
        }
        ^git repack -a -d -f --depth=300 --window=300 --window-memory=1g
    }
}
export alias grepack = git repack-repos

# Delete git merged branches (loal and remote)
export def "git gone" [] {
    git branch -vl
      | lines
      | split column " " BranchName Hash Status --collapse-empty
      | where Status == '[gone]'
      | each { |it| git branch -D $it.BranchName }
}
export alias ggone = git gone

#  View git committer activity as a histogram
export def "git activity" [
  path: path = .  # e.g. '*.rs', ./src ...
  --since: string = '1 year ago'
] {
  git log --since $'"($since)"' --pretty=%h»¦«%aN»¦«%s»¦«%aD  -- $path
  | lines
  | split column "»¦«" sha1 committer_name desc merged_at
  | histogram committer_name merger
  | sort-by merger
  | reverse
}
export alias gactivity = git activity


# https://stackoverflow.com/questions/46704572/git-error-encountered-7-files-that-should-have-been-pointers-but-werent
export def "git lfs-fix-everything" [] {
  git lfs migrate import --fixup --everything
}
export alias glfsfixeverything = git lfs-fix-everything

# This "migrates" files to git lfs which should be in lfs as per .gitattributes,
# but aren't at the moment (which is the reason for your error message).
#
# --no-rewrite prevents git from applying this to older commits, it creates a single new commit instead.
#
# Use -m "commitmessage" to set a commitmessage for that commit.
# https://stackoverflow.com/questions/46704572/git-error-encountered-7-files-that-should-have-been-pointers-but-werent
export def "git lfs-fix" [...paths: path] {
  git lfs migrate import --no-rewrite ...$paths
}
export alias glfsfix = git lfs-fix
