export def print_purple [...message: string] { 
    print $"(ansi purple_bold)($message | str join ' ')(ansi reset)" 
}

export def ask_yes_no [question: string] {
    return ( 
        match (input $"(ansi purple_bold)($question)(ansi reset) [y/n]") {
          "y" | "yes" | "Y" => true,
          _ => false,
        } 
    )
}
