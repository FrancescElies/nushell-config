# https://github.com/nushell/nu_scripts/blob/main/custom-completions/zellij/zellij-completions.nu

def "nu-complete subcommands" [] {
    ^zellij --help | lines
    | skip until {$in == SUBCOMMANDS:} | skip 1
    | str trim | into string
    | split column  -c --regex '  ' value description
}

def "nu-complete zellij" [] {
    [
        [ value    description];
        [ action              "Send actions to a specific session [aliases: ac]" ]
        [ attach              "Attach to a session [aliases: a]" ],
        [ convert-config      "" ],
        [ convert-layout      "" ],
        [ convert-theme       "" ],
        [ delete-all-sessions "Delete all sessions [aliases: da]" ],
        [ delete-session      "Delete a specific session [aliases: d]" ],
        [ edit                "Edit file with default $EDITOR / $VISUAL [aliases: e]" ],
        [ help                "Print this message or the help of the given subcommand(s)" ],
        [ kill-all-sessions   "Kill all sessions [aliases: ka]" ],
        [ kill-session        "Kill the specific session [aliases: k]" ],
        [ list-sessions       "List active sessions [aliases: ls]" ],
        [ options             "Change behaviour of zellij" ],
        [ pipe                "Send data to one or more plugins, launch them if they are not running" ],
        [ plugin              "Load a plugin [aliases: p]" ],
        [ run                 "Run a command in a new pane [aliases: r]" ],
        [ setup               "Setup zellij and check its configuration" ],
        # Aliases
        [ ac                  "Alias for `action`" ],
        [ a                   "Alias for `attach`" ],
        [ e                   "Alias for `edit`" ],
        [ da                  "Alias for `delete-all-sessions`" ],
        [ d                   "Alias for `delete-session`" ],
        [ ka                  "Alias for `kill-all-sessions`" ],
        [ k                   "Alias for `kill-session`" ],
        [ ls                  "Alias for `list-sessions`" ],
        [ p                   "Alias for `plugin`" ],
        [ r                   "Alias for `run`" ],
    ]
}

def "nu-complete zellij action" [] {
    [
        [ value                         description              ];
        [ close-pane                    "Close the focused pane" ]
        [ close-tab                     "Close the current tab" ]
        [ dump-screen                   "Dump the focused pane to a file" ]
        [ edit                          "Open the specified file in a new zellij pane with your default EDITOR" ]
        [ edit-scrollback               "Open the pane scrollback in your default editor" ]
        [ focus-next-pane               "Change focus to the next pane" ]
        [ focus-previous-pane           "Change focus to the precvious pane" ]
        [ go-to-next-tab                "Go to the next tab" ]
        [ go-to-previous-tab            "Go to the previous tab" ]
        [ go-to-tab                     "Go to tab with index [index]" ]
        [ half-page-scroll-down         "Scroll down half page in focus pane" ]
        [ half-page-scroll-up           "Scroll up half page in focus pane" ]
        [ help                          "Print this message or the help of the given subcommand(s)" ]
        [ move-focus                    "Move the focused pane in the specified direction. [right|left|up|down]" ]
        [ move-focus-or-tab             "Move focus to the pane or tab (if on screen edge) in the specified direction. [right|left|up|down]" ]
        [ move-pane                     "Change the location of the focused pane in the specified direction. [right|left|up|down]" ]
        [ new-pane                      "Open a new pane in the specified direction. [right|down] If no direction specified, will try to use the biggest available space" ]
        [ new-tab                       "Create a new tab, optionally with a specified tab layout and name" ]
        [ page-scroll-down              "Scroll down one page in focus pane" ]
        [ page-scroll-up                "Scroll up one page in focus pane" ]
        [ rename-pane                   "Renames the focused pane" ]
        [ rename-tab                    "Renames the focused tab" ]
        [ resize                        "Resize the focused pane in the specified direction. [right|left|up|down|+|-]" ]
        [ scroll-down                   "Scroll down to the bottom in focus pane" ]
        [ scroll-up                     "Scroll up in the focused pane" ]
        [ switch-mode                   "Switch input mode of all connected clients [locked|pane|tab|resize|move|search|session]" ]
        [ toggle-active-sync-tab        "Toggle between sending text commands to all panes on the current tab and normal mode" ]
        [ toggle-floating-panes         "Toggle visibility of all floating panes in the current tab, open one if none exist" ]
        [ toggle-fullscreen             "Toggle between fullscreen focus pane and normal layout" ]
        [ toggle-pane-embed-or-floating "Embed focused pane if floating or float focused pane if embedded" ]
        [ toggle-pane-frames            "Toggle frames around panes in the UI" ]
        [ undo-rename-pane              "Remove a previously set pane name" ]
        [ undo-rename-tab               "Remove a previously set tab name" ]
        [ write                         "Write bytes to the terminal" ]
        [ write-chars                   "Write characters to the terminal" ]
    ]
}

def "nu-complete zellij attach" [] {
    [
        [value    description];
        [ help    "Print this message or the help of a given subcommand(s)" ]
        [ options "Change the behaviour of zellij" ]
    ]
}

def "nu-complete sessions" [] {
    ^zellij ls -n | lines | parse "{value} {description}"
}

def "nu-complete zellij layouts" [] {
    let layout_dir = if 'ZELLIJ_CONFIG_DIR' in $env {
        [$env.ZELLIJ_CONFIG_DIR "layouts"] | path join
    } else {
        match $nu.os-info.name {
            "linux" => "~/.config/zellij/layouts/"
            "macos" => {
                if ("~/.config/zellij/layouts/" | path exists) {
                    "~/.config/zellij/layouts/"
                } else {
                    "~/Library/Application Support/org.Zellij-Contributors.Zellij/layouts"
                }
            }
            _ => (error make { msg: "Unsupported OS for zellij" })
        }
    }

    ls ( $layout_dir | path expand )
    | where name =~ "\\.kdl"
    | get name
    | each { |$it| { value: ($it | path basename | str replace ".kdl" ""), description: $it } }
}

# Turned off since it messes with sub-commands
#export extern "zellij" [
#  command?: string@"nu-complete zellij"
#  --config(-c)          # <CONFIG> Change where zellij looks for the configuration file [env: ZELLIJ_CONFIG_FILE=]
#  --config-dir          # <CONFIG_DIR> Change where zellij looks for the configuration directory [env: ZELLIJ_CONFIG_DIR=]
#  --debug(-d)           # Specify emitting additional debug information
#  --data-dir            # <DATA_DIR> Change where zellij looks for plugins
#  --help(-h)            # Print help message
#  --layout(-l)          # <LAYOUT> Name of a predefined layout inside the layout directory or the path to a layout file
#  --max-panes           # <MAX_PANES> Maximum panes on screen, caution: opening more panes will close old ones
#  --sessions(-s)        # <SESSION> Specify name of a new session
#  --version(-v)         # Print version information
#]

# Send actions to a specific session
export extern "zellij action" [
    command: string@"nu-complete zellij action"
    --help(-h) # Print help information
]

# Renames the focused tab
export extern "zellij action rename-tab" [
    name: string # Name for the tab
]

# Create a new tab, optionally with a specified tab layout and name
export extern "zellij action new-tab" [
    --cwd(-c): path # Change the working directory of the new tab
    --help(-h) # Print help information
    --layout(-l): string@"nu-complete zellij layouts" # Layout to use for the new tab
    --layout-dir: path # Default folder to look for layouts
    --name(-n): string # Name for the tab
]

# Attach to a session
export extern "zellij attach" [
    session_name?: string@"nu-complete sessions" # Name of the session to attach to
    command?: string@"nu-complete zellij attach"
    --create(-c) # Create a session if one does not exist
    --help(-h)   # Print help information
    --index      # <INDEX> Number of the session index in the active sessions ordered by creation date
]

# <OLD_CONFIG_FILE>
export extern "zellij convert-config" [
    file: path
    --help(-h) # Print help information
]

# <OLD_LAYOUT_FILE>
export extern "zellij convert-layout" [
    file: path
    --help(-h) # Print help information
]

# <OLD_THEME_FILE>
export extern "zellij convert-theme" [
    file: path
    --help(-h) # Print help information
]

def "nu-complete directions" [] {
    [ "right" "left" "down" "up" ]
}

# Edit file with default $EDITOR / $VISUAL
export extern "zellij edit" [
    file: path
    --cwd: path                                      # <CWD> Change the working directory of the editor
    --direction(-d): string@"nu-complete directions" # <DIRECTION> Direction to open the new pane in
    --floating(-f)                                   # Open the new pane in floating mode
    --help(-h)                                       # Print help information
    --line-number(-l): number                        # <LINE_NUMBER> Open the file in the specified line number
]

# Print this message or the help of the given subcommand(s)
export extern "zellij help" [
    command?: string@"nu-complete subcommands"
]

# Delete all sessions
export extern "zellij delete-all-sessions" [
    --force(-f) # Kill the sessions if they're running before deleting them
    --help(-h)  # Print help information
    --yes(-y) # Automatic yes to prompts
]

# Delete the specific session
export extern "zellij delete-session" [
    session_name: string@"nu-complete sessions" # <TARGET_SESSION> Name of target session
    --force(-f) # Kill the sessions if they're running before deleting them
    --help(-h)  # Print help information
]

# Kill all sessions
export extern "zellij kill-all-sessions" [
    --help(-h) # Print help information
    --yes(-y)  # Automatic yes to prompts
]

# Kill the specific session
export extern "zellij kill-session" [
    session_name: string@"nu-complete sessions" # <TARGET_SESSION> Name of target session
    --help(-h) # Print help information         # Print help information
]

# List active sessions
export extern "zellij list-sessions" [
    --help(-h) # Print help information
]

def "nu-complete string bools" [] {
    [ "'true'" "'false'" ]
}

def "nu-complete option copy-clipboard" [] {
    [ "system", "primary" ]
}

def "nu-complete option on-force-close" [] {
    [ "quit" "detach" ]
}

# Change the behaviour of zellij
export extern "zellij options" [
    --attach-to-session: string@"nu-complete string bools" # Whether to attach to a session specified in "session-name" if it exists [possible values: true, false]
    --copy-clipboard: string@"nu-complete option copy-clipboard" # OSC52 destination clipboard [possible values: system, primary]
    --copy-command: string # <COPY_COMMAND> Switch to using a user supplied command for clipboard instead of OSC52
    --copy-on-select: string@"nu-complete string bools" # Automatically copy when selecting text (tru or false) [possible values: true, false]
    --default-layout # <DEFAULT_LAYOUT> Set the default layout
    --default-mode # <DEFAULT_MODE> Set the default mode
    --default-shell # <DEFAULT_SHELL> Set the default shell
    --disable-mouse-mode # Disable handling of mouse events
    --help(-h) # Print help information
    --layout-dir: path # <LAYOUT_DIR> Set the layout_dir, defaults to subdirectory of config dir
    --mirror-session: string@"nu-complete string bools" # Mirror session when multiple users are connected (true or false) [possible values: true, false]
    --mouse-mode: string@"nu-complete string bools" # <MOUSE_MODE> Set the handling of mouse events (true or false) Can be temporarily bypassed by the [SHIFT] key [possible values: true, false]
    --on-force-close: string@"nu-complete option on-force-close" # <ON_FORCE_CLOSE> Set behaviour on force close (quit or detach)
    --pane-frames: string@"nu-complete string bools" # <PANE_FRAMES> Set display of pane frames (true or false) [possible values: true, false]
    --scroll-buffer-size: any # <SCROLL_BUFFER_SIZE>
    --scrollback-editor: path # <SCROLLBACK_EDITOR> Explicit full path to open the scrollback editor (default is $EDITOR or $VISUAL)
    --session-name: string # <SESSION_NAME> The name of the session to create when starting Zellij
    --simplified-ui: string@"nu-complete string bools" # <SIMPLIFIED_UI> Allow plugins to use a more simplified layout that is compatible with more fonts (true or false) [possible values: true, false]
    --theme: string # <THEME> Set the default theme
    --theme-dir: path # <THEME_DIR> Set the theme_dir, defaults to subdirectory of config dir
]

# Send data to one or more plugins, launch them if they are not running
export extern "zellij pipe" [
    --name(-n): string # <NAME> The name of the pipe
    --args(-a): string # <ARGS> The args of the pipe
    --plugin(-p): string # <PLUGIN> The plugin url (eg. file:/tmp/my-plugin.wasm) to direct this pipe to, if not specified, will be sent to all plugins, if specified and is not running, the plugin will be launched
    --plugin-configuration(-c): string # <PLUGIN_CONFIGURATION> The plugin configuration (note: the same plugin with different configuration is considered a different plugin for the purposes of determining the pipe destination)
    --help(-h) # Print help information
]

# Load a plugin
export extern "zellij plugin" [
    --configuration(-c): string # <CONFIGURATION> Plugin configuration
    --floating(-f) # Open the new pane in floating mode
    --help(-h) # Print help information
    --height: any # <HEIGHT> The height if the pane is floating as a bare integer (eg. 1) or percent (eg. 10%)
    --in-place(-i) # Open the new pane in place of the current pane, temporarily suspending it
    --skip-plugin-cache(-s) # Skip the memory and HD cache and force recompile of the plugin (good for development)
    --width: any # <WIDTH> The width if the pane is floating as a bare integer (eg. 1) or percent (eg. 10%)
    --x(-x): any # <X> The x coordinates if the pane is floating as a bare integer (eg. 1) or percent (eg. 10%)
    --y(-y): any # <Y> The y coordinates if the pane is floating as a bare integer (eg. 1) or percent (eg. 10%)
]


# Run a command in a new pane
export extern "zellij run" [
    command: string # Command to run
    --close-on-exit(-c) # Close the pane immediately when its command exits
    --cwd: path # <CWD> Change the working directory of th new pane
    --direction(-d): string@"nu-complete directions" # <DIRECTION> Direction to open new pane in
    --floating(-f) # Open the new pane in floating mode
    --help(-h) # Print help information
    --name(-n): string # <NAME> Name of the new pane
    --start-suspended(-s) # Start the command suspended, only running after you first presses ENTER
]

export extern "zellij setup" [
    --check # Checks the configuration of zellij and displays currently used directories
    --clean # Disables loading of configuration file at default location, loads the defaults that zellij ships with
    --dump-config # Dump the default configuration file to stdout
    --dump-layout: string # <DUMP_LAYOUT> Dump the specified layout file to stdout
    --generate-auto-start: string # Generates auto-start for the specified shell
    --generate-completion: string # Generates completion for the specified shell
    --help(-h) # Print help information
]
