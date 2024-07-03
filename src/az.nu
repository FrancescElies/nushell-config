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

# list my open stories
export def "az my-stories" [] {
  (az boards query --output table --wiql "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] = @me AND [System.WorkItemType] <> 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" -o json
  | from json
  | select fields | flatten
  )
}

# list my open tasks
export def "az my-tasks" [] {
  (az boards query --output table --wiql "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] = @me AND [System.WorkItemType] = 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" -o json
  | from json
  | select fields | flatten
  )
}

# list open items
export def "az my-items" [] {
  (az boards query --output table --wiql "SELECT [System.Id], [System.Title], [System.State], [System.IterationPath] FROM workitems WHERE [system.assignedto] = @me AND [system.state] NOT IN ('Closed', 'Obsolete') ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" -o json
  | from json
  | select fields | flatten
  )
}

# list my pull requests
export def "az my-prs" [] {
  az repos pr list -ojson --query "[].{title: title,createdby: createdBy.displayName, status: status, repo: repository.name, id: pullRequestId}" | from json | where createdby =~ "Francesc" | select id status title
}
