sub init()
    m.groups = []
    m.scene = m.top.getScene()
    m.overhang = m.scene.findNode("overhang")
end sub

'
' Push a new group onto the stack, replacing the existing group on the screen
sub push(newGroup)
    currentGroup = m.groups.peek()
    if currentGroup <> invalid
        'Search through group and store off last focused item
        if currentGroup.focusedChild <> invalid
            focused = currentGroup.focusedChild
            while focused.hasFocus() = false
                focused = focused.focusedChild
            end while
            currentGroup.lastFocus = focused
            currentGroup.setFocus(false)
        else
            currentGroup.lastFocus = invalid
            currentGroup.setFocus(false)
        end if

        if currentGroup.isSubType("JFGroup")
            unregisterOverhangData(currentGroup)
        end if

        currentGroup.visible = false
    end if

    m.groups.push(newGroup)

    'observe info about new group, set overhang title, etc.
    if newGroup.isSubType("JFGroup")
        registerOverhangData(newGroup)

        ' Some groups set focus to a specific component within init(), so we don't want to
        ' change if that is the case.
        if newGroup.isInFocusChain() = false
            newGroup.setFocus(true)
        end if
    else if newGroup.isSubType("JFVideo")
        newGroup.setFocus(true)
        newGroup.control = "play"
        m.overhang.visible = false
    end if

    ' TODO: figure out a better way to do this without relying on indexing
    if currentGroup <> invalid
        m.scene.replaceChild(newGroup, 1)
    else
        m.scene.appendChild(newGroup)
    end if
end sub

'
' Remove the current group and load the last group from the stack
sub pop()
    group = m.groups.pop()
    if group <> invalid
        if group.isSubType("JFGroup")
            unregisterOverhangData(group)
        else if group.isSubType("JFVideo")
            ' Stop video to make sure app communicates stop playstate to server
            group.control = "stop"
        end if
    else
        ' Exit app if for some reason we don't have anything on the stack
        m.scene.exit = true
    end if

    group = m.groups.peek()
    if group <> invalid
        registerOverhangData(group)
        'm.scene.callFunc("registerOverhangData")

        if group.subtype() = "Home"
            currentTime = CreateObject("roDateTime").AsSeconds()
            if group.timeLastRefresh = invalid or (currentTime - group.timeLastRefresh) > 20
                group.timeLastRefresh = currentTime
                group.callFunc("refresh")
            end if
        end if

        group.visible = true

        m.scene.replaceChild(group, 1)

        ' Restore focus
        if group.lastFocus <> invalid
            group.lastFocus.setFocus(true)
        else
            group.setFocus(true)
        end if
    else
        ' Exit app if the stack is empty after removing group
        m.scene.exit = true
    end if

end sub


'
' Return group at top of stack without removing
function peek() as object
    return m.groups.peek()
end function


'
' Register observers for overhang data
sub registerOverhangData(group)
    if group.isSubType("JFGroup")
        if group.overhangTitle <> invalid then m.overhang.title = group.overhangTitle

        if group.optionsAvailable
            m.overhang.showOptions = true
        else
            m.overhang.showOptions = false
        end if

        group.observeField("overhangTitle", "updateOverhangTitle")
        m.overhang.visible = true
    else if group.isSubType("JFVideo")
        m.overhang.visible = false
    else
        print "registerOverhangData(): Unexpected group type."
    end if
end sub


'
' Remove observers for overhang data
sub unregisterOverhangData(group)
    group.unobserveField("overhangTitle")
end sub


'
' Update overhang title
sub updateOverhangTitle(msg)
    m.overhang.title = msg.getData()
end sub