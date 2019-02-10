sub Main()
    'Indicate this is a Roku SceneGraph application'
    globals()

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    if get_setting("server") = invalid then
        set_setting("server", get_var("server"))
        screen.CreateScene("ServerSelect")
        screen.show()
        ' TODO - Do server select logic here
    end if

    if get_setting("active_user") = invalid then
        screen.CreateScene("UserSignIn")
        screen.show()
        ' TODO - sign in here
        get_token(get_var("username"), get_var("password"))
    end if

    first_scene = "Library"
    'Create a scene and load a component'
    m.scene = screen.CreateScene(first_scene)
    screen.show()

    libs = LibraryList().items
    librow = m.scene.findNode("LibrarySelect")

    'librow.GetRowListContent()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub


function get_var(key as String)
    return GetGlobalAA().Lookup(key)
end function

