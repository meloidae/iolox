defineAst := method(outputDir, baseName, types,
  path := outputDir .. "/" .. baseName .. ".io"
  f := File with(path) remove
  writer := f open(path)

  writer write(baseName .. " := Object clone do(", "\n")
  
  defineVisitor(writer, baseName, types)
  
  # All AST classes.
  types foreach(typeStr,
    typeSplit := typeStr split(":")
    className := typeSplit at(0) strip
    fields := typeSplit at(1) strip
    defineType(writer, baseName, className, fields)
  )

  # Base accept method
  writer write("\n")
  writer write("  accept := method(Exception raise(\"accept() is unimplemented\"))", "\n")

  writer write(")", "\n")
  writer close
)

defineVisitor := method(writer, baseName, types,
  writer write("  Visitor := Object clone do(", "\n")
  types foreach(typeStr,
    typeName := typeStr split(":") at(0) strip
    methodName := "visit" .. typeName .. baseName
    writer write("    " .. methodName .. " := method(Exception raise(\"" .. methodName .." is unimplemented\"))")
    writer write("\n")
  )
  writer write("  )", "\n")
)

defineType := method(writer, baseName, className, fieldList,
  # Initialize as slot
  writer write("  " .. className .. " := lazySlot(", "\n")
  writer write("    " .. baseName .. " clone do(", "\n")

  # Define with method (constructor)
  writer write("      with := method(" .. fieldList .. ",", "\n")
  writer write("        t := self clone", "\n")
  # Define subtype
  writer write("        t setSlot(\"" .. (baseName asLowercase) .. "Type\", \"" .. className .. "\")", "\n")
  # Strore parameters in slots
  fields := fieldList split(",")
  fields foreach(value,
    value := value strip
    writer write("        t setSlot(\"" .. value .. "\", " .. value .. ")", "\n")
  )
  # Visitor pattern
  writer write("\n")
  writer write("        t accept = method(visitor,", "\n")
  writer write("          visitor visit" .. className .. baseName .. "(self)", "\n")
  writer write("        )", "\n")
  writer write("        t", "\n")
  writer write("      )", "\n")

  writer write("    )", "\n")
  writer write("  )", "\n")
)

args := System args

if(args size != 2,
  writeln("Usage: generate_ast <output directory>")
  System exit(64)
)

outputDir := args at(1)
# Expression
defineAst(outputDir, "Expr",
  list(
    "Assign   : name, value",
    "Binary   : left, operator, right",
    "Grouping : expression",
    "Literal  : value",
    "Logical  : left, operator, right",
    "Unary    : operator, right",
    "Variable : name"
  )
)

# Statement
defineAst(outputDir, "Stmt",
  list(
    "Block      : statements",
    "Expression : expression",
    "If         : condition, thenBranch, elseBranch",
    "Print      : expression",
    "Var        : name, initializer",
    "While      : condition, body"
  )
)
