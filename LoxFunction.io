LoxFunction := LoxCallable clone do(
  with := method(declaration,
    f := self clone
    f setSlot("declaration", declaration)
    f
  )

  arity := method(
    self declaration params size
  )

  doCall := method(interpreter, arguments,
    # Store arguments in the newly created environment
    environment := Environment with(interpreter globals)
    for(i, 0, self declaration params size - 1,
      environment define(self declaration params at(i) lexeme, arguments at(i))
    )

    # Execute with body with the new environment
    interpreter executeBlock(self declaration body, environment)
  )

  asString := method(
    "<fn " .. (self declaration name lexeme) .. ">"
  )
)
