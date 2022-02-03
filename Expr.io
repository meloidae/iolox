Expr := Object clone do(
  Visitor := Object clone do(
    visitAssignExpr := method(Exception raise("visitAssignExpr is unimplemented"))
    visitBinaryExpr := method(Exception raise("visitBinaryExpr is unimplemented"))
    visitCallExpr := method(Exception raise("visitCallExpr is unimplemented"))
    visitGroupingExpr := method(Exception raise("visitGroupingExpr is unimplemented"))
    visitLiteralExpr := method(Exception raise("visitLiteralExpr is unimplemented"))
    visitLogicalExpr := method(Exception raise("visitLogicalExpr is unimplemented"))
    visitUnaryExpr := method(Exception raise("visitUnaryExpr is unimplemented"))
    visitVariableExpr := method(Exception raise("visitVariableExpr is unimplemented"))
  )
  Assign := lazySlot(
    Expr clone do(
      with := method(name, value,
        t := self clone
        t setSlot("exprType", "Assign")
        t setSlot("name", name)
        t setSlot("value", value)

        t accept = method(visitor,
          visitor visitAssignExpr(self)
        )
        t
      )
    )
  )
  Binary := lazySlot(
    Expr clone do(
      with := method(left, operator, right,
        t := self clone
        t setSlot("exprType", "Binary")
        t setSlot("left", left)
        t setSlot("operator", operator)
        t setSlot("right", right)

        t accept = method(visitor,
          visitor visitBinaryExpr(self)
        )
        t
      )
    )
  )
  Call := lazySlot(
    Expr clone do(
      with := method(callee, paren, arguments,
        t := self clone
        t setSlot("exprType", "Call")
        t setSlot("callee", callee)
        t setSlot("paren", paren)
        t setSlot("arguments", arguments)

        t accept = method(visitor,
          visitor visitCallExpr(self)
        )
        t
      )
    )
  )
  Grouping := lazySlot(
    Expr clone do(
      with := method(expression,
        t := self clone
        t setSlot("exprType", "Grouping")
        t setSlot("expression", expression)

        t accept = method(visitor,
          visitor visitGroupingExpr(self)
        )
        t
      )
    )
  )
  Literal := lazySlot(
    Expr clone do(
      with := method(value,
        t := self clone
        t setSlot("exprType", "Literal")
        t setSlot("value", value)

        t accept = method(visitor,
          visitor visitLiteralExpr(self)
        )
        t
      )
    )
  )
  Logical := lazySlot(
    Expr clone do(
      with := method(left, operator, right,
        t := self clone
        t setSlot("exprType", "Logical")
        t setSlot("left", left)
        t setSlot("operator", operator)
        t setSlot("right", right)

        t accept = method(visitor,
          visitor visitLogicalExpr(self)
        )
        t
      )
    )
  )
  Unary := lazySlot(
    Expr clone do(
      with := method(operator, right,
        t := self clone
        t setSlot("exprType", "Unary")
        t setSlot("operator", operator)
        t setSlot("right", right)

        t accept = method(visitor,
          visitor visitUnaryExpr(self)
        )
        t
      )
    )
  )
  Variable := lazySlot(
    Expr clone do(
      with := method(name,
        t := self clone
        t setSlot("exprType", "Variable")
        t setSlot("name", name)

        t accept = method(visitor,
          visitor visitVariableExpr(self)
        )
        t
      )
    )
  )

  accept := method(Exception raise("accept() is unimplemented"))
)
