sub init()
    set = m.top.findNode("panelset")
    set.height = 1080

    panel = set.findNode("panel-desc")
    panel.panelSize = "full"
    panel.hasNextPanel = true
    panel.isFullScreen = true
    panel.leftPosition = 150

    panel2 = set.findNode("panel-seasons")
    panel2.panelSize = "full"
    panel2.hasNextPanel = false
    panel2.isFullScreen = true
    panel2.leftPosition = 150
    ' TODO - set the bounds so seasons dont go off the edge of the screen
end sub

sub panelFocusChanged()
    set = m.top.findNode("panelset")
    index = m.top.panelFocused

    if index = 0
        ' Description page
        ' TODO - get the buttons to actually take focus back
        set.findNode("description").findNode("buttons").setFocus(true)
    else if index = 1
        ' Seasons page
        set.findNode("seasons").setFocus(true)
    end if

end sub