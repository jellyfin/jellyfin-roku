function APIRequest(url as String)
    req = createObject("roUrlTransfer")

    server = get_var("server")

    if server_is_https() then
        req.setCertificatesFile("common:/certs/ca-bundle.crt")
    end if

    req.setUrl(server + "/emby/" + url)

    req = authorize_request(req)

    return req
end function

function parseRequest(req)
    json = ParseJson(req.GetToString())
    return json
end function

function server_is_https() as Boolean
    server = get_var("server")

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

    GetGlobalAA().AddReplace("user_id", json.User.id)
    GetGlobalAA().AddReplace("user_token", json.AccessToken)
    return json
end function

function authorize_request(request)
    auth = "MediaBrowser"
    auth = auth + " Client=" + Chr(34) + "Jellyfin Roku" + Chr(34)
    auth = auth + ", Device=" + Chr(34) + "Roku Model" + Chr(34)
    auth = auth + ", DeviceId=" + Chr(34) + "12345" + Chr(34)
    auth = auth + ", Version=" + Chr(34) + "10.1.0" + Chr(34)

    user = get_var("user_id")
    if user <> invalid and user <> "" then
        auth = auth + ", UserId=" + Chr(34) + user + Chr(34)
    end if

    token = get_var("user_token")
    if token <> invalid and token <> "" then
        auth = auth + ", Token=" + Chr(34) + token + Chr(34)
    end if

    request.AddHeader("X-Emby-Authorization", auth)
    return request
end function

function VideoMetaData(id as String)
    url = Substitute("Users/{0}/Items/{1}", get_var("user_id"), id)
    resp = APIRequest(url)
    return parseRequest(resp)
end function

function VideoStream(id as String)
    player = createObject("roVideoPlayer")

    server = get_var("server")
    path = Substitute("Videos/{0}/stream.mp4", id)
    player.setUrl(server + "/" + path)
    player = authorize_request(player)

    return player
end function
