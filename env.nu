# https://github.com/nushell/nushell/blob/main/crates/nu-utils/src/default_files/default_env.nu

# Nushell Environment Config File
#
# version = "0.92.2"

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
# $env.ENV_CONVERSIONS = {
#     "PATH": {
#         from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
#         to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
#     }
#     "Path": {
#         from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
#         to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
#     }
# }

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)

match $nu.os-info.name {
    "windows" => {
        $env.HOME = ('~' | path expand)
        path add '~/AppData/Local/bob/nvim-bin'
        path add '~/AppData/Roaming/Python/Python312/Scripts'
        path add '~/AppData/Roaming/Python/Scripts'
        path add 'c:/Program Files/Neovim/bin'
        path add ('/Program Files/WIBU-SYSTEMS/AxProtector/Devkit/bin' | path expand)
        path add ('/Program Files/CodeMeter/DevKit/bin' | path expand)
        path add ("/Program Files/Cycling '74/Max 9/" | path expand)

        # HACK: appdata not read, `rg YAZI_CONFIG_HOME`
        $env.YAZI_CONFIG_HOME = ("~/src/nushell-config/config/yazi/" | path expand)

        # const perl_dir = '~/src/oss/strawberry-perl-5.40.0.1-RC1-64bit-portable/strawberry-perl-5.40.0.1-RC1-64bit-portable/'
        # path add ($perl_dir | path join 'perl\site\bin' | path expand)
        # path add ($perl_dir | path join 'perl\bin' | path expand)
        # path add ($perl_dir | path join 'c\bin' | path expand)
    },
    "macos" => {
        path add '/opt/homebrew/bin'
        path add '/usr/local/bin'
        path add '~/Library/Python/3.12/bin'
    },
    "linux" => {
        path add '/home/linuxbrew/.linuxbrew/bin'
        path add '/usr/local/bin'
        path add '/usr/local/go/bin'
        path add '/var/lib/flatpak/exports/share'
        path add '~/.local/share/bob/nvim-bin'
        path add "~/.rye/shims"
        path add '~/.local/share/flatpak/exports/share'
    },
    _ => { $env.PATH = $env.PATH },
}

# common paths
path add '~/src/radare2/prefix/bin'
path add '~/go/bin'
path add '~/.cargo/bin'
# pipx puts binaries in .local/bin
path add '~/.local/bin'

path add '~/bin'
mkdir ~/bin/dummy/bin
# add all ~/bin/* to PATH
path add (ls ~/bin | where type == dir | get name)
# add all ~/bin/*/bin to PATH
path add ( ls ~/bin/*/* | where type == dir | get name | where {$in|str ends-with "bin"} )

match $nu.os-info.name {
    "windows" => { $env.Path = ($env.Path | uniq) },
    _ => { $env.PATH = ($env.PATH | uniq) },
}


$env.SHELL = "nu"  # makes broot open nu
$env.EDITOR = "nvim"
$env.PYTHONUNBUFFERED = 1
$env.PYTHONBREAKPOINT = "ipdb.set_trace"
$env.RUST_BACKTRACE = 1
$env.RIPGREP_CONFIG_PATH  = ("~/src/nushell-config/src/.ripgreprc" | path expand)

$env.BR_INSTALL = "no"
$env.BROOT_CONFIG_DIR = ("~/src/nushell-config/broot-config" | path expand)


if $nu.os-info.name == "windows" {
    # cd ~/src/oss; git clone https://github.com/microsoft/vcpkg.git
    # cd vcpkg; ./bootstrap-vcpkg
    $env.VCPKG_ROOT = ("~/src/oss/vcpkg" | path expand)
    path add $env.VCPKG_ROOT
    # https://github.com/sfackler/rust-openssl
    # https://stackoverflow.com/questions/50625283/how-to-install-openssl-in-windows-10
    $env.X86_64_PC_WINDOWS_MSVC_OPENSSL_DIR = 'C:\Program Files\OpenSSL-Win64'
}

# $env.RUSTC_WRAPPER = 'sccache'
