
# Pull requests

def "pr create" [
  --target-branch (-t): string = 'master'  
] {
  git push
  az repos pr create --draft --open --auto-complete -t $target_branch -o table
}

def "commit" [ 
  title: string 
  body: string = ""
] {
 let branch = (git rev-parse --abbrev-ref HEAD)
 let story = ($branch | parse -r '[Ss]tory(?<story>\d+)' | get story.0 )
 git commit --message $"($title)" --message $"($body)" --message $"story #($story)"
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
