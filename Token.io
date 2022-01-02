Token := Object clone do(
  with := method(tokenType, lexeme, literal, line,
    self setSlot("tokenType", tokenType)
    self setSlot("lexeme", lexeme)
    self setSlot("literal", literal)
    self setSlot("line", line)
    self
  )

  toString := method(
    (self tokenType) .. (self lexeme) .. (self literal)
  )
)
