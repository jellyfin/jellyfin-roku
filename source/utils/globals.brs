sub initGlobal()
  if m.globals = invalid
    m.globals = CreateObject("roAssociativeArray")
  end if
end sub

function getGlobal(key="" as String) as Dynamic
  initGlobal()
  return m.globals[key]
end function

sub setGlobal(key="" as String, value=invalid as Dynamic)
  initGlobal()
  m.globals[key] = value
end sub
