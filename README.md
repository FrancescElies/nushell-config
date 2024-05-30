# nushell-config

## Install
Install just https://github.com/casey/just?tab=readme-ov-file#packages

```nu
mkdir ~/src
git clone https://github.com/FrancescElies/nushell-config ~/src/nushell-config
cd ~/src/nushell-config
just bootstrap
```

Few scripts need python (optional)
```nu
uv venv
uv pip sync requirements.txt
```

# Rust
Doesn't belong here but who cares

- https://ia0.github.io/unsafe-mental-model/what-are-types.html

# Plugins
```
cargo install nu_plugin_port_list
register ~/.cargo/bin/nu_plugin_port_list

cargo install nu_plugin_dns
register ~/.cargo/bin/nu_plugin_dns

```
## Links
- https://www.nushell.sh/blog/2023-08-23-happy-birthday-nushell-4.html
- https://github.com/dandavison/nushell-config
- https://github.com/nushell/nu_scripts

