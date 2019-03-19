function ItemSessionUpdate(id as String, params={})
  url = "Sessions/Playing/Progress"
  resp = APIRequest(url, make_params(id, params))
  return postJson(resp)
end function

function ItemSessionStart(id as String, params={})
  url = "Sessions/Playing"
  resp = APIRequest(url, make_params(id, params))
  return postJson(resp)
end function

function ItemSessionStop(id as String, params={})
  url = "Sessions/Playing/Stopped"
  resp = APIRequest(url, make_params(id, params))
  return postJson(resp)
end function

function make_params(id as string, params={})
  new_params = {
    "VolumeLevel":100,
    "IsMuted":"false",
    "IsPaused":"false",
    "RepeatMode":"RepeatNone",
    "MaxStreamingBitrate":140000000,
    "PositionTicks":0,
    "PlaybackStartTimeTicks":0,
    "AudioStreamIndex":1,
    "BufferedRanges":"[]",
    "PlayMethod":"DirectStream",
    "PlaySessionId":"",
    "PlaylistItemId":"playlistItem0",
    "MediaSourceId":id,
    "CanSeek":"true",
    "ItemId": id,
    "NowPlayingQueue":"[]"
  }
  for each p in params.items()
    new_params[p.key] = p.value
  end for
  print new_params
  return new_params
end function
