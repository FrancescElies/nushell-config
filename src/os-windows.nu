# Windows
# chcp 65001
# export alias vim = "c:/tools/vim/vim90/vim.exe"

export def "msi silent-install" [msi_file: path] {
  let $logfile = $"($msi_file | path basename).XXXX.log"
  let $logfile = (mktemp $logfile)
  echo $"Installing ($msi_file) see log at ($logfile)"
  msiexec.exe /i $msi_file /QN /L*V $logfile
}
