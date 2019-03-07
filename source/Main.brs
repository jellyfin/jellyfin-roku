sub Main()
  keepalive = CreateObject("roSGScreen")
  keepalive.show()

  ' First thing to do is validate the ability to use the API

  start_login:
  if get_setting("server") = invalid then
    print "Get server details"
    ShowServerSelect()
  end if

  if get_setting("active_user") = invalid then
    print "Get user login"
    ShowSigninSelect()
  end if

  ' Confirm the configured server and user work
  m.user = AboutMe()
  if m.user.id <> get_setting("active_user")
    print "Login failed, restart flow"
    goto start_login
  end if

  ShowLibrarySelect()
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
