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
  
  ' If there is a last playback positon, ask user if they want to resume
  position = meta.json.UserData.PlaybackPositionTicks
  if position > 0 and startPlaybackOver(position) then
    position = 0
  end if
  video.content.BookmarkPosition = int(position/10000000)

  video.PlaySessionId = ItemGetSession(video.id, position)

  if directPlaySupported(meta) and decodeAudioSupported(meta) then
    video.content.url = buildURL(Substitute("Videos/{0}/stream", video.id), {
      "PlaySessionId": video.PlaySessionId
      Static: "true",
      Container: container
    })
    video.content.streamformat = container
    video.content.switchingStrategy = ""
  else
    ' downgrade AAC 5.1 to AAC stereo
    ' todo - provide a user setting to keep 5.1 by switching codecs (instead of downgrading to stereo)
    if meta.json.MediaStreams[1].channels > 2 and meta.json.MediaStreams[1].codec = "aac" then
      audioChannels = 2
    else
      audioChannels = meta.json.MediaStreams[1].channels
    end if

    video.content.url = buildURL(Substitute("Videos/{0}/master.m3u8", video.id), {
      "PlaySessionId": video.PlaySessionId
      "VideoCodec": "h264",
      "AudioCodec": "aac",
      "MaxAudioChannels": audioChannels,
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
  video.content.setCertificatesFile("common:/certs/ca-bundle.crt")

  return video
end function

'Opens dialog asking user if they want to resume video or start playback over
function startPlayBackOver(time as LongInteger) as boolean
  return option_dialog([ "Resume playing at " + ticksToHuman(time) + ".", "Start over from the begining." ])
end function

function directPlaySupported(meta as object) as boolean
  devinfo = CreateObject("roDeviceInfo")
  return devinfo.CanDecodeVideo({ Codec: meta.json.MediaStreams[0].codec }).result
end function

function decodeAudioSupported(meta as object) as boolean
  devinfo = CreateObject("roDeviceInfo")
  return devinfo.CanDecodeAudio({ Codec: meta.json.MediaStreams[1].codec, ChCnt: meta.json.MediaStreams[1].channels }).result
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
    "PositionTicks": str(int(video.position)) + "0000000",
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
  ReportPlayback(video, "stop")
end function
