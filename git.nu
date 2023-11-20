
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

#  View git comitter activity as a histogram
def "git activity" [
  --path: path = .
  --since: string = '1 year ago'  
] {
  git log --since $'"($since)"' --pretty=%h»¦«%aN»¦«%s»¦«%aD  -- $path
  | lines 
  | split column "»¦«" sha1 committer desc merged_at 
  | histogram committer merger 
  | sort-by merger 
  | reverse
}


def "pr diff" [path: path = .] {
  let this_branch = (git rev-parse --abbrev-ref HEAD)
  git diff $this_branch ( git merge-base $this_branch origin/master ) 
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
