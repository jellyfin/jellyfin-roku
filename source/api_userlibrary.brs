function MarkItemFavorite(id as String)
  url = Substitute("Users/{0}/FavoriteItems/{1}", get_setting("active_user"), id)
  resp = APIRequest(url)
  return postJson(resp)
end function
