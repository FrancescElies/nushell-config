use ~/.config/broot/launcher/nushell/br *

export def --env "ssh-agent start" [] {
    ^ssh-agent -c
        | lines
        | first 2
        | parse "setenv {name} {value};"
        | transpose -r
        | into record
        | load-env
}

export def "my rqbit" [] {
  if (ps --long | where command =~  "3030:localhost:3030" | is-empty) {
    ssh -L 3030:localhost:3030 intel-pc -fN
  }
  start http://localhost:3030/web
}
export def "my prowlarr" [] {  start http://intel-pc:9696/ }
export def "my jellyfin" [] {  start http://intel-pc:8096 }
