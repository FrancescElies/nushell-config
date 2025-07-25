# ghidra
# pwndbg: make gdb debugging easier, e.g. adds hexdump instead of x/g30x $esp
# x64dbg: debugger for windows

# Official website: https://www.radare.org/n/
# Book: https://book.rada.re/
# https://monosource.gitbooks.io/radare2-explorations/content/introduction.html

# https://github.com/capstone-engine/capstone?tab=readme-ov-file

# https://blog.devit.co/diving-into-radare2/

use process.nu pid

export module reng {
    export alias r2 = radare2

    export def "docs r2" [] {
        r2 -Qc'?*~...' --
    }

    # retrieves basic binary info (imports, strings, libraries, relocs, entry-point, symbols) https://book.rada.re/tools/rabin2
    export def "rabin2 quick" [file: path, ] {
        let folder = ($file | path basename)
        mkdir $folder
        cd $folder
        let file = ($file | path expand)

        rabin2 -g  $file | save -f 01-all-info.txt
        rabin2 -I  $file | save -f file-type.txt
        rabin2 -i  $file | save -f imports.txt
        rabin2 -E  $file | save -f exports.txt
        rabin2 -s  $file | save -f symbols.txt
        rabin2 -l  $file | save -f libraries.txt
        rabin2 -S  $file | save -f sections.txt
        rabin2 -z $file | save -f strings-data-section.txt
        rabin2 -zzz $file | save -f strings-raw.txt
        rabin2 -R  $file | save -f relocs.txt
        rabin2 -e  $file | save -f entry_point.txt

        print $"see files in ($folder)"
    }

    # https://github.com/DynamoRIO/drmemory

    # binary instrumentation
    #
    # https://github.com/iddoeldor/frida-snippets
    #
    # https://medium.com/@schirrmacher/analyzing-whatsapp-calls-176a9e776213
    # frida-trace -U WhatsApp -m "*[* *Secret*]" -m "*[* *secret*]"
    # frida-trace -U WhatsApp -m "*[* *crypt*]" -i "*crypt*"
    # frida-trace -U WhatsApp -i “*signal*”
    # Which dlls will be loaded? Runtime linking makes use of LoadLibrary() WinAPI call from kernel32.dll
    # frida-trace -p (pid) -i LoadLibrary*
    # frida-trace -p (pidof notepad) -i mylib.dll!*

    export def "frida list modules-and-exports" [pid: number] {
        (frida -p $pid --eval 'Process.enumerateModules()' -q | from json)
    }
}
