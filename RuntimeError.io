RuntimeError := Exception clone do(
  token := nil
  msg := ""

  with := method(token, msg,
    err := self clone
    err setSlot("token", token)
    err setSlot("msg", msg)
    err
  )

  raise := method(
    call argCount switch(
      # Call raise() normally when argCounts are 1-2
      1, super(raise(call argAt(0))),
      2, super(raise(call argAt(0), call argAt(1))),
      # Otherwise, call raise() using the preset msg parameter
      super(raise(self msg))
    )
  )
)
