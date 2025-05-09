# fuzzy select find process pid
export def pid [] { ps | sort-by -in name | input list -d name --fuzzy  | get pid }

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
export def "ps name" [name: string = "" ] {
  if ($name | is-empty) {
    ps --long | sort-by -in name | input list -d name --fuzzy
  } else {
    ps --long | find --ignore-case --columns [name] -i $name
  }
}
export alias psn = ps name

# get the counts of the multiset processes
export def "ps count" [] {
    ps | get name | uniq --count | sort-by count
}
export alias psc = ps count

def "nu-complete list-process-names" [] { ps | get name | sort | uniq }

# kill specified process with substring
export def "ps kill-name" [name: string@"nu-complete list-process-names"] {
    let procs = ps | find --ignore-case --columns [name] $name | sort-by -in name
    print $procs
    if (input $"(ansi pb)Do you want to kill processes above [y/n](ansi reset)?" | str downcase) == "y" {
        $procs | each { try { kill -f $in.pid } }
    }
}
export alias killn = ps kill-name
