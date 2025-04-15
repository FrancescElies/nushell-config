export def --wrapped main [...rest] {
  with-env {
    # blinking mode (not common in manpages)
    LESS_TERMCAP_mb: $'(ansi rb)'
    # double-bright mode (used for boldface)
    LESS_TERMCAP_md: $'(ansi rb)'
    # exit/reset all modes
    LESS_TERMCAP_me: $'(ansi reset)'
    # enter standout mode (used by the less statusbar and search results)
    LESS_TERMCAP_so: $'(ansi yr)'
    # exit standout mode
    LESS_TERMCAP_se: $'(ansi reset)'
    # enter underline mode (used for underlined text)
    LESS_TERMCAP_us: $'(ansi gb)'
    # exit underline mode
    LESS_TERMCAP_ue: $'(ansi reset)'
  } {
    man ...$rest
  }
}
