sub Main()
  ' First thing to do is validate the ability to use the API

  if get_setting("server") = invalid then
    print "Get server details"
    ' TODO - be able to submit server info
    ShowServerSelect()
  end if

  if get_setting("active_user") = invalid then
    print "Get user login"
    ' TODO - be able to submit user info
    ' ShowSigninSelect()
  end if

  ' Confirm the configured server and user work
  m.user = AboutMe()
  if m.user.id <> get_setting("active_user")
    ' TODO - proper handling of the scenario where things have gone wrong
    print "OH NO!"
  end if

  ShowLibrarySelect()
end sub

sub ShowServerSelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("ServerSelection")

  screen.show()

  while(true)
    msg = wait(0, port)
    if msg.isScreenClosed() then
      return
    else
      print(msgType)
    end if
  end while
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
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      exit while
    else if itemSelectedQ(msg)
      target = getMsgRowTarget(msg)
      if target.libraryType = "movies"
        ShowMovieOptions(target.libraryID)
      else
        print "NOT YET IMPLEMENTED"
      end if
    end if
  end while
end sub

sub ShowMovieOptions(library_id)
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
      target = getMsgRowTarget(msg)
      showVideoPlayer(target.movieID)
    end if
  end while
end sub

sub showVideoPlayer(id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Scene")

  screen.show()

  VideoPlayer(scene, id)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    end if
  end while

end sub

sub itemSelectedQ(msg) as boolean
  ' "Q" stands for "Question mark" since itemSelected? wasn't acceptable
  ' Probably needs a better name, but unique for now
  return type(msg) = "roSGNodeEvent" and msg.getField() = "itemSelected"
end sub

sub getMsgRowTarget(msg) as object
  node = msg.getRoSGNode()
  coords = node.rowItemSelected
  target = node.content.getChild(coords[0]).getChild(coords[1])
  return target
end sub
