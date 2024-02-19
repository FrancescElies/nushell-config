alias cbr = cargo build --release
alias cbd = cargo build --debug

def "config ra-multiplex" [] {
    match $nu.os-info.name {
        "windows" => { nvim ~/AppData/Roaming/ra-multiplex/config/config.toml },
        _ => { nvim ~/.config/ra-multiplex/config.toml },
    }
}

