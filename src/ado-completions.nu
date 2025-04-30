# Necessary environment variables
# $env.ADO_ORGANIZATION = ''  # (1) go to https://dev.azure.com and copy the name of your organization from the left side bar.
# $env.ADO_PROJECT = ''       # (2) inside that organization copy the project name
# $env.ADO_TOKEN = ''         # (3) go to https://dev.azure.com/ADO_ORGANIZATION/_usersSettings/tokens and create a new token
# $env.ADO_TEAM = ''          # (4) `az devops team list -ojson | from json | select name id description | explore` to see teams and copy desired uuid
# $env.ADO_REPO = ''          # (4) `az repos list | from json | select name id` to see repos and copy desired uuid

use git-completions.nu "nu-complete git checkout"
use git-my-alias.nu "nu-complete semmantic-message"

export module ado {

    def "nu-complete my-tasks" [] {
        (list my tasks)
        | rename -c {id: value,  title: description} | select value description
    }

    def "nu-complete my-stories" [] {
        (list my stories)
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
    export def "worktree add" [
        branch: string # branch to create or checkout, e.g. cesc/1234-my-description
        path: path # checkout location
        --startingat(-@): string@"nu-complete git checkout"  # create a new branch starting at <commit-ish> e.g. master,
        # custom stuff
        --story(-s): int@"nu-complete my-stories"  # story number
        --task(-t): int@"nu-complete my-tasks"   # task number
        --no-pr # don't create pr
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
        if ($startingat | is-empty) {
            print_purple $"git worktree add -B ($branch) ($path)"
            git worktree add -B $branch $path
        } else {
            print_purple $"git worktree add -B ($branch) ($path) ($startingat)"
            git worktree add -B $branch $path $startingat
        }

        write_git_ado_db ($db | append $data)
        if not $no_pr {
            cd $path
            let title = $branch
            let pr = pr new $"🏗️: ($title)" --draft
            $data.pr = $pr.id
            write_git_ado_db ($db | append $data)
        }
    }

    export def --wrapped "commit" [
        type: string@"nu-complete semmantic-message"
        title: string
        --scope: string  # contextual information
        --breaking-changes(-b)
        ...rest
    ] {

    let scope = if ($scope | is-empty) { "" } else { $"\(($scope)\)" }
        let breaking_change = if $breaking_changes { "!" } else { "" }
        let current_branch = (git rev-parse --abbrev-ref HEAD)
        let db = read_git_ado_db

        mut links = []
        let story = ( $db | where name == $current_branch | get story.0 )
        let task = ( $db | where name == $current_branch | get task.0 )
        if $story != 0 { $links = ($links | append [-m $"story #($story)"]) }
        if $task != 0 { $links = ($links | append [-m $"task #($task)"]) }

        let pr = ( $db | where name == $current_branch | get pr.0 )
        let title = $"($type):($title) \(PR ($pr)\)"

        ^git commit -m $"($type)($scope)($breaking_change): ($title)" ...$links ...$rest
    }


    export def "pr new" [
        title?: string
        --target-branch (-t): string = 'master'
        --draft
    ] {
        git push
        let description = ($nu.temp-path | path join $"az-pr-(random chars).md")
        let title = if ($title | is-empty) { ( git log --format=%B -n 1 HEAD ) | lines | first } else { $title }
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

    export def "pr status" [
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
    export def "list machines-usercapabilities" [ has_capability: string = 'Python311' ] {
        (  az pipelines agent list
            --pool-id 1 --include-capabilities -o json
            --query $"[?userCapabilities.($has_capability)!=null].{capabilities: userCapabilities, name: name}"
        ) | from json
    }

    # Get azure devops machines
    export def "list machines" [ ] {
        (  az pipelines agent list
            --pool-id 1 --include-capabilities -o json
            --query "[*]"
        ) | from json
    }

    export def "queue build" [ definition_id: int = 42 ] {
        az pipelines build queue --open --branch (git rev-parse --abbrev-ref HEAD) --definition-id $definition_id
    }

    export def "download artifact" [ build_id: int ] {
        az pipelines runs artifact download --artifact-name Installer --path ~/Downloads --run-id $build_id
    }

    export alias "filter-active-workitem" = filter { $in not-in ['Closed' 'Obsolete' Review 'Info Needed' Implemented] }

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
        | rename --column { System.State: state,
                            System.Id: id,
                            System.WorkItemType: type,
                            System.IterationPath: iteration_path,
                            System.Title: title
                            System.ChangedDate: canged_date
                            System.CreatedDate: created_date }
        | sort-by state created_date title
        | move id --first
        | move state --after id
        | move type --after state
        | move title --after type

    }

    const select_from_workitems = "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State], [System.IterationPath], [System.CreatedDate], [system.ChangedDate] FROM workitems"

    export def "list bugs" [] {
        let wiql = [ $select_from_workitems
            "WHERE [System.WorkItemType] = 'Bug' AND [system.state] NOT IN ('Closed', 'Obsolete')"
            "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] ASC" ] | str join ' '
        board query $wiql
    }

    export def "list my stories" [] {
        let wiql = [ $select_from_workitems
            "WHERE [system.assignedto] = @me AND [System.WorkItemType] <> 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete')"
            "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] ASC" ] | str join ' '
        board query $wiql
    }

    export def "list my tasks" [] {
        let wiql = [ $select_from_workitems
            "WHERE [system.assignedto] = @me AND [System.WorkItemType] = 'Task' AND [system.state] NOT IN ('Closed', 'Obsolete')"
            " ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] ASC" ] | str join ' '
        board query $wiql
    }

    export def "list assigned-to-me" [] {
        let wiql = [ $select_from_workitems
            "WHERE [system.assignedto] = @me AND [system.state] NOT IN ('Closed', 'Obsolete')"
            "ORDER BY [Microsoft.VSTS.Common.Priority], [System.ChangedDate] ASC"] | str join " "
        board query $wiql
    }

    export def "list created-by-me" [] {
        let wiql = [ $select_from_workitems
            "WHERE [System.CreatedBy] = @me AND [system.state]  NOT IN ('Closed', 'Obsolete')"
            "ORDER BY [System.ChangedDate] ASC" ] | str join ' '
        board query $wiql
    }

    export def "list following" [] {
        let wiql = [ $select_from_workitems
            "WHERE [System.ID] IN (@Follows) AND [system.state]  NOT IN ('Closed', 'Obsolete')"
            "ORDER BY [System.ChangedDate] ASC" ] | str join ' '
        board query $wiql
    }

    # list my pull requests
    export def "list my prs" [--draft] {
    let my_query = "[].{title: title, createdby: createdBy.displayName, status: status, repo: repository.name, id: pullRequestId, draft: isDraft }"
    let prs = az repos pr list -ojson --query $my_query | from json | where createdby =~ "Francesc" | select id status title draft
    let prs = if $draft { $prs | where draft } else { $prs | where not draft }
        $prs | insert ci-status {
            pr status $in.id
            | select status title type | sort-by type status
            | update cells -c [status] { $in | str replace approved ✅| str replace running 👟| str replace queued ⏳| str replace rejected ❌ }
        }
    }

    def "nu-complete pr-id" [] { (list my prs) | rename -c {id: value,  title: description} }

    export def "pr rejected-or-expired-policies" [ pr_id: number@"nu-complete pr-id" ] {
        ( az repos pr policy list --id $pr_id -ojson | from json
            | filter {$in.configuration.isBlocking and $in.configuration.isEnabled}
            | select evaluationId configuration.type.displayName configuration.settings.displayName? status context.isExpired? context.buildId?
            | rename id           type                           title                               status expired            build-id
            | where type == Build
            | where status == rejected or expired == true
        )
    }

    # trigger ci for PR
    export def "pr ci re-queue" [ pr_id: number@"nu-complete pr-id" ] {
        ( pr rejected-or-expired-policies $pr_id | par-each {
            print $"(ansi pb)\tRe-queueing: ($in.title), previous build ($in.build-id) status=($in.status) expired=($in.expired)(ansi reset)"
            ( az repos pr policy queue --id $pr_id -e $in.id -ojson | from json
                | select status configuration.settings.displayName? configuration.type.displayName evaluationId
                | rename status title                               type                           id)
        })
    }

    export def "pr ci watch" [ pr_id: number@"nu-complete pr-id" ] {
        let pr = (az repos pr show --id  $pr_id | from json )
        let pr_title = $"PR ($pr_id) - ($pr | get title)"
        print $"(ansi pb)Watching(ansi reset) ($pr_title)"
        loop {
            if (((az repos pr show --id  $pr_id | from json ) | get status) == completed) {
                return $"($pr_title) (ansi lgi)completed(ansi reset)"
            }
            let result = pr ci re-queue $pr_id
            if (not ($result | is-empty)) { print $result }
            sleep 10sec
        }
    }

    # NOTE: https://github.com/Azure/azure-cli/issues/27531#issuecomment-2830207020
    export def "pr show-beta" [ pr_id: number@"nu-complete pr-id" ] {
        ( az devops invoke
            --organization $"https://dev.azure.com/($env.ADO_ORGANIZATION)/"
            --area git
            --resource pullRequestCommits
            --route-parameters $"project=($env.ADO_PROJECT) repositoryId=($env.ADO_REPO) pullRequestId=($pr_id)"
            --http-method GET
            --output json )
    }

    def "nu-complete my-workitems" [] {
        [ | | { list my stories }
          | | { list my tasks }
          | | { list assigned-to-me }
          | | { list created-by-me }
          | | { list following } ]
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
}
