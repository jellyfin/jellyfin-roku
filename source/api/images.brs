function ImageURL(id, version="Primary", params={})
  if params.count() = 0
    params =  {"maxHeight": "384", "maxWidth": "196", "quality": "90"}
  end if
  url = Substitute("Items/{0}/Images/{1}", id, version)
  ' ?maxHeight=384&maxWidth=256&tag=<tag>&quality=90"
  return buildURL(url, params)
end function
