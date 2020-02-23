sub init()
    m.title = m.top.findNode("title")
    m.title.text = "Loading..."
end sub

function itemContentChanged() as void
  item = m.top.itemContent
  itemData = item.json
  m.top.findNode("title").text = item.title
  m.top.findNode("poster").uri = item.posterURL
  m.top.findNode("overview").text = item.overview

  if type(itemData.RunTimeTicks) = "LongInteger"
    m.top.findNode("runtime").text = stri(getRuntime()) + " mins"
    m.top.findNode("endtime").text = "Ends at " + getEndTime()
  end if
  if itemData.communityRating <> invalid then
    m.top.findNode("communityRating").text = str(int(itemData.communityRating*10)/10)
  end if
end function

function getRuntime() as integer
  itemData = m.top.itemContent.json

  ' A tick is .1ms, so 1/10,000,000 for ticks to seconds,
  ' then 1/60 for seconds to minutess... 1/600,000,000
  return int(itemData.RunTimeTicks / 600000000.0)
end function

function getEndTime() as string
  itemData = m.top.itemContent.json
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
  minutes = stri(date.getMinutes()).trim()
  if val(minutes) > 10
    minutes= "0" + minutes
  end if

  return Substitute("{0}:{1} {2}", stri(hours).trim(), stri(date.getMinutes()).trim(), meridian)
end function
