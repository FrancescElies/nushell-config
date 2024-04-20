# my notes
export def notes [] {
  cd ~/src/zettelkasten
  broot .
}

# lazygit
export alias lg = lazygit
# extracts archives with different extensions
export alias extract = ouch decompress

# terrastruct/d2 diagram helper
# echo 'x -> y -> z' | save -f diagram.d2
export def diagram [name: path] {
  let filename = $"($name).d2"
  # wezterm cli split-pane --down --percent 30 -- watchexec -w $filename d2 $filename
  wezterm cli split-pane --bottom --percent 30 -- d2 --watch $filename
  nvim $filename
}

# ask something to chat gpt
export def "can you" [...words: string] {
  tgpt $"can you ($words | str join ' ')"
}

# ask something to chat gpt
export def "how do i" [...words: string] {
  tgpt $"how do i ($words | str join ' ')"
}

export def time-today [] {
  ~/src/nushell-config/.venv/bin/python ~/src/nushell-config/src/time_spent_today.py
}


# compact ls 
export def lsg [] { ls | sort-by type name -i | grid -c | str trim }
export alias l = lsg

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
export def --env mkdircd [dir] {
  mkdir $dir
  cd $dir
}
alias md = mkdircd

#compress to 7z using max compression
export def `7zmax` [
  filename: string  #filename without extension
  ...rest:  string  #files to compress and extra flags for 7z (add flags between quotes)
  #
  # Example:
  # compress all files in current directory and delete them
  # 7zmax * "-sdel"
] {

  if ($rest | is-empty) {
    print "no files to compress specified"
  } else {
     7z a -t7z -m0=lzma2 -mx=9 -ms=on -mmt=on $"($filename).7z" $rest
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

#kill specified process in name
export def killn [name: string] { ps | find $name | each {|x| kill -f $x.pid} }

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
export def "reduce video-size" [input_video: path] {
  ffmpeg -i $input_video -vcodec libx265 -crf 28  $"($input_video).mp4"
}

# reduces pdf size
export def "reduce-size pdf-size" [
  inputpdf: path, 
  outputpdf: path = output.pdf,
  # -dPDFSETTINGS=/screen     lower quality and smaller size. (72 dpi)
  # -dPDFSETTINGS=/ebook      default,  slightly larger size (150 dpi)
  # -dPDFSETTINGS=/prepress   higher size and quality (300 dpi)
  # -dPDFSETTINGS=/printer    printer type quality (300 dpi)
  # -dPDFSETTINGS=/default    useful for multiple purposes. Can cause large PDFS.
  pdfsettings: string = "/ebook"
] {
  ^gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 $"-dPDFSETTINGS=($pdfsettings)" -dNOPAUSE -dQUIET -dBATCH $"-sOutputFile=($outputpdf)" $inputpdf
}

# One could download move parts like follows from some website
# 400 is just an arbitrary number of how may parts there are
# 1..400 | par-each { |x| curl $"mylink/part-($x)" -o $x -fS }
export def concat-videos-in-folder [folder: path] {
  cd $folder
  ls | get name | sort --natural | each { $"file ($in)" } | save -f inputs.txt
  ffmpeg -f concat -safe 0 -i inputs.txt -c copy $"($folder | path basename).mkv"
}


export def watch-cwd [] {
  watch . { |op, path, new_path| $"($op) ($path) ($new_path)"}
}

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
  --audio-only     #
] {
   let yt_dlp = "~/bin/yt-dlp" | path expand
   if not ($yt_dlp | path exists) { http get https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp | save $yt_dlp }
   if $audio_only {
     python $yt_dlp -x --audio-format mp3 $url
   } else {
     python $yt_dlp $url
   }
}

# more robust rsync (works with FAT usbs too) :(-c) checksum, (-r) recursive, (-t) preserve modification times, (-P) keep partially transferred files and show progress
export def "rsync" [source: path, destination: path] {
  ^rsync -rtcvP --update $source $destination
}

export def "myip" [] {
  curl https://ipinfo.io
  # http get https://api.ipify.org
  # http get https://api6.ipify.org
}
