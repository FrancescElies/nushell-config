
export def ask_yes_no [question: string, message: string = ""] {
  return ( 
      match (input $"(ansi purple_bold)($question)(ansi reset) ($message) [y/n]") {
        "y" | "yes" | "Y" => true,
        _ => false,
      } 
  )
}

