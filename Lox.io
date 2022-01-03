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
    # Just print scanned tokens for now
    tokens foreach(token, writeln(token toString))
  )
  
  error := method(line, msg,
    report(line, "", msg)
  )
  
  report := method(line, where, msg,
    File standardError writeln(
      "[line " .. line .. "] Error" .. where .. ": " .. msg
    )
  )
)

arguments := System args
nargs := arguments size

# Print usage and exit if there are too many args
if (nargs > 2,
  writeln("Usage: jlox [script]")
  System exit(64)
)

if (nargs == 2,
  # Execute file
  Lox runFile(arguments at(1)),
  # Interactive
  Lox runPrompt
)
