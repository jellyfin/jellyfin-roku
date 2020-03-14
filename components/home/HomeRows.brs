sub init()
	m.top.itemComponentName = "HomeItem"
	' My media row should always exist
	m.top.numRows = 2

	m.top.rowFocusAnimationStyle = "fixedFocusWrap"
	m.top.vertFocusAnimationStyle = "fixedFocus"

	m.top.showRowLabel = [true]
	m.top.rowLabelOffset = [0, 20]
	m.top.showRowCounter = [true]

	updateSize()

	m.top.setfocus(true)

	' Load the Libraries from API via task
	m.LoadItemsTask = createObject("roSGNode", "LoadItemsTask")
	m.LoadItemsTask.observeField("content", "onLibrariesLoaded")
	m.LoadItemsTask.control = "RUN"

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

	m.libraryData = m.LoadItemsTask.content

	m.sizeArray = [[464, 261]]
	m.top.rowItemSize = m.sizeArray

	m.LoadItemsTask.unobserveField("content")

	if(m.libraryData <> invalid AND m.libraryData.count() > 0) then

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

	if(itemData <> invalid AND itemData.count() > 0) then

		'Add the Row
		row = m.top.content.CreateChild("HomeRow")
		row.title = "Continue Watching"

		m.sizeArray.Push([464, 261])
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

	if(itemData <> invalid AND itemData.count() > 0) then

		'Add the Next Up  Row
		row = m.top.content.CreateChild("HomeRow")
		row.title = "Next Up >"
		row.usePoster = true

		m.sizeArray.Push([464, 261])
		m.top.rowItemSize = m.sizeArray

		for each item in itemData
			row.appendChild(item)
		end for

	end if

	' Now load latest in all libraries
	for each lib in m.libraryData

		loadLatest = createObject("roSGNode", "LoadItemsTask")
		loadLatest.itemsToLoad = "latest"
		loadLatest.itemId = lib.id
	
		metadata = { "title" : lib.name}
		metadata.Append({"contentType" : lib.json.CollectionType})
		loadLatest.metadata = metadata

		loadLatest.observeField("content", "onLatestLoaded")
		loadLatest.control = "RUN"
	end for

end sub


function onLatestLoaded(msg)

	itemData = msg.GetData()

 	data = msg.getField()
	node = msg.getRoSGNode()

	node.unobserveField("content")

	if(itemData <> invalid AND itemData.count() > 0) then

		'Add the Latest  Row
		row = m.top.content.CreateChild("HomeRow")
		row.title = "Latest in " + node.metadata.title + " >"
		row.usePoster = true

		' Handle specific types with different item widths
		if node.metadata.contentType = "movies" then
			row.imageWidth = 180
			m.sizeArray.Push([188, 261])	
		else if node.metadata.contentType = "music" then
			row.imageWidth = 261
			m.sizeArray.Push([261, 261])	
		else
			row.imageWidth = 464
			m.sizeArray.Push([464, 261])	
		end if

		m.top.rowItemSize = m.sizeArray

		for each item in itemData
			row.appendChild(item)
		end for

	end if

end function


function onKeyEvent(key as string, press as boolean) as boolean
	if not press then return false

	if key <> "OK" then return false

	' Set the selected item
	m.top.selectedItem = m.top.content.getChild(m.top.rowItemFocused[0]).getChild(m.top.rowItemFocused[1])
	return true
end function