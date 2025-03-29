# NOTE: other easy installations https://webinstall.dev/trip/

# fast reverse proxy https://github.com/fatedier/frp?tab=readme-ov-file#p2p-mode
use utils.nu ask_yes_no
use symlinks.nu symlink



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
        "windows" => { input $"(ansi purple_bold)Install https://rustup.rs/(ansi reset) once done press enter." },
        _ => { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh },
    }
  } else {
    print "rustup already installed"
    rustup upgrade
  }
  rustup component add llvm-tools
  install cargo-binstall

}

