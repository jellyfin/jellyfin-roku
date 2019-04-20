function get_token(user as String, password as String)
  bytes = createObject("roByteArray")
  bytes.FromAsciiString(password)
  digest = createObject("roEVPDigest")
  digest.setup("sha1")
  hashed_pass = digest.process(bytes)

  url = "Users/AuthenticateByName?format=json"
  req = APIRequest(url)

  json = postJson(req, "Username=" + user + "&Password=" + hashed_pass)

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
  unset_user_setting("token")
  unset_setting("active_user")
end function
