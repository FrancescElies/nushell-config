export module "my config" {
    export def "edit weztern" [] { nvim ~/src/wezterm-config/wezterm.lua }

    export def "edit nvim" [] { nvim ~/src/kickstart.nvim/init.lua }

    export def "edit espanso" [] {
        if $nu.os-info.name == "windows" {
            nvim $"($env.APPDATA)/espanso/default.yml"
        } else {
            error make {msg: "espanso config missing?"}
        }
    }

    export def "edit broot" [] {
        if $nu.os-info.name == "windows" {
            nvim $"($env.APPDATA)/dystroy/broot/config/conf.hjson" $"($env.APPDATA)/dystroy/broot/config/verbs.hjson"
        } else {
            nvim "~/.config/broot/config/conf.hjson" "~/.config/broot/config/verbs.hjson"
        }
    }

    const config_repos = [~/src/nushell-config ~/src/kickstart.nvim ~/src/wezterm-config]

    # backup by-year
    export def "my backup by-year" [serverip: string = "intel-pc"] {
        restic --repo sftp:($serverip):by-year.restic backup ~/by-year
    }

    export def "my config status-all" [] {
        $config_repos | each {
            cd $in
            print $"(ansi pb)($in)(ansi reset)"
            ^git status
        }
    }

    export def "my config push-all" [] {
        $config_repos | each {
            cd $in
            print $"(ansi pb)($in)(ansi reset)"
            ^git push --force-with-lease
        }
    }

    export def "my config pull-all" [] {
        $config_repos | each {
            cd $in
            print $"(ansi pb)($in)(ansi reset)"
            ^git stash
            ^git pull
            ^git stash pop | complete
        }
    }

}
