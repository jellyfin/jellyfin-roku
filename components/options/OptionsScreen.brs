sub init()

  m.buttons = m.top.findNode("buttons")
  m.buttons.buttons = [tr("View"), tr("Sort"), tr("Filter")]
  m.buttons.setFocus(true)

  m.selectedSortIndex = 0
  m.selectedItem = 1

  m.menus = []
  m.menus.push(m.top.findNode("viewMenu"))
  m.menus.push(m.top.findNode("sortMenu"))
  m.menus.push(m.top.findNode("filterMenu"))

  m.viewNames = []
  m.sortNames = []

  m.buttons.observeField("focusedIndex", "buttonFocusChanged")

end sub


sub optionsSet()

  '  Views Tab
  if m.top.options.views <> invalid then
    viewContent = CreateObject("roSGNode", "ContentNode")
    index = 0
    selectedViewIndex = 0

    for each view in m.top.options.views
      entry = viewContent.CreateChild("ContentNode")
      entry.title = view.Title
      m.viewNames.push(view.Name)
      if view.selected <> invalid and view.selected = true then
        selectedViewIndex = index
      end if
      index = index + 1
    end for
    m.menus[0].content = viewContent
    m.menus[0].checkedItem = selectedViewIndex
  end if

  ' Sort Tab
  if m.top.options.sort <> invalid then
    sortContent = CreateObject("roSGNode", "ContentNode")
    index = 0
    m.selectedSortIndex = 0

    for each sortItem in m.top.options.sort
      entry = sortContent.CreateChild("ContentNode")
      entry.title = sortItem.Title
      m.sortNames.push(sortItem.Name)
      if sortItem.Selected <> invalid and sortItem.Selected = true then
        m.selectedSortIndex = index
        if sortItem.Ascending <> invalid and sortItem.Ascending = false then
          m.top.sortAscending = 0
        else
          m.top.sortAscending = 1
        end if
      end if
      index = index + 1
    end for
    m.menus[1].content = sortContent
    m.menus[1].checkedItem = m.selectedSortIndex

    if m.top.sortAscending = 1 then
      m.menus[1].focusedCheckedIconUri = m.global.constants.icons.ascending_black
      m.menus[1].checkedIconUri = m.global.constants.icons.ascending_white
    else
      m.menus[1].focusedCheckedIconUri = m.global.constants.icons.descending_black
      m.menus[1].checkedIconUri = m.global.constants.icons.descending_white
    end if
  end if

end sub


sub buttonFocusChanged()
  if m.buttons.focusedIndex = m.selectedItem then return
  m.menus[m.selectedItem].visible = false
  m.menus[m.buttons.focusedIndex].visible = true
  m.selectedItem = m.buttons.focusedIndex
end sub


function onKeyEvent(key as string, press as boolean) as boolean

  if key = "down" OR (key = "OK" AND m.top.findNode("buttons").hasFocus()) then
    m.top.findNode("buttons").setFocus(false)
    m.menus[m.selectedItem].setFocus(true)
    m.menus[m.selectedItem].drawFocusFeedback = true
    return true
  else if key = "OK"
    ' Handle Sort screen
    if(m.menus[m.selectedItem].isInFocusChain()) then
      if(m.selectedItem = 1) then
        if m.menus[1].itemSelected <> m.selectedSortIndex then
          m.menus[1].focusedCheckedIconUri = m.global.constants.icons.ascending_black
          m.menus[1].checkedIconUri = m.global.constants.icons.ascending_white

          m.selectedSortIndex = m.menus[1].itemSelected
          m.top.sortAscending = true
          m.top.sortField = m.sortNames[m.selectedSortIndex]
        else

          if m.top.sortAscending = true then
            m.top.sortAscending = false
            m.menus[1].focusedCheckedIconUri = m.global.constants.icons.descending_black
            m.menus[1].checkedIconUri = m.global.constants.icons.descending_white
          else
            m.top.sortAscending = true
            m.menus[1].focusedCheckedIconUri = m.global.constants.icons.ascending_black
            m.menus[1].checkedIconUri = m.global.constants.icons.ascending_white
          end if
        end if
      end if
    end if
    return true
  else if key = "back" or key = "up"
    if m.menus[m.selectedItem].isInFocusChain() then
      m.buttons.setFocus(true)
      m.menus[m.selectedItem].drawFocusFeedback = false
      return true
    end if
  else if key = "options"
    m.menus[m.selectedItem].drawFocusFeedback = false
    return false
  end if

  return false

end function