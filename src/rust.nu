export alias cbr = cargo build --release
export alias cbd = cargo build --debug

export def "config ra-multiplex" [] {
    match $nu.os-info.name {
        "windows" => { nvim ~/AppData/Roaming/ra-multiplex/config/config.toml },
        _ => { nvim ~/.config/ra-multiplex/config.toml },
    }
}

