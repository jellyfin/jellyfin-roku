function init()
    m.title = m.top.findNode("title")
    m.description = m.top.findNode("description")
    m.selectedIcon = m.top.findNode("selectedIcon")
end function

function itemContentChanged()
    m.title.text = m.top.itemContent.title
    m.description.text = m.top.itemContent.description

    if m.top.itemContent.description = "" then
        m.title.translation = [50, 20]
    end if

    if m.top.itemContent.selected then
        m.selectedIcon.uri = m.global.constants.icons.check_white
    else
        m.selectedIcon.uri = ""
    end if

end function

'
'Scroll description if focused
sub focusChanged()

    if m.top.itemHasFocus = true then
      m.description.repeatCount = -1
    else
      m.description.repeatCount = 0
    end if
  
end sub