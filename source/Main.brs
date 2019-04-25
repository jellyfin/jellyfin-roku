sub Main()
  keepalive = CreateObject("roSGScreen")
  keepalive.show()

  app_start:
  ' First thing to do is validate the ability to use the API
  LoginFlow()

  ' Confirm the configured server and user work
  ShowLibrarySelect()

  ' Have a catch for exiting the library on sign-out
  if get_setting("active_user") = invalid
    goto app_start
  end if
  if getGlobal("user_change") = true
    ' Signal caught, reset
    setGlobal("user_change", false)
    goto app_start
  end if
end sub

sub LoginFlow()
  start_login:
  if get_setting("server") = invalid then
    print "Get server details"
    ShowServerSelect()
  end if

  if ServerInfo() = invalid
    ' Maybe don't unset setting, but offer as a prompt
    ' Server not found, is it online? New values / Retry
    print "Connection to server failed, restart flow"
    SignOut()
    unset_setting("server")
    goto start_login
  end if

  if get_setting("active_user") = invalid then
    print "Get user login"
    ShowSigninSelect()
  end if

  m.user = AboutMe()
  if m.user = invalid or m.user.id <> get_setting("active_user")
    print "Login failed, restart flow"
    unset_setting("active_user")
    goto start_login
  end if
end sub
