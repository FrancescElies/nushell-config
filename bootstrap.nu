use src/symlinks.nu symlink
use src/utils.nu ask_yes_no


export def main [] {
    mkdir ~/src/work
    mkdir ~/src/oss

    # yt-dlp
    let yt_dlp = "~/bin/yt-dlp" | path expand
    if (not ($yt_dlp | path exists)) { http get https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp | save -f $yt_dlp }

    # broot
    let broot_config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\broot' ,
        _ => "~/.config/broot" ,
    }
    if not ($broot_config_dir | path exists) { mkdir $broot_config_dir }
    symlink --force ~/src/nushell-config/broot-config $broot_config_dir

    # bacon
    let bacon_config_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\dystroy\bacon\config' ,
        "macos" => '~/Library/Application Support/org.dystroy.bacon' ,
        _ => "~/.config/bacon" ,
    }
    if not ($bacon_config_dir | path exists) { mkdir $bacon_config_dir }
    symlink --force ~/src/nushell-config/bacon-config $bacon_config_dir

    # uv
    match $nu.os-info.name {
        "windows" => { powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex" }
        _ => { curl -LsSf https://astral.sh/uv/install.sh | sh },
    }

    # nushell
    let nushell_dir = match $nu.os-info.name {
        "windows" => '~\AppData\Roaming\nushell' ,
        "macos" => "~/Library/Application Support/nushell" ,
        _ => "~/.config/nushell" ,
    }
    if not ($nushell_dir | path exists) { mkdir $nushell_dir }
    symlink --force ~/src/nushell-config/env.nu ($nushell_dir | path join "env.nu")
    symlink --force ~/src/nushell-config/config.nu ($nushell_dir | path join "config.nu")


    use src/install-it.nu *

    # cross platform
    config python
    if (ask_yes_no "Install rust basics?") { install-or-upgrade rust }
}
