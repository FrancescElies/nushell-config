# https://www.youtube.com/watch?v=YXrb-DqsBNU
# You add one dependency but you can remove one cmake e.g.

# gives you hermetic builds, so that you don't have to depend on what's on the system.
# c/c++ drop in dropin replacement compailer
# zig cc
# enables ubasn by default
# -Werror -Wall -Wextra -fsanitize=undefined,address

# cross compilation
# zig cc -o hello hello.c -target x86_64-windows
# zig cc -o hello hello.c -target aarch64-macos
# zig cc -o hello hello.c -target aarch64-macos
# zig cc -o hello hello.c -target aarch-linux-gnu.2.31
# zig cc -o hello hello.c -target aarch-linux-musl  # creates a statib build, doesn't dyn link libc, distro independent

# built-in caching
# example building a c project
# https://github.com/facebook/zstd
# zig build-lib --name zstd -lc ...(ls lib/**/*c | get name)

# zi build system
# zig build --help 
# will show user defined flags in the help too


# mixing zig and c
# dumpCurrentStackTrace will show c and zig code
# zig build -Drelease-fast
# objdump -d zig-out/bin/foo -Minterl | vim
