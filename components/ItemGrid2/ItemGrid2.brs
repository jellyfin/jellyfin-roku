sub init()

  m.itemGrid = m.top.findNode("itemGrid")
  m.backdrop = m.top.findNode("backdrop")
  m.newBackdrop = m.top.findNode("backdropTransition")

  m.swapAnimation = m.top.findNode("backroundSwapAnimation")
  m.swapAnimation.observeField("state", "swapDone")
  
  m.loadedRows = 0
  m.loadedItems = 0

  m.data = CreateObject("roSGNode", "ContentNode")

  m.itemGrid.content = m.data
  m.itemGrid.setFocus(true)

  m.itemGrid.observeField("itemFocused", "onItemFocused")
  m.itemGrid.observeField("itemSelected", "onItemSelected")
  m.newBackdrop.observeField("loadStatus", "newBGLoaded")

  'Background Image Queued for loading
  m.queuedBGUri = ""

  m.loadItemsTask = createObject("roSGNode", "LoadItemsTask2")
  
end sub

'
'Load initial set of Data
sub loadInitialItems() 

  m.loadItemsTask.itemId = m.top.parentItem.Id
  m.loadItemsTask.observeField("content", "ItemDataLoaded")

  if m.top.parentItem.collectionType = "movies" then
    m.loadItemsTask.itemType = "Movie"
  else if m.top.parentItem.collectionType = "tvshows" then
    m.loadItemsTask.itemType = "Series"
  end if

  m.loadItemsTask.control = "RUN"
end sub

'
'Handle loaded data, and add to Grid
sub ItemDataLoaded(msg)
 
  itemData = msg.GetData()
  data = msg.getField()

  if itemData = invalid then 
    m.Loading = false
    return 
  end if

  for each item in itemData
    m.data.appendChild(item)
  end for

  'Update the stored counts
  m.loadedItems = m.itemGrid.content.getChildCount() 
  m.loadedRows = m.loadedItems / m.itemGrid.numColumns
  m.Loading = false
end sub

'
'Set Background Image
sub SetBackground(backgroundUri as string)

  'If a new image is being loaded, or transitioned to, store URL to load next
  if m.swapAnimation.state <> "stopped" or m.newBackdrop.loadStatus = "loading" then
    m.queuedBGUri = backgroundUri
    return
  end if

  m.newBackdrop.uri = backgroundUri
end sub

'
'Handle new item being focused
sub onItemFocused()

  focusedRow = CInt(m.itemGrid.itemFocused / m.itemGrid.numColumns) + 1

  ' Set Background
  itemInt = m.itemGrid.itemFocused

  SetBackground(m.itemGrid.content.getChild(m.itemGrid.itemFocused).backdropUrl)

  ' Load more data if focus is within last 3 rows, and there are more items to load
  if focusedRow >= m.loadedRows - 3 and m.loadeditems < m.loadItemsTask.totalRecordCount then
    loadMoreData()
  end if
end sub 

'
'When Image Loading Status changes
sub newBGLoaded()
  'If image load was sucessful, start the fade swap
  if m.newBackdrop.loadStatus = "ready"
    m.swapAnimation.control = "start"
  end if
end sub

'
'Swap Complete
sub swapDone()

  if m.swapAnimation.state = "stopped" then
  
    'Set main BG node image and hide transitioning node
    m.backdrop.uri = m.newBackdrop.uri
    m.backdrop.opacity = 0.25
    m.newBackdrop.opacity = 0
  
    'If there is another one to load
    if m.newBackdrop.uri <> m.queuedBGUri and m.queuedBGUri <> ""  then
        SetBackground(m.queuedBGUri)
        m.queuedBGUri = ""
    end if
  end if
end sub

'
'Load next set of items
sub loadMoreData()

  if m.Loading = true then return

  m.Loading = true
  m.loadItemsTask.startIndex = m.loadedItems
  m.loadItemsTask.control = "RUN"
end sub

'
'Item Selected
sub onItemSelected()
  m.top.selectedItem = m.itemGrid.content.getChild(m.itemGrid.itemSelected)
end sub