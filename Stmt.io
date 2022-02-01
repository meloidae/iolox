Stmt := Object clone do(
  Visitor := Object clone do(
    visitExpressionStmt := method(Exception raise("visitExpressionStmt is unimplemented"))
    visitPrintStmt := method(Exception raise("visitPrintStmt is unimplemented"))
    visitVarStmt := method(Exception raise("visitVarStmt is unimplemented"))
  )
  Expression := lazySlot(
    Stmt clone do(
      with := method(expression,
        t := self clone
        t setSlot("expression", expression)

        t accept = method(visitor,
          visitor visitExpressionStmt(self)
        )
        t
      )
    )
  )
  Print := lazySlot(
    Stmt clone do(
      with := method(expression,
        t := self clone
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