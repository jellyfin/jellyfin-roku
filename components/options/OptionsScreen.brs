sub init() 

	m.buttons = m.top.findNode("buttons")
  m.buttons.buttons = ["View", "Sort", "Filter"]
  m.buttons.setFocus(true)

  m.ascending = true
  m.selectedItem = 1

  m.menus = []
  m.menus.push(m.top.findNode("viewMenu"))
  m.menus.push(m.top.findNode("sortMenu"))
  m.menus.push(m.top.findNode("filterMenu"))

  m.buttons.observeField("focusedIndex", "buttonFocusChanged")

end sub



sub buttonFocusChanged()

  print "Button focus changed to index ", m.buttons.focusedIndex

  if m.buttons.focusedIndex = m.selectedItem then return

  print "Hiding " m.selectedItem
  m.menus[m.selectedItem].visible = false

  print "Showing " m.buttons.focusedIndex
  m.menus[m.buttons.focusedIndex].visible = true

  m.selectedItem = m.buttons.focusedIndex

end sub


function onKeyEvent(key as string, press as boolean) as boolean
    

'	print "OS KeyPress " key
	
	if not press then
'    print "OS Not Press!!"
'   return false
  end if

	if key = "down"
'  	print "OS Down Pressed.else.else.else.else.else.else.else.else. " 
    m.top.findNode("buttons").setFocus(false)
    m.top.findNode("sortMenu").setFocus(true)
    return true
	else if key = "OK"
    print "OS Key OK"

    ' if m.optionList.itemSelected  <> m.selectedItem then
    '   print "OS - Resetting to ASC"
    '   m.optionList.focusedCheckedIconUri = "pkg:/images/icons/up_black.png"
    '   m.optionList.checkedIconUri="pkg:/images/icons/up_white.png"
    '   m.selectedItem = m.optionList.itemSelected
    '   m.ascending = true
    ' else
    '   if m.ascending = true then
    '     print "Setting ascending to false"
    '     m.ascending = false
    '     m.optionList.focusedCheckedIconUri = "pkg:/images/icons/down_black.png"
    '     m.optionList.checkedIconUri="pkg:/images/icons/down_white.png"
    '   else
    '     print "Setting ascending to true"
    '     m.ascending = true
    '     m.optionList.focusedCheckedIconUri = "pkg:/images/icons/up_black.png"
    '     m.optionList.checkedIconUri="pkg:/images/icons/up_white.png"
    '   end if
    ' end if
    return true
  else if key = "back"
    if m.sortMenu.isInFocusChain() then
      m.buttons.setFocus(true)
      return true
    end if
  else
'    print "Key Unhandled"
    return false
  end if

  print "Moo?????"
end function