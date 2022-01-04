LoxUtils := Object clone do(
  cond := method(
    for(i, 0, call message argCount - 1, 2,
      if (call sender doMessage(call message argAt(i)),
        call sender doMessage(call message argAt(i + 1))
        break
      )
    )
  )
)
