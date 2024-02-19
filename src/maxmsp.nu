use ~/src/nushell-config/src/broot-helpers.nu *
alias rg-max = rg --type-add 'max:*.{maxhelp,maxpat,json}' -t max

# Cycling '74 Max cli wrap
def maxmsp [maxpat: string = ""] {
    let max_exe = match $nu.os-info.name { 
      "windows" => `C:/Program Files/Cycling '74/Max 8/Max.exe` 
      "macos" => "/Applications/Max.app/Contents/MacOS/Max", 
      _ => { error make {msg: "not implemented" } } 
    }
    ^$max_exe ($maxpat | path expand)
}

# opens maxpreferences.maxpref
def "maxmsp maxpreferences" [] {
  nvim `~/AppData/Roaming/Cycling '74/Max 8/Settings/maxpreferences.maxpref`
}

# opens maxinterface.json
def "maxmsp maxinterface" [] {
  nvim `C:/Program Files/Cycling '74/Max 8/resources/interfaces/maxinterface.json`
}

# goes to Cycling '74/Logs, where .dmp files are
def --env "maxmsp dumps" [] {
  cd `~/AppData/Roaming/Cycling '74/Logs`
  br
}

# opens Max's api
def "maxmsp api" [] {
  if not ("~/src/oss/max-sdk/source/max-sdk-base" | path exists) { 
    mkdir ~/src/oss
    cd ~/src/oss
    git clone https://github.com/Cycling74/max-sdk
  }
  cd `~/src/oss/max-sdk/source/max-sdk-base/c74support/max-includes`
  br 
}


# opens latest .dmp file from Cycling '74/Logs
def "maxmsp latest-dump" [] {
  let latest_dump = (ls `~/AppData/Roaming/Cycling '74/Logs` | sort-by modified | last)
  start $latest_dump.name
}

# opens Max 8 Packages folder
def --env "maxmsp packages" [] {
  cd `~/Documents/Max 8/Packages`
  br
}

# greps for something max related in all known locations where something interesting might be found
def "maxmsp grep" [pattern: string] {
  let locations = [
    (echo `~/src/oss/max-sdk` | path expand), 
    (echo `C:/Program Files/Cycling '74` | path expand),
    (echo `~/AppData/Roaming/Cycling '74`| path expand),
  ]
  rg $pattern ...$locations
}

