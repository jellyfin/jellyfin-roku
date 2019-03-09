sub itemSelectedQ(msg) as boolean
  ' "Q" stands for "Question mark" since itemSelected? wasn't acceptable
  ' Probably needs a better name, but unique for now
  return type(msg) = "roSGNodeEvent" and msg.getField() = "itemSelected"
end sub

sub itemFocusedQ(msg) as boolean
  ' "Q" stands for "Question mark" since itemSelected? wasn't acceptable
  ' Probably needs a better name, but unique for now
  return type(msg) = "roSGNodeEvent" and msg.getField() = "itemFocused"
end sub

sub getMsgRowTarget(msg) as object
  node = msg.getRoSGNode()
  coords = node.rowItemSelected
  target = node.content.getChild(coords[0]).getChild(coords[1])
  return target
end sub
