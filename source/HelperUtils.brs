' "Q" stands for "Question mark" since nodeEvent? wasn't acceptable
' Probably needs a better name, but unique for now
function nodeEventQ(msg, field) as boolean
  return type(msg) = "roSGNodeEvent" and msg.getField() = field
end function

function getMsgRowTarget(msg) as object
  node = msg.getRoSGNode()
  coords = node.rowItemSelected
  target = node.content.getChild(coords[0]).getChild(coords[1])
  return target
end function

sub themeScene(scene)
  dimensions = scene.currentDesignResolution
  scene.backgroundColor = "#101010"
  scene.backgroundURI = ""

  footer_background = scene.findNode("footerBackdrop")
  if footer_background <> invalid
    footer_background.color = scene.backgroundColor
    footer_background.width = dimensions.width
    footer_background.height = 115
    footer_background.translation = [0, dimensions.height - 115]
  end if

  overhang = scene.findNode("overhang")
  if overhang <> invalid
    overhang.logoUri = "pkg:/images/logo.png"
  end if
end sub

function leftPad(base as string, fill as string, length as integer) as string
  while len(base) < length
    base = fill + base
  end while
  return base
end function
