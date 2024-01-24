# edit .gitignore
export def "git ignore-edit" [] {
    nvim $"(git rev-parse --show-toplevel)/.gitignore"
}

export def "git difft" [...rest] {
    with-env [GIT_EXTERNAL_DIFF 'difft'] { git diff ...$rest }
}

alias gd = git difft

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
  | split column "»¦«" sha1 committer desc merged_at 
  | histogram committer merger 
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

