sub Main()
    m.port = CreateObject("roMessagePort")

    if get_setting("server") = invalid then
        ShowServerSelect()
        ' TODO - be able to submit server info
    end if

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

    librow = m.scene.findNode("LibrarySelect")
    libs = LibraryList()
    librow.libList = libs

    'librow.GetRowListContent()

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

  'debug(scene)

  await_response()
end sub

sub debug(scene)
  ' TODO - find out why itemName.text is "Host" but still displays as empty
  x = scene.findNode("config_server")
  print
  print scene.getallmeta()
  print 
  for each x in scene.getall()
    if x.id <> "config_server" then goto continuex
    print x.id
    print x.itemContent.labelText
    print x.findNode("itemName").text
    ' This says "A" for both. the node and label are set properly...
    ' why is it empty on the screen
    continuex:
  end for

  print
  print scene.getallmeta()
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
