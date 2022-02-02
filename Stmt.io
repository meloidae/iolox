Stmt := Object clone do(
  Visitor := Object clone do(
    visitBlockStmt := method(Exception raise("visitBlockStmt is unimplemented"))
    visitExpressionStmt := method(Exception raise("visitExpressionStmt is unimplemented"))
    visitIfStmt := method(Exception raise("visitIfStmt is unimplemented"))
    visitPrintStmt := method(Exception raise("visitPrintStmt is unimplemented"))
    visitVarStmt := method(Exception raise("visitVarStmt is unimplemented"))
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

  accept := method(Exception raise("accept() is unimplemented"))
)
