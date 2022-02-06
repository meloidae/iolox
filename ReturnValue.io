ReturnValue := Exception clone do(
  value := nil

  with := method(value,
    r := self clone
    r setSlot("value", value)
    r
  )
)
