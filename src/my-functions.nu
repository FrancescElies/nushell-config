# my notes
use utils.nu print_purple

export def notes [] {
  cd ~/src/zettelkasten
  broot .
}

# create big file
# use std
# "a" | std repeat (128kib | into int) | str join "" o> bigfile.txt
# 1..(128kib | into int) | each { 'a' } | save -f bigfile.txt

export alias pipx = python ~/bin/pipx.pyz

# list open listening ports
export def ports [] {
  match $nu.os-info.name {
      "windows" => { error make {msg: "netstat -tulnp ???"} },
      # netstat columns in unix
      # Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID Program name
      _ => { netstat -tulnp | str replace -a "/" " " | str replace "Program name" " program-name" | tail -n +2 | detect columns },
  }
}

# lazygit
export alias lg = lazygit
# extracts archives with different extensions
export alias extract = ouch decompress

export def "wezterm logs" [] {
  if $nu.os-info.name == "linux" {
    br $env.XDG_RUNTIME_DIR/wezterm
  } else {
    br ~/.local/share/wezterm/
  }
}

# terrastruct/d2 diagram helper: echo 'x -> y -> z' | save -f diagram.d2
export def diagram [name: path] {
  let filename = $"($name).d2"
  # wezterm cli split-pane --down --percent 30 -- watchexec -w $filename d2 $filename
  wezterm cli split-pane --bottom --percent 30 -- d2 --watch $filename
  nvim $filename
}

export alias chat = elia

# ask something to chat gpt
export def "could you" [...words: string] {
  tgpt $"could you ($words | str join ' ')"
}
# ask something to chat gpt
export def "how do i" [...words: string] { tgpt $"how do i ($words | str join ' ')" }
# ask something to chat gpt
export def "what" [...words: string] { tgpt $"what ($words | str join ' ')" }

export def time-today [] { ~/src/nushell-config/.venv/bin/python ~/src/nushell-config/src/time_spent_today.py }

# list services (printers, scanners...) in local network with avahi-browse
export def "network services" [] {
 avahi-browse --all --terminate --parsable
  | from csv --separator ";" --noheaders --flexible
  | rename "new(+)\ngone(-)\nresolved(=)" net IPvX ip service-type domain
}

# list printers in local network with avahi-browse
export def "network printers" [] {
 avahi-browse --terminate --parsable _ipp._tcp
  | from csv --separator ";" --noheaders --flexible
  | rename "new(+)\ngone(-)\nresolved(=)" net IPvX ip service-type domain
}


# compact ls
export def lsg [] { try { ls | sort-by type name -r | grid --icons --color | str trim } catch { ls | get name | to text} }

# jdownloader downloads info (requires a jdown python script)
export def jd [] {
  jdown | lines | each { |line| $line | from nuon } | flatten | flatten
}

#cd to the folder where a binary is located
export def --env which-cd [program] {
  let dir = (which $program | get path | path dirname | str trim)
  cd $dir.0
}

# date string YYYY-MM-DD
export def "date format-ymd" [] { (date now | format date %Y-%m-%d) }

# date string DD-MM-YYYY
export def "date format-dmy" [] { (date now | format date %d-%m-%Y) }

# create directory and cd into it (alias mcd)
export def --env mkdircd [dir] { mkdir $dir; cd $dir }
alias mcd = mkdircd

#compress to 7z using max compression
export def `7zmax` [
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

export def magnets [] {
  if (ps --long | where command =~  "3030:localhost:3030" | is-empty) {
    ssh -L 3030:localhost:3030 intel-pc -fN
  }
  start http://localhost:3030/web
}

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
    ps --long | find $name
  }
}

# fuzzy select find process pid
export def pid [] { ps | sort-by -in name | input list -d name --fuzzy  | get pid }


def "nu-complete list-process-names" [] { ps | get name | sort | uniq }

#kill specified process in name
export def killn [name: string@"nu-complete list-process-names"] {
  print "Following processes were killed"
  ps | find $name | each {|x| try {kill -f $x.pid}; echo $x }
}
export alias k = killn

# print worth watching speakers
export def speakers [] {
  return {
    python: "David Beazley, Raymond Hettinger, Hynek Schlawack"
    rust: "Jon Gjengset"
  }
}

export def clang-commands-json [] {
  if not ("~/src/clang-power-tools" | path exists) {
    cd ~/src
    git clone https://github.com/Caphyon/clang-power-tools
  }
  powershell -File ~/src/clang-power-tools/ClangPowerTools/ClangPowerTools/Tooling/v1/clang-build.ps1  -export-jsondb
}

export def where-dumpbin [] { vswhere -latest -find **/dumpbin.exe | str replace -a '\\' '/' }

#
# ffmpeg -i VIDEO.mp4 -vf unsharp=13:13:5 VIDEO-unsharp.mp4

# Reduces video size and converts to mp4
# See https://stackoverflow.com/questions/12026381/ffmpeg-converting-mov-files-to-mp4
export def "reduce-size video" [input_video: path] {
  ffmpeg -i $input_video -vcodec libx265 -crf 28  $"($input_video).mp4"
}

# reduces jpg size using mogrify from imagemagick
export def "reduce-size image-quality" [
  infile: path, # an image file supported by imagemagick
  quality: int = 10, # JPEG(1=lowest, 100=highest) see https://imagemagick.org/script/command-line-options.php#quality for other formats
  --outdir: path = './_reduced_images'
] {
  mkdir $outdir
  cp -f $infile $outdir
  let outfile = ($outdir | path join  ($infile | path basename))
  mogrify -quality $quality $outfile
}

# reduces jpg size using pngcrush
export def "reduce-size png" [
  infile: path, # a jpg/jpeg file
  --outdir: path = './_reduced_images'
] {
  mkdir $outdir
  cp -f $infile $outdir
  let outfile = ($outdir | path join ($infile | path basename))
  pngcrush $infile $outfile
}

# reduces jpg size using jpegoptim
export def "reduce-size jpg" [
  infile: path, # a jpg/jpeg file
  --size: string = '100k', #
  --outdir: path = './_reduced_images'
] {
  mkdir $outdir
  cp -f $infile $outdir
  let outfile = ($outdir | path join ($infile | path basename))
  jpegoptim --size $size $outfile
}

# reduces pdf size using gs
export def "reduce-size pdf" [
  infile: path, # a pdf file
  outputpdf: path = output.pdf,
  # -dPDFSETTINGS=/screen     lower quality and smaller size. (72 dpi)
  # -dPDFSETTINGS=/ebook      default,  slightly larger size (150 dpi)
  # -dPDFSETTINGS=/prepress   higher size and quality (300 dpi)
  # -dPDFSETTINGS=/printer    printer type quality (300 dpi)
  # -dPDFSETTINGS=/default    useful for multiple purposes. Can cause large PDFS.
  pdfsettings: string = "/ebook"
] {
  ^gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 $"-dPDFSETTINGS=($pdfsettings)" -dNOPAUSE -dQUIET -dBATCH $"-sOutputFile=($outputpdf)" $infile
}

# One could download move parts like follows from some website
# 400 is just an arbitrary number of how may parts there are
# 1..400 | par-each { |x| curl $"mylink/part-($x)" -o $x -fS }
export def concat-videos-in-folder [folder: path] {
  cd $folder
  ls | get name | sort --natural | each { $"file ($in)" } | save -f inputs.txt
  ffmpeg -f concat -safe 0 -i inputs.txt -c copy $"($folder | path basename).mkv"
}


export def watch-cwd [] { watch . { |op, path, new_path| $"($op) ($path) ($new_path)"} }

export def which-process-locks [path: path] {
  if $nu.os-info.name == "windows" {
    # https://learn.microsoft.com/en-us/sysinternals/downloads/handle
    handle $path
  } else {
    lsof $path
  }
}

export def "youtube download-audio" [ url: string ] {
  let yt_dlp = "~/bin/yt-dlp" | path expand
  mut args = ['-x' '--audio-format=vorbis']
  print_purple python $yt_dlp ...$args $url
  python $yt_dlp  ...$args $url
}

export def "youtube download-video" [
  url: string
  --sub-lang: string  # with subtitles language, e.g. de, tr, es, en
] {
  let yt_dlp = "~/bin/yt-dlp" | path expand
  mut args = []
  if ($sub_lang | is-not-empty) { $args = ($args | append $'--write-sub --sub-lang ($sub_lang)' ) }

  print_purple python $yt_dlp  ...$args $url
  python $yt_dlp  ...$args $url
}

# rsync that works with FAT formatted usbs, (-c) checksum, (-r) recursive, (-t) preserve modification times, (-P) keep partially transferred files and show progress
export alias rsync-fat = ^rsync -rtcvP --update

# what is my public ip
export def "my ip" [] {
  curl https://ipinfo.io
  # http get https://api.ipify.org
  # http get https://api6.ipify.org
}

# which apps do I have
export def "my apps" [] {
  let venv_pkgs = (python -c `from importlib.metadata import entry_points; print('\n'.join(x.name for x in entry_points()['console_scripts']))` | lines)
  let bin_pkgs = (ls ~/bin/**/* | where type == file | get name)
  let cargo_bin_pkgs = (ls ~/.cargo/bin/* | where type == file | get name)
  let go_bin_pkgs = (ls ~/go/bin/* | where type == file | get name)
  return ($venv_pkgs | append $bin_pkgs | append $cargo_bin_pkgs | append $go_bin_pkgs)
}

export def todos [] { mkdircd ~/src/zettelkasten ; nvim todos.md }

def "nu-complete projects" [] {
    {
        options: {
            case_sensitive: false,
            completion_algorithm: fuzzy, # fuzzy or prefix
            positional: false,
            sort: true,
        },
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
export def --env cdp [project: string@"nu-complete projects"] { cd ('~/src' | path expand | path join $project ) }


# https://youtu.be/YXrb-DqsBNU?feature=shared&t=546
# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#available-checks
def compiler-flags [] {
  print "-Werror -Wall -Wextra -fsanitize=address,undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,local-bounds,nullability"
}

