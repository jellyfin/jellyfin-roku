sub init()
    itemText = m.top.findNode("itemText")
    itemText.text = "Loading..."

    updateSize()
end sub

sub updateSize()
    itemText = m.top.findNode("itemText")
    maxSize = m.top.getParent().itemSize
    itemText.width = maxSize[0]
    itemText.height = maxSize[1]

    itemText.translation = [0, (maxSize[1] / 2) - 15]
end sub

function itemContentChanged() as void
    itemData = m.top.itemContent
    if itemData = invalid then return

    itemText = m.top.findNode("itemText")
    itemText.text = itemData.name
    updateSize()
end function