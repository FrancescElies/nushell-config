# my notes
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

# terrastruct/d2 diagram helper
# echo 'x -> y -> z' | save -f diagram.d2
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


# compact ls
export def lsg [] { ls | sort-by type name -i | grid -c | str trim }

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
export def ymd [] { (date now | format date %Y-%m-%d) }

# date string DD-MM-YYYY
export def dmy [] { (date now | format date %d-%m-%Y) }

# create directory and cd into it (alias md)
export def --env mkdircd [dir] { mkdir $dir; cd $dir }
alias md = mkdircd

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

# convert SVGs to PDFs
export def svgs-to-pdfs [path: path] {
  for file in (ls *svg) {
    $file.name
    | inkscape -f ($in | path join) -A ($in | update extension ' pdf' | path join)
  }
}

#search for specific process
export def psn [name: string] { ps | find $name }


def "nu-complete list-process-names" [] { ps | get name | uniq }

#kill specified process in name
export def killn [name: string@"nu-complete list-process-names"] { ps | find $name | each {|x| kill -f $x.pid} }
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


# Reduces video size and converts to mp4
# See https://stackoverflow.com/questions/12026381/ffmpeg-converting-mov-files-to-mp4
export def "reduce-size video" [input_video: path] {
  ffmpeg -i $input_video -vcodec libx265 -crf 28  $"($input_video).mp4"
}

# reduce any image file size
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

export def "reduce-size png" [
  infile: path, # a jpg/jpeg file
  --outdir: path = './_reduced_images'
] {
  mkdir $outdir
  cp -f $infile $outdir
  let outfile = ($outdir | path join ($infile | path basename))
  pngcrush $infile $outfile
}

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

# reduces pdf size
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

export def who-locks [path: path] {
  if $nu.os-info.name == "windows" {
    # https://learn.microsoft.com/en-us/sysinternals/downloads/handle
    handle $path
  } else {
    lsof $path
  }
}

export def lldbb-attach-windows-process [processid: int] {
  with-env {Path: ($env.Path | prepend "C:/Python310") ,PYTHONHOME: `C:/Python310`, PYTHONPATH: "C:/Python310/Lib"} {
    python --version
    lldb -p $processid
  }
}

export def "youtube download" [
  url: string
  --audio-only  # downloads mp3 only
  --update      # updates yt_dlp
] {
  # alternative https://github.com/iawia002/lux
   let yt_dlp = "~/bin/yt-dlp" | path expand
   if (not ($yt_dlp | path exists) or $update) { http get https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp | save -f $yt_dlp }
   if $audio_only {
     python $yt_dlp -x --audio-format mp3 $url
   } else {
     python $yt_dlp $url
   }
}

# more robust rsync (works with FAT usbs too) :(-c) checksum, (-r) recursive, (-t) preserve modification times, (-P) keep partially transferred files and show progress
export def "rsync" [source: path, destination: path] { ^rsync -rtcvP --update $source $destination }

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

# https://youtu.be/YXrb-DqsBNU?feature=shared&t=546
# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#available-checks
def compiler-flags [] {
  print "-Werror -Wall -Wextra -fsanitize=address,undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,local-bounds,nullability"
}

