sub init()
    m.top.backgroundColor = "#000b35ff"
    m.top.backgroundURI = ""

    m.top.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if not press then return false
  list = m.top.findNode("configOptions")
  button = m.top.findNode("submit")
  if key = "down" and button.focusedChild = invalid
    limit = list.content.getChildren(-1, 0).count() - 1

    if limit = list.itemFocused
      m.top.setFocus(false)
      button.setFocus(true)
      return true
    end if
  else if key = "up" and button.focusedChild <> invalid
    list.setFocus(true)
    return true
  end if
  return false
end function
