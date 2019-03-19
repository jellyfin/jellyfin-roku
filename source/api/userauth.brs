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

  set_setting("active_user", json.User.id)
  set_user_setting("id", json.User.id)  ' redundant, but could come in handy
  set_user_setting("token", json.AccessToken)
  return json
end function

function AboutMe()
  url = Substitute("Users/{0}", get_setting("active_user"))
  resp = APIRequest(url)
  return getJson(resp)
end function
