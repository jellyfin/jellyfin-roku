sub init()

end sub

function itemContentChanged() as void
  itemData = m.top.itemContent
  if itemData = invalid then return

  itemText = m.top.findNode("itemText")
  itemPoster = m.top.findNode("itemPoster")

  if itemData.json.CollectionType = invalid then
    itemPoster.uri = itemData.imageURL

    itemText.height = 34
    itemText.font.size = 25
    itemText.horizAlign = "left"
    itemText.vertAlign = "bottom"

    itemTextExtra = m.top.findNode("itemTextExtra")
    itemTextExtra.font.size = 24
    itemTextExtra.visible = true

    if itemData.type = "Episode" then
      itemText.text = itemData.json.SeriesName
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
    else if itemData.type = "Movie" then
      itemText.text = itemData.name
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
    end if
  else
    ' handle libraries with no picture
    if itemData.type = "livetv" then
      itemPoster.width = "96"
      itemPoster.height = "96"
      itemPoster.translation = "[192, 88]"
      itemPoster.uri = "pkg:/images/baseline_live_tv_white_48dp.png"
      itemText.text = itemData.name
    else if itemData.type = "music" then
      itemPoster.width = "96"
      itemPoster.height = "96"
      itemPoster.translation = "[192, 88]"
      itemPoster.uri = "pkg:/images/baseline_library_music_white_48dp.png"
      itemText.text = itemData.name
    else
      itemPoster.uri = itemData.imageURL
      itemText.text = itemData.name
    end if
  end if
end function
