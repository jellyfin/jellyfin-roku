function onKeyEvent(key as string, press as boolean) as boolean

    if key = "OK"
        m.top.close = true
    end if

    return true
end function
