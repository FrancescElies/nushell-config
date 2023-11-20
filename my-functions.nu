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

# Create a symlink
export def symlink [
    existing: path   # The existing file
    link_name: path  # The name of the symlink
] {
    let existing = ($existing | path expand -s)
    let link_name = ($link_name | path expand)

    if $nu.os-info.family == 'windows' {
        if ($existing | path type) == 'dir' {
            mklink /D $link_name $existing
        } else {
            mklink $link_name $existing
        }
    } else {
        ln -s $existing $link_name | ignore
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

def maxmsp [maxpat: string = ""] {
    `C:\Program Files\Cycling '74\Max 8\Max.exe` ($maxpat | path expand)
}
def "maxmsp dumps" [] {
  cd `~/AppData/Roaming/Cycling '74/Logs`
}
def "maxmsp open-latest-dump" [] {
  let latest_dump = (ls `~/AppData/Roaming/Cycling '74/Logs` | sort-by modified | last)
  start $latest_dump.name
}


