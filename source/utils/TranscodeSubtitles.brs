function systemOverlayClosed()
  video = m.scene.focusedChild
  if video.globalCaptionMode <> video.captionMode then
    video.captionMode = video.globalCaptionMode
    reviewSubtitleDisplay()
  end if
end function

function reviewSubtitleDisplay()
  'TODO handle changing subtitles tracks during playback
  displayed = areSubtitlesDisplayed()
  needed = areSubtitlesNeeded()
  print "displayed: " displayed " needed: " needed
  if areSubtitlesNeeded() and (not areSubtitlesDisplayed()) then 
    rebuildURL(true)
  else if areSubtitlesDisplayed() and (not areSubtitlesNeeded()) then
    rebuildURL(false)
  end if
end function

function areSubtitlesDisplayed()
  index = m.scene.focusedChild.transcodeParams.lookup("SubtitleStreamIndex")
  if index <> invalid and index <> -1 then
    return true
  else 
    return false
  end if
 end function

function areSubtitlesNeeded() 
  captions = m.scene.focusedChild.globalCaptionMode
  if captions = "On"
    return true
  else if captions = "Off"
    return false
  else if captions = "When mute"
    return m.mute
  else if captions = "Instant replay"
    'Unsupported. Do we want to do this? Is it worth transcoding for rewinded content and then untranscoding?
    return false
  end if
end function

sub rebuildURL(captions as boolean)
  playBackBuffer = -5

  video = m.scene.focusedChild
  video.control = "pause"

  tmpParams = video.transcodeParams
  if captions = false then
    tmpParams.delete("SubtitleStreamIndex")
     tmpParams.delete("SubtitleStreamIndex")
  else
    if video.Subtitles[video.SelectedSubtitle] <> invalid then
      tmpParams.addreplace("SubtitleStreamIndex", int(video.Subtitles[video.SelectedSubtitle].Index))
    end if
  end if

  if video.isTranscoded then
    deleteTranscode(video.PlaySessionId)
  end if
  tmpParams.PlaySessionId  = video.PlaySessionId = ItemGetSession(video.id, int(video.position) + playBackBuffer)
  video.transcodeParams = tmpParams

  if video.directPlaySupported and video.decodeAudioSupported and not captions then
    'Captions are off and we do not need to transcode video or audo
    base = Substitute("Videos/{0}/stream", video.id)
    params = {
      "Static": "true",
      "Container": video.container
      "PlaySessionId": video.PlaySessionId
    }
    video.isTranscoded = false
    video.content.streamformat = video.container
  else
    'Captions are on or we need to transcode for any other reason
    video.content.streamformat = "hls"
    base = Substitute("Videos/{0}/master.m3u8", video.id)
    video.isTranscoded = true
    params = video.transcodeParams
  end if

  video.content.url = buildURL(base, params)
  print "video url: " video.content.url
  video.content.BookmarkPosition = int(video.position + playBackBuffer)
  video.control = "play"
end sub
