# Machines
# Get azure devops machines having a certain capability
export def "az machines-usercapabilities" [
  has_capability: string = 'Python311',
  --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
  (  az pipelines agent list
     --pool-id 1 --include-capabilities -o $output
     --query $"[?userCapabilities.($has_capability)!=null].{capabilities: userCapabilities, name: name}"
  )
}

# Get azure devops machines
export def "az machines" [
  --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
  (  az pipelines agent list
     --pool-id 1 --include-capabilities -o $output
     --query "[*]"
  )
}

export def "build queue" [ definition_id: int = 42 ] {
  az pipelines build queue --open --branch (git rev-parse --abbrev-ref HEAD) --definition-id $definition_id
}


export def "build download" [
  build_id: int
] {
  az pipelines runs artifact download --artifact-name Installer --path ~/Downloads --run-id $build_id
}

# NOTE: https://learn.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax?view=azure-devops#where-clause

# az boards query --output table --wiql "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] contains 'cesc' AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" -o json | from json | get fields
# list my open stories
export def "az my-stories" [] {
  let wiql = "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] = @me AND [System.WorkItemType] <> 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC"
  (az boards query --output table --wiql $wiql -o json
  | from json
  | select fields | flatten
  | rename --column {System.State: state, System.Id: id, System.IterationPath: iteration_path, System.Title: title}
  | sort-by state
  )
}

# list my open tasks
export def "az my-tasks" [] {
  let wiql = "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] = @me AND [System.WorkItemType] = 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC"
  (az boards query --output table --wiql $wiql -o json
  | from json
  | select fields | flatten
  | rename --column {System.State: state, System.Id: id, System.IterationPath: iteration_path, System.Title: title}
  | sort-by state
  )
}

# list open items
export def "az assigned-to-me" [] {
  let wiql = "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] = @me AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC"
  az boards query --output table --wiql $wiql -o json
  | from json
  | select fields | flatten
  | rename --column {System.State: state, System.Id: id, System.IterationPath: iteration_path, System.Title: title}
  | sort-by state
}

export def "az created-by-me" [] {
  let wiql = " SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State], [System.AreaPath], [System.IterationPath] FROM workitems WHERE [System.CreatedBy] = @me ORDER BY [System.ChangedDate] DESC"
  # let wiql = "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.CreatedBy] = @me AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [System.ChangedDate] DESC"
  az boards query --output table --wiql $wiql -o json | from json | select fields | flatten
  | rename --column {System.State: state, System.Id: id, System.IterationPath: iteration_path, System.Title: title}
  | sort-by state
}

# list my pull requests
export def "az my-prs" [] {
  let my_query = "[].{title: title,createdby: createdBy.displayName, status: status, repo: repository.name, id: pullRequestId}"
  az repos pr list -ojson --query $my_query | from json | where createdby =~ "Francesc" | select id status title
}
