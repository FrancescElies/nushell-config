
# gets pid of process with name
export def pidof [name: string ] {
  let procs = ps --long | where name =~ $name
  if (($procs | length) > 1) {
    $procs | sort-by -in name | input list -d name --fuzzy | get pid
  } else {
    $procs | get 0.pid
  }
}

# grep for specific process names
export def psn [name: string = "" ] {
  if ($name | is-empty) {
    ps --long | sort-by -in name | input list -d name --fuzzy
  } else {
    ps --long | find --columns [name] -i $name
  }
}

# fuzzy select find process pid
export def pid [] { ps | sort-by -in name | input list -d name --fuzzy  | get pid }


def "nu-complete list-process-names" [] { ps | get name | sort | uniq }

#kill specified process in name
export def killn [name: string@"nu-complete list-process-names"] {
  print "Following processes were killed"
  ps | find --columns [name] $name | each {|x| try {kill -f $x.pid}; echo $x }
}
export alias k = killn
