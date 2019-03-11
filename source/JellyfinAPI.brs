' Functions for making requests to the API

function buildURL(path as String, params={} as Object) as string
  ' roURLTransfer can only be created on a Task Node, and somewhere something
  ' is trying to call it from a "regular" node
  ' So we'll just avoid using it for now
  ' Sucks that we can't use htmlescape any other way though
  req = createObject("roUrlTransfer")  ' Just so we can use it for escape
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

function parseRequest(req)
  'req.retainBodyOnError(True)
  'print req.GetToString()
  json = ParseJson(req.GetToString())
  return json
end function

function get_base_url()
  base = get_setting("server")
  port = get_setting("port")
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

function get_token(user as String, password as String)
  bytes = createObject("roByteArray")
  bytes.FromAsciiString(password)
  digest = createObject("roEVPDigest")
  digest.setup("sha1")
  hashed_pass = digest.process(bytes)

  url = "Users/AuthenticateByName?format=json"

  req = APIRequest(url)

  ' BrightScript will only return a POST body if you call post asynch
  ' and then wait for the response
  req.setMessagePort(CreateObject("roMessagePort"))
  req.AsyncPostFromString("Username=" + user + "&Password=" + hashed_pass)
  resp = wait(5000, req.GetMessagePort())
  if type(resp) <> "roUrlEvent"
    return invalid
  end if

  json = ParseJson(resp.GetString())

  set_setting("active_user", json.User.id)
  set_user_setting("id", json.User.id)  ' redundant, but could come in handy
  set_user_setting("token", json.AccessToken)
  return json
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

function AboutMe()
  url = Substitute("Users/{0}", get_setting("active_user"))
  resp = APIRequest(url)
  return parseRequest(resp)
end function

function ImageURL(id)
  url = Substitute("Items/{0}/Images/Primary", id)
  ' ?maxHeight=384&maxWidth=256&tag=<tag>&quality=90"
  return buildURL(url, {"maxHeight": "384", "maxWidth": "196", "quality": "90"})
end function

' ServerBrowsing

' List Available Libraries for the current logged in user
' Params: None
' Returns { Items, TotalRecordCount }
function LibraryList()
  url = Substitute("Users/{0}/Views/", get_setting("active_user"))
  resp = APIRequest(url)
  return parseRequest(resp)
end function

' Search for a string
' Params: Search Query
' Returns: { SearchHints, TotalRecordCount }
function SearchMedia(query as String)
  resp = APIRequest("Search/Hints", {"searchTerm": query})
  return parseRequest(resp)
end function

' List items from within a Library
' Params: Library ID, Limit, Offset, SortBy, SortOrder, IncludeItemTypes, Fields, EnableImageTypes
' Returns { Items, TotalRecordCount }
function ItemList(library_id=invalid as String, params={})
  if params["limit"] = invalid
    params["limit"] = 30
  end if
  if params["page"] = invalid
    params["page"] = 1
  end if
  params["parentid"] = library_id
  url = Substitute("Users/{0}/Items/", get_setting("active_user"))
  resp = APIRequest(url, params)
  return parseRequest(resp)
end function

function ItemMetaData(id as String)
  url = Substitute("Users/{0}/Items/{1}", get_setting("active_user"), id)
  resp = APIRequest(url)
  return parseRequest(resp)
end function

function TVSeasons(id as String)
  url = Substitute("Shows/{0}/Seasons", id)
  resp = APIRequest(url, {"UserId": get_setting("active_user")})
  return parseRequest(resp)
end function


function TVNext(id as String)
  url = Substitute("Shows/NextUp", id)
  resp = APIRequest(url, {"UserId": get_setting("active_user"), "SeriesId": id})
  return parseRequest(resp)
end function
