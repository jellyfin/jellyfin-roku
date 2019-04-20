function initGlobal()
  if m.globals = invalid
    m.globals = CreateObject("roAssociativeArray")
  end if
end function

function getGlobal(key="" as String) as Dynamic
  initGlobal()
  return m.globals[key]
end function

function setGlobal(key="" as String, value=invalid as Dynamic)
  initGlobal()
  m.globals[key] = value
end function
