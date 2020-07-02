sub init()
  m.posterMask = m.top.findNode("posterMask")
  m.itemPoster = m.top.findNode("itemPoster")
  m.itemText = m.top.findNode("itemText")

  m.itemText.translation = [0, m.itemPoster.height + 7]
end sub

sub itemContentChanged()

  itemData = m.top.itemContent

  if itemData = invalid then return

  if itemData.type = "Movie" then
    m.itemPoster.uri = itemData.PosterUrl
    m.itemText.text = itemData.Title
    return
  else if itemData.type = "Series" then
    m.itemPoster.uri = itemData.PosterUrl
    m.itemText.text = itemData.Title
    return
  else if itemData.type = "Boxset" then
    itemPoster.uri = itemData.PosterUrl
    m.itemText.text = itemData.Title
    return
  end if

  print "Unhandled Item Type: " + itemData.type

end sub

'
'Use FocusPercent to animate scaling of Poser Image
sub focusChanging()
  scaleFactor = 0.85 + (m.top.focusPercent * 0.15)
  m.posterMask.scale = [scaleFactor, scaleFactor]
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
