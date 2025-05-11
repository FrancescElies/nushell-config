# my notes
export alias ex = explore
export alias ll = ls -l

def "nu-complete projects" [] {
    {
        options: { completion_algorithm: fuzzy, case_sensitive: false, positional: false, sort: true, },
        completions: (
          ls ~/src
          | append (try {ls ~/src/work})
          | append (try {ls ~/src/work/*-worktrees/*})
          | append (try {ls ~/src/oss})
          | where type == dir | get name
          | path relative-to ~/src)
    }
}
# cd into project
export def --env "my project" [project: string@"nu-complete projects"] { cd ('~/src' | path expand | path join $project ) }
# cd into project
export alias cdp = my project

export def "my todos" [] {
    mkdir ~/src/zettelkasten
    cd ~/src/zettelkasten
    br
}
export alias todos = my todos

# create big file
export def "my create big-file" [filesize: filesize, outfile: path = bigfile.txt] {
    use std
    "a" | std repeat (128kib | into int) | str join "" o> $outfile
}

export alias pipx = python ~/bin/pipx.pyz

# list open listening ports
export def "my open-ports" [] {
  match $nu.os-info.name {
      "windows" => { error make {msg: "netstat -tulnp ???"} },
      # netstat columns in unix
      # Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID Program name
      _ => { netstat -tulnp | str replace -a "/" " " | str replace "Program name" " program-name" | tail -n +2 | detect columns },
  }
}

# extracts archives with different extensions
export alias decompress = ouch decompress
# extracts archives
export def "decompress all" [path: path = "."] {
    cd $path
    ( ls *[tar, zip, bz, bz2, gz, lz4, xz, lzma, tgz, tbz, tlz4, txz, tzlma, tsz, tzst sz, zst, rar]
    | each { ouch decompress $in.name })
}

export def "my wezterm logs" [] {
  if $nu.os-info.name == "linux" {
    br $env.XDG_RUNTIME_DIR/wezterm
  } else {
    br ~/.local/share/wezterm/
  }
}

export def "my time-today" [] {
    cd ~
    python ~/src/nushell-config/src/time_spent_today.py
}

# list services (printers, scanners...) in local network with avahi-browse
export def "my network services" [] {
 avahi-browse --all --terminate --parsable
  | from csv --separator ";" --noheaders --flexible
  | rename "new(+)\ngone(-)\nresolved(=)" net IPvX ip service-type domain
}

# list printers in local network with avahi-browse
export def "my network printers" [] {
 avahi-browse --terminate --parsable _ipp._tcp
  | from csv --separator ";" --noheaders --flexible
  | rename "new(+)\ngone(-)\nresolved(=)" net IPvX ip service-type domain
}


# compact ls
export def lsg [] { try { ls | sort-by type name -r | grid --icons --color | str trim } catch { ls | get name | to text} }
export alias l = lsg

# cd to the folder where a binary is located
export def --env "cd where-is" [program] {
  let dir = (which $program | get path | path dirname | str trim)
  cd $dir.0
}

# date string YYYY-MM-DD
export def "date format ymd" [] { (date now | format date %Y-%m-%d) }

# date string DD-MM-YYYY
export def "date format dmy" [] { (date now | format date %d-%m-%Y) }

# create directory and cd into it (alias mcd)
export def --env mkdircd [dir: path] { mkdir $dir; cd $dir }
alias mcd = mkdircd

#compress to 7z using max compression
export def `7z compress max` [
  outfile: string  # out filename without extension
  ...rest:  string  # files to compress and extra flags for 7z (add flags between quotes)
  #
  # Example:
  # compress all files in current directory and delete them
  # 7zmax * "-sdel"
] {

  if ($rest | is-empty) {
    print "no files to compress specified"
  } else {
     7z a -t7z -m0=lzma2 -mx=9 -ms=on -mmt=on $"($outfile).7z" ...$rest
  }
}

# print worth watching speakers
export def "my speakers" [] {
  return {
    python: "David Beazley, Raymond Hettinger, Hynek Schlawack"
    rust: "Jon Gjengset"
  }
}

# what is my public ip
export def "my ip" [] {
  http get https://ipinfo.io/json
  # http get https://api.ipify.org
  # http get https://api6.ipify.org
}

# which apps do I have
export def "my apps" [] {
  let venv_pkgs = (python -c `from importlib.metadata import entry_points; print('\n'.join(x.name for x in entry_points()['console_scripts']))` | lines)
  let bin_pkgs = (try {ls ~/bin/**/*} catch {[]} | where type == file | get name)
  let cargo_bin_pkgs = (try {ls ~/.cargo/bin/*} catch {[]} | where type == file | get name)
  let go_bin_pkgs = (try {ls ~/go/bin/*} catch {[]} | where type == file | get name)
  return ($venv_pkgs | append $bin_pkgs | append $cargo_bin_pkgs | append $go_bin_pkgs
        | path parse | flatten | move stem --first | move extension --after stem
    )
}

def "my compiler-flags" [] {
    print https://youtu.be/YXrb-DqsBNU?feature=shared&t=546
    print https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#available-checks
    print "-Werror -Wall -Wextra -fsanitize=address,undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,local-bounds,nullability"
}

# backup by-year
export def "my backup by-year" [serverip: string = "intel-pc"] {
    restic --repo sftp:($serverip):by-year.restic backup ~/by-year
}

