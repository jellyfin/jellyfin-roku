sub itemContentChanged()
  itemData = m.top.itemJson

  m.top.findNode("moviePoster").uri = ImageURL(itemData.id)

  ' Handle all "As Is" fields
  setFieldText("title", itemData.name)
  setFieldText("releaseYear", itemData.productionYear)
  setFieldText("officialRating", itemData.officialRating)
  setFieldText("communityRating", str(itemData.communityRating))
  setFieldText("overview", itemData.overview)

  setFieldText("runtime", stri(getRuntime()) + " mins")
  setFieldText("ends-at", "Ends at " + getEndTime())

  if itemData.genres.count() > 0
    setFieldText("genres", itemData.genres.join(", "))
  end if
  director = invalid
  for each person in itemData.people
    if person.type = "Director"
      director = person.name
      exit for
    end if
  end for
  if director <> invalid
    setFieldText("director", "Director: " + director)
  end if
  setFieldText("video_codec", "Video: " + itemData.mediaStreams[0].displayTitle)
  setFieldText("audio_codec", "Audio: " + itemData.mediaStreams[1].displayTitle)
  ' TODO - cmon now. these are buttons, not words
  setFieldText("buttons", "Play, Delete, Watched, Favorite, ...")
  if itemData.taglines.count() > 0
    setFieldText("tagline", itemData.taglines[0])
  end if
end sub

sub setFieldText(field as string, value)
  node = m.top.findNode(field)
  if node = invalid then return

  node.text = value
end sub

function getRuntime() as Integer
  itemData = m.top.itemJson

  ' A tick is .1ms, so 1/10,000,000 for ticks to seconds,
  ' then 1/60 for seconds to minutess... 1/600,000,000
  return round(itemData.RunTimeTicks / 600000000.0)
end function

function getEndTime() as string
  itemData = m.top.itemJson

  date = CreateObject("roDateTime")
  duration_s = int(itemData.RunTimeTicks / 10000000.0)
  date.fromSeconds(date.asSeconds() + duration_s)
  date.toLocalTime()
  hours = date.getHours()
  meridian = "AM"
  if hours = 0
    hours = 12
    meridian = "AM"
  else if hours = 12
    hours = 12
    meridian = "PM"
  else if hours > 12
    hours = hours - 12
    meridian = "PM"
  end if

  return Substitute("{0}:{1} {2}", stri(hours), stri(date.getMinutes()), meridian)
end function

function round(f as Float) as Integer
  ' BrightScript only has a "floor" round
  ' This compares floor to floor + 1 to find which is closer
  m = int(f)
  n = m + 1
  x = abs(f - m)
  y = abs(f - n)
  if y > x
    return m
  else
    return n
  end if
end function
