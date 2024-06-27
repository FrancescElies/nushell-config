export def "fix js" [] {
  # check = format & lint
  npx @biomejs/biome check --apply .
}

export def "fix python" [] {
    ruff check --fix
    black .
    pyright .
}

export def "fix rust" [] {
  print "formatting"
  cargo fmt --all
  print "fix"
  cargo fix --allow-dirty --allow-staged
  print "clippy fix"
  cargo clippy --fix --allow-dirty --allow-staged
}
