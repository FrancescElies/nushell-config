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
  cargo fmt --all
  cargo clippy --fix --allow-dirty --allow-staged
}
