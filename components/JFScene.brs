sub init()
    m.top.backgroundColor = "#262626" '"#101010"
    m.top.backgroundURI = ""
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "back"
        m.global.groupStack.callFunc("pop")
        return true
    else if key = "options"
        group = m.global.groupStack.callFunc("peek")
        if group.optionsAvailable
            group.lastFocus = group.focusedChild
            panel = group.findNode("options")
            panel.visible = true
            panel.findNode("panelList").setFocus(true)
        end if
        return true
    end if

    return false
end function
