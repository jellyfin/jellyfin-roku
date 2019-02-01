sub Main()
    'Indicate this is a Roku SceneGraph application'
    globals()

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    'todo - pick the scene based on if we need a server already
    first_scene = "ServerSelect"
    'Create a scene and load a component'
    m.scene = screen.CreateScene("VideoScene")
    screen.show()

    get_token(get_var("username"), get_var("password"))
    player = VideoPlayer(get_var("video_id"))

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

