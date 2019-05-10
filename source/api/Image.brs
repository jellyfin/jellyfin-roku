function ItemImages(id="" as String)
  ' This seems to cause crazy core dumps
  resp = APIRequest(Substitute("Items/{0}/Images", id))
  data = getJson(resp)
  results = []
  for each item in data
    tmp = CreateObject("roSGNode", "ImageData")
    tmp.json = item
    tmp.url = ImageURL(id, tmp.imagetype)
    results.push(tmp)
  end for
  return results
end function


function PosterImage(id)
    images = ItemImages(id)
    primary_image = invalid

    for each image in images
      if image.imagetype = "Primary"
        primary_image = image
      else if image.imagetype = "Logo" and primary_image = invalid
        primary_image = image
      else if image.imagetype = "Thumb" and primary_image = invalid
        primary_image = image
        ' maybe find more fallback images
      end if
    end for

    return primary_image
end function


function ImageURL(id, version="Primary", params={})
  if params.count() = 0
    params =  {"maxHeight": "384", "maxWidth": "196", "quality": "90"}
  end if
  url = Substitute("Items/{0}/Images/{1}", id, version)
  ' ?maxHeight=384&maxWidth=256&tag=<tag>&quality=90"
  return buildURL(url, params)
end function
