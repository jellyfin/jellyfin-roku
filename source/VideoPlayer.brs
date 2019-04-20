function VideoPlayer(id)
  video = CreateObject("roSGNode", "Video")
  content = VideoContent(id)

  video.setFocus(true)

  video.content = content
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

  container = meta.json.mediaSources[0].container
  if container = invalid
    container = ""
  else if container = "m4v" or container = "mov"
    container = "mp4"
  end if

  content.url = buildURL(Substitute("Videos/{0}/stream", id), {
    Static: "true",
    Container: container
  })

  content = authorize_request(content)

  content.streamformat = container
  content.switchingStrategy = ""


  if server_is_https() then
    content.setCertificatesFile("common:/certs/ca-bundle.crt")
  end if

  return content
end function
