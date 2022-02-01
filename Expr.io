Expr := Object clone do(
  Visitor := Object clone do(
    visitBinaryExpr := method(Exception raise("visitBinaryExpr is unimplemented"))
    visitGroupingExpr := method(Exception raise("visitGroupingExpr is unimplemented"))
    visitLiteralExpr := method(Exception raise("visitLiteralExpr is unimplemented"))
    visitUnaryExpr := method(Exception raise("visitUnaryExpr is unimplemented"))
    visitVariableExpr := method(Exception raise("visitVariableExpr is unimplemented"))
  )
  Binary := lazySlot(
    Expr clone do(
      with := method(left, operator, right,
        t := self clone
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
  Grouping := lazySlot(
    Expr clone do(
      with := method(expression,
        t := self clone
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
        t setSlot("value", value)

        t accept = method(visitor,
          visitor visitLiteralExpr(self)
        )
        t
      )
    )
  )
  Unary := lazySlot(
    Expr clone do(
      with := method(operator, right,
        t := self clone
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
