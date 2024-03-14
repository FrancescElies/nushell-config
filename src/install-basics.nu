use utils.nu ask_yes_no

export def "install for-windows" [] {
  # winget upgrade --slient --all
  try { winget install --silent --id Git.Git }
  try { winget install --silent --id GitHub.cli  }
  try { winget install --silent --id GitHub.GitHubDesktop }
  try { winget install --silent --id wez.wezterm }
}

export def "install for-mac" [] {
 try { brew install gh vlc git neovim restic fd-find ripgrep }
 try { brew install --cask wezterm }
}

export def "install for-debian" [] {
  let debian_pkgs = [
    build-essential clang-16 cmake golang nodejs npm
    curl fail2ban rsync vim vlc wget restic
    fd-find fzf ripgrep bat gh git neovim 
    ffmpeg libasound2-dev rfkill
    printer-driver-splix
    nginx 
    python3.11-full python3-pipdeptree python3-pip
  ]
  
  echo $"apt will install: ($debian_pkgs | path join ' ')"
  sudo apt install -y ...$debian_pkgs

  # https://wezfurlong.org/wezterm/install/linux.html#__tabbed_1_2
  mkdir ~/bin
  cd ~/bin
  wget https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage
  mv WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage wezterm
  chmod +x wezterm
}

# https://github.com/cargo-bins/cargo-binstall?tab=readme-ov-file#manually
def "install cargo-binstall" [] {
  cd (mktemp -d)
  let os_arch =  $nu.os-info.arch # e.g. x86_64
  let url_base = $"https://github.com/cargo-bins/cargo-binstall/releases/download/v1.6.3/"
  let filename = match $nu.os-info.name {
      "windows" => { $"cargo-binstall-($os_arch)-pc-windows-msvc.zip" },
      "linux" => { $"cargo-binstall-($os_arch)-unknown-linux-musl.tgz" },
      "macos" => { $"cargo-binstall-universal-apple-darwin.zip" },
      _ => { error make {msg: "download binstall: os not supported"} },
  }
  let extension = ($filename | path parse | get extension)
  let disk_file = $"tmp.($extension)"
  http get $"($url_base)($filename)" | save -f $disk_file
  match $extension { 
    "zip" => {unzip $disk_file}, 
    _ => {tar -xvzf $disk_file} 
  }
  mkdir ~/bin
  mv cargo-binstall* ~/bin/
}

export def "install python" [] {
  match $nu.os-info.name {
    "windows" => { input $"(ansi purple_bold)Install https://rye-up.com/(ansi reset) once done press enter." },
    _ => { curl -sSf https://rye-up.com/get | bash },
  }
  mkdir ~/.pip/

  # prevent pip from installing packages in the global installation
  "
  [install]
  require-virtualenv = true
  [uninstall]
  require-virtualenv = true
  " | save ~/.pip/pip.conf
}

export def "install rust" [] {

  let filename = match $nu.os-info.name {
      "windows" => { input $"(ansi purple_bold)Install https://rustup.rs/(ansi reset) once done press enter." },
      _ => { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh },
  }

  install cargo-binstall

  let cargo_pkgs = [ tealdeer bat broot bob-nvim diskonaut nu pueue bottom ouch pgen xh mprocs ]
  # py-spy
  echo $"cargo will install: ($cargo_pkgs | path join ' ')"
  cargo binstall -y ...$cargo_pkgs

  bob use nightly

  if (ask_yes_no "Install rust coreutils (might take long)?") { cargo install coreutils }

}

export def "install rust-devtools" [] {
  let cargo_pkgs = [ amber ast-grep fastmod tokei just 
                     git-delta difftastic fnm huniq mdbook 
                     bacon checkexec watchexec-cli hwatch ]
  # py-spy
  echo $"cargo will install: ($cargo_pkgs | path join ' ')"
  cargo binstall -y ...$cargo_pkgs
}

