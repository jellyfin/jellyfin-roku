sub setFields()
    json = m.top.json
  
    startDate = createObject("roDateTime") 
    endDate = createObject("roDateTime")
    startDate.FromISO8601String(json.StartDate)
    endDate.FromISO8601String(json.EndDate)

    m.top.Title = json.Name
    m.top.PlayStart = startDate.AsSeconds()
    m.top.PlayDuration = endDate.AsSeconds() - m.top.PlayStart
    m.top.Id = json.Id
    m.top.Description = json.overview
    m.top.EpisodeTitle = json.EpisodeTitle
    m.top.isLive = json.isLive
    m.top.isRepeat = json.isRepeat
    m.top.startDate = json.startDate
    m.top.endDate = json.endDate
    m.top.channelId = json.channelId

    if json.IsSeries <> invalid and json.IsSeries = true then
        if json.IndexNumber <> invalid
            m.top.episodeNumber = json.IndexNumber
        end if

        if json.ParentIndexNumber <> invalid
            m.top.seasonNumber = json.ParentIndexNumber
        end if
    end if


    ' m.top.id = json.id
    ' m.top.Title = json.name
    ' m.top.Description = json.overview
    ' m.top.favorite = json.UserData.isFavorite
    ' m.top.watched = json.UserData.played
    ' m.top.Type = "Movie"  
    
    ' if json.ProductionYear <> invalid then
    '   m.top.SubTitle = json.ProductionYear
    ' end if
  
    ' if json.OfficialRating <> invalid and json.OfficialRating <> "" then
    '   m.top.Rating = json.OfficialRating
    '   if m.top.SubTitle <> "" then
    '     m.top.SubTitle = m.top.SubTitle + " - " + m.top.Rating
    '   else
    '     m.top.SubTitle = m.top.Rating
    '   end if
    ' end if
  
    setPoster()
  end sub
  
  sub setPoster()
    if m.top.image <> invalid
      m.top.posterURL = m.top.image.url
    else
      if m.top.json.ImageTags <> invalid and m.top.json.ImageTags.Thumb <> invalid then
        imgParams = { "maxHeight": 500, "maxWidth": 500, "Tag" : m.top.json.ImageTags.Thumb }
        m.top.posterURL = ImageURL(m.top.json.id, "Thumb", imgParams)
        ' imgParams = { "maxHeight": 440, "maxWidth": 295, "Tag" : m.top.json.ImageTags.Primary }
        ' m.top.posterURL = ImageURL(m.top.json.id, "Primary", imgParams)
      end if
    end if
  end sub
