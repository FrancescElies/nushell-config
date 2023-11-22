# opens maxpreferences.maxpref
alias edit-maxsettings = nvim `~/AppData/Roaming/Cycling '74/Max 8/Settings/maxpreferences.maxpref`
alias edit-maxinterface = nvim `C:/Program Files/Cycling '74/Max 8/resources/interfaces/maxinterface.json`

# Cycling '74 Max cli wrap
def maxmsp [maxpat: string = ""] {
    `C:/Program Files/Cycling '74/Max 8/Max.exe` ($maxpat | path expand)
}

# opens Cycling '74/Logs, where .dmp files are
def "maxmsp dumps" [] {
  cd `~/AppData/Roaming/Cycling '74/Logs`
}

# opens latest .dmp file from Cycling '74/Logs
def "maxmsp open-latest-dump" [] {
  let latest_dump = (ls `~/AppData/Roaming/Cycling '74/Logs` | sort-by modified | last)
  start $latest_dump.name
}

