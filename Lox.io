Lox := Object clone do(
  # Keeps track of error status
  hadError := false
  
  runFile := method(path,
    # Read file contents from a given path and run
    contents := (File openForReading(path)) contents
    run(contents)
    if(hadError, System exit(65))
  )
  
  runPrompt := method(
    # Open stdin
    reader := File standardInput
  
    # Read loop
    loop(
      write("> ")
      line := reader readLine
      if(line isNil, break)
      run(line)
      hadError := false
    )
  )
  
  run := method(source,
    scanner := Scanner with(source)
    tokens := scanner scanTokens
    # Parse an expression
    parser := Parser with(tokens)
    expression := parser parse

    # Stop if there was a syntax error
    if(self hadError, return)

    writeln(AstPrinter printExpr(expression))
  )
  
  error := method(arg1, arg2,
    # Branch to different error functions depending on the type of 1st argument
    if(arg1 type == Token type,
      _tokenError(arg1, arg2),
      _lineError(arg1, arg2)
    )
  )

  _tokenError := method(token, msg,
    if(token tokenType == TokenType EOF,
      report(token line, " at end", msg),
      report(token line, " at '" .. (token lexeme) .. "'", msg)
    )
  )

  _lineError := method(line, msg,
    report(line, "", msg)
  )
  
  report := method(line, where, msg,
    # Print error to stderr
    File standardError writeln(
      "[line " .. line .. "] Error" .. where .. ": " .. msg
    )
    self hadError = true
  )
)

arguments := System args
nargs := arguments size

# Print usage and exit if there are too many args
if (nargs > 2,
  writeln("Usage: Lox.io [script]")
  System exit(64)
)

if (nargs == 2,
  # Execute file
  Lox runFile(arguments at(1)),
  # Interactive
  Lox runPrompt
)
