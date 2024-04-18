export def "config weztern" [] {
  nvim ~/src/wezterm-config/wezterm.lua
}

export def "config nvim" [] {
  nvim ~/src/kickstart.nvim/init.lua
}

export def "config espanso" [] {
  if $nu.os-info.name == "windows" {
    nvim $"($env.APPDATA)/espanso/default.yml"
  } else {
    error make {msg: "espanso config missing?"}
  }
}

export def "config broot" [] {
  if $nu.os-info.name == "windows" {
    nvim $"($env.APPDATA)/dystroy/broot/config/conf.hjson" $"($env.APPDATA)/dystroy/broot/config/verbs.hjson"
  } else {
    nvim "~/.config/broot/config/conf.hjson" "~/.config/broot/config/verbs.hjson"
  }
}

export def "you-dont-know-js" [] {
  # https://github.com/francescelies/You-Dont-Know-JS
  cd ~/src/oss/You-Dont-Know-JS
  just open
}
