Stmt := Object clone do(
  Visitor := Object clone do(
    visitBlockStmt := method(Exception raise("visitBlockStmt is unimplemented"))
    visitExpressionStmt := method(Exception raise("visitExpressionStmt is unimplemented"))
    visitFunctionStmt := method(Exception raise("visitFunctionStmt is unimplemented"))
    visitIfStmt := method(Exception raise("visitIfStmt is unimplemented"))
    visitPrintStmt := method(Exception raise("visitPrintStmt is unimplemented"))
    visitReturnStmt := method(Exception raise("visitReturnStmt is unimplemented"))
    visitVarStmt := method(Exception raise("visitVarStmt is unimplemented"))
    visitWhileStmt := method(Exception raise("visitWhileStmt is unimplemented"))
  )
  Block := lazySlot(
    Stmt clone do(
      with := method(statements,
        t := self clone
        t setSlot("stmtType", "Block")
        t setSlot("statements", statements)

        t accept = method(visitor,
          visitor visitBlockStmt(self)
        )
        t
      )
    )
  )
  Expression := lazySlot(
    Stmt clone do(
      with := method(expression,
        t := self clone
        t setSlot("stmtType", "Expression")
        t setSlot("expression", expression)

        t accept = method(visitor,
          visitor visitExpressionStmt(self)
        )
        t
      )
    )
  )
  Function := lazySlot(
    Stmt clone do(
      with := method(name, params, body,
        t := self clone
        t setSlot("stmtType", "Function")
        t setSlot("name", name)
        t setSlot("params", params)
        t setSlot("body", body)

        t accept = method(visitor,
          visitor visitFunctionStmt(self)
        )
        t
      )
    )
  )
  If := lazySlot(
    Stmt clone do(
      with := method(condition, thenBranch, elseBranch,
        t := self clone
        t setSlot("stmtType", "If")
        t setSlot("condition", condition)
        t setSlot("thenBranch", thenBranch)
        t setSlot("elseBranch", elseBranch)

        t accept = method(visitor,
          visitor visitIfStmt(self)
        )
        t
      )
    )
  )
  Print := lazySlot(
    Stmt clone do(
      with := method(expression,
        t := self clone
        t setSlot("stmtType", "Print")
        t setSlot("expression", expression)

        t accept = method(visitor,
          visitor visitPrintStmt(self)
        )
        t
      )
    )
  )
  Return := lazySlot(
    Stmt clone do(
      with := method(keyword, value,
        t := self clone
        t setSlot("stmtType", "Return")
        t setSlot("keyword", keyword)
        t setSlot("value", value)

        t accept = method(visitor,
          visitor visitReturnStmt(self)
        )
        t
      )
    )
  )
  Var := lazySlot(
    Stmt clone do(
      with := method(name, initializer,
        t := self clone
        t setSlot("stmtType", "Var")
        t setSlot("name", name)
        t setSlot("initializer", initializer)

        t accept = method(visitor,
          visitor visitVarStmt(self)
        )
        t
      )
    )
  )
  While := lazySlot(
    Stmt clone do(
      with := method(condition, body,
        t := self clone
        t setSlot("stmtType", "While")
        t setSlot("condition", condition)
        t setSlot("body", body)

        t accept = method(visitor,
          visitor visitWhileStmt(self)
        )
        t
      )
    )
  )

  accept := method(Exception raise("accept() is unimplemented"))
)
