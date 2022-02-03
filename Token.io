Token := Object clone do(
  tokenType := nil
  lexeme := ""
  literal := nil
  line := 0

  with := method(tokenType, lexeme, literal, line,
    token := self clone
    token setSlot("tokenType", tokenType)
    token setSlot("lexeme", lexeme)
    token setSlot("literal", literal)
    token setSlot("line", line)
    token
  )

  asString := method(
    (self tokenType) .. " " .. (self lexeme) .. " " .. (self literal)
  )
)
