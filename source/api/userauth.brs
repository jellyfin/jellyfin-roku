function get_token(user as String, password as String)
  url = "Users/AuthenticateByName?format=json"
  req = APIRequest(url)

  json = postJson(req, "Username=" + user + "&Pw=" + password)

  if json = invalid then return invalid

  userdata = CreateObject("roSGNode", "UserData")
  userdata.json = json

  userdata.callFunc("setActive")
  userdata.callFunc("saveToRegistry")
  return userdata
end function

function AboutMe()
  id = get_setting("active_user")
  url = Substitute("Users/{0}", id)
  resp = APIRequest(url)
  return getJson(resp)
end function

function SignOut()
  if get_setting("active_user") <> invalid
    unset_user_setting("token")
  end if
  unset_setting("active_user")
end function

function AvailableUsers()
  users = get_setting("available_users", {})
  return users
end function

function PickUser(id as string)


end function

function ServerInfo()
  url = "System/Info/Public"
  resp = APIRequest(url)
  return getJson(resp)
end function
