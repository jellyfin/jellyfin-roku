sub init()
  m.itemPoster = m.top.findNode("itemPoster")
  m.itemText = m.top.findNode("itemText")
end sub

sub itemContentChanged()

  itemData = m.top.itemContent

  if itemData = invalid then return

  itemPoster = m.top.findNode("itemPoster")

  if itemData.type = "Movie" then
    itemPoster.uri = itemData.PosterUrl
    m.itemText.text = itemData.Title
    return
  else if itemData.type = "Series" then
    itemPoster.uri = itemData.PosterUrl
    m.itemText.text = itemData.Title
    return
  end if

  print "Unhandled Item Type: " + itemData.type

end sub

'
'Use FocusPercent to animate scaling of Poser Image
sub focusChanging()
  scaleFactor = 1 + (m.top.focusPercent * 0.17333)
  m.itemPoster.scale = [scaleFactor, scaleFactor]
end sub

'
'Display or hide title Visibility on focus change
sub focusChanged()

  if m.top.itemHasFocus = true then
    m.itemText.visible = true
  else
    m.itemText.visible = false
  end if

end sub
