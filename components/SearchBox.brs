sub init()
    m.top.layoutDirection = "vert"
    dimensions = m.top.getScene().currentDesignResolution
    m.top.translation = [dimensions.width / 2, 880]
    m.top.horizAlignment = "center"
    m.top.vertAlignment = "top"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "OK"
        ' Make a Keyboard Dialog here
        show_dialog()
        return true
    else if key = "up"
        m.top.findNode("search-input").active = false
        m.top.escape = true
        return true
    end if

    return false
end function

function onDialogButton()
    d = m.top.getScene().dialog
    button_text = d.buttons[d.buttonSelected]

    if button_text = "Search"
        m.top.search_value = d.text
        dismiss_dialog()
        return true
    else if button_text = "Cancel"
        dismiss_dialog()
        return true
    end if

    return false
end function

sub show_dialog()
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Search"
    dialog.buttons = ["Search", "Cancel"]

    m.top.getScene().dialog = dialog

    dialog.observeField("buttonselected", "onDialogButton")
end sub

sub dismiss_dialog()
    m.top.getScene().dialog.close = true

end sub