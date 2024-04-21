# Windows
# chcp 65001
# export alias vim = "c:/tools/vim/vim90/vim.exe"

overlay use ~/src/nushell-config/.venv/scripts/activate.nu

# https://stackoverflow.com/questions/8560166/silent-installation-of-a-msi-package
export def "msi silent-install" [msi_file: path] {
  # wmic product get name
  # msiexec /i c:\path\to\package.msi /quiet /qn /norestart /log c:\path\to\install.log PROPERTY1=value1 PROPERTY2=value2
  let $logfile = $"($msi_file | path basename).XXXX.log"
  let $logfile = (mktemp $logfile)
  print $"Installing ($msi_file) see log at ($logfile)"
  msiexec.exe /i $msi_file /QN /L*V $logfile
}

def "nu-complete installed-pkgs" [] { 
  ( open /tmp/installed-pkgs.txt | lines 
  | each { $in | str trim } 
  | filter {not ($in | is-empty) } 
  )
}

export def "msi refresh-list" [] { wmic product get name | save -f /tmp/installed-pkgs.txt }

export def "msi uninstall" [
  pkg: string@"nu-complete installed-pkgs"  # call `msi refresh-list` if you feel not up to date
] {
  # example
  print wmic Product Where "Name='Max 8 (64-bit)'" Call Uninstall /NoInteractive
}
