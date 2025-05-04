export module ai {
    export alias chat = elia

    # ask something to chat gpt
    export def "could you" [...words: string] {
        tgpt $"could you ($words | str join ' ')"
    }
    # ask something to chat gpt
    export def "how do i" [...words: string] { tgpt $"how do i ($words | str join ' ')" }
    # ask something to chat gpt
    export def "what" [...words: string] { tgpt $"what ($words | str join ' ')" }
}
