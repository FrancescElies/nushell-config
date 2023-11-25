alias b = nu build.nu
alias todos = nvim ~/todos/todos.md
alias e = nvim 
alias r2 = radare2
alias lg = lazygit

# extracts archives with different extensions
alias extract = ouch decompress

def lsg [] { ls | sort-by type name -i | grid -c | str trim }
alias l = lsg

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



