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

function onDialogButton()
  d = m.top.dialog
  button_text = d.buttons[d.buttonSelected]

  if button_text = "OK"
    m.focused_item.text = d.text
    dismiss_dialog()
    return true
  else if button_text = "Cancel"
    dismiss_dialog()
    return false
  end if
end function


sub show_dialog(title as String)
  dialog = createObject("roSGNode", "KeyboardDialog")
  dialog.title = "Enter the " + m.focused_item.id
  dialog.buttons = ["OK", "Cancel"]

  if m.focused_item.text <> "" then
    dialog.text = m.focused_item.text
  end if

  m.top.dialog = dialog

  dialog.observeField("buttonSelected", "onDialogButton")
end sub

sub dismiss_dialog()
  m.top.dialog.close = true
end sub
