export def "install-basics debian" [] {
  let debian_pkgs = [
    build-essential clang-16 cmake golang nodejs npm
    curl fail2ban rsync vim vlc wget restic
    fd-find fzf ripgrep bat gh git neovim 
    ffmpeg libasound2-dev rfkill
    printer-driver-splix
    nginx 
    python3.11-full python3-pipdeptree python3-pip virtualenv
  ]
  
  echo $"apt will install: ($debian_pkgs | path join ' ')"
  sudo apt install -y ...$debian_pkgs

  # https://wezfurlong.org/wezterm/install/linux.html#__tabbed_1_2
  mkdir ~/bin
  wget https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage
  mv WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage wezterm
  chmod +x wezterm
}

export def "install-basics rust" [] {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  # https://github.com/cargo-bins/cargo-binstall?tab=readme-ov-file#manually
  # or install with cargo
  cargo install cargo-binstall

  let cargo_pkgs = [amber ast-grep bacon bat broot btm git-delta difftastic diskonaut fastmod fnm huniq hwatch just mdbook mprocs nu ouch pgen py-spy skim tealdeer tokei watchexec-cli xh pueue bob-nvim]
  echo $"cargo will install: ($cargo_pkgs | path join ' ')"
  cargo binstall -y ...$cargo_pkgs

  bob use nightly

  cargo install coreutils
  cargo install --git https://github.com/astral-sh/rye rye

}

