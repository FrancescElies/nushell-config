# NOTE: other easy installations https://webinstall.dev/trip/

# fast reverse proxy https://github.com/fatedier/frp?tab=readme-ov-file#p2p-mode
use utils.nu ask_yes_no
use symlinks.nu symlink

export def "install for-windows" [] {

  print "window manager https://github.com/LGUG2Z/komorebi"
  print "sysinternals https://learn.microsoft.com/en-us/sysinternals/downloads/"
  # winget upgrade --slient --all

  # random list for windows:
  # Ditto Eartrumpet Xmousebuttoncontrol
  # sketchup8 dupeguru winmerge handbrake

  # available packages at https://github.com/microsoft/winget-pkgs/
  [
    wez.wezterm bmatzelle.Gow gerardog.gsudo charmbracelet.glow
    VideoLAN.VLC SumatraPDF.SumatraPDF
    Casey.Just BurntSushi.ripgrep.MSVC sharkdp.fd junegunn.fzf Nushell.Nushell
    JesseDuffield.lazygit Git.Git GitHub.GitHubDesktop GitHub.GitLFS
    Microsoft.AzureCLI GitHub.cli DBBrowserForSQLite.DBBrowserForSQLite
    Terrastruct.D2
    Flameshot.Flameshot
    Python.Python.3.12 GoLang.Go Rustlang.Rustup
    mesonbuild.meson Ninja-build.Ninja Kitware.CMake Graphviz.Graphviz
    OBSProject.OBSStudio Neovide.Neovide GIMP.GIMP 7zip.7zip Audacity.Audacity
  ] | each {
    try { winget install --silent --id $in }
  }

}

export def "install for-mac" [] {
 try { brew install gh vlc git neovim restic fd ripgrep lazygit cmake fzf meson ninja glow }
 try { brew install --cask wezterm gimp vlc obs neovide neovim nushell flameshot }
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
  print "Easy scrollable window tiling: https://github.com/paperwm/PaperWM"

  let debian_pkgs = [
    build-essential curl fail2ban rsync vim vlc wget restic
    fd-find fzf ripgrep bat gh git neovim
    ffmpeg libasound2-dev rfkill
    printer-driver-splix
    flameshot
  ]

  print $"apt will install: ($debian_pkgs | path join ' ')"
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
  cd ~/.cargo/bin
  http get $"($url_base)($filename)" | save -f $disk_file
  tar -xvzf $disk_file
}

export def "config python" [] {
  mkdir ~/.pip/

  # prevent pip from installing packages in the global installation
  "
  [install]
  require-virtualenv = true
  [uninstall]
  require-virtualenv = true
  " | save -f ~/.pip/pip.conf
}


export def "install-or-upgrade rust" [] {

  if (which rustup | is-empty ) {
    let filename = match $nu.os-info.name {
        "windows" => {
            powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
            input $"(ansi purple_bold)Install https://rustup.rs/(ansi reset) once done press enter."
        },
        _ => {
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
            curl -LsSf https://astral.sh/uv/install.sh | sh
        },
    }
  } else {
    print "rustup already installed"
    rustup upgrade
  }
  rustup component add llvm-tools
  install cargo-binstall

}

