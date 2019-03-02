sub Main()
    m.port = CreateObject("roMessagePort")
    screen = CreateObject("roSGScreen")
    screen.setMessagePort(m.port)
    m.scene = screen.CreateScene("Library")
    m.screen = screen

    screen.show()

    if get_setting("server") = invalid then
        print "Get server details"
        ' TODO - make this into a dialog
        ' TODO - be able to submit server info
        ' ShowServerSelect()
    end if

    if get_setting("active_user") = invalid then
        print "Get user login"
        ' TODO - make this into a dialog
        ' screen.CreateScene("UserSignIn")
        ' TODO - sign in here
    end if

    ' TODO - something here to validate that the active_user is still
    ' valid.

    library = m.scene.findNode("LibrarySelect")
    libs = LibraryList()
    library.libList = libs

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then exit while
        end if
    end while
end sub

sub ShowServerSelect()
  dialog = CreateObject("roSGNode", "ServerSelection")
  dialog.title = "Select Server"
  m.scene.dialog = dialog

  await_response()
end sub

sub await_response()
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else
          print(msgType)
        end if
    end while
end sub
