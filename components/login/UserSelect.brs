sub init()
end sub

sub ItemContentChanged()
  m.top.findNode("UserRow").ItemContent = m.top.ItemContent
  Redraw()
end sub

sub Redraw()
  UserCount = m.top.ItemContent.Count()
  TopBorder = 360
  LeftBorder= 130
  ItemWidth = 300
  ItemSpacing = 40

  if UserCount < 5 then
    LeftBorder = (1920 - ((UserCount * ItemWidth) + ((UserCount - 1) * ItemSpacing))) / 2
  end if
'   break()
  m.top.findNode("UserRow").translation = [LeftBorder, TopBorder]
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  if not press then return false

  if key = "back" then
    m.top.backPressed = true
  else if key = "up" then
    if m.top.focusedChild.isSubType("LabelList") then
      m.top.findNode("UserRow").setFocus(true)
      return true
    end if
  else if key = "down" then
    if m.top.focusedChild.isSubType("UserRow") then
      m.top.findNode("AlternateOptions").setFocus(true)
      return true
    end if
  end if
  return false
end function
