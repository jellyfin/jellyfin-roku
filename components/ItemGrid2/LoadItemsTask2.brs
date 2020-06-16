sub init()
  m.top.functionName = "loadItems"
end sub

sub loadItems()

  results = []

  sort_order = get_user_setting("movie_sort_order", "Ascending")
  sort_field = get_user_setting("movie_sort_field", "SortName")


  params = {
    limit: m.top.limit,
    StartIndex: m.top.startIndex,
    parentid: m.top.itemId,
    SortBy: sort_field,
    SortOrder: sort_order,
    recursive: false
  }

  if m.top.ItemType <> "" then
    params.append({ IncludeItemTypes: m.top.ItemType})
  end if

  url = Substitute("Users/{0}/Items/", get_setting("active_user"))
  resp = APIRequest(url, params)
  data = getJson(resp)

  if data.TotalRecordCount <> invalid then
    m.top.totalRecordCount = data.TotalRecordCount
  end if
  
  for each item in data.Items

    tmp = invalid
    if item.Type = "Movie" then
      tmp = CreateObject("roSGNode", "MovieData")
    else
      print "Unknown Type: " item.Type

    end if
  
    if tmp <> invalid then

      tmp.json = item
      results.push(tmp)

    end if
  end for

  m.top.content = results

end sub