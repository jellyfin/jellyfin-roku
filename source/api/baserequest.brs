' Functions for making requests to the API

function buildURL(path as String, params={} as Object) as string
  ' roURLTransfer can only be created on a Task Node, and somewhere something
  ' is trying to call it from a "regular" node
  ' So we'll just avoid using it for now
  ' Sucks that we can't use htmlescape any other way though
  req = createObject("roUrlTransfer")  ' Just so we can use it for escape

  if req = invalid
    print "How is this even!?"
    return ""
  end if

  full_url = get_base_url() + "/emby/" + path
  if params.count() > 0
    full_url = full_url + "?"

    param_array = []
    for each field in params.items()
      if type(field.value) = "String" then
        item = field.key + "=" + req.escape(field.value.trim())
        'item = field.key + "=" + field.value.trim()
      else if type(field.value) = "roInteger" then
        item = field.key + "=" + req.escape(str(field.value).trim())
        'item = field.key + "=" + str(field.value).trim()
      else if type(field.value) = "roFloat" then
        item = field.key + "=" + req.escape(str(field.value).trim())
      else if type(field.value) = "roArray" then
        ' TODO handle array params
      else if field <> invalid
        item = field.key + "=" + req.escape(field.value)
        'item = field.key + "=" + field.value
      end if
      param_array.push(item)
    end for
    full_url = full_url + param_array.join("&")
  end if

  return full_url
end function

function APIRequest(url as String, params={} as Object)
  req = createObject("roUrlTransfer")

  if server_is_https() then
    req.setCertificatesFile("common:/certs/ca-bundle.crt")
  end if

  full_url = buildURL(url, params)

  req.setUrl(full_url)

  req = authorize_request(req)

  return req
end function

function getJson(req)
  'req.retainBodyOnError(True)
  'print req.GetToString()
  json = ParseJson(req.GetToString())
  return json
end function

function postVoid(req, data="" as string)
  status = req.PostFromString(data)
  if status = 200
    return true
  else
    return false
  end if
end function

function postJson(req, data="" as string)
  req.setMessagePort(CreateObject("roMessagePort"))
  req.AsyncPostFromString(data)

  resp = wait(5000, req.GetMessagePort())
  if type(resp) <> "roUrlEvent"
    return invalid
  end if

  if resp.getString() = ""
    return invalid
  end if

  json = ParseJson(resp.GetString())

  return json
end function

function get_base_url()
  base = get_setting("server")
  port = get_setting("port")

  if base.instr(0, "http") <> 0
    protocol = "http"
    if port = "443" or port = "8920"
      protocol = protocol + "s"
    end if
    protocol = protocol + "://"
    base = protocol + base
  end if

  if port <> "" and port <> invalid then
    base = base + ":" + port
  end if
  return base
end function

function server_is_https() as Boolean
  server = get_setting("server")

  i = server.Instr(":")

  ' No protocol found
  if i = 0 then
    return False
  end if

  protocol = Left(server, i)
  if protocol = "https" then
    return True
  end if
  return False
end function

function authorize_request(request)
  auth = "MediaBrowser"
  auth = auth + " Client=" + Chr(34) + "Jellyfin Roku" + Chr(34)
  auth = auth + ", Device=" + Chr(34) + "Roku Model" + Chr(34)
  auth = auth + ", DeviceId=" + Chr(34) + "12345" + Chr(34)
  auth = auth + ", Version=" + Chr(34) + "10.1.0" + Chr(34)

  user = get_setting("active_user")
  if user <> invalid and user <> "" then
    auth = auth + ", UserId=" + Chr(34) + user + Chr(34)
  end if

  token = get_user_setting("token")
  if token <> invalid and token <> "" then
    auth = auth + ", Token=" + Chr(34) + token + Chr(34)
  end if

  request.AddHeader("X-Emby-Authorization", auth)
  return request
end function
