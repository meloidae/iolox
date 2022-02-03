LoxCallable := Object clone do(
  arity := method(Exception raise("arity is unimplemented"))
  doCall := method(Exception raise("doCall is unimplemented"))
)
