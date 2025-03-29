set shell := ["nu", "-c"]

default := "bootstrap"

bootstrap:
  nu bootstrap.nu

# create a python virtual environment
home-venv:
  cd ~
  uv venv
  uv pip install ...(open packages.toml | get python | transpose | get column0)


[windows]
install-windows-pkgs: home-venv
 (open packages.toml | get windows | transpose | get column0) | each { try { winget install --silent --id $in } }

# see https://askubuntu.com/questions/645681/samsung-m2020-on-ubuntu#645949
[unix]
install-printer-driver-samsung-M2026:
  sudo cp drivers/Samsung_M2020_Series.ppd /etc/cups/ppd/
  print "you might need to open printer's configuration and add ppd file manually"

[unix]
dont-suspend-ignore-laptop-lid:
  print "see logind.conf -> HandleLidSwitch=ignore"

[unix]
install-debian-pkgs: home-venv
  sudo apt remove -y nano
  sudo apt install -y ...(open packages.toml | get debian | transpose | get column0)

[unix]
install-fedora-pkgs: home-venv
  sudo dnf remove -y nano
  sudo dnf install -y ...(open packages.toml | get fedora | transpose | get column0)

install-rust-pkgs:
  cargo binstall -y ...(open packages.toml | get cargo-pkgs | transpose | get column0)

install-rust-dev-pkgs:
  cargo binstall -y ...(open packages.toml | get dev-cargo-pkgs | transpose | get column0)
