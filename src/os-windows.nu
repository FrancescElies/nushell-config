# Windows
# chcp 65001
# export alias vim = "c:/tools/vim/vim90/vim.exe"

# https://github.com/winsiderss/systeminformer

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

# https://learn.microsoft.com/en-us/sysinternals/downloads/procdump
# Examples:
# > prodcump -ma
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

export def "attach to-process-with-windbg" [
  --pid(-p): int@"nu-complete processes"  # process-id
] {

   ~/AppData/Local/Microsoft/WindowsApps/WinDbgX.exe -p $pid
}

export def "attach to-process-with-lldbb" [processid: int] {
  with-env {Path: ($env.Path | prepend "C:/Python310") ,PYTHONHOME: `C:/Python310`, PYTHONPATH: "C:/Python310/Lib"} {
    python --version
    lldb -p $processid
  }
}

export def open-in-windbg [executable: path] {
   ~/AppData/Local/Microsoft/WindowsApps/WinDbgX.exe $executable
}

export def --wrapped "cargo test-windbg" [
  ...args: string  # args passed to `cargo test`
] {
  let executable = (cargo t ...$args --no-run e>| parse --regex 'Executable.*\((?<name>.+)\)' | get 0.name)
  open-in-windbg $executable
}

