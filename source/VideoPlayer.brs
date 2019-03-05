function VideoPlayer(scene, id)
  video = scene.createChild("Video")
  content = VideoContent(id)

  video.content = content

  video.setFocus(true)
  video.control = "play"

  return video
end function

function VideoContent(id) as object
    content = createObject("RoSGNode", "ContentNode")

    meta = ItemMetaData(id)
    content.title = meta.Name

    server = get_setting("server")
    content.url = Substitute("{0}/emby/Videos/{1}/stream.mp4", server, id)
    content.url = content.url + "?Static=true"

    content = authorize_request(content)

    if server_is_https() then
        content.setCertificatesFile("common:/certs/ca-bundle.crt")
    end if

    return content

end function
