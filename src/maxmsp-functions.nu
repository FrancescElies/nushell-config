use ~/src/nushell-config/src/broot-helpers.nu *
export alias rg-max = rg --type-add 'max:*.{maxhelp,maxpat,json}' -t max

# Cycling '74 Max cli wrap
export def Max [maxpat?: path] {
    let max_exe = match $nu.os-info.name {
      "windows" => "C:/Program Files/Cycling '74/Max 9/Max.exe"
      "macos" => "/Applications/Max.app/Contents/MacOS/Max",
      _ => { error make {msg: "not implemented" } }
    }
    if ($maxpat == null) { run-external $max_exe } else { run-external $max_exe ($maxpat | path expand) }
}
export alias maxpats = br --cmd ".maxpat&t/"

# opens Max settings
export def --env "Max settings" [] {
  cd "~/AppData/Roaming/Cycling '74/Max 9/Settings"
  br
}

# sets Max Audio Status
export def "Max set-audio-status" [] {
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


# opens maxpreferences.maxpref
export def "Max maxpreferences" [] {
  cd "~/AppData/Roaming/Cycling '74/Max 9/Settings"
  nvim "~/AppData/Roaming/Cycling '74/Max 9/Settings/maxpreferences.maxpref"
}

# opens maxinterface.json
export def "Max maxinterface" [] {
  nvim "C:/Program Files/Cycling '74/Max 9/resources/interfaces/maxinterface.json"
}

# goes to Cycling '74/Logs, where .dmp files are
export def --env "Max dumps" [] {
  cd "~/AppData/Roaming/Cycling '74/Logs"
  br
}

# opens Max examples
export def --env "Max examples" [] {
  cd "~/src/oss/max-sdk/source"
  br
}

# opens Max's api
export def "Max api" [] {
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

# opens Max 9 Packages folder
export def --env "Max packages" [] {
  cd "~/Documents/Max 9/Packages"
  br
}

export def "Max download-installers" [] {
  let dir = '~/src/work/installers-exe'
  mkdir $dir
  cd $dir
  if not ("Max862_240319.zip" | path exists) { wget https://downloads.cdn.cycling74.com/max8/Max862_240319.zip }
  if not ("Max833_221006.zip" | path exists) { wget https://downloads.cdn.cycling74.com/max8/Max833_221006.zip }

}

# greps for something max related in all known locations where something interesting might be found
export def "Max grep" [pattern: string] {
  let locations = [
    ("~/src/oss/max-sdk" | path expand),
    ("C:/Program Files/Cycling '74" | path expand),
    ("~/AppData/Roaming/Cycling '74"| path expand),
  ]
  rg $pattern ...$locations
}

