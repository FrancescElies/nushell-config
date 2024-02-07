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
def "git repack-repos" [
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
alias grepack = git repack-repos

# Delete git merged branches (loal and remote)
def "git gone" [] {
    git branch -vl  
      | lines  
      | split column " " BranchName Hash Status --collapse-empty 
      | where Status == '[gone]' 
      | each { |it| git branch -D $it.BranchName }
}
alias ggone = git gone

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
alias gactivity = git activity


# https://stackoverflow.com/questions/46704572/git-error-encountered-7-files-that-should-have-been-pointers-but-werent
def "git lfs-fix-everything" [] {
  git lfs migrate import --fixup --everything
}
alias glfsfixeverything = git lfs-fix-everything

# https://stackoverflow.com/questions/46704572/git-error-encountered-7-files-that-should-have-been-pointers-but-werent
# This "migrates" files to git lfs which should be in lfs as per .gitattributes, but aren't at the moment (which is the reason for your error message).
#
# --no-rewrite prevents git from applying this to older commits, it creates a single new commit instead.
#
# Use -m "commitmessage" to set a commitmessage for that commit.
def git-lfs-fix [...paths: path] {
  git lfs migrate import --no-rewrite $paths
}
alias glfsfix = git lfs-fix
