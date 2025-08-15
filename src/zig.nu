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


# // zig cc main.c -o main.exe -lUser32
# #include <windows.h>
#
# int main() {
#     MessageBoxA(NULL, "Hello from Windows API!", "Zig & C", MB_OK);
#     return 0;
# }


export def "zig links" [] {
    [
        [name                 link];
        [zig-guide https://zig.guide/]
        [zig-book https://pedropark99.github.io/zig-book/]
        [zig-lings https://codeberg.org/ziglings/exercises]
        [zig-docs https://ziglang.org/documentation/master/std/]
        [operation-costs-cpucycles  http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/]
        [handles-better-pointers    https://mjtsai.com/blog/2018/06/27/handles-are-the-better-pointers/]
    ]
}
