function ItemsList(params={} as object)
  ' Gets items based on a query.
  resp = APIRequest("Items", params)
  data = getJson(resp)
  ' TODO - parse items
  return data
end function

function UserItems(params={} as object)
  ' Gets items based on a query
  resp = APIRequest(Substitute("Items/{0}/Items", get_setting("active_user")), params)
  data = getJson(resp)
  ' TODO - parse items
  return data
end function

function UserItemsResume(params={} as object)
  ' Gets items based on a query
  resp = APIRequest(Substitute("Items/{0}/Items/Resume", get_setting("active_user")), params)
  data = getJson(resp)
  ' TODO - parse items
  return data
end function




' List of available libraries
function LibraryList()
  url = Substitute("Users/{0}/Views/", get_setting("active_user"))
  resp = APIRequest(url)
  data = getJson(resp)
  results = []
  for each item in data.Items
    tmp = CreateObject("roSGNode", "LibraryData")
    tmp.json = item
    results.push(tmp)
  end for
  data.Items = results
  return data
end function

' Search across all libraries
function SearchMedia(query as String)
  resp = APIRequest("Search/Hints", {"searchTerm": query})
  data = getJson(resp)
  results = []
  for each item in data.SearchHints
    if item.type = "Movie"
      item.posterURL = ImageURL(item.id)
    else if item.type = "Person"
      item.posterURL = ImageURL(item.id)
    else if item.type = "Episode"
      item.posterURL = ImageURL(item.id)
    end if

    tmp = CreateObject("roSGNode", "SearchData")
    tmp.json = item
    results.push(tmp)
  end for
  data.SearchHints = results
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
  results = []
  for each item in data.Items
    ' TODO - actually check item for available images

    if item.imagetags.primary <> invalid
      item.posterURL = ImageURL(item.id, "Primary")
      ' item.posterAspect = item.PrimaryImageAspectRatio
    else if item.imagetags.logo <> invalid
      item.posterURL = ImageURL(item.id, "Logo")
    else if item.imagetags.thumb <> invalid
      item.posterURL = ImageURL(item.id, "Thumb")
    else
      ' Maybe find more fallback images!
    end if

    if item.type = "Movie"
      tmp = CreateObject("roSGNode", "MovieData")
      tmp.json = item
      results.push(tmp)
    else if item.type = "Series"
      tmp = CreateObject("roSGNode", "SeriesData")
      tmp.json = item
      results.push(tmp)
    else if item.type = "BoxSet"
      tmp = CreateObject("roSGNode", "CollectionData")
      tmp.json = item
      results.push(tmp)
    else
      print item.type
      ' Otherwise we just stick with the JSON
      results.push(item)
    end if
  end for
  data.items = results
  return data
end function

' MetaData about an item
function ItemMetaData(id as String)
  url = Substitute("Users/{0}/Items/{1}", get_setting("active_user"), id)
  resp = APIRequest(url)
  data = getJson(resp)
  data.posterURL = ImageURL(data.id)
  if data.type = "Movie"
    tmp = CreateObject("roSGNode", "MovieData")
    tmp.json = data
    return tmp
  else if data.type = "Series"
    tmp = CreateObject("roSGNode", "SeriesData")
    tmp.json = data
    return tmp
  else if data.type = "BoxSet"
    tmp = CreateObject("roSGNode", "CollectionData")
    tmp.json = item
    results.push(tmp)
  else
    print data.type
    ' Return json if we don't know what it is
    return data
  end if
  return data
end function

' Seasons for a TV Show
function TVSeasons(id as String)
  url = Substitute("Shows/{0}/Seasons", id)
  resp = APIRequest(url, {"UserId": get_setting("active_user")})

  data = getJson(resp)
  results = []
  for each item in data.Items
    item.posterURL = ImageURL(item.id)
    tmp = CreateObject("roSGNode", "TVEpisodeData")
    tmp.json = item
    results.push(tmp)
  end for
  data.Items = results
  return data
end function

function TVEpisodes(show_id as String, season_id as String)
  url = Substitute("Shows/{0}/Episodes", show_id)
  resp = APIRequest(url, {"seasonId": season_id, "UserId": get_setting("active_user")})

  data = getJson(resp)
  results = []
  for each item in data.Items
    item.posterURL = ImageURL(item.id)
    tmp = CreateObject("roSGNode", "TVEpisodeData")
    tmp.json = item
    results.push(tmp)
  end for
  data.Items = results
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
