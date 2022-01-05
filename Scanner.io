Scanner := Object clone do(
  source ::= ""
  tokens := list()
  start := 0
  current := 0
  line := 1
  keywords := nil

  init := method(
    self keywords := Map clone
    self keywords atPut("and", TokenType AND)
    self keywords atPut("class", TokenType CLASS)
    self keywords atPut("else", TokenType ELSE)
    self keywords atPut("false", TokenType FALSE)
    self keywords atPut("for", TokenType FOR)
    self keywords atPut("fun", TokenType FUN)
    self keywords atPut("if", TokenType IF)
    self keywords atPut("nil", TokenType NIL)
    self keywords atPut("or", TokenType OR)
    self keywords atPut("print", TokenType PRINT)
    self keywords atPut("return", TokenType RETURN)
    self keywords atPut("super", TokenType SUPER)
    self keywords atPut("this", TokenType THIS)
    self keywords atPut("true", TokenType TRUE)
    self keywords atPut("var", TokenType VAR)
    self keywords atPut("while", TokenType WHILE)
  )

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
        while((self peek != newline) and(self isAtEnd not), self advance),
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
      LoxUtils cond(
        self isDigit(c), self number,
        self isAlpha(c), self identifier,
        true, Lox error(self line, "Unexpected character.")
      )
    )
  )

  identifier := method(
    while(self isAlphaNumeric(self peek), self advance)
    # This identifier is a keyword if it's in the keywords map.
    text := self source exSlice(self start, self current)
    tokenType := self keywords at(text, TokenType IDENTIFIER)
    self addToken(tokenType)
  )

  number := method(
    # Consume consecutive digits.
    while(self isDigit(self peek),
      self advance
    )

    # Look for a fractional part.
    if (self peek == ("." at(0)) and(self isDigit(self peekNext)),
      # Consume the '.'
      self advance
      # Consume the fractional part
      while (self isDigit(self peek), self advance)
    )

    self addToken(TokenType NUMBER, self source exSlice(self start, self current) asNumber)
  )

  string := method(
    dquote := "\"" at(0)
    newline := "\n" at(0)
    # Keep peeking (and advaning) until the closing " is found.
    while(self peek != dquote and(self isAtEnd not),
      if(self peek == newline, self line = (self line) + 1)
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
    tokenType := call evalArgAt(0)
    # The 2nd argument (literal) maybe omitted.
    literal := nil
    if(call argCount > 1, literal = call evalArgAt(1))

    text := self source exSlice(self start, self current)
    self tokens append(Token with(tokenType, text, literal, self line))
  )

  match := method(expected,
    # Match a single character
    if(self isAtEnd, return(false))
    if(self source at (self current) != expected, return(false))

    # Only move forward when the current character is matches the expected character
    self current = (self current) + 1
    true
  )

  peek := method(
    # Match a single character without consuming it
    # Return a character code
    if(self isAtEnd, return(0))
    self source at(self current)
  )

  peekNext := method(
    if(self current + 1 >= (self source size), return(0))
    self source at(self current + 1)
  )

  isAlpha := method(c,
    # 'a' = 97, 'z' = 122, 'A' = 65, 'Z' = 90, '_' = 95
    ((c >= 97 and(c <= 122)) or(c >= 65 and(c <= 90))) or(c == 95)
  )

  isAlphaNumeric := method(c,
    self isAlpha(c) or(self isDigit(c))
  )

  isDigit := method(c,
    # '0' = 48, '9' = 57
    c >= 48 and(c <= 57)
  )
)
