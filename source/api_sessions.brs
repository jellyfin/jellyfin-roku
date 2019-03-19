function ItemSessionUpdate(id as String, params={})
  url = "Sessions/Playing/Progress"
  params.ItemId = id
  resp = APIRequest(url, params)
  return postJson(resp)
end function

function ItemSessionStart(id as String, params={})
  url = "Sessions/Playing"
  params.ItemId = id
  resp = APIRequest(url, params)
  return postJson(resp)
end function

function ItemSessionStop(id as String, params={})
  url = "Sessions/Playing/Stopped"
  params.ItemId = id
  resp = APIRequest(url, params)
  return postJson(resp)
end function
