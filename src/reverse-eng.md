# Radare2
https://rada.re/n/radare2.html

```
# ~/.radare2rc  or `ed` in r2
e asm.pseudo = true
e cfg.fortunes = false
e cmd.stack = true
e scr.utf8 = true
e asm.describe = true

# stack and register values on top of disasembly view (visual mode)
e cmd.stack = true

# comments at right of disassembly
e asm.cmt.right=true

# Shows pseudocode in disassembly. Eg mov eax, str.ok = > eax = str.ok
e asm.pseudo = true

# Relocs
# e bin.cache=true

```

## usage
cli
```
$ rasm2 -a arm -b 32 -d `rasm2 -a arm -b 32 nop`
$ rabin2 -Ss /bin/ls  # list symbols and sections
$ rahash2 -a md5 /bin/ls
$ rafind2 -x deadbeef bin
```
Some common commands
```
$ r2 /bin/ls
> aaa    # analyze all the things
> is     # list symbols
> afl    # list functions found
> pdf    # disassemble function, e.g. pdf @ sym.main
> s <tab># seek to address
> v      # enter visual panels mode
> p      # cycle modes visual modes (visual mode)
> ood    # reload program
```

## plugins
```
$ r2pm update
$ r2pm -i r2ghidra r2dec r2frida
```

## frida
```
$ r2 frida:///bin/ls
> :dc         # continue the execution
> :dcu        # continue the execution until
> :dd         # list file descriptors
> :dm         # show process memory maps
> :dmm        # show modules mapped
> :dl foo.so  # load a shlib
> :dt write   # trace every call to 'write'
> :isa read   # find where's the read symbol located
> :ii         # list imports off the current module
> :dxc exit 0 # call 'exit' symbol with argument 0
```

## debugger
```
$ r2 -d gdb://127.0.0.1
> ds          # step into
> dso         # step over
> dr=         # show registers in columns
> dbt         # show backtrace
> dsu entry0  # continue until entrypoint
> dr rax=33   # change value of register
> pxr@rsp     # inspect stack
> drr         # periscoped register values
> S           # step over

```

## docs
```
r2 -Qc'?*~...' --
```
