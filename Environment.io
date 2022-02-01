Environment := Object clone do(
  # Initialize an empty Map
  values := Map with

  get := method(name,
    if(self values hasKey(name lexeme),
      return(self values at(name lexeme))
    )

    RuntimeError with(name, "Undefined variable '" .. (name lexeme) .. "'.") raise
  )

  assign := method(name, value,
    if(self values hasKey(name lexeme),
      self values atPut(name lexeme, value)
      return
    )

    # Assignment can't create a new variable so throw an error if a given name is not present
    RuntimeError with(name, "Undefined variable '" .. (name lexeme) .. "'.") raise
  )

  define := method(name, value,
    self values atPut(name, value)
  )
)
