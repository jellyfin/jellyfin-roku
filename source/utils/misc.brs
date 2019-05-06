' "Q" stands for "Question mark" since nodeEvent? wasn't acceptable
' Probably needs a better name, but unique for now
function nodeEventQ(msg, field as string) as boolean
  return type(msg) = "roSGNodeEvent" and msg.getField() = field
end function

function getMsgRowTarget(msg, subnode="" as string) as object
  node = msg.getRoSGNode()
  ' Subnode allows for handling alias messages
  if subnode <> ""
    node = node.findNode(subnode)
  end if
  coords = node.rowItemSelected
  target = node.content.getChild(coords[0]).getChild(coords[1])
  return target
end function

sub themeScene(scene)
  ' Takes a scene and applies a consisten UI Theme
  dimensions = scene.currentDesignResolution
  scene.backgroundColor = "#101010"
  scene.backgroundURI = ""

  footer_background = scene.findNode("footerBackdrop")
  overhang = scene.findNode("overhang")
  options = scene.findNode("options")

  if footer_background <> invalid
    footer_background.color = scene.backgroundColor
    footer_background.width = dimensions.width
    height = footer_background.height
    if height = invalid or height = 0 then height = 115
    footer_background.height = height
    footer_background.translation = [0, dimensions.height - height]
  end if

  if overhang <> invalid
    overhang.logoUri = "pkg:/images/logo.png"
    overhang.logoBaselineOffset = 7.5
    overhang.showOptions = true
    if options <> invalid
      overhang.optionsAvailable = true
    else
      overhang.optionsAvailalbe = false
    end if
  end if
end sub

function leftPad(base as string, fill as string, length as integer) as string
  while len(base) < length
    base = fill + base
  end while
  return base
end function

function make_dialog(message="" as string)
  ' Takes a string and returns an object for dialog popup
  dialog = createObject("roSGNode", "Dialog")
  dialog.id = "popup"
  dialog.buttons = ["OK"]
  dialog.message = message

  return dialog
end function
