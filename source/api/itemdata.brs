' List of available libraries
function LibraryList()
  url = Substitute("Users/{0}/Views/", get_setting("active_user"))
  resp = APIRequest(url)
  return getJson(resp)
end function

' Search across all libraries
function SearchMedia(query as String)
  resp = APIRequest("Search/Hints", {"searchTerm": query})
  data = getJson(resp)
  for each item in data.SearchHints
    if item.type = "Movie"
      item.posterURL = ImageURL(item.id)
    else if item.type = "Person"
      item.posterURL = ImageURL(item.id)
    else if item.type = "Episode"
      item.posterURL = ImageURL(item.id)
    end if
  end for
  return data
end function

' List items from within a library
function ItemList(library_id=invalid as String, params={})
  if params["limit"] = invalid
    params["limit"] = 30
  end if
  if params["page"] = invalid
    params["page"] = 1
  end if
  params["parentid"] = library_id
  url = Substitute("Users/{0}/Items/", get_setting("active_user"))
  resp = APIRequest(url, params)
  data = getJson(resp)
  for each item in data.Items
    item.posterURL = ImageURL(item.id)
  end for
  return data
end function

' MetaData about an item
function ItemMetaData(id as String)
  url = Substitute("Users/{0}/Items/{1}", get_setting("active_user"), id)
  resp = APIRequest(url)
  data = getJson(resp)
  data.posterURL = ImageURL(data.id)
  return data
end function

' Seasons for a TV Show
function TVSeasons(id as String)
  url = Substitute("Shows/{0}/Seasons", id)
  resp = APIRequest(url, {"UserId": get_setting("active_user")})

  data = getJson(resp)
  for each item in data.Items
    item.posterURL = ImageURL(item.id)
  end for
  return data
end function

' The next up episode for a TV show
function TVNext(id as String)
  url = Substitute("Shows/NextUp", id)
  resp = APIRequest(url, {"UserId": get_setting("active_user"), "SeriesId": id})

  data = getJson(resp)
  for each item in data.Items
    item.posterURL = ImageURL(item.id)
  end for
  return data
end function
