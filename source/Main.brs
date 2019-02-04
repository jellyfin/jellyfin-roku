sub Main()
    'Indicate this is a Roku SceneGraph application'
    globals()

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    'todo - pick the scene based on if we need a server already
    first_scene = "Library"
    'Create a scene and load a component'
    m.scene = screen.CreateScene(first_scene)
    screen.show()

    get_token(get_var("username"), get_var("password"))

    libs = LibraryList().items
    librow = m.scene.findNode("LibrarySelect")

    'librow.GetRowListContent()

    ' For now, just play whatever is the first item in the list
    ' of the first folder

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

