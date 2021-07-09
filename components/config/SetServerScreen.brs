sub init()
  m.top.setFocus(true)
  m.top.optionsAvailable = false

  m.spinner = m.top.findNode("spinner")
  m.serverPicker = m.top.findNode("serverPicker")
  m.serverUrlTextbox = m.top.findNode("serverUrlTextbox")
  m.serverUrlContainer = m.top.findNode("serverUrlContainer")
  m.serverUrlOutline = m.top.findNode("serverUrlOutline")
  m.submit = m.top.findNode("submit")

  m.serverPicker.setFocus(true)
  ScanForServers()

end sub

function onKeyEvent(key as string, press as boolean) as boolean
  print "onKeyEvent", key, press

  if not press then return true
  handled = true

  if key = "OK" and m.serverPicker.hasFocus() then
    m.top.serverUrl = m.serverPicker.content.getChild(m.serverPicker.itemFocused).baseUrl
    m.submit.setFocus(true)
    'if the user pressed the down key and we are already at the last child of server picker, then change focus to the url textbox
  else if key = "down" and m.serverPicker.hasFocus() and m.serverPicker.itemFocused = m.serverPicker.content.getChildCount() - 1
    m.serverUrlContainer.setFocus(true)
  else if key = "up" and m.serverUrlContainer.hasFocus()
    m.serverPicker.setFocus(true)
  else if key = "OK" and m.serverUrlContainer.hasFocus()
    ShowKeyboard()
    'focus the serverUrl input from submit button
  else if key = "up" and m.submit.hasFocus()
    m.serverUrlContainer.setFocus(true)
    'focus the submit button from serverUrl
  else if key = "down" and m.serverUrlContainer.hasFocus()
    m.submit.setFocus(true)
  else
    handled = false
  end if
  'show/hide input box outline
  m.serverUrlOutline.visible = m.serverUrlContainer.isInFocusChain()
  return handled
end function

function ScanForServers()
  m.ssdpScanner = CreateObject("roSGNode", "SSDPTask")
  'run the task
  m.ssdpScanner.observeField("content", "ScanForServersComplete")
  m.ssdpScanner.control = "RUN"
end function

sub ScanForServersComplete(event)
  servers = event.getData()
  items = CreateObject("roSGNode", "ContentNode")
  for each server in servers
    server.subtype = "ContentNode"
    'add new fields for every server property onto the ContentNode (rather than making a dedicated component just to hold data...)
    items.update([server], true)
  end for
  m.serverPicker.content = items
  m.spinner.visible = false
end sub

function ShowKeyboard()
  dialog = createObject("roSGNode", "KeyboardDialog")
  dialog.title = "Enter the server name or ip address"
  dialog.buttons = [tr("OK"), tr("Cancel")]
  dialog.text = m.serverUrlTextbox.text

  m.top.getscene().dialog = dialog
  m.dialog = dialog

  dialog.observeField("buttonSelected", "onDialogButton")
end function

function onDialogButton()
  d = m.dialog
  button_text = d.buttons[d.buttonSelected]

  if button_text = tr("OK")
    m.serverUrlTextbox.text = d.text
    m.dialog.close = true
    return true
  else if button_text = tr("Cancel")
    m.dialog.close = true
    return true
  end if
end function
