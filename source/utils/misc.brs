function isNodeEvent(msg, field as string) as boolean
  return type(msg) = "roSGNodeEvent" and msg.getField() = field
end function


function getMsgPicker(msg, subnode = "" as string) as object
  node = msg.getRoSGNode()
  ' Subnode allows for handling alias messages
  if subnode <> ""
    node = node.findNode(subnode)
  end if
  coords = node.rowItemSelected
  target = node.content.getChild(coords[0]).getChild(coords[1])
  return target
end function

function getButton(msg, subnode = "buttons" as string) as object
  buttons = msg.getRoSGNode().findNode(subnode)
  active_button = buttons.focusedChild

  return active_button
end function

sub themeScene()
  ' Takes a scene and applies a consisten UI Theme
  m.scene.backgroundColor = "#101010"
  m.scene.backgroundURI = ""

  m.scene.insertChild(m.overhang, 0)
end sub

function leftPad(base as string, fill as string, length as integer) as string
  while len(base) < length
    base = fill + base
  end while
  return base
end function

function ticksToHuman(ticks as longinteger) as string
  totalSeconds = int(ticks / 10000000)
  hours = stri(int(totalSeconds / 3600)).trim()
  minutes = stri(int((totalSeconds - (val(hours)*3600))/60)).trim()
  seconds = stri(totalSeconds - (val(hours)*3600) - (val(minutes)*60)).trim()
  if val(hours) > 0 and val(minutes) < 10 then minutes = "0" + minutes
  if val(seconds) < 10 then seconds = "0" + seconds
  r=""
  if val(hours) > 0 then r = stri(hours).trim() + ":"
  r = r + minutes + ":" + seconds
  return r
end function

function div_ceiling(a as integer, b as integer) as integer
  if a < b then return 1
  if int(a/b) = a/b then
    return a/b
  end if
  return a/b + 1
end function

function message_dialog(message = "" as string)
  ' Takes a string and returns an object for dialog popup
  dialog = createObject("roSGNode", "JFMessageDialog")
  dialog.id = "popup"
  dialog.buttons = ["OK"]
  dialog.message = message

  m.scene.dialog = dialog
  m.scene.dialog.setFocus(true)
end function

function option_dialog(options) as integer
  dialog = CreateObject("roSGNode", "JFMessageDialog")
  dialog.backExitsDialog = false
  dialog.buttons = options
  m.scene.dialog = dialog
  m.scene.dialog.setFocus(true)
  
  while m.scene.dialog <> invalid
  end while
  
  return dialog.buttonSelected
end function
