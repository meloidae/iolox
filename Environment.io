Environment := Object clone do(
  enclosing := nil
  # Initialize an empty Map
  values := nil

  with := method(
    env := self clone
    env setSlot("values", Map with)
    if(call argCount >= 1,
      enclosingEnv := call evalArgAt(0)
      env setSlot("enclosing", enclosingEnv)
    )
    return(env)
  )

  get := method(name,
    if(self values hasKey(name lexeme),
      return(self values at(name lexeme))
    )

    # Check for the variable in the enclosing environment
    if(self enclosing != nil,
      return(self enclosing get(name))
    )

    RuntimeError with(name, "Undefined variable '" .. (name lexeme) .. "'.") raise
  )

  assign := method(name, value,
    if(self values hasKey(name lexeme),
      self values atPut(name lexeme, value)
      return
    )

    # Look for a target of assignment in the enclosing environment
    if(self enclosing != nil,
      self enclosing assign(name, value)
      return
    )

    # Assignment can't create a new variable so throw an error if a given name is not present
    RuntimeError with(name, "Undefined variable '" .. (name lexeme) .. "'.") raise
  )

  define := method(name, value,
    self values atPut(name, value)
  )
)
