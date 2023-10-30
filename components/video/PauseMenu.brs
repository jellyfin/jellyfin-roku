import "pkg:/source/utils/misc.brs"

sub init()
    m.chapterNavigation = m.top.findNode("chapterNavigation")

    m.selectedButtonIndex = 0
    m.chapterNavigation.getChild(m.selectedButtonIndex).focus = true
end sub

sub onButtonSelected()
    selectedButton = m.chapterNavigation.getChild(m.selectedButtonIndex)

    if LCase(selectedButton.id) = "chapterlist"
        m.top.showChapterList = not m.top.showChapterList
    end if

    m.top.action = selectedButton.id
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "OK"
        onButtonSelected()
        return true
    end if

    if key = "right"
        if m.selectedButtonIndex + 1 >= m.chapterNavigation.getChildCount()
            return true
        end if

        selectedButton = m.chapterNavigation.getChild(m.selectedButtonIndex)
        selectedButton.focus = false

        m.selectedButtonIndex++

        selectedButton = m.chapterNavigation.getChild(m.selectedButtonIndex)
        selectedButton.focus = true

        return true
    end if

    if key = "left"
        if m.selectedButtonIndex = 0
            return true
        end if

        selectedButton = m.chapterNavigation.getChild(m.selectedButtonIndex)
        selectedButton.focus = false

        m.selectedButtonIndex--

        selectedButton = m.chapterNavigation.getChild(m.selectedButtonIndex)
        selectedButton.focus = true

        return true
    end if

    ' All other keys hide the menu
    m.top.action = "hide"
    return true
end function
