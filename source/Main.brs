sub Main()
    m.port = CreateObject("roMessagePort")

    if get_setting("server") = invalid then
        print "Moving to server select"
        ShowServerSelect()
    end if

    print("WE MOVED ON")
'    if get_setting("active_user") = invalid then
'        screen = CreateObject("roSGScreen")
'        screen.setMessagePort(m.port)

'        screen.CreateScene("UserSignIn")
'        screen.show()
        ' TODO - sign in here
'        await_response()
'        screen.close()
'    end if

    screen = CreateObject("roSGScreen")
    screen.setMessagePort(m.port)

    first_scene = "Library"
    'Create a scene and load a component'
    m.scene = screen.CreateScene(first_scene)
    screen.show()

    libs = LibraryList().items
    librow = m.scene.findNode("LibrarySelect")

    'librow.GetRowListContent()

    print 1 + "halt" ' Mixed types stops the debugger

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
