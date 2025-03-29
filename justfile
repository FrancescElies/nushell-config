set shell := ["nu", "-c"]

default := "bootstrap"

bootstrap:
  nu bootstrap.nu

# create a python virtual environment
venv-home:
  cd ~
  uv venv
  uv pip install ...(open packages.toml | get python | transpose | get column0)

# requirements.in
compile-requirements:
  uv pip compile requirements.in -o requirements.txt

sync-requirements:
  uv pip sync requirements.txt

install-windows-pkgs:
 (open packages.toml | get windows | transpose | get column0) | each { try { winget install --silent --id $in } }

install-debian-pkgs:
  sudo apt install -y ...(open packages.toml | get debian | transpose | get column0)

install-fedora-pkgs:
  sudo dnf install -y ...(open packages.toml | get fedora | transpose | get column0)

install-rust-pkgs:
  cargo binstall -y ...(open packages.toml | get cargo-pkgs | transpose | get column0)

install-rust-dev-pkgs:
  cargo binstall -y ...(open packages.toml | get dev-cargo-pkgs | transpose | get column0)
