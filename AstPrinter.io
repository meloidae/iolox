AstPrinter := Expr Visitor clone do(
  printExpr := method(expr,
    expr accept(self)
  )

  # Override Visitor methods
  visitBinaryExpr = method(expr,
    self parenthesize(expr operator lexeme, expr left, expr right)
  )

  visitGroupingExpr = method(expr,
    self parenthesize("group", expr expression)
  )

  visitLiteralExpr = method(expr,
    expr value ifNil(return("nil"))
    expr value
  )

  visitUnaryExpr = method(expr,
    self parenthesize(expr operator lexeme, expr right)
  )

  parenthesize := method(
    exprs := call evalArgs
    # First item is not Expr
    name := exprs removeFirst

    str := "(" .. name
    exprs foreach(expr,
      str := str .. " " .. (expr accept(self))
    )
    str .. ")"
  )
)

expression := Expr Binary with(
  Expr Unary with(
    Token with(TokenType MINUS, "-", nil, 1),
    Expr Literal with(123)
  ),
  Token with(TokenType STAR, "*", nil 1),
  Expr Grouping with(
    Expr Literal with(45.67)
  )
)
writeln(AstPrinter printExpr(expression))
