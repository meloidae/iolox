Scanner := Object clone do(
)

runFile := method(path,
  # Read file contents from a given path and run
  contents := (File openForReading(path)) contents
  run(contents)
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
  )

  reader close
)

run := method(contents,
  writeln(contents)
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
  runFile(arguments at(1)),
  # Interactive
  runPrompt
)
