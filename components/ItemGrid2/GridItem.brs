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
  end if

  print "Unhandled Item Type: " + itemData.type

end sub

'
'Resize Poster and Title Vivbility on focus change
sub focusChanged()

  if m.top.itemHasFocus = true then
    m.itemPoster.width = 295
    m.itemPoster.height = 440
    m.itemPoster.translation = [0,0]
    m.itemText.visible = true
  else
    m.itemPoster.width = 250
    m.itemPoster.height = 375
    m.itemPoster.translation = [21,35]
    m.itemText.visible = false
  end if

end sub
