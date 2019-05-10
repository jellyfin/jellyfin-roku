sub setFields()
    datum = m.top.json
    m.top.id = datum.id
    m.top.title = datum.name
    m.top.overview = datum.overview

    setPoster()

    'm.top.seasons = TVSeasons(datum.id)
    'm.top.nextup = TVNext(datum.id)
end sub

sub setPoster()
    if m.top.image <> invalid
      m.top.posterURL = m.top.image.url
    else
        m.top.posterURL = ""
    end if
end sub