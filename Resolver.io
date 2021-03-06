Resolver := Object clone do(
  # Interfaces
  appendProto(Expr Visitor)
  appendProto(Stmt Visitor)

  interpreter := nil
  scopes := nil
  currentFunction := nil

  # local enums
  FunctionType := Object clone do(
    NONE := "NONE"
    FUNCTION := "FUNCTION"
  )

  with := method(interpreter,
    r := self clone
    r setSlot("interpreter", interpreter)
    r setSlot("scopes", list())
    r setSlot("currentFunction", FunctionType NONE)
    r
  )

  resolve := method(arg,
    _resolveStatements(arg)
  )

  _resolveStatements := method(statements,
    statements foreach(statement,
      _resolveStmtOrExpr(statement)
    )
  )

  _resolveStmtOrExpr := method(stmtOrExpr,
    stmtOrExpr accept(self)
  )

  resolveFunction := method(function, functionType,
    enclosingFunction := self currentFunction
    self currentFunction := functionType

    self beginScope
    function params foreach(param,
      self declare(param)
      self define(param)
    )
    self _resolveStatements(function body)
    self endScope
    self currentFunction = enclosingFunction
  )

  beginScope := method(
    self scopes push(Map with)
  )

  endScope := method(
    self scopes pop
  )

  declare := method(name,
    if(self scopes isEmpty, return)

    # Peek at the top item of stack without removing it
    scope := self scopes last
    # Provides error on accidental redeclaration in a local scope
    if(scope hasKey(name lexeme),
      Lox error(name, "Already a variable with this name in this scope.")
    )
    # Mark the variable as not initialized
    scope atPut(name lexeme, false)
  )

  define := method(name,
    if(self scopes isEmpty, return)
    # Mark the variable as initialized
    self scopes last atPut(name lexeme, true)
  )

  resolveLocal := method(expr, name,
    for(i, self scopes size - 1, 0, -1,
      if(self scopes at(i) hasKey(name lexeme),
        self interpreter resolve(expr, self scopes size - (i + 1))
        return
      )
    )
  )

  # Overrides
  visitBlockStmt := method(stmt,
    self beginScope
    self resolve(stmt statements)
    self endScope
  )

  visitExpressionStmt := method(stmt,
    self _resolveStmtOrExpr(stmt expression)
  )

  visitIfStmt := method(stmt,
    self _resolveStmtOrExpr(stmt condition)
    self _resolveStmtOrExpr(stmt thenBranch)
    if (stmt elseBranch != nil, self _resolveStmtOrExpr(stmt elseBranch))
  )

  visitPrintStmt := method(stmt,
    self _resolveStmtOrExpr(stmt expression)
  )

  visitReturnStmt := method(stmt,
    # Gives error when return is called in top-level code
    if(self currentFunction == FunctionType NONE,
      Lox error(stmt keyword, "Can't return from top-level code.")
    )
    
    if(stmt value != nil, self _resolveStmtOrExpr(stmt value))
  )

  visitFunctionStmt := method(stmt,
    self declare(stmt name)
    self define(stmt name)

    self resolveFunction(stmt, FunctionType FUNCTION)
  )

  visitVarStmt := method(stmt,
    self declare(stmt name)
    if(stmt initializer != nil,
      self _resolveStmtOrExpr(stmt initializer)
    )
    self define(stmt name)
  )

  visitWhileStmt := method(stmt,
    self _resolveStmtOrExpr(stmt condition)
    self _resolveStmtOrExpr(stmt body)
  )

  visitVariableExpr := method(expr,
    if(self scopes isEmpty not and(self scopes last at(expr name lexeme) == false),
      Lox error(expr name, "Can't read local variable in its own initializer.")
    )

    self resolveLocal(expr, expr name)
  )

  visitAssignExpr := method(expr,
    self _resolveStmtOrExpr(expr value)
    self resolveLocal(expr, expr name)
  )

  visitBinaryExpr := method(expr,
    self _resolveStmtOrExpr(expr left)
    self _resolveStmtOrExpr(expr right)
  )

  visitCallExpr := method(expr,
    self _resolveStmtOrExpr(expr callee)

    expr arguments foreach(argument,
      self _resolveStmtOrExpr(argument)
    )
  )

  visitGroupingExpr := method(expr,
    self _resolveStmtOrExpr(expr expression)
  )

  visitLiteralExpr := method(expr,
    nil
  )

  visitLogicalExpr := method(expr,
    self _resolveStmtOrExpr(expr left)
    self _resolveStmtOrExpr(expr right)
  )

  visitUnaryExpr := method(expr,
    self _resolveStmtOrExpr(expr right)
  )

)

