sub init()
    m.top.layoutDirection = "vert"
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("focusButton", "onFocusButtonChanged")
end sub

sub onFocusChanged()
    if m.top.hasFocus()
        m.top.getChild(0).setFocus(true)
        m.top.focusButton = 0
    end if
end sub

sub onFocusButtonChanged()
    m.top.getChild(m.top.focusButton).setFocus(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "OK"
        m.top.selected = m.top.focusButton
        return true
    end if

    if not press then return false

    if key = "down"
        i = m.top.focusButton
        target = i + 1
        if target >= m.top.getChildCount() then return false
        m.top.focusButton = target
        return true
    else if key = "up"
        i = m.top.focusButton
        target = i - 1
        if target < 0 then return false
        m.top.focusButton = target
        return true
    else if key = "left" or key = "right"
        m.top.escape = key
        return true
    end if

    return false
end function
