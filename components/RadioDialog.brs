import "pkg:/source/utils/misc.brs"

sub init()
    m.contentArea = m.top.findNode("contentArea")
    m.radioOptions = m.top.findNode("radioOptions")
    m.scrollBar = []

    m.top.observeField("contentData", "onContentDataChanged")
    m.top.observeFieldScoped("buttonSelected", "onButtonSelected")

    m.radioOptions.observeField("focusedChild", "onItemFocused")

    m.top.id = "OKDialog"
    m.top.height = 900
end sub

' Event handler for when user selected a button
sub onButtonSelected()
    if m.top.buttonSelected = 0
        m.global.sceneManager.returnData = m.top.contentData.data[m.radioOptions.selectedIndex]
    end if
end sub

' Event handler for when user's cursor highlights an option in the option list
sub onItemFocused()
    focusedChild = m.radioOptions.focusedChild
    if not isValid(focusedChild) then return

    ' We hide the scrollbar here because we must ensure not only that content has been loaded, but that Roku has drawn the popup
    hideScrollBar()

    ' If a scrollbar is found, move the option list to the user's section
    if m.scrollBar.count() <> 0
        hightedButtonTranslation = m.radioOptions.focusedChild.translation
        m.radioOptions.translation = [m.radioOptions.translation[0], -1 * hightedButtonTranslation[1]]
    end if

end sub

' Hide the popup's scroll bar
sub hideScrollBar()
    ' If we haven't found the scrollbar node yet, try to find it now
    if m.scrollBar.count() = 0
        m.scrollBar = findNodeBySubtype(m.contentArea, "StdDlgScrollbar")
        if m.scrollBar.count() = 0 or not isValid(m.scrollBar[0]) or not isValid(m.scrollBar[0].node)
            return
        end if
    end if

    ' Don't waste time trying to hide it if it's already hidden
    if not m.scrollBar[0].node.visible then return

    m.scrollBar[0].node.visible = false
end sub

' Once user selected an item, move cursor down to OK button
sub onItemSelected()
    buttonArea = findNodeBySubtype(m.top, "StdDlgButtonArea")

    if buttonArea.count() <> 0 and isValid(buttonArea[0]) and isValid(buttonArea[0].node)
        buttonArea[0].node.setFocus(true)
    end if
end sub

sub onContentDataChanged()
    i = 0
    for each item in m.top.contentData.data
        cardItem = m.radioOptions.CreateChild("StdDlgActionCardItem")
        cardItem.iconType = "radiobutton"
        cardItem.id = i

        if isValid(item.selected)
            m.radioOptions.selectedIndex = i
        end if

        textLine = cardItem.CreateChild("SimpleLabel")
        textLine.text = item.track.description
        cardItem.observeField("selected", "onItemSelected")
        i++
    end for
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "up"
        ' By default UP from the OK button is the scrollbar
        ' Instead, move the user to the option list
        if not m.radioOptions.isinFocusChain()
            m.radioOptions.setFocus(true)
            return true
        end if
    end if

    return false
end function
