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
              cd ( fd --type directory --hidden
                   | fzf --preview 'tree -C {} | head -n 200');
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
              commandline edit --append (
                fd --type file --hidden
                | fzf --preview 'bat --color=always --style=full --line-range=:500 {}'
              );
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

