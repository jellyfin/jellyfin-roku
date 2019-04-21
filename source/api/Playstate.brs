function PlaystateStart(id, params)
  params = PlaystateDefaults(id, params)
  resp = APIRequest("Sessions/Playing")
  return postJson(resp, params)
end function

function PlaystateUpdate(id, params)
  params = PlaystateDefaults(id, params)
  resp = APIRequest("Sessions/Playing/Progress")
  return postJson(resp, params)
end function

function PlaystateStop(id, params={})
  params = PlaystateDefaults(id, params)
  resp = APIRequest("Sessions/Playing/Stopped")
  return postJson(resp, params)
end function

function PlaystateDefaults(id="" as string, params={} as object)
  new_params = {
    '"CanSeek": false
    '"Item": "{}", ' TODO!
    '"NowPlayingQueue": "[]", ' TODO!
    '"PlaylistItemId": "",
    "ItemId": id,
    '"SessionId": "", ' TODO!
    '"MediaSourceId": id,
    '"AudioStreamIndex": 1,
    '"SubtitleStreamIndex": 0,
    "IsPaused": false,
    '"IsMuted": false,
    '"PositionTicks": 0,
    '"PlaybackStartTimeTicks": 0,
    '"VolumeLevel": 100,
    '"Brightness": 100,
    '"AspectRatio": "16x9",
    '"PlayMethod": "DirectStream"
    '"LiveStreamId": "",
    '"PlaySessionId": "",
    '"RepeatMode": "RepeatNone"
  }
  for each p in params.items()
    new_params[p.key] = p.value
  end for
  return buildParams(new_params)
end function
