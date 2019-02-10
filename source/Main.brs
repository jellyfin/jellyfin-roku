sub Main()

    if get_setting("server") = invalid then
        print("SERVER IS MISSING")
        ShowServerSelect()
    end if

    print("WE MOVED ON")
    m.port = CreateObject("roMessagePort")
    if get_setting("active_user") = invalid then
        screen = CreateObject("roSGScreen")
        screen.setMessagePort(m.port)

        screen.CreateScene("UserSignIn")
        screen.show()
        ' TODO - sign in here
        await_response()
        screen.close()
    end if

    screen = CreateObject("roSGScreen")
    screen.setMessagePort(m.port)

    first_scene = "Library"
    'Create a scene and load a component'
    m.scene = screen.CreateScene(first_scene)
    screen.show()

    libs = LibraryList().items
    librow = m.scene.findNode("LibrarySelect")

    'librow.GetRowListContent()

    print 1 + "halt"

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

sub ShowServerSelect()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("ServerSelect")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if

    end while
end sub

sub await_response()
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
