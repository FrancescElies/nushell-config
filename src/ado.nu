# Necessary environment variables
# $env.ADO_ORGANIZATION = ''  # (1) go to https://dev.azure.com and copy the name of your organization from the left side bar.
# $env.ADO_PROJECT = ''       # (2) inside that organization copy the project name
# $env.ADO_TOKEN = ''         # (3) go to https://dev.azure.com/ADO_ORGANIZATION/_usersSettings/tokens and create a new token
# $env.ADO_TEAM = ''          # (4) `az devops team list -ojson | from json | select name id description | explore` to see teams and copy desired uuid
# $env.ADO_REPO = ''          # (4) `az repos list | from json | select name id` to see repos and copy desired uuid


def "nu-complete my-tasks" [] {
    (ado list my tasks)
    | rename -c {id: value,  title: description} | select value description
}

def "nu-complete my-stories" [] {
    (ado list my stories)
    | rename -c {id: value,  title: description} | select value description
}


const dbfile = ('~/.git-ado.json' | path expand )

export def read_git_ado_db [] {
    if ($dbfile | path exists) {
        open $dbfile
    } else {
        []
    }
}
export def write_git_ado_db [db] {
    $db | to json | save -f $dbfile
}

# git worktree add - convenience wrapper
export def "ado worktree add" [
    branch: string # branch to create or checkout, e.g. cesc/1234-my-description
    path: path # checkout location
    --startingat(-@): string = ""  # create a new branch starting at <commit-ish> e.g. master,
    # custom stuff
    --story(-s): int@"nu-complete my-stories"  # story number
    --task(-t): int@"nu-complete my-tasks"   # task number
] {
    let branch_name = if ($branch | is-empty) { (git rev-parse --abbrev-ref HEAD) } else { $branch }

    let db = read_git_ado_db

    mut data = {
        name: $branch_name
        story: (if $story == null { 0 } else { $story })
        task: (if $task == null { 0 } else { $task })
        pr: 0
    }


    let repo_name = pwd | path basename | str replace ".git" ""
    # make sure path has no slashes coming from branch name
    # let branch_folder = $branch | str replace -a -r `[\\/]` "-"
    # let path = (".." | path join $"($repo_name)-($branch_folder)")

    git fetch --all
    if $startingat == "" {
        print_purple $"git worktree add -B ($branch) ($path)"
        git worktree add -B $branch $path
    } else {
        print_purple $"git worktree add -B ($branch) ($path) ($startingat)"
        git worktree add -B $branch $path $startingat
    }

    write_git_ado_db ($db | append $data)
    cd $path
    let pr = ado pr new --draft
    $data.pr = $pr.id
    write_git_ado_db ($db | append $data)
}

export def "ado commit" [
    title: string
    body: string = ""
] {

    let current_branch = (git rev-parse --abbrev-ref HEAD)
    let db = read_git_ado_db

    mut rest = []
    if $body != "" { $rest = ($rest | append [-m $"($body)"]) }

    let story = ( $db | where name == $current_branch | get story.0 )
    if $story != 0 { $rest = ($rest | append [-m $"story #($story)"]) }

    let task = ( $db | where name == $current_branch | get task.0 )
    if $task != 0 { $rest = ($rest | append [-m $"task #($task)"]) }

    let pr = ( $db | where name == $current_branch | get pr.0 )
    let title = $"($title) \(PR ($pr)\)"

    git commit --message $title ...$rest
}


export def "ado pr new" [ --target-branch (-t): string = 'master' --draft] {
    git push
    let description = ($nu.temp-path | path join $"az-pr-(random chars).md")
    let title = ( git log --format=%B -n 1 HEAD ) | lines | first
    [ "**Problem:** " "" "**Solution:** " "" "**Notes:** " ] | to text | save -f $description

    nvim $description

    let db = read_git_ado_db
    let current_branch = (git rev-parse --abbrev-ref HEAD)
    let work_items = ([
        ( $db | where name == $current_branch | get story.0 )
        ( $db | where name == $current_branch | get task.0 )
    ] | filter { $in != 0})

    mut args = []
    if $draft { $args = ($args | append '--draft') }
    ( ^az repos pr create --open --delete-source-branch
        --description ...($description | open | lines)
        --auto-complete -t $target_branch
        --work-items ...($work_items)
        --title $title
        ...$args
        -o json
    )
    | from json
    | select pullRequestId title mergeStatus
    | rename id            title mergeStatus
}

export def "ado pr status" [
    pr_id: number@"nu-complete pr-id"
    --pending(-p)  # list only not yet approved policies
    --with-policy-id
] {
    let status = (
        az repos pr policy list --id $pr_id -ojson | from json
        | filter {$in.configuration.isBlocking and $in.configuration.isEnabled}
        | select status context.isExpired? configuration.settings.displayName? configuration.type.displayName evaluationId
        | rename status expired            title                               type                           policy-id
        | sort-by status expired
    )
    let status = if $with_policy_id { $status } else { $status | reject policy-id }
    if $pending { $status | where status != approved } else { $status }
}

# Get azure devops machines having a certain capability
export def "ado list machines-usercapabilities" [
    has_capability: string = 'Python311',
    --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
    (  az pipelines agent list
        --pool-id 1 --include-capabilities -o $output
        --query $"[?userCapabilities.($has_capability)!=null].{capabilities: userCapabilities, name: name}"
    )
}

# Get azure devops machines
export def "ado list machines" [
    --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
    (  az pipelines agent list
        --pool-id 1 --include-capabilities -o $output
        --query "[*]"
    )
}

export def "ado queue build" [ definition_id: int = 42 ] {
    az pipelines build queue --open --branch (git rev-parse --abbrev-ref HEAD) --definition-id $definition_id
}

export def "ado download artifact" [
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
    | rename --column {System.State: state, System.Id: id, System.WorkItemType: type, System.IterationPath: iteration_path, System.Title: title}
    | sort-by state title
    | move id --first
    | move state --after id
    | move type --after state
    | move title --after type

}

export def "ado list my stories" [] {
    let wiql = [ "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State], [System.IterationPath] FROM workitems"
        "WHERE [system.assignedto] = @me AND [System.WorkItemType] <> 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete')"
        "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" ] | str join ' '
    board query $wiql
}

export def "ado list my tasks" [] {
    let wiql = [ "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State], [System.IterationPath] FROM workitems"
        "WHERE [system.assignedto] = @me AND [System.WorkItemType] = 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete')"
        " ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC" ] | str join ' '
    board query $wiql
}

export def "ado list assigned-to-me" [] {
    let wiql = [ "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State], [System.IterationPath] FROM workitems"
        "WHERE [system.assignedto] = @me AND [system.state] NOT IN ('Closed', 'Obsolete')"
        "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] DESC"] | str join " "
    board query $wiql
}

export def "ado list created-by-me" [] {
    let cols = "[System.Id], [System.WorkItemType], [System.Title], [System.State], [System.AreaPath], [System.IterationPath]"
    let wiql = [ $"SELECT ($cols) FROM workitems"
        "WHERE [System.CreatedBy] = @me AND [system.state]  NOT IN ('Closed', 'Obsolete')"
        "ORDER BY [System.ChangedDate] DESC" ] | str join ' '
    board query $wiql
}

export def "ado list following" [] {
    let cols = "[System.Id], [System.WorkItemType], [System.Title], [System.State], [System.AreaPath], [System.IterationPath]"
    let wiql = [ $"SELECT ($cols) FROM workitems"
        "WHERE [System.ID] IN (@Follows) AND [system.state]  NOT IN ('Closed', 'Obsolete')"
        "ORDER BY [System.ChangedDate] DESC" ] | str join ' '
    board query $wiql
}

# list my pull requests
export def "ado list my prs" [--draft] {
let my_query = "[].{title: title, createdby: createdBy.displayName, status: status, repo: repository.name, id: pullRequestId, draft: isDraft }"
let prs = az repos pr list -ojson --query $my_query | from json | where createdby =~ "Francesc" | select id status title draft
let prs = if $draft { $prs | where draft } else { $prs | where not draft }
    $prs | insert ci-status {
        ado pr status $in.id
        | select status title type | sort-by type status
        | update cells -c [status] { $in | str replace approved ✅| str replace running 👟| str replace queued ⏳| str replace rejected ❌ }
    }
}

def "nu-complete pr-id" [] { (ado list my prs) | rename -c {id: value,  title: description} }

export def "ado pr rejected-or-expired-policies" [ pr_id: number@"nu-complete pr-id" ] {
    ( az repos pr policy list --id $pr_id -ojson | from json
        | filter {$in.configuration.isBlocking and $in.configuration.isEnabled}
        | select evaluationId configuration.type.displayName configuration.settings.displayName? status context.isExpired? context.buildId?
        | rename id           type                           title                               status expired            build-id
        | where type == Build
        | where status == rejected or expired == true
    )
}

# trigger ci for PR
export def "ado pr ci re-queue" [ pr_id: number@"nu-complete pr-id" ] {
    ( ado pr rejected-or-expired-policies $pr_id | par-each {
        print $"(ansi pb)\tRe-queueing: ($in.title), previous build ($in.build-id) status=($in.status) expired=($in.expired)(ansi reset)"
        ( az repos pr policy queue --id $pr_id -e $in.id -ojson | from json
            | select status configuration.settings.displayName? configuration.type.displayName evaluationId
            | rename status title                               type                           id)
    })
}

export def "ado pr ci watch" [ pr_id: number@"nu-complete pr-id" ] {
    let pr = (az repos pr show --id  $pr_id | from json )
    let pr_title = $"PR ($pr_id) - ($pr | get title)"
    print $"(ansi pb)Watching(ansi reset) ($pr_title)"
    loop {
        if (((az repos pr show --id  $pr_id | from json ) | get status) == completed) {
            return $"($pr_title) (ansi lgi)completed(ansi reset)"
        }
        let result = ado pr ci re-queue $pr_id
        if (not ($result | is-empty)) { print $result }
        sleep 10sec
    }
}

# NOTE: https://github.com/Azure/azure-cli/issues/27531#issuecomment-2830207020
export def "ado pr show-beta" [ pr_id: number@"nu-complete pr-id" ] {
    ( az devops invoke
    --organization $"https://dev.azure.com/($env.ADO_ORGANIZATION)/"
    --area git
    --resource pullRequestCommits
    --route-parameters $"project=($env.ADO_PROJECT) repositoryId=($env.ADO_REPO) pullRequestId=($pr_id)"
    --http-method GET
    --output json )
}

def "nu-complete my-workitems" [] {
    [ | | { ado list my stories }
      | | { ado list my tasks }
      | | { ado list assigned-to-me }
      | | { ado list created-by-me }
      | | { ado list following } ]
    | par-each { do $in }
    | flatten
    | rename -c {id: value,  title: description} | select value description
}

export def "open workitems" [ ...workitems: int@"nu-complete my-workitems" ] {
    if ($in | is-empty) {
        $workitems | each {start $"https://($env.ADO_ORGANIZATION).visualstudio.com/($env.ADO_PROJECT)/_workitems/edit/($in)" }
    } else {
        $in | get id | each { start $"https://($env.ADO_ORGANIZATION).visualstudio.com/($env.ADO_PROJECT)/_workitems/edit/($in)" }
    }
}
