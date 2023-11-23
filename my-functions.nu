alias b = nu build.nu
alias todos = nvim ~/todos/todos.md
alias e = nvim 
alias r2 = radare2
alias lg = lazygit

# extracts archives with different extensions
alias extract = ouch decompress

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

def "config weztern" [] {
  nvim ~\src\wezterm-config\wezterm.lua
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



