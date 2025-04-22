export def "az pr new" [ --target-branch (-t): string = 'master' ] {
  git push
  az repos pr create --draft --open --auto-complete -t $target_branch -o table
}

export def "az pr status" [
  pr_id: number@"nu-complete pr-id"
  --pending(-p)  # list only not yet approved policies
] {
  let status = (
    az repos pr policy list --id $pr_id -ojson | from json
    | filter {$in.configuration.isBlocking and $in.configuration.isEnabled}
    | select status configuration.settings.displayName? configuration.type.displayName evaluationId
    | rename status title type id
    | sort-by status
  )
  if $pending { $status | where status != approved } else { $status }
}

# Get azure devops machines having a certain capability
export def "az list machines-usercapabilities" [
  has_capability: string = 'Python311',
  --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
  (  az pipelines agent list
     --pool-id 1 --include-capabilities -o $output
     --query $"[?userCapabilities.($has_capability)!=null].{capabilities: userCapabilities, name: name}"
  )
}

# Get azure devops machines
export def "az list machines" [
  --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
  (  az pipelines agent list
     --pool-id 1 --include-capabilities -o $output
     --query "[*]"
  )
}

export def "az queue build" [ definition_id: int = 42 ] {
  az pipelines build queue --open --branch (git rev-parse --abbrev-ref HEAD) --definition-id $definition_id
}

export def "az download artifact" [
  build_id: int
] {
  az pipelines runs artifact download --artifact-name Installer --path ~/Downloads --run-id $build_id
}

# NOTE: https://learn.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax?view=azure-devops#where-clause

def "board query" [wiql: string] {
    let table = az boards query --output table --wiql $wiql -o json
    if ($table | is-empty) {
      print $"(ansi pb)Table empty(ansi reset)"
      return
    }
    $table
    | from json
    | select fields | flatten
    | rename --column {System.State: state, System.Id: id, System.IterationPath: iteration_path, System.Title: title}
    | sort-by state title

}

export def "az list my stories" [] {
  let wiql = [ "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems"
               "WHERE [system.assignedto] = @me AND [System.WorkItemType] <> 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete')"
               "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" ] | str join ' '
    board query $wiql
}

export def "az list my tasks" [] {
  let wiql = [ "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems"
               "WHERE [system.assignedto] = @me AND [System.WorkItemType] = 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete')"
               " ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" ] | str join ' '
    board query $wiql
  }

export def "az list assigned-to-me" [] {
  let wiql = [ "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems"
               "WHERE [system.assignedto] = @me AND [system.state] NOT IN ('Closed', 'Obsolete')"
               "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC"] | str join " "
  board query $wiql
}

export def "az list created-by-me" [] {
  let cols = "[System.Id], [System.WorkItemType], [System.Title], [System.State], [System.AreaPath], [System.IterationPath]"
  let wiql = [ $"SELECT ($cols) FROM workitems"
               "WHERE [System.CreatedBy] = @me AND [system.state]  NOT IN ('Closed', 'Obsolete')"
               "ORDER BY [System.ChangedDate] DESC" ] | str join ' '
  board query $wiql
}

export def "az list following" [] {
  let cols = "[System.Id], [System.WorkItemType], [System.Title], [System.State], [System.AreaPath], [System.IterationPath]"
  let wiql = [ $"SELECT ($cols) FROM workitems"
               "WHERE [System.ID] IN (@Follows) AND [system.state]  NOT IN ('Closed', 'Obsolete')"
               "ORDER BY [System.ChangedDate] DESC" ] | str join ' '
  board query $wiql
}

# list my pull requests
export def "az list my prs" [--draft] {
  let my_query = "[].{title: title, createdby: createdBy.displayName, status: status, repo: repository.name, id: pullRequestId, draft: isDraft }"
  let prs = az repos pr list -ojson --query $my_query | from json | where createdby =~ "Francesc" | select id status title draft
  let prs = if $draft { $prs | where draft } else { $prs | where not draft }
  $prs | insert ci-status {
      az pr status $in.id
      | select status title type | sort-by type status
      | update cells -c [status] { $in | str replace approved ✅| str replace running 👟| str replace queued ⏳| str replace rejected ❌ }
  }
}

def "nu-complete pr-id" [] { (az list my prs) | rename -c {id: value,  title: description} }

# trigger ci for PR
export def "az trigger pr-ci" [ pr_id: number@"nu-complete pr-id" ] {
  ( az repos pr policy list --id $pr_id -ojson | from json
  | filter {$in.configuration.isBlocking and $in.configuration.isEnabled}
  | select evaluationId configuration.type.displayName configuration.settings.displayName?
  | rename id type title
  | where type == Build
  | get id
  | par-each --threads 8 {(
        az repos pr policy queue --id $pr_id -e $in -ojson | from json
        | select status configuration.settings.displayName? configuration.type.displayName evaluationId
        | rename status title type id
        | update cells -c [status] { $in | str replace approved ✅| str replace running 👟| str replace queued ⏳| str replace rejected ❌ }
    )}
  )

}
