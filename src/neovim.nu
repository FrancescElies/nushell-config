export alias e = nvim
export alias nv = nvim
export alias ee = nvim -u ~/src/kickstart.nvim/minimal-vimrc.vim
export alias nvim-emergency = nvim -u ~/src/kickstart.nvim/minimal-vimrc.vim
export alias nve = nvim -u ~/src/kickstart.nvim/minimal-vimrc.vim

export def "nvim clean shada" [] {
    match $nu.os-info.name {
        "windows" => { fd swp ~/AppData/Local/nvim-data/swap -x rm },
        _ => { rm -rf ~/.local/state/nvim/shada },
    }
}
export def "nvim clean swap" [] {
    match $nu.os-info.name {
        "windows" => { fd swp ~/AppData/Local/nvim-data/swap -x rm },
        _ => { fd swp ~/.local/state/nvim/swap -x rm },
    }
}

export def "nvim pr-files" [] { nvim ...(pr files) }
export def "nvim server" [] { nvim --listen ~/.cache/nvim/server.pipe --headless }
export def "nvim client" [...file: path] { nvim --remote --server ~/.cache/nvim/server.pipe ...$file }

