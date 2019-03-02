sub Main()
    m.port = CreateObject("roMessagePort")
    screen = CreateObject("roSGScreen")
    screen.setMessagePort(m.port)
    m.scene = screen.CreateScene("Library")

    screen.show()

    if get_setting("server") = invalid then
        ' TODO - make this into a dialog
        ' TODO - be able to submit server info
        ' ShowServerSelect()
    end if

    if get_setting("active_user") = invalid then
        ' TODO - make this into a dialog
        ' screen.CreateScene("UserSignIn")
        ' TODO - sign in here
    end if

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
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("ServerSelection")
  screen.show()

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
