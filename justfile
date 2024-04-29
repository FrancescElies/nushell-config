set shell := ["nu", "-c"]

default := "bootstrap"

bootstrap:
  nu bootstrap.nu

# create a python virtual environment
venv:
  uv venv

# requirements.in
compile-requirements:
  uv pip compile requirements.in -o requirements.txt

sync-requirements:
  uv pip sync requirements.txt
