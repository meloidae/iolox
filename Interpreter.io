Interpreter := Object clone do(
  # Interfaces
  appendProto(Expr Visitor)
  appendProto(Stmt Visitor)

  environment := Environment with

  interpret := method(statements,
    # Run a list of statements and report any error
    e := try(
      statements foreach(statement,
        self execute(statement)
      )
    )

    e catch(RuntimeError,
      Lox runtimeError(e)
    ) pass # Reraise any erorr that's not a RuntimeError
  )

  evaluate := method(expr,
    expr accept(self)
  )

  execute := method(stmt,
    stmt accept(self)
  )

  executeBlock := method(statements, env,
    previous := self environment
    e := try(
      self environment := env

      statements foreach(statement,
        self execute(statement)
      )
    )
    e catch(
      e print
    )
    self environment = previous
  )

  # Stmt interface methods
  visitBlockStmt := method(stmt,
    self executeBlock(stmt statements, Environment with(self environment))
  )

  visitExpressionStmt := method(stmt,
    self evaluate(stmt)
  )

  visitIfStmt := method(stmt,
    if(self isTruthy(self evaluate(stmt condition))) then(
      self execute(stmt thenBranch)
    ) elseif(stmt elseBranch != nil) then(
      self execute(stmt elseBranch)
    )
  )

  visitPrintStmt := method(stmt,
    value := self evaluate(stmt expression)
    writeln(self stringify(value))
  )

  visitVarStmt := method(stmt,
    value := nil # The value is set to nil if it's not explicitly initialized
    if(stmt initializer != nil,
      value = self evaluate(stmt initializer)
    )

    self environment define(stmt name lexeme, value)
  )

  visitAssignExpr := method(expr,
    value := self evaluate(expr value)
    self environment assign(expr name, value)
    value
  )

  # Expr interface methods
  visitBinaryExpr := method(expr,
    left := self evaluate(expr left)
    right := self evaluate(expr right)

    (expr operator tokenType) switch(
      # Comparisons
      TokenType GREATER, 
      self checkNumberOperands(expr operator, left, right)
      return(left > right),
      TokenType GREATER_EQUAL,
      self checkNumberOperands(expr operator, left, right)
      return(left >= right),
      TokenType LESS,
      self checkNumberOperands(expr operator, left, right)
      return(left < right),
      TokenType LESS_EQUAL,
      self checkNumberOperands(expr operator, left, right)
      return(left <= right),
      TokenType BANG_EQUAL,
      self checkNumberOperands(expr operator, left, right)
      return(self isEqual(left, right) not),
      TokenType EQUAL_EQUAL,
      self checkNumberOperands(expr operator, left, right)
      return(self isEqual(left, right)),
      # Subtraction
      TokenType MINUS,
      self checkNumberOperands(expr operator, left, right)
      return(left - right),
      # Numeric addition or string concatenation
      TokenType PLUS,
      # Numbers
      if (left type == "Number" and(right type == "Number"), return(left + right))
      # Strings
      if (left type == "Sequence" and(right type == "Sequence"), return(left .. right))

      # Throw an error if neither of numbers or strings cases match
      RuntimeError with(expr operator, "Operands must be two numbers or two strings.") raise,
      # Division
      TokenType SLASH,
      self checkNumberOperands(expr operator, left, right)
      return(left / right),
      # Multiplication
      TokenType STAR,
      self checkNumberOperands(expr operator, left, right)
      return(left * right)
    )

    # Should be unreachable
    nil
  )

  # Override Visitor methods
  visitGroupingExpr := method(expr,
    self evaluate(expr expression)
  )

  visitLiteralExpr := method(expr,
    expr value
  )

  visitLogicalExpr := method(expr,
    left := self evaluate(expr left)

    if(expr operator tokenType == (TokenType OR),
      if(self isTruthy(left), return(left))
      if(self isTruthy(left) not, return(left))
    )

    self evaluate(expr right)
  )

  visitUnaryExpr := method(expr,
    right := self evaluate(expr right)

    (expr operator tokenType) switch(
      # Logical not
      TokenType BANG, return(self isTruthy(right) not),
      # Negate
      TokenType MINUS,
      self checkNumberOperand(expr operator, right)
      return(-right)
    )

    # Should be unreachable
    nil
  )

  visitVariableExpr := method(expr,
    self environment get(expr name)
  )

  checkNumberOperand := method(operator, operand,
    if(operand type == "Number", return)
    RuntimeError with(operator, "Operand must be a number.") raise
  )

  checkNumberOperands := method(operator, left, right,
    if(left type == "Number" and(right type == "Number"), return)
    RuntimeError with(operator, "Operands must be numbers.") raise
  )

  isTruthy := method(object,
    # nil and false are falsy, but everything else is truthy
    if(object == nil, return(false))
    if(object == false) then(return false) else(return true)
  )

  isEqual := method(a, b,
    # iolang lets you compare nil like any other object, so this is fine
    a == b
  )

  stringify := method(object,
    # Special treatment is for a number only
    if(object type == "Number",
      if(object % 1 == 0,
        # Remove decimals if it's an integer
        return(object asString(0, 0)),
        # Otherwise return up to 6 decimal places (Is it possible to auto remove trailing zeros?)
        return(object asString(0))
      )
    )

    object asString
  )
)
