sub init()
    m.top.backgroundColor = "#000b35ff"
    m.top.backgroundURI = ""

    m.top.setFocus(true)

    m.focused_options = [
      m.top.findNode("host"),
      m.top.findNode("port")
    ]
    m.focused_index = 0
    m.focused_item = m.focused_options[m.focused_index]
    focus_node(m.focused_item)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if (key = "OK") then
      show_dialog(m.focused_item.id)
      return true
    else if (key = "up") then
      ' Already at the top, ignore
      if m.focused_index = 0 then
        return true
      end if

      unfocus_node(m.focused_item)
      m.focused_index = m.focused_index - 1
      m.focused_item = m.focused_options[m.focused_index]
      focus_node(m.focused_item)
      return true
    else if (key = "down") then
      ' Already at the bottom, ignore
      if m.focused_index = (m.focused_options.count() - 1) then
        return true
      end if

      unfocus_node(m.focused_item)
      m.focused_index = m.focused_index + 1
      m.focused_item = m.focused_options[m.focused_index]
      focus_node(m.focused_item)
      return true
    end if
  end if

  return false

end function


sub focus_node(node)
  node.textColor = "#ffffff"
  node.hintTextColor = "#999999"
end sub

sub unfocus_node(node)
  node.textColor = "#777777"
  node.hintTextColor = "#555555"
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
