# https://github.com/nushell/nushell/blob/main/crates/nu-utils/src/default_files/default_config.nu

$env.NU_LIB_DIRS = [
    "~/src/nushell-config/src"
]

# cog -r config.nu
#
# [[[cog
# import cog
# import os, glob
# from pathlib import Path
# nu_files = sorted(Path(x) for x in glob.glob('src/*.nu') if not Path(x).name.startswith("os-"))
# for file in nu_files:
#     this_repo = Path("~/src/nushell-config")
#     cog.outl(f"use {this_repo / file} *".replace('\\', '/'))
# ]]]*/
use ~/src/nushell-config/src/ado-completions.nu *
use ~/src/nushell-config/src/ai-completions.nu *
use ~/src/nushell-config/src/bat-completions.nu *
use ~/src/nushell-config/src/broot-helpers.nu *
use ~/src/nushell-config/src/btm-completions.nu *
use ~/src/nushell-config/src/cargo-completions.nu *
use ~/src/nushell-config/src/clipboard.nu *
use ~/src/nushell-config/src/docs.nu *
use ~/src/nushell-config/src/fd-completions.nu *
use ~/src/nushell-config/src/fix.nu *
use ~/src/nushell-config/src/flamegraph-completions.nu *
use ~/src/nushell-config/src/fnm.nu *
use ~/src/nushell-config/src/gh-completions.nu *
use ~/src/nushell-config/src/git-completions.nu *
use ~/src/nushell-config/src/git-my-alias.nu *
use ~/src/nushell-config/src/git-pr.nu *
use ~/src/nushell-config/src/git-worktree.nu *
use ~/src/nushell-config/src/history-utils.nu *
use ~/src/nushell-config/src/hosts-completions.nu *
use ~/src/nushell-config/src/just-completions.nu *
use ~/src/nushell-config/src/man.nu *
use ~/src/nushell-config/src/maxmsp-completions.nu *
use ~/src/nushell-config/src/media-completions.nu *
use ~/src/nushell-config/src/miniserve-completions.nu *
use ~/src/nushell-config/src/my-configs.nu *
use ~/src/nushell-config/src/my-functions.nu *
use ~/src/nushell-config/src/neovim.nu *
use ~/src/nushell-config/src/nupass.nu *
use ~/src/nushell-config/src/ouch-completions.nu *
use ~/src/nushell-config/src/parse-help.nu *
use ~/src/nushell-config/src/pnpm-completions.nu *
use ~/src/nushell-config/src/process.nu *
use ~/src/nushell-config/src/pueue-completions.nu *
use ~/src/nushell-config/src/pytest-completions.nu *
use ~/src/nushell-config/src/reverse-eng.nu *
use ~/src/nushell-config/src/rg-completions.nu *
use ~/src/nushell-config/src/rust.nu *
use ~/src/nushell-config/src/rustup-completions.nu *
use ~/src/nushell-config/src/ssh-completions.nu *
use ~/src/nushell-config/src/symlinks.nu *
use ~/src/nushell-config/src/ttyper-completions.nu *
use ~/src/nushell-config/src/utils.nu *
use ~/src/nushell-config/src/vpn.nu *
use ~/src/nushell-config/src/wezterm-completions.nu *
use ~/src/nushell-config/src/wibu.nu *
use ~/src/nushell-config/src/winget-completions.nu *
use ~/src/nushell-config/src/work.nu *
use ~/src/nushell-config/src/zellij-completions.nu *
use ~/src/nushell-config/src/zig.nu *
# [[[end]]]


# https://www.nushell.sh/blog/2024-12-04-configuration_preview.html
#
# Finding overridden values
#
# let defaults = nu -n -c "$env.config = {}; $env.config | reject color_config keybindings menus | to nuon" | from nuon | transpose key default
# let current = $env.config | reject color_config keybindings menus | transpose key current
# $current | merge $defaults | where $it.current != $it.default

# learning about configuration options
# config nu --default  | nu-highlight

$env.config.show_banner = true
# $env.config.buffer_editor = ["nvim" "-u" "~/src/kickstart.nvim/minimal-vimrc.vim"]
$env.config.buffer_editor = ["nvim"]
$env.config.shell_integration.osc133 = false
# https://www.nushell.sh/book/custom_completions.html
# $env.config.completions.algorithm = "prefix"
$env.config.completions.algorithm = "fuzzy"

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
   vi_normal: underscore
 }

$env.config.edit_mode = "vi"

def "env-change pwd toolkit" [ --directory ] {
    {
        condition: (if $directory {
            {|_, after| $after | path join 'toolkit' 'mod.nu' | path exists }
        } else {
            {|_, after| $after | path join 'toolkit.nu' | path exists }
        })
        code: ([
            "print -n $'(ansi default_underline)(ansi default_bold)toolkit(ansi reset) module (ansi yellow_italic)detected(ansi reset)... '"
            $"use (if $directory { 'toolkit/' } else { 'toolkit.nu' })"
            "print $'(ansi green_bold)activated!(ansi reset)'"
        ] | str join "\n")
    }
}


$env.config.hooks.env_change = {
    PWD: [
        (env-change pwd toolkit)
        (env-change pwd toolkit --directory)
        {
            condition: { |_, after| (
                ( (pwd | path basename) != "nushell-config" )
                and ( (pwd | path basename) != "nushell"  )
                and ( $after | path join env.nu | path exists )
            ) }
            code: "overlay use env.nu"
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

$env.config.menus = [
    {
      name: abbr_menu
      only_buffer_difference: false
      marker: "👀 "
      type: {
        layout: columnar
        columns: 1
        col_width: 20
        col_padding: 2
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
      source: { |buffer, position|
        scope aliases
        | where name == $buffer
        | each { |elt| {value: $elt.expansion }}
      }
    }
]

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
         name: insert_absolute_File_with_Broot
         modifier: control
         keycode: char_a
         mode: [emacs, vi_normal, vi_insert]
         event: {
           send: executehostcommand,
           cmd: "commandline edit --insert (cd ~; bro)"
         }
    }
    {
        name: fzf_dirs
        modifier: control
        keycode: char_y
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: executehostcommand
            cmd: "
              let FZF_CTRL_Y_COMMAND = \$\"fd --type directory --hidden | fzf --preview 'tree -C {} | head -n 200'\";
              let result = nu -n -c $FZF_CTRL_Y_COMMAND;
              cd $result;
            "
          }
        ]
    }
    {
        name: fzf_files
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: executehostcommand
            cmd: "
              let fzf_ctrl_t_command = \$\"fd --type file --hidden | fzf --preview 'bat --color=always --style=full --line-range=:500 {}' \";
              let result = nu -n -l -i -c $fzf_ctrl_t_command;
              commandline edit --append $result;
              commandline set-cursor --end
            "
          }
        ]
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
           cmd: "zi"
         }
    }
    {
        name: open_editor
        modifier: alt
        keycode: char_e
        mode: [emacs, vi_normal, vi_insert]
        event: { send: executehostcommand, cmd: 'nvim' }
    }
    {
        name: open_editor
        modifier: alt
        keycode: char_b
        mode: [emacs, vi_normal, vi_insert]
        event: { send: executehostcommand, cmd: 'br' }
    }
    {
        name: goto_to_project
        modifier: alt
        keycode: char_p
        mode: [emacs, vi_normal, vi_insert]
        event: {
           send: executehostcommand,
           cmd: ' cd ("~/src" | path expand | path join ( nu-complete projects | get completions | input list --fuzzy $"Goto (ansi mu)project(ansi reset):") )'
        }
   }
   {
       # nu_scripts/custom-menus/fuzzy/modules.nu
       name: fuzzy_module
       modifier: control
       keycode: char_u
       mode: [emacs, vi_normal, vi_insert]
       event: {
           send: executehostcommand
           cmd: '
               commandline edit --replace "use "
               commandline edit --insert (
                   $env.NU_LIB_DIRS
                   | each { |dir| cd $dir; ls *.nu }
                   | flatten
                   | get name
                   | input list --fuzzy
                       $"Please choose a (ansi magenta)module(ansi reset) to (ansi cyan_underline)load(ansi reset):"
               )
           '
       }
   }
   # NOTE: clunky, doesn't work nicely with multiline
   # {
   #     # nu_scripts/custom-menus/fuzzy/history.nu
   #     name: fuzzy_history
   #     modifier: control
   #     keycode: char_h
   #     mode: [emacs, vi_normal, vi_insert]
   #     event: {
   #         send: executehostcommand
   #         cmd: "commandline edit --insert (
   #         history
   #         | each { |it| $it.command }
   #         | uniq
   #         | reverse
   #         | input list --fuzzy
   #         $'Please choose a (ansi magenta)command from history(ansi reset):'
   #         )"
   #     }
   # }
]

# cargo binstall starship
# mkdir ~/.cache/starship
# starship init nu | save -f ~/.cache/starship/init.nu
# https://starship.rs/guide/
#
# mkdir ($nu.data-dir | path join "vendor/autoload")
# starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

source ~/src/nushell-config/src/os-this-machine.nu
source ~/src/nushell-config/zoxide.nu

const ctrl_bindings = [
    $"insert (ansi rb)a(ansi reset)bsolute (ansi rb)f(ansi reset)ile path"
    $"(ansi rb)j(ansi reset)ump"
    $"(ansi rb)u(ansi reset)se \(fuzzy\)"
    $"(ansi rb)space(ansi reset) \(expands alias\)"
]
const alt_bindings = [
    $"(ansi yb)p(ansi reset)roject"
    $"open (ansi yb)e(ansi reset)ditor"
    $"(ansi yb)b(ansi reset)root"
]
print $"(ansi defb)ctrl-i(ansi reset): (ansi defr)TAB(ansi reset), (ansi defb)ctrl-m(ansi reset): (ansi defr)ENTER(ansi reset), (ansi defb)ctrl-[(ansi reset): (ansi defr)ESC(ansi reset)"
print $"(ansi rb)ctrl(ansi reset): ($ctrl_bindings | str join ', ')"
print $"(ansi yb)alt(ansi reset): open ($alt_bindings | str join ', ')"

