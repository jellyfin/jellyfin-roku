function VideoPlayer(id)
  video = CreateObject("roSGNode", "Video")
  content = VideoContent(id)

  video.content = content

  video.setFocus(true)
  video.control = "play"

  jellyfin_blue = "#00a4dcFF"

  video.retrievingBar.filledBarBlendColor = jellyfin_blue
  video.bufferingBar.filledBarBlendColor = jellyfin_blue
  video.trickPlayBar.filledBarBlendColor = jellyfin_blue

  return video
end function

function VideoContent(id) as object
  content = createObject("RoSGNode", "ContentNode")

  meta = ItemMetaData(id)
  content.title = meta.Name

  ' I'm not super happy that I'm basically re-implementing APIRequest
  ' but for a ContentNode instead of UrlTransfer
  server = get_setting("server")
  content.url = Substitute("{0}/emby/Videos/{1}/stream.mp4", server, id)
  content.url = content.url + "?Static=true"

  content = authorize_request(content)

  if server_is_https() then
    content.setCertificatesFile("common:/certs/ca-bundle.crt")
  end if

  return content
end function
