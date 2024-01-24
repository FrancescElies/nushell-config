# See ":help startup-options" for all options.
# export extern nvim [
#   -l: path              # Execute Lua <script> (with optional args)
#   -c: string            # Execute <cmd> after config and first file
#   --cmd: string         # Execute <cmd> before any config
#   -t: string            # edit file where tag is defined
#   -q: path              # edit file with first error
#   -b                    # Binary mode
#   -d                    # Diff mode
#   -e                    # Ex mode
#   --es                  # Silent (batch) mode
#   -i: path              # Use this shada file
#   -m                    # Modifications (writing files) not allowed
#   -M                    # Modifications in text not allowed
#   -n                    # No swap file, use memory only
#   -o: int = 1           # Open N windows (default: one per file)
#   -O: int = 1           # Open N vertical windows (default: one per file)
#   -p: int = 1           # Open N tab pages (default: one per file)
#   -r,                   # List swap files
#   -L                    # List swap files
#   -r:  string           # Recover edit state for this file
#   -R                    # Read-only mode
#   -S: string            # Source <session> after loading the first file
#   -s: string            # Read Normal mode commands from <scriptin>
#   -u: string            # Use this config file
#   --version(-v)         # Print version information
#   --help(-h)            # Print this help message
#   -V: int 1             # Verbose [level][file]
#   --api-info            # Write msgpack-encoded API metadata to stdout
#   --clean               # "Factory defaults" (skip user config and plugins, shada)
#   --embed               # Use stdin/stdout as a msgpack-rpc channel
#   --headless            # Don't start a user interface
#   --listen: string      # Serve RPC API from this address
#   --noplugin            # Don't load plugins
#   --remote-subcommand   # Execute commands remotely on a server
#   --remote              # Execute commands remotely on a server
#   --server: string      # Specify RPC server to send commands to
#   --startuptime: string # Write startup timing messages to <file>
# ]
#
alias e = nvim
