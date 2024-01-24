# todos
alias todos = nvim ~/todos/todos.md
# radare2
alias r2 = radare2
# lazygit
alias lg = lazygit
# extracts archives with different extensions
alias extract = ouch decompress

alias time-today = python ~/src/nushell-config/time_spent_today.py

# compact ls 
def lsg [] { ls | sort-by type name -i | grid -c | str trim }
alias l = lsg

# jdownloader downloads info (requires a jdown python script)
def jd [] {
  jdown | lines | each { |line| $line | from nuon } | flatten | flatten
}

#cd to the folder where a binary is located
def --env which-cd [program] {
  let dir = (which $program | get path | path dirname | str trim)
  cd $dir.0
}

# date string YYYY-MM-DD
def ymd [] {
  (date now | format date %Y-%m-%d)
}

# date string DD-MM-YYYY
def dmy [] {
  (date now | format date %d-%m-%Y)
}

# create directory and cd into it.
def --env md [dir] {
  mkdir $dir
  cd $dir
}

# Group list values that match the next-group regex.
# This function is a useful helper to quick and dirty parse data
# that contains line-wise a 'header', followed by a variable number
# of data entries. The return value is a table of header-keys with
# a list of values in the second column. Values before a header-key
# and header-keys without values are ignored.
#
# Example:
#   [id_a 1 2 id_b 3] | group-list '^id_'
def group-list [
  regex # on match, a new group is created
] {
  let lst = $in
  def make-group [v, buf, ret, key] {
    let new_group = ($'($v)' =~ $regex)
    if $new_group {
      let is_key = (not ($key | is-empty))
      let is_buf = (not ($buf | is-empty))
      if ($is_buf and $is_key) {
        let ret = ($ret | append {key: $key, values: $buf})
        {buf: [], ret: $ret, key: $v}
      } else {
        {buf: [], ret: $ret, key: $v}
      }
    } else {
      let buf = ($buf | append $v)
      {buf: $buf, ret: $ret, key: $key}
    }
  }
  def loop [lst, buf=[], ret=[], key=''] {
    if ($lst | is-empty) {
      {ret: $ret, buf: $buf, key: $key}
    } else {
      let v = ($lst | first)
      let obj = (make-group $v $buf $ret $key)
      let rest = ($lst | skip)
      loop $rest $obj.buf $obj.ret $obj.key
    }
  }
  let obj = (loop $lst)
  let ret = $obj.ret
  let buf = $obj.buf
  let key = $obj.key
  let is_key = (not ($key | is-empty))
  let is_buf = (not ($buf | is-empty))
  if ($is_buf and $is_key) {
    $ret | append {key: $key, values: $buf}
  } else {
    $ret
  }
}

#compress to 7z using max compression
def `7zmax` [
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
def trans [
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
def svgs-to-pdfs [path: path] {
  for file in (ls *svg) {
    $file.name 
    | inkscape -f ($in | path join) -A ($in | update extension ' pdf' | path join)
  }
}

#search for specific process
def psn [name: string] {
  ps | find $name
}

#kill specified process in name
def killn [name: string] {
  ps | find $name | each {|x| kill -f $x.pid}
}

def clang-commands-json [] {
  if not ("~/src/clang-power-tools" | path exists) { 
    cd ~/src
    git clone https://github.com/Caphyon/clang-power-tools
  }
  powershell -File ~/src/clang-power-tools/ClangPowerTools/ClangPowerTools/Tooling/v1/clang-build.ps1  -export-jsondb
}

def where-dumpbin [] {
  vswhere -latest -find **/dumpbin.exe | str replace -a '\\' '/'
}


# Reduces video size and converts to mp4
# See https://stackoverflow.com/questions/12026381/ffmpeg-converting-mov-files-to-mp4
def reduce-video-size [input_video: path] {
  ffmpeg -i $input_video -vcodec libx265 -crf 28  $"($input_video).mp4"
}

# One could download move parts like follows from some website
# 400 is just an arbitrary number of how may parts there are
# 1..400 | par-each { |x| curl $"mylink/part-($x)" -o $x -fS }
def concat-videos-in-folder [folder: path] {
  cd $folder
  ls | get name | sort --natural | each { $"file ($in)" } | save -f inputs.txt
  ffmpeg -f concat -safe 0 -i inputs.txt -c copy $"($folder | path basename).mkv"
}

def "config weztern" [] {
  nvim ~/src/wezterm-config/wezterm.lua
}

def "config nvim" [] {
  nvim ~/src/kickstart.nvim/init.lua
}

def "config espanso" [] {
  if $nu.os-info.name == "windows" {
    nvim $"($env.APPDATA)/espanso/default.yml"
  } else {
    error make {msg: "espanso config missing?"}
  }
}

def watch-cwd [] {
  watch . { |op, path, new_path| $"($op) ($path) ($new_path)"}
}

def who-locks [path: path] {
  if $nu.os-info.name == "windows" {
    # https://learn.microsoft.com/en-us/sysinternals/downloads/handle
    handle $path 
  } else {
    lsof $path
  }
}
