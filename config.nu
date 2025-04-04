# https://github.com/nushell/nushell/blob/main/crates/nu-utils/src/default_files/default_config.nu

# cargo binstall starship
# mkdir ~/.cache/starship
# starship init nu | save -f ~/.cache/starship/init.nu
use ~/.cache/starship/init.nu

source ~/src/nushell-config/src/this-machine.nu

use ~/src/nushell-config/src/my-configs.nu *
use ~/src/nushell-config/src/my-functions.nu *
use ~/src/nushell-config/src/pueue-completions.nu *

use ~/src/nushell-config/src/az.nu *

use ~/src/nushell-config/src/broot-helpers.nu *
use ~/src/nushell-config/src/clipboard.nu *
use ~/src/nushell-config/src/docs.nu *
use ~/src/nushell-config/src/fix.nu *

use ~/src/nushell-config/src/git.nu *
use ~/src/nushell-config/src/git-pr.nu *
use ~/src/nushell-config/src/git-worktree.nu *

use ~/src/nushell-config/src/history-utils.nu *
use ~/src/nushell-config/src/hosts.nu
use ~/src/nushell-config/src/maxmsp-functions.nu *
use ~/src/nushell-config/src/neovim.nu *
use ~/src/nushell-config/src/reverse-eng.nu *
use ~/src/nushell-config/src/rust.nu *
use ~/src/nushell-config/src/symlinks.nu *
use ~/src/nushell-config/src/utils.nu *
use ~/src/nushell-config/src/vpn.nu
use ~/src/nushell-config/src/wibu.nu *

use ~/src/nushell-config/src/ssh-completions.nu *
use ~/src/nushell-config/src/btm-completions.nu *
use ~/src/nushell-config/src/cargo-completions.nu *
use ~/src/nushell-config/src/git-completions.nu *
use ~/src/nushell-config/src/just-completions.nu *
use ~/src/nushell-config/src/miniserve-completions.nu *
use ~/src/nushell-config/src/rg-completions.nu *
use ~/src/nushell-config/src/bat-completions.nu *
use ~/src/nushell-config/src/rustup-completions.nu *
use ~/src/nushell-config/src/vscode-completions.nu *
use ~/src/nushell-config/src/wezterm-completions.nu *

use ~/src/nushell-config/src/fnm.nu *
fnm-setup


# https://www.nushell.sh/blog/2024-12-04-configuration_preview.html
#
# Finding overriden values
#
# let defaults = nu -n -c "$env.config = {}; $env.config | reject color_config keybindings menus | to nuon" | from nuon | transpose key default
# let current = $env.config | reject color_config keybindings menus | transpose key current
# $current | merge $defaults | where $it.current != $it.default

# learning about configuration options
# config nu --default  | nu-highlight

$env.config.show_banner = false
# $env.config.buffer_editor = ["nvim" "-u" "~/src/kickstart.nvim/minimal-vimrc.vim"]
$env.config.buffer_editor = ["nvim"]
$env.config.shell_integration.osc133 = false

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

$env.config.cursor_shape = {
   # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape
   emacs: line
   vi_insert: line
   vi_normal: block
 }

$env.config.edit_mode = "vi" # emacs, vi

$env.config.hooks.env_change = {
    PWD: [
        {
            condition: { |_, after| (
                ( (pwd | path basename) != "nushell-config" )
                and ( (pwd | path basename) != "nushell"  )
                and ( $after | path join env.nu | path exists )
            ) }
            code: "overlay use env.nu"
        }
        {
            |before, after|
                print (pwd);
                if ((ls | length) < 15) { print (lsg) } else { print "folder has +15 files" }
        }
        # windows activate venv
        {
            condition: {|before, after|
                (not ('activate' in (overlay list))) and ($after | path join ".venv/Scripts/activate.nu" | path exists)
            }
            code: 'overlay use .venv/Scripts/activate.nu'
        }
        # unix like activate venv
        {
            condition: {|before, after|
                (not ('activate' in (overlay list))) and ($after | path join ".venv/bin/activate.nu" | path exists)
            }
            code: 'overlay use .venv/bin/activate.nu'
        }
        {
            condition: {|before, after| [.nvmrc .node-version] | path exists | any { |it| $it }}
            code: {|before, after| if ('FNM_DIR' in $env) { fnm use } }
        }
        # https://github.com/nushell/nu_scripts/blob/main/nu-hooks/nu-hooks/rusty-paths/rusty-paths.nu
        {
            condition: {|_, after| ($after | path join 'Cargo.lock' | path exists) }
            code: {
                use std "path add"
                path add ($env.PWD | path join 'target/debug')
                path add ($env.PWD | path join 'target/release')
            }
        }
    ]
}

# The default config record. This is where much of your global configuration is setup.
$env.config.keybindings = [
    # https://www.nushell.sh/blog/2024-05-15-top-nushell-hacks.html
    {
        name: abbr
        modifier: control
        keycode: space
        mode: [emacs, vi_normal, vi_insert]
        event: [
            { send: menu name: abbr_menu }
            { edit: insertchar, value: ' '}
        ]
    }
    {
         name: open_broot
         modifier: control
         keycode: char_b
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "br"
         }
    }
    {
         name: open_lazyGit
         modifier: control
         keycode: char_g
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "lazygit"
         }
    }
    {
         name: find_file_with_Broot
         modifier: control
         keycode: char_b
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "br"
         }
    }
    {
         name: insert_absolute_File_with_Broot
         modifier: control
         keycode: char_a
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "commandline edit --insert (bro)"
         }
    }
    {
         name: insert_File_with_Broot
         modifier: control
         keycode: char_f
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "commandline edit --insert (bro | path expand | path relative-to ('.' | path expand))"
         }
    }
    {
         name: go_Up_to_root_dir
         modifier: control
         keycode: char_u
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "cdroot"
         }
    }
    {
         name: Jump_to_directory
         modifier: control
         keycode: char_j
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "cd (^broot --only-folders --conf ~/src/nushell-config/broot-config/selectdir.hjson)"
         }
   }
]

print $"(ansi pi)ctrl(ansi reset): [(ansi pi)b(ansi reset)]root, [(ansi pi)g(ansi reset)]it, insert-[(ansi pi)a(ansi reset)]bsolute-[(ansi pi)f(ansi reset)]ilepath, [(ansi pi)j(ansi reset)]ump, go [(ansi pi)u(ansi reset)]p, [(ansi pi)space(ansi reset)] expand"

