function VideoPlayer(id)
  ' Get video controls and UI
  video = CreateObject("roSGNode", "JFVideo")
  video.id = id
  video = VideoContent(video)
  if video = invalid 
    return invalid
  end if
  jellyfin_blue = "#00a4dcFF"

  video.retrievingBar.filledBarBlendColor = jellyfin_blue
  video.bufferingBar.filledBarBlendColor = jellyfin_blue
  video.trickPlayBar.filledBarBlendColor = jellyfin_blue
  return video
end function

function VideoContent(video) as object
  ' Get video stream
  video.content = createObject("RoSGNode", "ContentNode")
  params = {}

  meta = ItemMetaData(video.id)
  video.content.title = meta.Name
  container = getContainerType(meta)
  
  ' If there is a last playback positon, ask user if they want to resume
  position = meta.json.UserData.PlaybackPositionTicks
  if position > 0 then
    dialogResult = startPlaybackOver(position)
    'Dialog returns -1 when back pressed, 0 for resume, and 1 for start over
    if dialogResult = -1 then
      'User pressed back, return invalid and don't load video
      return invalid
    else if dialogResult = 1 then
      'Start Over selected, change position to 0
      position = 0
    end if
  end if
  video.content.BookmarkPosition = int(position/10000000)

  video.PlaySessionId = ItemGetSession(video.id, position)
  params.append({"PlaySessionId": video.PlaySessionId})

  video.Subtitles = getSubtitles(meta.id,meta.json.MediaStreams)
  if video.Subtitles.count() > 0 then
    if video.Subtitles[0].IsTextSubtitleStream then
      video.content.SubtitleTracks = video.Subtitles[0].track
    else if getCaptionMode() = "On"
      'Only transcode if subtitles are turned on
      params.append({"SubtitleStreamIndex" : video.Subtitles[0].index })
    end if
  end if

  if directPlaySupported(meta) and decodeAudioSupported(meta) and params.SubtitleStreamIndex = invalid then
    params.append({
      "Static": "true",
      "Container": container
    })
    video.content.url = buildURL(Substitute("Videos/{0}/stream", video.id), params)
    video.content.streamformat = container
    video.content.switchingStrategy = ""
  else
    if decodeAudioSupported(meta) then
      audioCodec = meta.json.MediaStreams[1].codec
      audioChannels = meta.json.MediaStreams[1].channels
    else
      audioCodec = "aac"
      audioChannels = 2
    end if
    params.append({
      "VideoCodec": "h264",
      "AudioCodec": audioCodec,
      "MaxAudioChannels": audioChannels,
      "MediaSourceId": video.id,
      "SegmentContainer": "ts",
      "MinSegments": 1,
      "BreakOnNonKeyFrames": "True",
      "h264-profile": "high,main,baseline,constrainedbaseline",
      "RequireAvc": "false",
    })
    video.content.url = buildURL(Substitute("Videos/{0}/master.m3u8", video.id), params)
  end if
  video.content = authorize_request(video.content)

  ' todo - audioFormat is read only
  video.content.audioFormat = getAudioFormat(meta)
  video.content.setCertificatesFile("common:/certs/ca-bundle.crt")
  return video
end function

'Checks available subtitle tracks and puts subtitles in preferred language at the top
function getSubtitles(id as string, MediaStreams)
  tracks = []
  devinfo = CreateObject("roDeviceInfo")
  'Too many args for using substitute
  dashedid = id.left(8) + "-" + id.mid(8,4) + "-" + id.mid(12,4) + "-" + id.mid(16,4) + "-" + id.right(12)
  prefered_lang = devinfo.GetPreferredCaptionLanguage()
  for each stream in MediaStreams
    if stream.type = "Subtitle" then
      'Documentation lists that srt, ttml, and dfxp can be sideloaded but only srt was working in my testing,
      'forcing srt for all text subtitles
      url = Substitute("{0}/Videos/{1}/{2}/Subtitles/{3}/0/", get_url(), dashedid, id, stream.index.tostr())
      url = url + Substitute("Stream.js?api_key={0}&format=srt", get_setting("active_user"))
      stream = { "Track": { "Language" : stream.language, "Description": stream.displaytitle , "TrackName": url }, "IsTextSubtitleStream": stream.IsTextSubtitleStream, "Index": stream.index }
      if prefered_lang = stream.language then
          tracks.unshift( stream )
      else
        tracks.push( stream )
      end if
    end if
  end for
  return tracks
end function

function getCaptionMode() as string
  devinfo = CreateObject("roDeviceInfo")
  return devinfo.GetCaptionsMode()
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
