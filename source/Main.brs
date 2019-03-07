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
