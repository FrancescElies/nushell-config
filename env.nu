# https://github.com/nushell/nushell/blob/main/crates/nu-utils/src/default_files/default_env.nu

# Nushell Environment Config File
#

match $nu.os-info.name {
    "windows" => {
        $env.HOME = ('~' | path expand)
        $env.path ++= [
            '~/AppData/Local/bob/nvim-bin'
            '~/AppData/Roaming/Python/Python312/Scripts'
            '~/AppData/Roaming/Python/Scripts'
            ('/Program Files/WinHTTrack' | path expand)
            ('/Program Files/Neovim/bin' | path expand)
            ('/Program Files/WIBU-SYSTEMS/AxProtector/Devkit/bin' | path expand)
            ('/Program Files/CodeMeter/DevKit/bin' | path expand)
            ('/Program Files/LLVM/bin' | path expand)
            ('/Program Files/nodejs' | path expand)
            ("/Program Files/Cycling '74/Max 9" | path expand)
        ]

        # HACK: appdata not read, `rg YAZI_CONFIG_HOME`
        $env.YAZI_CONFIG_HOME = ("~/src/nushell-config/config/yazi/" | path expand)
    },
    "macos" => {
        $env.path ++= [
            '/opt/homebrew/bin'
            '/usr/local/bin'
            '~/Library/Python/3.12/bin'
        ]
    },
    "linux" => {
        $env.path ++= [
            '/home/linuxbrew/.linuxbrew/bin'
            '/usr/local/bin'
            '/usr/local/go/bin'
            '/var/lib/flatpak/exports/share'
            '~/.local/share/bob/nvim-bin'
            "~/.rye/shims"
            '~/.local/share/flatpak/exports/share'
        ]
    },
    _ => { $env.path = $env.path },
}

# common paths
$env.path ++= [
    '~/.zvm/bin'
    '~/src/radare2/prefix/bin'
    '~/go/bin'
    '~/.cargo/bin'
    '~/.zvm/bin'
    '~/.zvm/bin/self'
    # pipx puts binaries in .local/bin
    '~/.local/bin'
    '~/bin'
]
$env.path ++= ( ls ~/bin | where type == dir | get name )
$env.path ++= ( ls ~/bin/*/bin | get name )
$env.path ++= ( ls /usr/local/*/bin | get name )

$env.path = ($env.path | uniq)


$env.SHELL = "nu"  # makes broot open nu
$env.EDITOR = "nvim"
$env.PYTHONUNBUFFERED = 1
$env.PYTHONBREAKPOINT = "ipdb.set_trace"
$env.RIPGREP_CONFIG_PATH  = ("~/src/nushell-config/src/.ripgreprc" | path expand)

$env.BR_INSTALL = "no"
$env.BROOT_CONFIG_DIR = ("~/src/nushell-config/broot-config" | path expand)

$env.FZF_DEFAULT_COMMAND = "fd --type file --hidden"

$env.RUST_BACKTRACE = 1
# $env.RUSTC_WRAPPER = 'sccache'
