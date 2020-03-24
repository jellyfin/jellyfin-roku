sub init()
  m.top.itemComponentName = "HomeItem"
  ' how many rows are visible on the screen
  m.top.numRows = 2

  m.top.rowFocusAnimationStyle = "fixedFocusWrap"
  m.top.vertFocusAnimationStyle = "fixedFocus"

  m.top.showRowLabel = [true]
  m.top.rowLabelOffset = [0, 20]
  m.top.showRowCounter = [true]

  updateSize()

  m.top.setfocus(true)

  ' Load the Libraries from API via task
  m.LoadLibrariesTask = createObject("roSGNode", "LoadItemsTask")
  m.LoadLibrariesTask.observeField("content", "onLibrariesLoaded")
  m.LoadLibrariesTask.control = "RUN"
end sub

sub updateSize()
  sideborder = 100
  m.top.translation = [111, 155]

  itemWidth = 480
  itemHeight = 330

  m.top.itemSize = [1920 - 111 - 27, itemHeight]
  ' spacing between rows
  m.top.itemSpacing = [0, 105]

  ' spacing between items in a row
  m.top.rowItemSpacing = [20, 0]

  m.top.visible = true
end sub

sub onLibrariesLoaded()
  m.libraryData = m.LoadLibrariesTask.content

  m.sizeArray = [[464, 311]]
  m.top.rowItemSize = m.sizeArray

  m.LoadLibrariesTask.unobserveField("content")

  if(m.libraryData <> invalid and m.libraryData.count() > 0) then

    'Add the Libraries Row
    m.data = CreateObject("roSGNode", "ContentNode")
    row = m.data.CreateChild("HomeRow")
    row.title = "My Media"

    for each item in m.libraryData
      row.appendChild(item)
    end for

  end if

  ' Load the Continue Watching Data
  m.top.content = m.data
  m.LoadContinueTask = createObject("roSGNode", "LoadItemsTask")
  m.LoadContinueTask.itemsToLoad = "continue"
  m.LoadContinueTask.observeField("content", "onContinueItemsLoaded")
  m.LoadContinueTask.control = "RUN"
end sub

sub onContinueItemsLoaded()
  m.LoadContinueTask.unobserveField("content")
  itemData = m.LoadContinueTask.content

  if(itemData <> invalid and itemData.count() > 0) then

    'Add the Row
    row = m.top.content.CreateChild("HomeRow")
    row.title = "Continue Watching"

    m.sizeArray.Push([464, 331])
    m.top.rowItemSize = m.sizeArray

    for each item in itemData
      row.appendChild(item)
    end for

  end if

  ' Load Next Up
  m.LoadNextUpTask = createObject("roSGNode", "LoadItemsTask")
  m.LoadNextUpTask.itemsToLoad = "nextUp"
  m.LoadNextUpTask.observeField("content", "onNextUpItemsLoaded")
  m.LoadNextUpTask.control = "RUN"
end sub

sub onNextUpItemsLoaded()
  m.LoadNextUpTask.unobserveField("content")
  itemData = m.LoadNextUpTask.content

  if(itemData <> invalid and itemData.count() > 0) then

    'Add the Next Up  Row
    row = m.top.content.CreateChild("HomeRow")
    row.title = "Next Up >"

    m.sizeArray.Push([464, 331])
    m.top.rowItemSize = m.sizeArray

    for each item in itemData
      row.appendChild(item)
    end for

  end if

  ' Now load latest in all libraries
  for each lib in m.libraryData

    if lib.collectionType <> "livetv" then
      loadLatest = createObject("roSGNode", "LoadItemsTask")
      loadLatest.itemsToLoad = "latest"
      loadLatest.itemId = lib.id

      metadata = { "title" : lib.name }
      metadata.Append({ "contentType" : lib.json.CollectionType })
      loadLatest.metadata = metadata

      loadLatest.observeField("content", "onLatestLoaded")
      loadLatest.control = "RUN"
    end if
  end for
end sub

function onLatestLoaded(msg)
  itemData = msg.GetData()

  data = msg.getField()
  node = msg.getRoSGNode()

  node.unobserveField("content")

  if(itemData <> invalid and itemData.count() > 0) then

    'Add the Latest  Row
    row = m.top.content.CreateChild("HomeRow")
    row.title = "Latest in " + node.metadata.title + " >"
    row.usePoster = true

    ' Handle specific types with different item widths
    if node.metadata.contentType = "movies" then
      row.imageWidth = 180
      m.sizeArray.Push([188, 331])
    else if node.metadata.contentType = "music" then
      row.imageWidth = 261
      m.sizeArray.Push([261, 331])
    else
      row.imageWidth = 464
      m.sizeArray.Push([464, 331])
    end if

    m.top.rowItemSize = m.sizeArray

    for each item in itemData
      row.appendChild(item)
    end for

  end if
end function

function updateHomeRows()
  m.LoadContinueTask.observeField("content", "updateContinueItems")
  m.LoadContinueTask.control = "RUN"
end function

function updateContinueItems()
  m.LoadContinueTask.unobserveField("content")
  itemData = m.LoadContinueTask.content

  if itemData = invalid then return false

  homeRows = m.top.content
  continueRowIndex = invalid
  for i = 1 to homeRows.getChildCount() - 1
    ' skip row 0 since it's always "My Media"
    tmpRow = homeRows.getChild(i)
    if tmpRow.title = "Continue Watching" then
      continueRowIndex = i
      exit for
    end if
  end for

  if itemData.count() < 1 then
    if continueRowIndex <> invalid then
      ' remove the row
      deleteFromSizeArray(continueRowIndex)
      homeRows.removeChildIndex(continueRowIndex)
    end if
  else
    ' remake row using the new data
    row = CreateObject("roSGNode", "HomeRow")
    row.title = "Continue Watching"
    itemSize = [464, 331]
    for each item in itemData
      row.appendChild(item)
    end for

    if continueRowIndex = invalid then
      ' insert new row under "My Media"
      updateSizeArray(itemSize, 1)
      homeRows.insertChild(row, 1)
    else
      ' replace the old row
      homeRows.replaceChild(row, continueRowIndex)
    end if
  end if

  m.LoadNextUpTask.observeField("content", "updateNextUpItems")
  m.LoadNextUpTask.control = "RUN"
end function

function updateNextUpItems()
  m.LoadNextUpTask.unobserveField("content")
  itemData = m.LoadNextUpTask.content

  if itemData = invalid then return false

  homeRows = m.top.content
  nextUpRowIndex = invalid
  for i = 1 to homeRows.getChildCount() - 1
    ' skip row 0 since it's always "My Media"
    tmpRow = homeRows.getChild(i)
    if tmpRow.title = "Next Up >" then
      nextUpRowIndex = i
      exit for
    end if
  end for

  if itemData.count() < 1 then
    if nextUpRowIndex <> invalid then
      ' remove the row
      deleteFromSizeArray(nextUpRowIndex)
      homeRows.removeChildIndex(nextUpRowIndex)
    end if
  else
    ' remake row using the new data
    row = m.top.content.CreateChild("HomeRow")
    row.title = "Next Up >"
    itemSize = [464, 331]
    for each item in itemData
      row.appendChild(item)
    end for

    if nextUpRowIndex = invalid then
      ' insert new row under "Continue Watching if it exists"
      tmpRow = homeRows.getChild(1)
      if tmpRow.title = "Continue Watching" then
        updateSizeArray(itemSize, 2)
        homeRows.insertChild(row, 2)
      else
        updateSizeArray(itemSize, 1)
        homeRows.insertChild(row, 1)
      end if
    else
      ' replace the old row
      homeRows.replaceChild(row, nextUpRowIndex)
    end if
  end if

  ' Update "Latest in" for all libraries
  for each lib in m.libraryData
    if lib.collectionType <> "livetv" then
      loadLatest = createObject("roSGNode", "LoadItemsTask")
      loadLatest.itemsToLoad = "latest"
      loadLatest.itemId = lib.id

      metadata = { "title" : lib.name }
      metadata.Append({ "contentType" : lib.json.CollectionType })
      loadLatest.metadata = metadata

      loadLatest.observeField("content", "updateLatestItems")
      loadLatest.control = "RUN"
    end if
  end for
end function

function updateLatestItems(msg)
  itemData = msg.GetData()

  data = msg.getField()
  node = msg.getRoSGNode()
  node.unobserveField("content")

  if itemData = invalid then return false

  homeRows = m.top.content
  rowIndex = invalid
  for i = 1 to homeRows.getChildCount() - 1
    ' skip row 0 since it's always "My Media"
    tmpRow = homeRows.getChild(i)
    if tmpRow.title = "Latest in " + node.metadata.title + " >" then
      rowIndex = i
      exit for
    end if
  end for

  if itemData.count() < 1 then
    ' remove row
    if rowIndex <> invalid then
      deleteFromSizeArray(rowIndex)
      homeRows.removeChildIndex(rowIndex)
    end if
  else
    ' remake row using new data
    row = m.top.content.CreateChild("HomeRow")
    row.title = "Latest in " + node.metadata.title + " >"
    row.usePoster = true
    ' Handle specific types with different item widths
    if node.metadata.contentType = "movies" then
      row.imageWidth = 180
      itemSize = [188, 331]
    else if node.metadata.contentType = "music" then
      row.imageWidth = 261
      itemSize = [261, 331]
    else
      row.imageWidth = 464
      itemSize = [464, 331]
    end if

    for each item in itemData
      row.appendChild(item)
    end for

    if rowIndex = invalid then
      ' append new row
      ' todo: insert row based on user settings
      updateSizeArray(itemSize)
      homeRows.appendChild(row)
    else
      ' replace the old row
      homeRows.replaceChild(row, rowIndex)
    end if
  end if
end function

sub updateSizeArray(rowItemSize, rowIndex = invalid, action = "add")
  sizeArray = m.top.rowItemSize
  ' append by default
  if rowIndex = invalid then
    rowIndex = sizeArray.count()
  end if

  newSizeArray = []
  for i = 0 to sizeArray.count()
    if rowIndex = i then
      if action = "add" then
        ' insert new row size
        newSizeArray.Push(rowItemSize)
        if sizeArray[i] <> invalid then
          ' copy row size
          newSizeArray.Push(sizeArray[i])
        end if
      end if
    else if sizeArray[i] <> invalid then
      ' copy row size
      newSizeArray.Push(sizeArray[i])
    end if
  end for
  m.top.rowItemSize = newSizeArray
end sub

sub deleteFromSizeArray(rowIndex)
  updateSizeArray([0, 0], rowIndex, "delete")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  if not press then return false

  if key <> "OK" then return false

  ' Set the selected item
  m.top.selectedItem = m.top.content.getChild(m.top.rowItemFocused[0]).getChild(m.top.rowItemFocused[1])
  return true
end function