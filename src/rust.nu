
export alias cbr = cargo build --release
export alias cbd = cargo build --debug

export def "config ra-multiplex" [] {
    match $nu.os-info.name {
        "windows" => { nvim ~/AppData/Roaming/ra-multiplex/config/config.toml },
        _ => { nvim ~/.config/ra-multiplex/config.toml },
    }
}

export def "rust libraries" [] {
    return [
        [name type description];
        [turmoil testing "async chaos"]
        [shuttle testing "sync chaos"]
        ["quickcheck/proptest" testing "(hypothesis like): value chaos (fuzzing, figure out inputs with erroneous behaviour)"]
        [cargo-mutants testing "logic chaos, e.g. switches sign of +/- boundary conditions"]
        [loom testing "interleaves all possible permutation of thread interactions"]
        [kani testing "symbolic execution, interprets the code and sees which values to set to execute other branches"]
    ]
}
