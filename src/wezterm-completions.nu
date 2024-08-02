
export def --env "wezterm logs" [] {
    let logs = match $nu.os-info.name {
      "linux" => $"($env.XDG_RUNTIME_DIR)/wezterm",
      "windows" => "~/.local/share/wezterm",
      "macos" => "~/.local/share/wezterm",
      _ => {error make {msg: "not implemented", }},
    }
  cd $logs
  br --sort-by-date
}
