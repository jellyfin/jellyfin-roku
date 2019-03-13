function MarkItemFavorite(id as String)
  url = Substitute("Users/{0}/FavoriteItems/{1}", get_setting("active_user"), id)
  resp = APIRequest(url)
  return postJson(resp)
end function

function UnmarkItemFavorite(id as String)
  url = Substitute("Users/{0}/FavoriteItems/{1}", get_setting("active_user"), id)
  resp = APIRequest(url)
  resp.setRequest("DELETE")
  return getJson(resp)
end function
