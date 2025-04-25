# opens nvim
export alias e = nvim
# opens nvim in emergency mode (minimal defaults and no plugins)
export alias ee = nvim -u ~/src/kickstart.nvim/minimal-vimrc.vim

export def "nvim clean-swap" [] {
    match $nu.os-info.name {
        "windows" => { fd swp ~/AppData/Local/nvim-data/swap -x rm },
        _ => { fd swp ~/.local/share/nvim/swap -x rm },
    }
}

export def "nvim pr-files" [] { nvim ...(pr files) }
export def "nvim server" [] { nvim --listen ~/.cache/nvim/server.pipe --headless }
export def "nvim client" [...file: path] { nvim --remote --server ~/.cache/nvim/server.pipe ...$file }

