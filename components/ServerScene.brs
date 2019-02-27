sub init()
    m.top.backgroundColor = "#000b35ff"
    m.top.backgroundURI = ""

    m.top.setFocus(true)
end sub

function onDialogButton()
  d = m.top.dialog
  button_text = d.buttons[d.buttonSelected]

  if button_text = "OK"
    ' TODO - pick right field
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


function submit()
  set_setting("server", m.hostname)
  set_setting("port", m.port)
end function
