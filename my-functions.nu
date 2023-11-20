alias e = nvim 
alias r2 = radare2
alias elisten = nvim --listen 127.0.0.1:6666
alias lg = lazygit
alias b = bat
alias edit-maxsettings = nvim `~/AppData/Roaming/Cycling '74/Max 8/Settings/maxpreferences.maxpref`

def lsg [] { ls | sort-by type name -i | grid -c | str trim }
alias l = lsg

if $nu.os-info.name == "windows" {
  alias vim = c:\tools\vim\vim90\vim.exe
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

#Function to extract archives with different extensions
def extract [name:string #name of the archive to extract
] {
  let extension = [ [ex com];
                    ['.tar.bz2' 'tar xjf']
                    ['.tar.gz' 'tar xzf']
                    ['.bz2' 'bunzip2']
                    ['.rar' 'unrar x']
                    ['.tbz2' 'tar xjf']
                    ['.tgz' 'tar xzf']
                    ['.zip' 'unzip']
                    ['.7z' '7z x']
                    ['.deb' 'ar x']
                    ['.tar.xz' 'tar xvf']
                    ['.tar.zst' 'tar xvf']
                    ['.tar' 'tar xvf']
                    ['.gz' 'gunzip']
                    ['.Z' 'uncompress']
                    ]
  let command = ($extension | where $name =~ $it.ex|first)
  if ($command|is-empty) {
    echo 'Error! Unsupported file extension'
  } else {
    nu -c (build-string $command.com ' ' $name)
  }
}


def clang-commands-json [] {
  powershell -File "~/src/clang-power-tools/ClangPowerTools/ClangPowerTools/Tooling/v1/clang-build.ps1"  -export-jsondb
}

def where-dumpbin [] {
  vswhere -latest -find **/dumpbin.exe | str replace -a '\\' '/'
}


# Reduces video size and converts to mp4
# See https://stackoverflow.com/questions/12026381/ffmpeg-converting-mov-files-to-mp4
def reduce-video-size [input_video: path] {
  ffmpeg -i $input_video -vcodec libx265 -crf 28  $"($input_video).mp4"
}


def todos [] {
  nvim ~/todos/todos.md
}

# https://dystroy.org/broot/tricks/
# A generic fuzzy finder
# The goal here is to have a function you can use in shell to give you a path.
#
# Example:
# echo $(bo)
def bo [] {
  let os = (sys | get host.name)
  let select_hjson = (if $os == "Windows" {
    $"($env.APPDATA)/dystroy/broot/config/select.hjson"
  } else {
    $"~/.config/broot/config/select.hjson"
  } | path expand)
  if not ($select_hjson | path exists) {
    echo '
      # select.hjson
      verbs: [
          {
              invocation: "ok"
              key: "enter"
              leave_broot: true
              execution: ":print_path"
              apply_to: "file"
          }
      ]' | save $select_hjson
  }
  ^broot --conf $select_hjson
}

def tree [path: path = .] {
  ^broot -c :pt $path
}

def myconfig [] {
  let os = (sys | get host.name)
  if $os == "Windows" {
     nvim ~/.my-functions.nu $"($env.APPDATA)/espanso/default.yml" $"($env.APPDATA)/helix/languages.toml" $"($env.APPDATA)/helix/config.toml" $"($env.APPDATA)/dystroy/broot/config/conf.hjson" $"($env.APPDATA)/dystroy/broot/config/verbs.hjson" $"(($nu.config-path | path parse ).parent)/*.nu"
      
  } else {
     nvim ~/.my-functions.nu ~/.config/helix/languages.toml ~/.config/helix/config.toml "~/.config/broot/config/conf.hjson" "~/.config/broot/config/verbs.hjson" $"(($nu.config-path | path parse ).parent)/*.nu"
      
  }
}

def watch-cwd [] {
  watch . { |op, path, new_path| $"($op) ($path) ($new_path)"}
}

def maxmsp [maxpat: string = ""] {
    `C:\Program Files\Cycling '74\Max 8\Max.exe` ($maxpat | path expand)
}

