
function selectSubtitleTrack(tracks, current = -1) as integer
  video = m.scene.focusedChild
  trackSelected = selectSubtitleTrackDialog(video.Subtitles, video.SelectedSubtitle)
  if trackSelected = invalid or trackSelected = -1  then
    return invalid
  else
    return trackSelected - 1
  end if
end function

' Present Dialog to user to select subtitle track
function selectSubtitleTrackDialog(tracks, currentTrack = -1)
  iso6392 = getSubtitleLanguages()
  options = ["None"]
  for each item in tracks
    forced = ""
    default = ""
    if item.IsForced then forced = " [Forced]"
    if item.IsDefault then default = " - Default"
    if item.Track.Language <> invalid then
      language = iso6392.lookup(item.Track.Language)
      if language = invalid then language = item.Track.Language
    else 
      language = "Undefined"
    end if
    options.push(language + forced + default)
  end for
  return option_dialog(options, "Select a subtitle track", currentTrack + 1)
end function

sub changeSubtitleDuringPlayback(newid)

  ' If no subtitles set
  if newid = invalid or newid = -1 then 
    turnoffSubtitles()
    return
  end if

  video = m.scene.focusedChild

  ' If no change of subtitle track, return
  if newId = video.SelectedSubtitle then return

  currentSubtitles = video.Subtitles[video.SelectedSubtitle]
  newSubtitles = video.Subtitles[newid]

  if newSubtitles.IsEncoded then

    ' Switching to Encoded Subtitle stream
    video.control = "stop"
    AddVideoContent(video, video.audioIndex, newSubtitles.Index, video.position * 10000000)
    video.control = "play"
    video.globalCaptionMode = "Off"	' Using encoded subtitles - so turn off text subtitles

  else if (currentSubtitles <> invalid AND currentSubtitles.IsEncoded) then

    ' Switching from an Encoded stream to a text stream
    video.control = "stop"
    AddVideoContent(video, video.audioIndex, -1, video.position * 10000000)
    video.control = "play"
    video.globalCaptionMode = "On"
    video.subtitleTrack = video.availableSubtitleTracks[newSubtitles.TextIndex].TrackName
    
  else

    ' Switch to Text Subtitle Track
    video.globalCaptionMode = "On"
    video.subtitleTrack = video.availableSubtitleTracks[newSubtitles.TextIndex].TrackName
  end if

  video.SelectedSubtitle = newId

end sub

function turnoffSubtitles()
  video = m.scene.focusedChild
  current = video.SelectedSubtitle
  video.SelectedSubtitle = -1
  video.globalCaptionMode = "Off"
  m.device.EnableAppFocusEvent(false)
  ' Check if Enoded subtitles are being displayed, and turn off
  if current > -1 and video.Subtitles[current].IsEncoded then
    video.control = "stop"
    AddVideoContent(video, video.audioIndex, -1, video.position * 10000000)
    video.control = "play"
  end if
end function

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
  else
    if video.Subtitles[video.SelectedSubtitle] <> invalid then
      tmpParams.addreplace("SubtitleStreamIndex", int(video.Subtitles[video.SelectedSubtitle].Index))
    end if
  end if

  if video.isTranscoded then
    deleteTranscode(video.PlaySessionId)
  end if
  video.PlaySessionId = ItemGetPlaybackInfo(video.id, int(video.position) + playBackBuffer).PlaySessionId
  tmpParams.PlaySessionId  = video.PlaySessionId
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
  video.content.PlayStart = int(video.position + playBackBuffer)
  video.control = "play"
end sub
