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
  if val(hours) > 0 then r = hours + ":"
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

'Returns the item selected or -1 on backpress or other unhandled closure of dialog.
function get_dialog_result(dialog, port)
  while dialog <> invalid
    msg = wait(0, port)
    if isNodeEvent(msg, "backPressed") then
      return -1
    elseif isNodeEvent(msg, "itemSelected")
      return dialog.findNode("optionList").itemSelected 
    end if
  end while
  'Dialog has closed outside of this loop, return -1 for failure
  return -1
end function

function lastFocusedChild(obj as object) as object
  child = obj
  for i = 0 to obj.getChildCount()
    if obj.focusedChild <> invalid then
      child = child.focusedChild
    end if 
  end for 
  return child
end function

function show_dialog(message as string, options = [], defaultSelection = 0) as integer
  group = m.scene.focusedChild
  lastFocus = lastFocusedChild(m.scene)
  'We want to handle backPressed instead of the main loop
  m.scene.unobserveField("backPressed")

  dialog = createObject("roSGNode", "JFMessageDialog")
  if options.count() then dialog.options = options
  if message.len() > 0 then
    reg = CreateObject("roFontRegistry")
    font = reg.GetDefaultFont()
    dialog.fontHeight = font.GetOneLineHeight()
    dialog.fontWidth = font.GetOneLineWidth(message, 999999999)
    dialog.message = message
  end if

  if defaultSelection > 0 then
    dialog.findNode("optionList").jumpToItem = defaultSelection
  end if

  dialog.visible = true
  m.scene.appendChild(dialog)
  dialog.setFocus(true)

  port = CreateObject("roMessagePort")
  dialog.observeField("backPressed", port)
  dialog.findNode("optionList").observeField("itemSelected", port)

  result = get_dialog_result(dialog, port)

  m.scene.removeChildIndex(m.scene.getChildCount() - 1)
  lastFocus.setFocus(true)
  m.scene.observeField("backPressed", m.port)

  return result
end function

function message_dialog(message = "" as string)
  return show_dialog(message,["OK"])
end function

function option_dialog(options, message = "", defaultSelection = 0) as integer
  return show_dialog(message, options, defaultSelection)
end function
