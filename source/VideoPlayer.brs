function VideoPlayer(id)

    content = VideoContent(id)

    video = m.scene.findNode("VideoPlayer")

    if content.protocol = "https" then
        video.setCertificatesFile("common:/certs/ca-bundle.crt")
    end if

    video.content = content

    video.setFocus(true)
    video.control = "play"

    return video

end function


function VideoContent(id) as object
    content = createObject("RoSGNode", "ContentNode")

    content.title = "Loading..."
    meta = VideoMetaData(id)
    content.title = meta.Name

    protocol = get_var("protocol")
    hostname = get_var("hostname")
    params = "?Static=true&mediaSourceId=" + get_var("video_id") + "&Tag=e781255330167721024e07504244c553&api_key=" + get_var("user_token")
    content.url = Substitute("{0}://{1}/emby/Videos/{2}/stream.mp4", protocol, hostname, id) + params
    content.protocol = "https"

    return content

end function


function VideoMetaData(id)
    protocol = get_var("protocol")
    hostname = get_var("hostname")
    user_id = get_var("user_id")
    url = Substitute("{0}://{1}/emby/Users/{2}/Items/{3}", protocol, hostname, user_id, id)


    req = createObject("roUrlTransfer")
    req.setCertificatesFile("common:/certs/ca-bundle.crt")
    req.setUrl(url)
    req.AddHeader("X-Emby-Authorization", build_auth())

    json = ParseJson(req.GetToString())

    return json
end function

function build_auth() as String
    auth = "MediaBrowser"
    auth = auth + " Client=" + Chr(34) + "Jellyfin Roku" + Chr(34)
    auth = auth + ", Device=" + Chr(34) + "Roku Model" + Chr(34)
    auth = auth + ", DeviceId=" + Chr(34) + "12345" + Chr(34)
    auth = auth + ", Version=" + Chr(34) + "10.1.0" + Chr(34)

    auth = auth + ", UserId=" + Chr(34) + get_var("user_id") + Chr(34)
    auth = auth + ", Token=" + Chr(34) + get_var("user_token") + Chr(34)
    return auth
end function

