# Windows
# chcp 65001
# export alias vim = "c:/tools/vim/vim90/vim.exe"

# https://github.com/winsiderss/systeminformer

use utils.nu print_purple

# NOTE: broken
# overlay use ~/src/nushell-config/.venv/scripts/activate.nu

# sigcheck wrapper, file version and signature viewer
export def "version of" [file: path ] {
  print $"sigcheck -nobanner ($file)"
  ^sigcheck -nobanner $file | lines | skip 1 | parse --regex '\s*(?<name>.+?):(?<value>.+)'
}

# File version and signature viewer (see "version of" wrapper")
#
# Examples:
#     sigcheck -nobanner -q -n foo.dll
#
# Usage:
#     sigcheck [-a][-h][-i][-e][-l][-n][[-s]|[-c|-ct]|[-m]][-q][-p <policy GUID>][-r][-u][-vt][-v[r][s]][-f catalog file] [-w file] <file or directory>
#     sigcheck -d [-c|-ct] [-w file] <file or directory>
#     sigcheck -o [-vt][-v[r]] [-w file] <sigcheck csv file>
#     sigcheck -t[u][v] [-i] [-c|-ct] [-w file] <certificate store name|*>
export extern "sigcheck" [
  ...args: any                              # Arguments to be passed to your program
  -a    # Show extended version information. The entropy measure reported
        # is the bits per byte of information of the file's contents.
  -c    # CSV output with comma delimiter
  --ct  # CSV output with tab delimiter Specify -nobanner to avoid banner being output to CSV
  -d    # Dump contents of a catalog file
  -e    # Scan executable images only (regardless of their extension)
  -f    # Look for signature in the specified catalog file
  -h    # Show file hashes
  -i    # Show catalog name and signing chain
  -l    # Traverse symbolic links and directory junctions
  -m    # Dump manifest
  -n    # Only show file version number
  -o    # Performs Virus Total lookups of hashes captured in a CSV
        #    file previously captured by Sigcheck when using the -h option.
        #    This usage is intended for scans of offline systems.
  -p    # Verify signatures against the specified policy, represented by
#           its GUID, or the custom code integrity policy stored in the specified
#           policy file.
  -r    # Disable check for certificate revocation
  -s    # Recurse subdirectories
  -t    # Dump contents of specified certificate store ('*' for all stores).
  --tu    # Dump contents of specified certificate store ('*' for all stores). Query the user store (machine store is the default)
  --tuv   # Dump contents of specified certificate store ('*' for all stores). Query the user store (machine store is the default)
          #    Append '-v' to have Sigcheck download the trusted Microsoft
          #    root certificate list and only output valid certificates not rooted to
          #    a certificate on that list. If the site is not accessible,
          #    authrootstl.cab or authroot.stl in the current directory are
          #    used instead, if present.
  -u      # If VirusTotal check is enabled, show files that are unknown by VirusTotal or have non-zero detection, otherwise show only unsigned files.

#   -v[rs]  Query VirusTotal (www.virustotal.com) for malware based on file hash.
#           Add 'r' to open reports for files with non-zero detection. Files
#           reported as not previously scanned will be uploaded to VirusTotal
#           if the 's' option is specified. Note scan results may not be
#           available for five or more minutes.
#   -vt     Before using VirusTotal features, you must accept
#           VirusTotal terms of service. See:
#
#           https://www.virustotal.com/en/about/terms-of-service/
#
#           If you haven't accepted the terms and you omit this
#           option, you will be interactively prompted.
#   -w      Writes the output to the specified file.
  --nobanner  # Do not display the startup banner and copyright message.
#
]

# https://learn.microsoft.com/en-us/sysinternals/downloads/procdump#using-procdump
#
# Examples:
#   Install ProcDump as the (AeDebug) postmortem debugger:
#   procdump -ma -i c:\dumps
#
#   Uninstall ProcDump as the (AeDebug) postmortem debugger:
#   procdump -u
export extern "procdump" [
  ...args: any                              # Arguments to be passed to your program
  # command?: string@"nu-complete rustup"
]

# https://stackoverflow.com/questions/8560166/silent-installation-of-a-msi-package
export def "msi silent-install" [msi_file: path] {
  # wmic product get name
  # msiexec /i c:\path\to\package.msi /quiet /qn /norestart /log c:\path\to\install.log PROPERTY1=value1 PROPERTY2=value2
  let $logfile = $"($msi_file | path basename).XXXX.log"
  let $logfile = (mktemp $logfile)
  print $"Installing ($msi_file) see log at ($logfile)"
  msiexec.exe /i $msi_file /QN /L*V $logfile
}

def "nu-complete installed-pkgs" [] {
  ( open /tmp/installed-pkgs.txt | lines
  | each { $in | str trim }
  | filter {not ($in | is-empty) }
  )
}

export def "msi refresh-list" [] { wmic product get name | save -f /tmp/installed-pkgs.txt }

export def "msi uninstall" [
  pkg: string@"nu-complete installed-pkgs"  # call `msi refresh-list` if you feel not up to date
] {
  # example
  print wmic Product Where "Name='Max 8 (64-bit)'" Call Uninstall /NoInteractive
}

def "nu-complete processes" [] { ps | select pid name | sort-by name | rename -c {pid: value, name: description} }

export def "windbg attach-to-process" [
  --pid(-p): int@"nu-complete processes"  # process-id
] {

   ~/AppData/Local/Microsoft/WindowsApps/WinDbgX.exe -p $pid
}

export def "windbg open-exe" [executable: path] {
   ~/AppData/Local/Microsoft/WindowsApps/WinDbgX.exe $executable
}


export alias dumps = broot --sort-by-date c:/dumps

# https://lldb.llvm.org/use/tutorial.html, `br set -n myfunction` , wa set var ret
export def "lldb attach-to-process" [process_name: string = "", processid: int = 0] {
  let processid = if $process_name != "" {
    ps | where name =~ $"\(?i\)($process_name)" | get pid.0
  } else {
    if $processid == 0 {  ps | input list -d name --fuzzy  | get pid } else { $processid }
  }

  let python_dir = (py -3.10 -c "import sys; print(sys.base_exec_prefix)")
  print_purple $"pythond_dir ($python_dir)"

  with-env {Path: ($env.Path | prepend $python_dir) ,PYTHONHOME: $python_dir, PYTHONPATH: $"($python_dir)/Lib"} {
    python --version
    lldb -p $processid
  }
}

export def --wrapped "cargo test-windbg" [
  ...args: string  # args passed to `cargo test`
] {
  let executable = (cargo t ...$args --no-run e>| parse --regex 'Executable.*\((?<name>.+)\)' | get 0.name)
  open-in-windbg $executable
}

# open in visual studio
export def vs [file: path] {
  let file = ($file | path expand)
  run-external `C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe` /Edit $file
}

export alias timeline = start http://localhost:5600/#/timeline

# open screen shots
export def "screen shots" [] { start ('~/Pictures/Screenshots' | path expand) }
export def "br screen shots" [] { br --sort-by-date ('~/Pictures/Screenshots' | path expand)  }

# open screen recordings
export def "screen recordings" [] { start ('~/Videos/Screen Recordings' | path expand) }
export def "br screen recordings" [] { br --sort-by-date ('~/Videos/Screen Recordings' | path expand)  }

export def "screen recordings to gif" [] {
  ( ls `~/Videos/Screen Recordings/*mp4` | get name | path parse
    | filter {|x| not ($x.parent | path join $'($x.stem).gif' | path exists) }
    | par-each { |el| ffmpeg -i ($el.parent | path join $'($el.stem).($el.extension)') $"($el.parent | path join $el.stem).gif"} )

  start ('~/Videos/Screen Recordings' | path expand)
}

def "nu-complete proc-names" [] { ps | get name | uniq }

def "nu-complete ps-priority" [] { [ [value description]; [3 High] [6 'Above Normal'] [2 Normal] [5 'Below Normal'] [1 Low] ] }

# do I have admin rights?
export def "am i admin" [] {
  # https://stackoverflow.com/questions/7985755/how-to-detect-if-cmd-is-running-as-administrator-has-elevated-privileges
  if (net session | complete).exit_code == 0 {
    true
  } else {
    false
  }
}

# permanently set priority for process in windows registry
export def "ps set-permanent-priority" [
  proc_name: string@"nu-complete proc-names"
  --cpu-priority: int@"nu-complete ps-priority" = 2  # Normal
  --io-priority: int@"nu-complete ps-priority" = 2  # Normal
] {
  # https://answers.microsoft.com/en-us/windows/forum/all/how-to-permanently-set-priority-processes-using/2f9ec439-5333-4625-9577-69d322cfbc5e
  let perf_options_path = $'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\($proc_name)\PerfOptions'
  reg add $perf_options_path /v CpuPriorityClass /t REG_DWORD /d $cpu_priority
  reg add $perf_options_path /v IoPriority /t REG_DWORD /d $io_priority
}

