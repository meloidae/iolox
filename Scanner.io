Scanner := Object clone do(
  source ::= ""
  tokens := list()
  start := 0
  current := 0
  line := 1

  with := method(source,
    self clone setSource(source)
  )

  scanTokens := method(
    while(self isAtEnd not,
      # Beginning of the next lexeme.
      self start := (self current)
      self scanToken
    )
    # Add EOF for clearity
    self tokens append(Token with(TokenType EOF, "", nil, self line))
  )

  scanToken := method(
    c := self advance
    c switch(
      "(" at(0), self addToken(TokenType LEFT_PAREN),
      ")" at(0), self addToken(TokenType RIGHT_PAREN),
      "{" at(0), self addToken(TokenType LEFT_BRACE),
      "}" at(0), self addToken(TokenType RIGHT_BRACE),
      "," at(0), self addToken(TokenType COMMA),
      "." at(0), self addToken(TokenType DOT),
      "." at(0), self addToken(TokenType DOT),
      "-" at(0), self addToken(TokenType MINUS),
      "+" at(0), self addToken(TokenType PLUS),
      ";" at(0), self addToken(TokenType SEMICOLON),
      "*" at(0), self addToken(TokenType STAR),
      # One or two character operators
      "!" at(0), self addToken(if(self match("=" at(0)), TokenType BANG_EQUAL, TokenType BANG)),
      "=" at(0), self addToken(if(self match("=" at(0)), TokenType EQUAL_EQUAL, TokenType EQUAL)),
      "<" at(0), self addToken(if(self match("=" at(0)), TokenType LESS_EQUAL, TokenType LESS)),
      ">" at(0), self addToken(if(self match("=" at(0)), TokenType GREATER_EQUAL, TokenType GREATER)),
      # Longer lexeme
      "/" at(0), if(self match("/" at(0)),
        # Two consecutive '/'s means a comment.
        # A comment goes until the end of the line.
        newline := "\n" at(0)
        while((self peak != newline) and(self isAtEnd not), self advance),
        # An isolated '/' is a division operator
        self addToken(TokenType SLASH)
      ),
      # Skip white spaces
      " " at(0), nil,
      "\r" at(0), nil,
      "\t" at(0), nil,
      # Newline
      "\n" at(0), self line = (self line) + 1,
      # String
      "\"" at(0), self string,
      # Default clause
      Lox error(self line, "Unexpected character.")
    )
  )

  string := method(
    dquote := "\"" at(0)
    newline := "\n" at(0)
    # Keep peaking (and advaning) until the closing " is found.
    while(self peak != dquote and(self isAtEnd not),
      if(self peak == newline, self line = (self line) + 1)
      self advance
    )

    if(self isAtEnd,
      Lox error(self line, "Unterminated string")
      return
    )

    # The closing "
    self advance

    # Trim the surrounding quotes.
    value := self source exSlice(self start + 1, self current - 1)
    self addToken(TokenType STRING, value)
  )

  isAtEnd := method(
    (self current) >= (self source size)
  )

  advance := method(
    c := self source at (self current)
    self current = (self current) + 1
    c
  )

  addToken := method(
    # The 1st argument is always the TokenType.
    tokenType := call message argAt(0)
    # The 2nd argument (literal) maybe omitted.
    literal := nil
    if(call message argCount > 1, literal = (call message argAt(1)))

    text := self source exSlice(self start, self current)
    self tokens append(Token with(tokenType, text, literal, self line))
  )

  match := method(expected,
    # Match a single character
    if(self isAtEnd, return false)
    if(self source at (self current) != expected, return false)

    # Only move forward when the current character is matches the expected character
    self current = (self current) + 1
    true
  )

  peak := method(
    # Match a single character without consuming it
    # Return a character code
    if(self isAtEnd, return 0)
    self source at(self current)
  )
)

