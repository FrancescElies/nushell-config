use ~/src/nushell-config/src/broot-helpers.nu *
export alias rg-max = rg --type-add 'max:*.{maxhelp,maxpat,json}' -t max

# Cycling '74 Max cli wrap
export def maxmsp [maxpat: string = ""] {
    let max_exe = match $nu.os-info.name { 
      "windows" => `C:/Program Files/Cycling '74/Max 8/Max.exe` 
      "macos" => "/Applications/Max.app/Contents/MacOS/Max", 
      _ => { error make {msg: "not implemented" } } 
    }
    ^$max_exe ($maxpat | path expand)
}

# opens maxpreferences.maxpref
export def "maxmsp maxpreferences" [] {
  nvim `~/AppData/Roaming/Cycling '74/Max 8/Settings/maxpreferences.maxpref`
}

# opens maxinterface.json
export def "maxmsp maxinterface" [] {
  nvim `C:/Program Files/Cycling '74/Max 8/resources/interfaces/maxinterface.json`
}

# goes to Cycling '74/Logs, where .dmp files are
export def --env "maxmsp dumps" [] {
  cd `~/AppData/Roaming/Cycling '74/Logs`
  br
}

# opens Max examples
export def --env "maxmsp examples" [] {
  cd `~/src/oss/max-sdk/source`
  br 
}

# opens Max's api
export def "maxmsp api" [] {
  if not ("~/src/oss/max-sdk/source/max-sdk-base" | path exists) { 
    mkdir ~/src/oss
    cd ~/src/oss
    git clone https://github.com/Cycling74/max-sdk
  }
  cd `~/src/oss/max-sdk/source/max-sdk-base/c74support/max-includes`
  br 
}


# opens latest .dmp file from Cycling '74/Logs
export def "maxmsp latest-dump" [] {
  let latest_dump = (ls `~/AppData/Roaming/Cycling '74/Logs` | sort-by modified | last)
  start $latest_dump.name
}

# opens Max 8 Packages folder
export def --env "maxmsp packages" [] {
  cd `~/Documents/Max 8/Packages`
  br
}

export def "maxmsp download-installers" [] {
  let dir = '~/src/work/installers-exe'
  mkdir $dir
  cd $dir
  if not ("Max862_240319.zip" | path exists) { wget https://downloads.cdn.cycling74.com/max8/Max862_240319.zip }
  if not ("Max833_221006.zip" | path exists) { wget https://downloads.cdn.cycling74.com/max8/Max833_221006.zip }
  
}

# greps for something max related in all known locations where something interesting might be found
export def "maxmsp grep" [pattern: string] {
  let locations = [
    (echo `~/src/oss/max-sdk` | path expand), 
    (echo `C:/Program Files/Cycling '74` | path expand),
    (echo `~/AppData/Roaming/Cycling '74`| path expand),
  ]
  rg $pattern ...$locations
}

