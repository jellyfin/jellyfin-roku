sub init()
  m.top.itemComponentName = "UserItem"
  m.top.content = SetData()
  'm.top.rowFocusAnimationStyle = "floatingFocus"
  m.top.showRowLabel = [false]
  UpdateSize()
  m.top.setFocus(true)
end sub

sub UpdateSize()
  dimensions = m.top.getScene().currentDesignResolution

  border = 200
  'm.top.translation = [border, border + 115]

  textHeight = 80
  itemWidth = 300
  itemHeight = 364

  m.top.visible = true

  ' Size of the individual rows
  m.top.itemSize = [1660, itemHeight]
  ' Spacing between Rows
  m.top.itemSpacing = [ 0, 40]

  ' Size of items in the row
  m.top.rowItemSize = [ itemWidth, itemHeight ]
  ' Spacing between items in the row
  m.top.rowItemSpacing = [ 40, 0 ]
end sub


function SetData()
  if m.top.ItemContent = invalid then
    data = CreateObject("roSGNode", "ContentNode")
    return data
  end if

  UserData = m.top.ItemContent
  data = CreateObject("roSGNode", "ContentNode")
  row = data.CreateChild("ContentNode")
  for each item in UserData
    row.appendChild(item)
  end for
  m.top.content = data
  UpdateSize()
  return data
end function

function onKeyEvent(key as string, press as boolean) as boolean
  if not press then return false

  if key = "OK" then
    m.top.UserSelected = m.top.ItemContent[m.top.rowItemFocused[1]].Name
  end if
  return false
end function
