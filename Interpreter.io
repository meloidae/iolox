Interpreter := Expr Visitor clone do(
  interpret := method(expr,
    e := try(
      value := self evaluate(expr)
      writeln(self stringify(value))
    )

    e catch(RuntimeError,
      Lox runtimeError(e)
    ) pass # Call pass for debugging
  )

  evaluate := method(expr,
    expr accept(self)
  )

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
    # iolang let's you compare nil like any other object, so this is fine
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
