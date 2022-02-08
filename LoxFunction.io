LoxFunction := LoxCallable clone do(
  declartion := nil
  closure := nil

  with := method(declaration, closure,
    f := self clone
    f setSlot("declaration", declaration)
    f setSlot("closure", closure)
    f
  )

  arity := method(
    self declaration params size
  )

  doCall := method(interpreter, arguments,
    # Store arguments in the newly created environment
    environment := Environment with(self closure)
    for(i, 0, self declaration params size - 1,
      environment define(self declaration params at(i) lexeme, arguments at(i))
    )

    ret := nil
    # Catch any return value as a part of Exception (Return)
    e := try(
      # Execute with body with the new environment
      interpreter executeBlock(self declaration body, environment)
    )
    e catch(ReturnValue,
      ret = e value
    ) pass

    ret
  )

  asString := method(
    "<fn " .. (self declaration name lexeme) .. ">"
  )
)
