sub itemContentChanged()
  itemData = m.top.itemContent
  if itemData = invalid then return
  itemData.Title = itemData.name ' Temporarily required while we move from "HomeItem" to "JFContentItem"
  
  m.itemText = m.top.findNode("itemText")
  itemPoster = m.top.findNode("itemPoster")
  itemIcon = m.top.findNode("itemIcon")
  itemTextExtra = m.top.findNode("itemTextExtra")

  ' Desired Image Width
  imageWidth = 464
  if m.top.GetParent().content.imageWidth <> invalid
    imageWidth = m.top.GetParent().content.imageWidth
  end if

  itemPoster.width = imageWidth
  m.itemText.maxWidth = imageWidth
  itemTextExtra.width = imageWidth

  ' Randmomise the background colors
  m.backdrop = m.top.findNode("backdrop")
  posterBackgrounds = m.global.constants.poster_bg_pallet
  m.backdrop.color = posterBackgrounds[rnd(posterBackgrounds.count()) - 1]
  m.backdrop.width = imageWidth

  ' Whether to use WidePoster or Thumbnail in this row
  usePoster = m.top.GetParent().content.usePoster

  if itemData.iconUrl <> invalid
    itemIcon.uri = itemData.iconUrl
  end if

  ' Format the Data based on the type of Home Data

  if itemData.type = "CollectionFolder" OR itemData.type = "UserView"  OR itemData.type = "Channel" then
    m.itemText.text = itemData.name
    itemPoster.uri = itemData.widePosterURL
    return
  end if

  if itemData.type = "UserView" then
    itemPoster.width = "96"
    itemPoster.height = "96"
    itemPoster.translation = "[192, 88]"
    m.itemText.text = itemData.name
    itemPoster.uri = itemData.widePosterURL
    return
  end if


  m.itemText.height = 34
  m.itemText.font.size = 25
  m.itemText.horizAlign = "left"
  m.itemText.vertAlign = "bottom"
  itemTextExtra.visible = true
  itemTextExtra.font.size = 22


  if itemData.type = "Episode" then
    m.itemText.text = itemData.json.SeriesName

    if usePoster = true then
      itemPoster.uri = itemData.widePosterURL
    else
      itemPoster.uri = itemData.thumbnailURL
    end if

    ' Set Series and Episode Number for Extra Text
    extraPrefix = ""
    if itemData.json.ParentIndexNumber <> invalid then
      extraPrefix = "S" + StrI(itemData.json.ParentIndexNumber).trim()
    end if
    if itemData.json.IndexNumber <> invalid then
      extraPrefix = extraPrefix + "E" + StrI(itemData.json.IndexNumber).trim()
    end if
    if extraPrefix.len() > 0 then
      extraPrefix = extraPrefix + " - "
    end if

    itemTextExtra.text = extraPrefix + itemData.name
    return
  end if

  if itemData.type = "Movie" then
    m.itemText.text = itemData.name

    ' Use best image, but fallback to secondary if it's empty
    if (imageWidth = 180 and itemData.posterURL <> "") or itemData.thumbnailURL = ""
      itemPoster.uri = itemData.posterURL
    else
      itemPoster.uri = itemData.thumbnailURL
    end if

    ' Set Release Year and Age Rating for Extra Text
    textExtra = ""
    if itemData.json.ProductionYear <> invalid then
      textExtra = StrI(itemData.json.ProductionYear).trim()
    end if
    if itemData.json.OfficialRating <> invalid then
      if textExtra <> "" then
        textExtra = textExtra + " - " + itemData.json.OfficialRating
      else
        textExtra = itemData.json.OfficialRating
      end if
    end if
    itemTextExtra.text = textExtra

    return
  end if

  if itemData.type = "Video" then
    m.itemText.text = itemData.name

    if imageWidth = 180
      itemPoster.uri = itemData.posterURL
    else
      itemPoster.uri = itemData.thumbnailURL
    end if
    return
  end if
  if itemData.type = "Series" then

    m.itemText.text = itemData.name

    if usePoster = true then
      if imageWidth = 180 then
        itemPoster.uri = itemData.posterURL
      else
        itemPoster.uri = itemData.widePosterURL
      end if
    else
      itemPoster.uri = itemData.thumbnailURL
    end if

    textExtra = ""
    if itemData.json.ProductionYear <> invalid then
      textExtra = StrI(itemData.json.ProductionYear).trim()
    end if

    ' Set Years Run for Extra Text
    if itemData.json.Status = "Continuing" then
      textExtra = textExtra + " - Present"
    else if itemData.json.Status = "Ended" and itemData.json.EndDate <> invalid
      textExtra = textExtra + " - " + LEFT(itemData.json.EndDate, 4)
    end if
    itemTextExtra.text = textExtra

    return
  end if

  if itemData.type = "MusicAlbum" then
    m.itemText.text = itemData.name
    itemTextExtra.text = itemData.json.AlbumArtist
    itemPoster.uri = itemData.posterURL
    return
  end if

  print "Unhandled Item Type: " + itemData.type

end sub

'
' Enable title scrolling based on item Focus
sub focusChanged()

  if m.top.itemHasFocus = true then
    m.itemText.repeatCount = -1
  else
    m.itemText.repeatCount = 0
  end if

end sub
