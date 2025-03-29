set shell := ["nu", "-c"]

default := "bootstrap"

bootstrap:
  nu bootstrap.nu
  print $"Now you can e.g. (ansi lyu)just fedora-pkgs(ansi reset) or (ansi lyu)just debian-pkgs(ansi reset) or (ansi lyu)just windows-pkgs(ansi reset)"
  print $"Later on e.g. (ansi lyu)just rust-pkgs(ansi reset) and/or (ansi lyu)just rust-dev-pkgs(ansi reset)"

# create a python virtual environment
home-venv: bootstrap
  # NOTE: cd not honored between lines, thus everything in one line
  let pkgs = (open packages.toml | get python | transpose | get column0); cd ~; uv venv; uv pip install ...$pkgs


[windows]
windows-pkgs: home-venv
  (open packages.toml | get windows | transpose | get column0) | each { try { winget install --silent --id $in } }

# https://blog.xoria.org/macos-tips/
[macos]
mac-pkgs: home-venv
  brew install ...(open packages.toml | get mac-brew | transpose | get column0)
  brew install --cask ...(open packages.toml | get mac-brew-cask | transpose | get column0)

# see https://askubuntu.com/questions/645681/samsung-m2020-on-ubuntu#645949
[unix]
printer-driver-samsung-M2026:
  sudo cp drivers/Samsung_M2020_Series.ppd /etc/cups/ppd/
  print "you might need to open printer's configuration and add ppd file manually"

[unix]
dont-suspend-ignore-laptop-lid:
  print "see logind.conf -> HandleLidSwitch=ignore"

[unix]
debian-pkgs: home-venv
  sudo apt remove -y nano
  sudo apt install -y ...(open packages.toml | get debian | transpose | get column0)
  sudo systemctl enable syncthing@cesc.service

[unix]
fedora-pkgs: home-venv
  sudo dnf remove -y nano
  sudo dnf install -y ...(open packages.toml | get fedora | transpose | get column0)
  sudo systemctl enable syncthing@cesc.service

[private]
[windows]
rustup:
  if (which ^rustup | is-empty ) { input $"(ansi purple_bold)Install https://rustup.rs/(ansi reset) once done press enter." }

[private]
[unix]
rustup:
  if (which ^rustup | is-empty ) { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh }

[private]
rustup-tooling: rustup
  rustup component add llvm-tools rust-analyzer

[private]
cargo-binstall: rustup-tooling
  if (which ^cargo-binstall | is-empty ) { cargo install cargo-binstall }

rust-pkgs: cargo-binstall
  cargo binstall -y ...(open packages.toml | get rust-pkgs | transpose | get column0)

rust-dev-pkgs: cargo-binstall
  cargo binstall -y ...(open packages.toml | get rust-dev-pkgs | transpose | get column0)
