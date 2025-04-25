
# Pull requests

export def "pr diff" [path: path = .] {
  let this_branch = (git rev-parse --abbrev-ref HEAD)
  git diff $this_branch ( git merge-base $this_branch origin/master )
}

# opens files modified by pr in nvim
export def "pr files" [
  path: path = .
  --extension: string = ""  # ts, py, rs ... (no dot), default matches everything
  --target-branch: string = "origin/master"  # pr's target branch (normally main, master, ...)
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
export def "pr review-maxpats" [
  --target-branch: string = "origin/master"  # pr's target branch (normally main, master, ...)
  --dry-run
] {
  print $"target branch: ($target_branch)"
  let prfiles = (pr files --extension maxpat --target-branch $target_branch)
  if $dry_run {
     print $prfiles
     return
  }
  let open_files = $prfiles | each { |x| (
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
  print "untracked maxpats:"
  print $untracked_maxpats

  if (input "remove untracked maxpat files (y/n)?") == "y" {
    $untracked_maxpats | each { || rm $in }
  }
  print "Once done cleanup: rm tmp_*maxpat"

}
