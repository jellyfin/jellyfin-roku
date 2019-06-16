sub setFields()
  json = m.top.json

  m.top.id = json.id
  m.top.title = json.name
  m.top.overview = json.overview
  m.top.favorite = json.UserData.isFavorite
  m.top.watched = json.UserData.played

  setPoster()
  setContainer()
end sub

sub setPoster()
  if m.top.image <> invalid
    m.top.posterURL = m.top.image.url
  else
    m.top.posterURL = ""
  end if

end sub

sub setContainer()
  json = m.top.json

  if json.mediaSources = invalid then return
  if json.mediaSources.count() = 0 then return

  m.top.container = json.mediaSources[0].container

  if m.top.container = invalid then m.top.container = ""

  if m.top.container = "m4v" or m.top.container = "mov"
    m.top.container = "mp4"
  end if
end sub