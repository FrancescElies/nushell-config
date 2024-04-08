# NOTE: other easy installations https://webinstall.dev/trip/

# fast reverse proxy https://github.com/fatedier/frp?tab=readme-ov-file#p2p-mode
use utils.nu ask_yes_no 
use symlinks.nu symlink

export def "install for-windows" [] {

  echo "window manager https://github.com/LGUG2Z/komorebi"
  echo "sysinternals https://learn.microsoft.com/en-us/sysinternals/downloads/"
  # winget upgrade --slient --all

  [ 
    wez.wezterm bmatzelle.Gow gerardog.gsudo 
    VideoLAN.VLC GitHub.cli SumatraPDF.SumatraPDF 
    BurntSushi.ripgrep.MSVC sharkdp.fd junegunn.fzf Nushell.Nushell 
    Git.Git GitHub.cli  GitHub.GitHubDesktop GitHub.GitLFS Microsoft.AzureCLI 
    Python.Python.3.12 GoLang.Go Rustlang.Rustup
    mesonbuild.meson Ninja-build.Ninja
    OBSProject.OBSStudio Neovide.Neovide GIMP.GIMP 7zip.7zip Audacity.Audacity
  ] | each {
    try { winget install --silent --id $in }
  }
  
}

export def "install for-mac" [] {
 try { brew install gh vlc git neovim restic fd-find ripgrep }
 try { brew install --cask wezterm }
}

export def "install custom-pkgs for-debian" [] {
  mkdir ~/.local/share/applications
  
  # gnome apps
  (ls ~/src/nushell-config/src/linux/gnome-apps/*.desktop 
  | get name 
  | each { |it| symlink $it ("~/.local/share/applications" | path join ($it | path basename))}
  )

  mkdir ~/bin
  cd ~/bin

  # NOTE: dowload localsend
  wget https://github.com/localsend/localsend/releases/download/v1.14.0/LocalSend-1.14.0-linux-x86-64.AppImage
  mv LocalSend-1.14.0-linux-x86-64.AppImage localsend
  let sha256 = (open localsend | hash sha256)
  if ($sha256 != "e89e885a1de2122dbe5b2b7ec439dca00accee1e63237d4685946a48a35ca8d2") { 
    rm localsend 
    error make {msg: "localsend hash missmatch"}
  }

  # NOTE: dowload wezterm
  # https://wezfurlong.org/wezterm/install/linux.html#__tabbed_1_2
  wget https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22-ubuntu20.04.appimage
  mv wezterm-20240203-110809-5046fc22-ubuntu20.04.appimage wezterm
  let sha256 = (open wezterm | hash sha256)
  if ($sha256 != "34010a07076d2272c4d4f94b5e0dae608a679599e8d729446323f88f956c60f0") { 
    rm wezterm 
    error make {msg: "wezterm hash missmatch"}
  }
  chmod +x wezterm
}

export def "install pkgs for-debian" [] {
  echo "Easy scrollable window tiling: https://github.com/paperwm/PaperWM"

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
  " | save -f ~/.pip/pip.conf
}

export def "install rust" [] {

  let filename = match $nu.os-info.name {
      "windows" => { input $"(ansi purple_bold)Install https://rustup.rs/(ansi reset) once done press enter." },
      _ => { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh },
  }

  install cargo-binstall

  let cargo_pkgs = [ 
    kondo tealdeer bat broot bob-nvim diskonaut 
    nu pueue bottom ouch pgen mprocs fclones
    trippy miniserve rustscan xh 
  ]
  # py-spy
  echo $"cargo will install: ($cargo_pkgs | path join ' ')"
  cargo binstall -y ...$cargo_pkgs

  bob use nightly

  if (ask_yes_no "Install rust coreutils (might take long)?") { cargo install coreutils }

}

export def "install rust-devtools" [] {
  let cargo_pkgs = [ amber ast-grep fastmod tokei just secure_remove
                     git-delta difftastic fnm huniq mdbook 
                     bacon checkexec watchexec-cli hwatch ]
  # py-spy
  echo $"cargo will install: ($cargo_pkgs | path join ' ')"
  cargo binstall -y ...$cargo_pkgs
}

