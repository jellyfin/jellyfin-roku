sub Main()
  m.port = CreateObject("roMessagePort")

  ' This facade keeps the app open when maybe other screens close
  facade = CreateObject("roSGScreen")
  facade.show()

  if get_setting("server") = invalid then
    print "Get server details"
    ' TODO - make this into a dialog
    ' TODO - be able to submit server info
    ShowServerSelect()
  end if

  if get_setting("active_user") = invalid then
    print "Get user login"
    ' TODO - make this into a dialog
    ' screen.CreateScene("UserSignIn")
    ' TODO - sign in here
  end if

  ' TODO - something here to validate that the active_user is still
  ' valid.

  selected = ShowLibrarySelect()

  await_response()
end sub

sub ShowServerSelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)

  scene = screen.CreateScene("ServerSelection")

  screen.show()

  await_response()
end sub

sub ShowLibrarySelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)

  scene = screen.CreateScene("Library")

  screen.show()

  library = scene.findNode("LibrarySelect")
  libs = LibraryList()
  library.libList = libs

  library.observeField("itemSelected", port)

  while(true)
    msg = wait(0, port)
    print msg
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      exit while
    else if itemSelectedQ(msg)
      target = getRowTarget(msg)
      ShowLibraryOptions(target.libraryID)
    end if
  end while
end sub

sub itemSelectedQ(msg) as boolean
  return type(msg) = "roSGNodeEvent" and msg.getField() = "itemSelected"
end sub

sub getRowTarget(msg) as object
  node = msg.getRoSGNode()
  coords = node.rowItemSelected
  target = node.content.getChild(coords[0]).getChild(coords[1])
  return target
end sub

sub ShowLibraryOptions(library_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)

  scene = screen.CreateScene("Movies")

  screen.show()

  options = scene.findNode("MovieSelect")
  options_list = ItemList(library_id)
  options.movieData = options_list

  options.observeField("itemSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if itemSelectedQ(msg)
      target = getRowTarget(msg)
      showVideoPlayer(target.movieID)
      print msg
    end if
  end while
end sub

sub showVideoPlayer(id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)

  scene = screen.CreateScene("VideoScene")

  screen.show()

  VideoPlayer(scene, id)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    end if
  end while

end sub

sub await_response(port=invalid)
  if port = invalid then
    port = m.port
  end if
  while(true)
    msg = wait(0, port)
    if msg.isScreenClosed() then
      return
    else
      print(msgType)
    end if
  end while
end sub
