function VideoPlayer(id)
  ' Get video controls and UI
  video = CreateObject("roSGNode", "JFVideo")
  video.id = id
  video = VideoContent(video)

  jellyfin_blue = "#00a4dcFF"

  video.retrievingBar.filledBarBlendColor = jellyfin_blue
  video.bufferingBar.filledBarBlendColor = jellyfin_blue
  video.trickPlayBar.filledBarBlendColor = jellyfin_blue
  return video
end function

function VideoContent(video) as object
  ' Get video stream
  video.content = createObject("RoSGNode", "ContentNode")

  meta = ItemMetaData(video.id)
  video.content.title = meta.Name
  container = getContainerType(meta)
  video.PlaySessionId = ItemGetSession(video.id)

  if directPlaySupported(meta) then
    video.content.url = buildURL(Substitute("Videos/{0}/stream", video.id), {
      "PlaySessionId": video.PlaySessionId
      Static: "true",
      Container: container
    })
    video.content.streamformat = container
    video.content.switchingStrategy = ""
  else
    video.content.url = buildURL(Substitute("Videos/{0}/master.m3u8", video.id), {
      "PlaySessionId": video.PlaySessionId
      "VideoCodec": "h264",
      "AudioCodec": "aac",
      "MediaSourceId": video.id,
      "SegmentContainer": "ts",
      "MinSegments": 1,
      "BreakOnNonKeyFrames": "True",
      "h264-profile": "high,main,baseline,constrainedbaseline",
      "RequireAvc": "false",
    })
  end if
  video.content = authorize_request(video.content)

  ' todo - audioFormat is read only
  video.content.audioFormat = getAudioFormat(meta)

  if server_is_https() then
    video.content.setCertificatesFile("common:/certs/ca-bundle.crt")
  end if
  return video
end function

function directPlaySupported(meta as object) as boolean
    devinfo = CreateObject("roDeviceInfo")
    return devinfo.CanDecodeVideo({ Codec: meta.json.MediaStreams[0].codec }).result
end function

function getContainerType(meta as object) as string
  ' Determine the file type of the video file source
  print type(meta)
  if meta.json.mediaSources = invalid then return ""

  container = meta.json.mediaSources[0].container
  if container = invalid
    container = ""
  else if container = "m4v" or container = "mov"
    container = "mp4"
  end if

  return container
end function

function getAudioFormat(meta as object) as string
  ' Determine the codec of the audio file source
  if meta.json.mediaSources = invalid then return ""

  audioInfo = getAudioInfo(meta)
  if audioInfo.count() = 0 then return ""
  return audioInfo[0].codec
end function

function getAudioInfo(meta as object) as object
  ' Return audio metadata for a given stream
  results = []
  for each source in meta.json.mediaSources[0].mediaStreams
    if source["type"] = "Audio"
      results.push(source)
    end if
  end for
  return results
end function

function ReportPlayback(video, state = "update" as string)
  params = {
    "PlaySessionId": video.PlaySessionId,
    "PositionTicks": str(int(video.position))+"0000000",
    "IsPaused": (video.state = "paused"),
  }
  PlaystateUpdate(video.id, state, params)
end function

function StopPlayback()
  video = m.scene.focusedchild
  video.findNode("playbackTimer").control = "stop"
  video.control = "stop"
  video.visible = "false"
  if video.status = "finished" then MarkItemWatched(video.id)
  ReportPlayback(video,"stop")
end function
