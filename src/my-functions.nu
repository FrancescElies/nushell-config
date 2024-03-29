# todos
export alias todos = br ~/zettelkasten
# radare2
export alias r2 = radare2
# lazygit
export alias lg = lazygit
# extracts archives with different extensions
export alias extract = ouch decompress

export alias time-today = python ~/src/nushell-config/time_spent_today.py

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

# create directory and cd into it.
export def --env md [dir] {
  mkdir $dir
  cd $dir
}

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
    echo "no files to compress specified"
  } else {
     7z a -t7z -m0=lzma2 -mx=9 -ms=on -mmt=on $"($filename).7z" $rest
  }
}

#translate text using mymemmory api
export def trans [
  ...search:string  #search query]
  --from:string     #from which language you are translating (default english)
  --to:string       #to which language you are translating (default spanish)
  #
  #Use ISO standar names for the languages, for example:
  #english: en-US
  #spanish: es-ES
  #italian: it-IT
  #swedish: sv-SV
  #
  #More in: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
] {

  if ($search | is-empty) {
    echo "no search query provided"
  } else {
    let key = "api_kei"
    let user = "user_email"

    let from = if ($from | is-empty) {"en-US"} else {$from}
    let to = if ($to | is-empty) {"es-ES"} else {$to}

    let to_translate = ($search | str join "%20")

    let url = $"https://api.mymemory.translated.net/get?q=($to_translate)&langpair=($from)%7C($to)&of=json&key=($key)&de=($user)"

    http get $url | get responseData | get translatedText
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
