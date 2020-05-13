sub init()

  m.rowList = m.top.findNode("RowList") '  createObject("roSGNode", "RowList")
  '  m.top.appendChild(m.rowList)

  m.rowList.itemComponentName = "HomeItem"

  formatRowList()

  m.rowList.setfocus(true)

  m.rowList.observeField("rowItemSelected", "itemSelected")

end sub

sub formatRowList()

  ' how many rows are visible on the screen
  m.rowList.numRows = 2

  m.rowList.rowFocusAnimationStyle = "fixedFocusWrap"
  m.rowList.vertFocusAnimationStyle = "fixedFocus"

  m.rowList.showRowLabel = [true]
  m.rowList.rowLabelOffset = [0, 20]
  m.rowList.showRowCounter = [true]

  sideborder = 100
  m.rowList.translation = [111, 155]

  m.rowItemSizes = []

  itemWidth = 480
  itemHeight = 330

  m.rowList.itemSize = [1920 - 111 - 27, itemHeight]
  ' spacing between rows
  m.rowList.itemSpacing = [0, 105]

  ' spacing between items in a row
  m.rowList.rowItemSpacing = [20, 0]

  m.rowList.visible = true
end sub


sub setupRows()

  for each item in m.top.objects.Items

    homeItem = CreateObject("roSGNode", "HomeData")
    homeItem.json = item.json

    if homeItem.Type = "Video" or homeItem.Type = "Movie" or homeItem.Type = "Episode" then

      if m.videoRow = invalid then
        m.videoRow = CreateObject("roSGNode", "HomeRow")
        m.videoRow.title = tr("Videos")
        m.videoRow.usePoster = true
        m.videoRow.imageWidth = 180
      end if

      m.videoRow.appendChild(homeItem)

    else if homeItem.Type = "MusicAlbum"

      if m.albumRow = invalid then
        m.albumRow = CreateObject("roSGNode", "HomeRow")
        m.albumRow.imageWidth = 261
        m.albumRow.title = tr("Albums")
        m.albumRow.usePoster = true
      end if

      m.albumRow.appendChild(homeItem)

    else if homeItem.Type = "Series"

      if m.seriesRow = invalid then
        m.seriesRow = CreateObject("roSGNode", "HomeRow")
        m.seriesRow.title = tr("Series")
        m.seriesRow.usePoster = true
        m.seriesRow.imageWidth = 180
      end if

      m.seriesRow.appendChild(homeItem)

    else
      print "Collection - Unknown Type ", homeItem.Type
    end if
  end for

  data = CreateObject("roSGNode", "ContentNode")

  if m.videoRow <> invalid then
    data.appendChild(m.videoRow)
    m.rowItemSizes.push([188, 331])
  end if

  if m.seriesRow <> invalid then
    data.appendChild(m.seriesRow)
    m.rowItemSizes.push([188, 331])
  end if

  if m.albumRow <> invalid then
    data.appendChild(m.albumRow)
    m.rowItemSizes.push([261, 331])
  end if

  m.rowList.rowItemSize = m.rowItemSizes
  m.rowList.content = data

end sub

function itemSelected()
  m.top.selectedItem = m.rowList.content.getChild(m.rowList.rowItemSelected[0]).getChild(m.rowList.rowItemSelected[1])
end function
