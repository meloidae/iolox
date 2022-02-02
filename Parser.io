Parser := Object clone do(
  ParserError := Exception clone
  tokens := list()
  current := 0

  with := method(tokens,
    parser := self clone
    parser setSlot("tokens", tokens)
    parser
  )

  parse := method(
    statements := list()
    while(self isAtEnd not,
      statements append(self declaration)
    )

    statements
  )

  expression := method(
    self assignment
  )

  # declaration -> varDecl | statement ;
  declaration := method(
    ret := nil
    e := try(
      if(self match(TokenType VAR),
        ret = self varDeclaration
        return
      )
      ret = self statement
    )

    e catch(ParserError,
      self synchronize
      ret = nil
    ) pass # Reraise any error that's not a ParserError
    ret
  )

  # statement -> exprStmt | ifStmt | printStmt | block ;
  statement := method(
    if(self match(TokenType IF), return(self ifStatement))
    if(self match(TokenType PRINT), return(self printStatement))
    if(self match(TokenType LEFT_BRACE), return(Stmt Block with(self codeBlock)))

    # Anything that's not a print stmt is an expression stmt
    self expressionStatement
  )

  # ifStmt -> "if" "(" expression ")" statement ( "else" statement )? ;
  ifStatement := method(
    self consume(TokenType LEFT_PAREN, "Expect '(' after 'if'.")
    condition := self expression
    self consume(TokenType RIGHT_PAREN, "Expect ')' after if condition.")
    
    thenBranch := self statement
    elseBranch := nil
    if(self match(TokenType ELSE),
      elseBranch = self statement
    )

    Stmt If with(condition, thenBranch, elseBranch)
  )

  # printStmt -> "print" expression ";" ;
  printStatement := method(
    value := self expression
    self consume(TokenType SEMICOLON, "Expect ';' after value.")
    Stmt Print with(value)
  )

  # varDecl -> "var" IDENTIFIER ( "=" expression )? ";" ;
  varDeclaration := method(
    name := self consume(TokenType IDENTIFIER, "Expect variable name")

    initializer := nil
    if(self match(TokenType EQUAL),
      initializer = self expression
    )

    self consume(TokenType SEMICOLON, "Expect ';' after vaiable declaration")
    Stmt Var with(name, initializer)
  )

  # exprStmt -> expression ";" ;
  expressionStatement := method(
    expr := self expression
    self consume(TokenType SEMICOLON, "Expect ';' after expression.")
    Stmt Expression with(expr)
  )

  # block -> "{" declaration* "}" ;
  codeBlock := method(
    statements := list()
    while(self check(TokenType RIGHT_BRACE) not and(self isAtEnd not),
      statements append(self declaration)
    )

    self consume(TokenType RIGHT_BRACE, "Expect '}' after block.")
    statements
  )

  # assignment -> IDENTIFIER "=" assignment | equality ;
  assignment := method(
    expr := self equality

    if(self match(TokenType EQUAL),
      equals := self previous
      value := self assignment

      if(expr type == (Expr Variable type),
        name := expr name
        return(Expr Assign with(name, value))
      )

      self error(equals, "Invalud assignment target.")
    )

    expr
  )

  # equality -> comparison ( ( "!=" | "==" ) comparison )* ;
  equality := method(
    expr := self comparison
    while(self match(TokenType BANG_EQUAL, TokenType EQUAL_EQUAL),
      operator := self previous
      right := self comparison
      expr = Expr Binary with(expr, operator, right)
    )
    expr
  )

  # comparison -> term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  comparison := method(
    expr := self term
    while(self match(TokenType GREATER, TokenType GREATER_EQUAL, TokenType LESS, TokenType LESS_EQUAL),
      operator := self previous
      right := self term
      expr = Expr Binary with(expr, operator, right)
    )
    expr
  )

  # term -> factor ( ( "-" | "+" ) factor )* ;
  term := method(
    expr := self factor
    while(self match(TokenType MINUS, TokenType PLUS),
      operator := self previous
      right := self factor
      expr = Expr Binary with(expr, operator, right)
    )
    expr
  )

  # factor -> unary ( ( "/" | "*" ) unary )* ;
  factor := method(
    expr := self unary
    while(self match(TokenType SLASH, TokenType STAR),
      operator := self previous
      right := self unary
      expr = Expr Binary with(expr, operator, right)
    )
    expr
  )

  # unary -> ( "!" | "-" ) unary | primary ;
  unary := method(
    if(self match(TokenType BANG, TokenType MINUS),
      operator := self previous
      right := self unary
      return(Expr Unary with(operator, right))
    )
    self primary
  )

  # primary -> NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER ;
  primary := method(
    if(self match(TokenType FALSE), return(Expr Literal with(false)))
    if(self match(TokenType TRUE), return(Expr Literal with(true)))
    if(self match(TokenType NIL), return(Expr Literal with(nil)))

    if(self match(TokenType NUMBER, TokenType STRING),
      return(Expr Literal with(self previous literal))
    )

    if(self match(TokenType IDENTIFIER),
      return(Expr Variable with(self previous))
    )

    if(self match(TokenType LEFT_PAREN),
      expr := self expression
      self consume(TokenType RIGHT_PAREN, "Expect ')' after expression.")
      return(Expr Grouping with(expr))
    )

    # Raise error
    self error(self peek, "Expect expression.") raise
  )

  match := method(
    for(i, 0, call argCount - 1,
      if(self check(call evalArgAt(i)),
        self advance
        return(true)
      )
    )
    # Did not find any match.
    return(false)
  )

  consume := method(tokenType, msg,
    if(self check(tokenType), return(self advance))
    # Raise error
    self error(self peek, msg) raise
  )

  check := method(tokenType,
    if(self isAtEnd, return(false))
    (self peek tokenType) == tokenType
  )

  advance := method(
    if(self isAtEnd not, self current = (self current) + 1)
    self previous
  )

  isAtEnd := method(
    (self peek tokenType) == (TokenType EOF)
  )

  peek := method(
    self tokens at(self current)
  )

  previous := method(
    self tokens at(self current - 1)
  )

  error := method(token, msg,
    Lox error(token, msg)
    return(ParserError)
  )

  synchronize := method(
    self advance

    while(self isAtEnd not,
      if(self previous tokenType == TokenType SEMICOLON, return)

      self peek tokenType switch(
        TokenType CLASS, return,
        TokenType FUN, return,
        TokenType VAR, return,
        TokenType FOR, return,
        TokenType IF, return,
        TokenType WHILE, return,
        TokenType PRINT, return,
        TokenType RETURN, return
      )

      self advance
    )
  )
)
