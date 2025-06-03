use broot-helpers.nu *
use my-functions.nu *
use reverse-eng.nu *
use utils.nu *


const maxmsp = if $nu.os-info.name == "windows" {
    "C:/Program Files/Cycling '74/Max 9/Max.exe"
} else if $nu.os-info.name == "macos" {
    "/Applications/Max.app/Contents/MacOS/Max"
} else {
    "not implemented"
}

def "nu-complete maxpats" [] { {
    options: { completion_algorithm: fuzzy, case_sensitive: false, positional: false, sort: true, },
    completions: ( ls **/*.max* | get name)
} }
# Cycling '74 Max cli wrap
export def "Max start" [maxpat?: path@"nu-complete maxpats"] {
    Max preferences set no-crashrecovery
    Max preferences set node-logging
    Max preferences set logtosystemconsole
    if ($maxpat | is-empty) {
        run-external $maxmsp
    } else {
        run-external $maxmsp ($maxpat | path expand)
    }
}

def "nu-complete my-maxpats" [] { {
    options: { completion_algorithm: fuzzy, case_sensitive: false, positional: false, sort: true, },
    completions: ( ls ~/src/work/my-maxpats/**/*proj*maxpat | get name)
} }
# Cycling '74 Max cli wrap
export def "Max start my" [maxpat: path@"nu-complete my-maxpats"] {
    cd ~/src/work/my-maxpats
    Max preferences set no-crashrecovery
    Max preferences set node-logging
    Max preferences set logtosystemconsole
    run-external $maxmsp ( $maxpat | path expand )
}

# broot Max stuff
export alias braxpat = br --cmd ".maxpat&t/"
export alias broject = br --cmd "project&t/"
export alias brataset = br --cmd ".xml&t/"


# sets Max Audio Status
export def "Max set audio-status" [] {
    let path = ("~/AppData/Roaming/Cycling '74/Max 9/Settings/admme@.txt" | path expand)
    print "Before"
    bat --paging never $path

    let contents = [
        'max v2;'
        'dsp prefsr 44100;'
        'dsp prefiovs 512;'
        'dsp prefsigvs 256;'
        'dsp takeover 0;'
        'dsp cpulimit 0;'
        'dsp optimize 1;'
        '#AD version 20030520;'
        '#AD mmeinputdevicepref "Microphone Array (Realtek(R) Au";'
        '#AD mmeoutputdevicepref "Lautsprecher (Realtek(R) Audio)";'
        '#AD threadpriority 3;'
        '#AD mme_latency 7;'
    ]
    $contents | to text | save -f $path
    print "Now"
    bat --paging never $path
}

const maxpreferences = ("~/AppData/Roaming/Cycling '74/Max 9/Settings/maxpreferences.maxpref" | path expand)

# opens maxpreferences.maxpref
export def "Max preferences" [] {
    cd "~/AppData/Roaming/Cycling '74/Max 9/Settings"
    nvim $maxpreferences
}

# opens maxinterface.json
export def "Max interface" [] { nvim "C:/Program Files/Cycling '74/Max 9/resources/interfaces/maxinterface.json" }

# br AppData Cycling '74
export def --env "Max br" [] { cd "~/AppData/Roaming/Cycling '74"; br }

# opens Max settings
export def --env "Max br settings" [] { cd "~/AppData/Roaming/Cycling '74/Max 9/Settings"; br }

# goes to Cycling '74/Logs, where .dmp files are
export def --env "Max br logs-and-dumps" [] { cd "~/AppData/Roaming/Cycling '74/Logs"; br }

# opens Max 9 Packages folder
export def --env "Max br packages" [] { cd "~/Documents/Max 9/Packages"; br }


# show Max examples
export def --env "Max br examples" [] { cd "~/src/oss/max-sdk/source"; br }

# opens Max's api
export def "Max br api" [] {
    if not ("~/src/oss/max-sdk/source/max-sdk-base" | path exists) {
        mkdir ~/src/oss
        cd ~/src/oss
        git clone https://github.com/Cycling74/max-sdk
    }
    cd "~/src/oss/max-sdk/source/max-sdk-base/c74support/max-includes"
    br
}


# opens latest .dmp file from Cycling '74/Logs
export def "Max latest-dump" [] {
    let latest_dump = (ls "~/AppData/Roaming/Cycling '74/Logs" | sort-by modified | last)
    print $"opening ($latest_dump.name)"
    start $latest_dump.name
}

export def "Max download-installers" [] {
    let dir = '~/src/work/installers-exe'
    mkdir $dir
    cd $dir
    if not ("Max862_240319.zip" | path exists) { wget https://downloads.cdn.cycling74.com/max8/Max862_240319.zip }
    if not ("Max833_221006.zip" | path exists) { wget https://downloads.cdn.cycling74.com/max8/Max833_221006.zip }

}

export def "Max preferences set no-crashrecovery" [] {
    open $maxpreferences | from json
    | upsert preferences.crashrecovery Never
    | to json | save -f $maxpreferences
}

export def "Max preferences set logtosystemconsole" [] {
    open $maxpreferences | from json
    | upsert preferences.logtosystemconsole 1
    | to json | save -f $maxpreferences
}

export def "Max preferences set node-logging" [] {
    const logname = "node-for-max-log.txt"
    let logfolder = pwd
    print $"(ansi pb)> tspin ($logname)(ansi reset)"
    open $maxpreferences | from json
    | upsert preferences.n4m_debug_log_name $logname
    | upsert preferences.n4m_debug_log_enabled 1
    | upsert preferences.n4m_debug_log_folder $logfolder
    | to json | save -f $maxpreferences
    return ($logfolder | path join $logname)
}

# greps for something max related in all known locations where something interesting might be found
export def "Max rg" [pattern: string] {
    let locations = [
        ("~/src/oss/max-sdk" | path expand),
        ("C:/Program Files/Cycling '74" | path expand),
        ("~/AppData/Roaming/Cycling '74"| path expand),
    ]
    rg $pattern ...$locations
}

# ripgrep Max stuff
export alias "rg-max" = rg --type-add 'max:*.{maxhelp,maxpat,json}' -t max

export def "Max list loaded-mxe64" [] { frida list modules-and-exports (pidof Max) | where dll =~ mxe64 }
export def "Max list my-loaded-mxe64" [] { Max list loaded-mxe64 | filter { $in.dll | str starts-with m. } }

export def "Max list available-objects" [] {
    let alias = (
        ls `~/Documents/Max 9/Packages/*/init/*txt` | get name | each { |file|
            ( open $file | parse "max objectfile {name} {obj};"
                | insert max-package { $""}
                | insert description { $"alias of $($in.obj) by ($file | path basename)"} )
        }
    ) | flatten
    let objects_without_alias = (
        fd --follow -HI mxe64 ("~/Documents/Max 9/Packages" | path expand) | lines | path parse | get stem
        | each {
            if not ($in in $alias.obj) { $in } } | wrap name | insert description { null }
    )
    $alias | select name description | append $objects_without_alias
}
