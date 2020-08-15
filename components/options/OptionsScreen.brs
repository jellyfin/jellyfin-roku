sub init() 

	m.buttons = m.top.findNode("buttons")
  m.buttons.buttons = ["View", "Sort", "Filter"]
  m.buttons.setFocus(true)

  m.ascending = true
  m.selectedSortIndex = 0

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
    m.top.findNode("buttons").setFocus(false)
    m.menus[m.selectedItem].setFocus(true)
    return true
	else if key = "OK"
    print "OS Key OK"

    ' Handle Sort screen
    if(m.selectedItem = 1) then
      if m.menus[1].itemSelected  <> m.selectedSortIndex then
        print "OS - Resetting to ASC"
        m.menus[1].focusedCheckedIconUri = "pkg:/images/icons/up_black.png"
        m.menus[1].checkedIconUri="pkg:/images/icons/up_white.png"
        m.selectedSortIndex = m.menus[1].itemSelected
        m.ascending = true
      else
        if m.ascending = true then
          print "Setting ascending to false"
          m.ascending = false
          m.menus[1].focusedCheckedIconUri = "pkg:/images/icons/down_black.png"
          m.menus[1].checkedIconUri="pkg:/images/icons/down_white.png"
        else
          print "Setting ascending to true"
          m.ascending = true
          m.menus[1].focusedCheckedIconUri = "pkg:/images/icons/up_black.png"
          m.menus[1].checkedIconUri="pkg:/images/icons/up_white.png"
        end if
      end if
    end if
    return true
  else if key = "back" OR key = "up"
    if m.menus[m.selectedItem].isInFocusChain() then
      m.buttons.setFocus(true)
      return true
    end if
  else
'    print "Key Unhandled"
    return false
  end if

  print "Moo?????"
end function