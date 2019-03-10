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
  scene.backgroundColor = "#101010"
  scene.backgroundURI = ""
end sub
