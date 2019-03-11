sub itemContentChanged()
  itemData = m.top.itemContent.full_data

  m.top.findNode("tvshowPoster").uri = m.top.itemContent.posterURL

  ' Handle all "As Is" fields
  setFieldText("title", itemData.name)
  setFieldText("releaseYear", itemData.productionYear)
  setFieldText("officialRating", itemData.officialRating)
  setFieldText("communityRating", str(itemData.communityRating))
  setFieldText("overview", itemData.overview)

  setFieldText("runtime", stri(getRuntime()) + " mins")

  setFieldText("history", getHistory())

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
  if itemData.taglines.count() > 0
    setFieldText("tagline", itemData.taglines[0])
  end if

  setSeasons()
end sub

sub setSeasons()
  itemData = m.top.itemContent
  row = m.top.findNode("TVSeasonSelect")

  print itemData.seasons

  row.TVSeasonData = itemData.seasons
end sub

sub setFieldText(field as string, value)
  node = m.top.findNode(field)
  if node = invalid then return

  node.text = value
end sub

function getRuntime() as Integer
  itemData = m.top.itemContent.full_data

  ' A tick is .1ms, so 1/10,000,000 for ticks to seconds,
  ' then 1/60 for seconds to minutess... 1/600,000,000
  return round(itemData.RunTimeTicks / 600000000.0)
end function

function getEndTime() as string
  itemData = m.top.itemContent.full_data

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

  return Substitute("{0}:{1} {2}", stri(hours).trim(), stri(date.getMinutes()).trim(), meridian)
end function

function getHistory() as string
  itemData = m.top.itemContent.full_data
  ' Aired Fridays at 9:30 PM on ABC (US)

  airwords = invalid
  studio = invalid
  if itemData.status = "Ended"
    verb = "Aired"
  else
    verb = "Airs"
  end if

  airdays = itemData.airdays
  airtime = itemData.airtime
  if airtime <> invalid and airdays.count() = 1
    airwords = airdays[0] + " at " + airtime
  endif

  if itemData.studios.count() > 0
    studio = itemData.studios[0].name
  end if

  if studio = invalid and airwords = invalid
    return ""
  end if

  words = verb
  if airwords <> invalid
    words = words + " " + airwords
  end if
  if studio <> invalid
    words = words + " on " + studio
  end if

  return words
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

