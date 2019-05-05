sub init()
  m.name = m.top.findNode("label")
  m.value = m.top.findNode("value")

  m.top.layoutDirection = "horiz"
  m.top.vertAlignment = "top"

  m.name.width = 250
  m.name.height = 80

  m.name.vertAlign = "center"
  m.name.horizAlign = "center"

  ' TODO - calculate "width" better... this is total item - (label + spacings)
  m.value.width = 1000 - 230
  m.value.height = 80

  m.value.hintText = "Enter a value..."
  m.value.maxTextLength = 100
end sub

sub itemContentChanged()
  data = m.top.itemContent

  m.name.text = data.label
  if data.type = "password"
    m.value.secureMode = true
  end if

  m.value.text = data.value
end sub

sub setColors()
  if m.top.itemHasFocus
    color = "#101010FF"
  else
    color = "#ffffffFF"
  end if

  m.name.color = color
  m.value.textColor = color

end sub