export def "rust libraries" [] {
    return [
        [name type description];
        [turmoil testing "async chaos"]
        [shuttle testing "sync chaos"]
        ["quickcheck/proptest" testing "(hypothesis like): value chaos (fuzzing, figure out inputs with erroneous behaviour)"]
        [cargo-mutants testing "logic chaos, e.g. switches sign of +/- boundary conditions"]
        [loom testing "interleaves all possible permutation of thread interactions"]
        [kani testing "symbolic execution, interprets the code and sees which values to set to execute other branches"]
        [ai-callgrind bench "runs measurement through valgrind and reports number of instructions executed (dont use time or ops/sec, this depends on external processes)"]
        [tango bench "runs the old code and the new one interleaved"]
        ["Open Versus Closed: A Cautionary Tale" bench "https://www.usenix.org/legacy/event/nsdi06/tech/full_papers/schroeder/schroeder.pdf"]
    ]
}

export def "rust links" [] {
    return [
        [name link];
        [nextest https://nexte.st/]
        [comprehensive-rust https://google.github.io/comprehensive-rust/error-handling/thiserror-and-anyhow.html]
        [rust-cookbook https://rust-lang-nursery.github.io/rust-cookbook/]
        [rust-by-example https://doc.rust-lang.org/rust-by-example/]
        [cross-compiling https://actually.fyi/posts/zig-makes-rust-cross-compilation-just-work/]
        [ytb-logan-smith https://www.youtube.com/@_noisecode]
        [unsafe-rust-and-zig https://zackoverflow.dev/writing/unsafe-rust-vs-zig]
    ]

}
