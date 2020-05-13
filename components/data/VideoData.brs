sub setFields()
    datum = m.top.json

    m.top.id = datum.id
    m.top.title = datum.name

end sub

sub setPoster()
  if m.top.image <> invalid
    m.top.posterURL = m.top.image.url
  else
    m.top.posterURL = ""
  end if

end sub
