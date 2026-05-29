'import "pkg:/source/api/baserequest.bs"
'import "pkg:/source/api/Image.bs"
'import "pkg:/source/api/MoonfinPlugin.bs"
'import "pkg:/source/enums/CollectionType.bs"
'import "pkg:/source/enums/ColorPalette.bs"
'import "pkg:/source/enums/ImageLayout.bs"
'import "pkg:/source/enums/ItemType.bs"
'import "pkg:/source/enums/KeyCode.bs"
'import "pkg:/source/enums/String.bs"
'import "pkg:/source/enums/TaskControl.bs"
'import "pkg:/source/utils/config.bs"
'import "pkg:/source/utils/deviceCapabilities.bs"
'import "pkg:/source/utils/misc.bs"

' Return parent collection type
function getCollectionType() as string
    return (function(m)
            __bsConsequent = m.top.parentItem.collectionType
            if __bsConsequent <> invalid then
                return __bsConsequent
            else
                return m.top.parentItem.Type
            end if
        end function)(m)
end function







sub setupNodes()
    m.top.imageDisplayMode = "scaleToZoom"
    m.top.showItemTitles = "showonhover"
    ' Background color
    m.librarybackground = m.top.findNode("librarybackground")
    ' Grid and lists
    m.options = m.top.findNode("options")
    m.itemGrid = m.top.findNode("itemGrid")
    m.genreGrid = m.top.findNode("genreGrid")
    m.emptyText = m.top.findNode("emptyText")
    ' Info display
    m.selectedItemName = m.top.findNode("selectedItemName")
    m.selectedItemProductionYear = m.top.findNode("selectedItemProductionYear")
    m.selectedItemOfficialRating = m.top.findNode("selectedItemOfficialRating")
    m.infoGroup = m.top.findNode("infoGroup")
    m.communityRatingGroup = m.top.findNode("communityRatingGroup")
    m.star = m.top.findNode("star")
    m.criticRatingIcon = m.top.findNode("criticRatingIcon")
    m.criticRatingGroup = m.top.findNode("criticRatingGroup")
    m.pluginRatings = m.top.findNode("pluginRatings")
    ' Header
    m.libraryName = m.top.findNode("libraryName")
    m.itemCountLabel = m.top.findNode("itemCount")
    ' Toolbar icon buttons
    m.homeButton = m.top.findNode("homeButton")
    m.sortButton = m.top.findNode("sortButton")
    m.settingsButton = m.top.findNode("settingsButton")
    m.toolbarButtons = [
        m.homeButton
        m.sortButton
        m.settingsButton
    ]
    ' Alpha picker
    m.alphaPicker = m.top.findNode("alphaPicker")
    m.alphaGrid = m.alphaPicker.findNode("alphaGrid")
    ' Status bar
    m.statusText = m.top.findNode("statusText")
    m.paginationText = m.top.findNode("paginationText")
    m.overhang = getActiveNav(m.top.getScene())
end sub

sub init()
    ' Tell SceneManager to hide the overhang for this screen
    m.top.overhangVisible = false
    m.favoritesOptionText = tr("Add To Favorites")
    m.showOptionMenu = false
    m.itemGridCounter = 0
    m.top.optionsAvailable = false
    setupNodes()
    m.bypassSearchEvent = false
    m.librarybackground.color = chainLookupReturn(m.global.session, "user.settings.colorBackground", "0x000018FF")
    m.itemGrid.focusBitmapBlendColor = chainLookupReturn(m.global.session, "user.settings.colorCursor", "0xff6867FF")
    m.genreGrid.focusBitmapBlendColor = chainLookupReturn(m.global.session, "user.settings.colorCursor", "0xff6867FF")
    m.options.observeField("visible", "onOptionsVisibleChange")
    m.loadedRows = 0
    m.loadedItems = 0
    ' Toolbar focus state: 0=home, 1=sort, 2=settings, 3=alpha
    m.toolbarFocusIndex = 0
    m.data = createSGNode("ContentNode")
    m.itemGrid.observeField("itemFocused", "onItemFocused")
    m.itemGrid.observeFieldScoped("itemSelected", "onItemSelected")
    m.itemGrid.content = m.data
    m.genreData = createSGNode("ContentNode")
    m.genreGrid.observeFieldScoped("itemSelected", "onGenreItemSelected")
    m.genreGrid.content = m.genreData
    ' Item sort
    m.sortField = "SortName"
    m.sortAscending = true
    m.filter = "All"
    m.filterOptions = {}
    m.view = "presentation"
    m.loadItemsTask1 = createObject("roSGNode", "LoadItemsTask")
    m.isInMyListTask = createObject("roSGNode", "LoadItemsTask")
    m.isInMyListTask.itemsToLoad = "isInMyList"
    m.loadItemsTask = createObject("roSGNode", "LoadItemsTask2")
    m.getFiltersTask = createObject("roSGNode", "GetFiltersTask")
    ' Set initial counts
    m.loadItemsTask.totalRecordCount = 0
end sub

sub OnScreenHidden()
    if not m.overhang.isVisible
        m.overhang.disableMoveAnimation = true
        m.overhang.isVisible = true
        m.overhang.disableMoveAnimation = false
    end if
end sub

sub OnScreenShown(isReturning = false as boolean)
    ' Hide the overhang/navbar
    m.overhang.isVisible = false
    ' Set library name in header
    if isValid(m.top.genreFilter) and isValidAndNotEmpty(m.top.genreFilter.genreName)
        m.libraryName.text = m.top.genreFilter.genreName
    else if isValid(m.top.parentItem)
        if isValid(m.top.parentItem.name) then
            m.libraryName.text = m.top.parentItem.name
        else
            m.libraryName.text = m.top.parentItem.title
        end if
    end if
    ' Only redraw items on initial show, not when returning from detail screens
    if not isReturning
        redrawItems()
    end if
    ' Temporarily unobserve itemSelected to prevent triggering navigation when restoring focus
    m.itemGrid.unobserveFieldScoped("itemSelected")
    m.showOptionMenu = false
    group = m.global.sceneManager.callFunc("getActiveScene")
    if isValid(m.top.lastFocus)
        m.top.lastFocus.setFocus(true)
        group.lastFocus = m.top.lastFocus
        ' Re-observe itemSelected after focus is restored
        m.itemGrid.observeFieldScoped("itemSelected", "onItemSelected")
        ' Skip metadata loading when returning from detail screens
        if isReturning then
            return
        end if
        focusedItem = getItemFocused()
        if isValid(focusedItem)
            m.loadItemsTask1.itemId = focusedItem.LookupCI("id")
            m.loadItemsTask1.observeField("content", "onItemDataLoaded")
            m.loadItemsTask1.itemsToLoad = "metaData"
            m.loadItemsTask1.control = "RUN"
        end if
    else
        m.top.setFocus(true)
        group.lastFocus = m.top
        ' Re-observe itemSelected even if no lastFocus
        m.itemGrid.observeFieldScoped("itemSelected", "onItemSelected")
    end if
end sub

sub onItemDataLoaded()
    itemData = m.loadItemsTask1.content
    m.loadItemsTask1.unobserveField("content")
    m.loadItemsTask1.control = "STOP"
    m.loadItemsTask1.content = []
    if not isValidAndNotEmpty(itemData) then
        return
    end if
    focusedItem = getItemFocused()
    if not isValid(focusedItem) then
        return
    end if
    focusedItem.callFunc("setWatched", chainLookupReturn(itemData[0], "json.UserData.Played", false), chainLookupReturn(itemData[0], "json.UserData.UnplayedItemCount", 0))
    if chainLookupReturn(itemData[0], "json.UserData.IsFavorite", false) then
        m.favoritesOptionText = tr("Remove From Favorites")
    else
        m.favoritesOptionText = tr("Add To Favorites")
    end if
    if m.showOptionMenu
        m.isInMyListTask.observeField("content", "onMyListLoaded")
        m.isInMyListTask.control = "RUN"
    end if
end sub

sub redrawItems()
    posterOrientation = getPosterOrientation()
    if inArray([
        "photo"
        "photoalbum"
        "musicvideo"
    ], m.top.mediaType) or isStringEqual(m.view, "Episodes")
        setColumnSizes("landscape")
    else if isStringEqual(m.view, "Albums") or isStringEqual(m.top.mediaType, "playlist")
        setColumnSizes("square")
    else if isStringEqual(posterOrientation, "default")
        setColumnSizes("portrait")
    else
        setColumnSizes(posterOrientation)
    end if
    itemGridContent = m.data.getChildren(-1, 0)
    m.data = createSGNode("ContentNode")
    m.itemGrid.content = m.data
    m.data.appendChildren(itemGridContent)
    ' Reset cursor back to its previous location
    m.itemGrid.jumpToItem = m.itemGrid.itemFocused
    genreContent = m.genreData.getChildren(-1, 0)
    m.genreData = createSGNode("ContentNode")
    m.genreGrid.content = m.genreData
    m.genreData.appendChildren(genreContent)
    ' Reset cursor back to its previous location
    m.genreGrid.jumpToItem = m.genreGrid.itemFocused
end sub

' Get the ID to use for this item (libraryId for library folders, id for BoxSets/collections)
function getParentItemId() as string
    if isValid(m.top.parentItem.libraryId) and m.top.parentItem.libraryId <> ""
        return m.top.parentItem.libraryId
    end if
    return m.top.parentItem.id
end function

function getPosterOrientation() as string
    orientationSettingId = getParentItemId()
    if isValid(orientationSettingId) and orientationSettingId <> "" and isChainValid(m.global.session, ("user.settings." + bslib_toString(orientationSettingId) + "-useLandscapeImages"))
        useLandscapeImages = chainLookupReturn(m.global.session, ("user.settings." + bslib_toString(orientationSettingId) + "-useLandscapeImages"), false)
        return (function(__bsCondition)
                if __bsCondition then
                    return "landscape"
                else
                    return "default"
                end if
            end function)(useLandscapeImages)
    end if
    return chainLookupReturn(m.global, "session.user.settings.libraryPosterOrientation", "default")
end function

' Load initial set of data
sub loadInitialItems()
    m.loadItemsTask.control = "STOP"
    startLoadingSpinner(false)
    itemId = getParentItemId()
    m.sortField = m.global.session.user.settings["display." + itemId + ".sortField"]
    m.filter = m.global.session.user.settings["display." + itemId + ".filter"]
    m.filterOptions = m.global.session.user.settings["display." + itemId + ".filterOptions"]
    m.view = m.global.session.user.settings["display." + itemId + ".landing"]
    m.sortAscending = m.global.session.user.settings["display." + itemId + ".sortAscending"]
    ' If user has not set a preferred view for this folder, check if they've set a default view
    if not isValid(m.view)
        settingName = ("display." + bslib_toString(m.top.mediaType) + "library.defaultview")
        if isStringEqual(m.top.mediaType, "photoalbum")
            settingName = ("display." + bslib_toString("photo") + "library.defaultview")
        end if
        m.view = m.global.session.user.settings[settingName]
    end if
    ' Boxsets are sorted by Premiere Data by default
    if not isValidAndNotEmpty(m.sortField)
        if isStringEqual(getCollectionType(), "boxset")
            m.sortField = "PremiereDate,SortName"
        else if isStringEqual(getCollectionType(), "mylist")
            m.sortField = "OrderAdded"
        else
            m.sortField = "SortName"
        end if
    end if
    if not isValidAndNotEmpty(m.filter) then
        m.filter = "All"
    end if
    if not isValidAndNotEmpty(m.filterOptions) then
        m.filterOptions = "{}"
    end if
    if not isValidAndNotEmpty(m.view)
        if isStringEqual(m.top.mediaType, "musicartist")
            m.view = "Artists"
        else
            m.view = "presentation"
        end if
    end if
    if not isValid(m.sortAscending)
        m.sortAscending = true
    else if not isStringEqual(type(m.sortAscending), "roBoolean")
        m.sortAscending = isStringEqual(m.sortAscending, "true")
    end if
    ' If we're in genre browse mode, force view to presentation (never "Genres")
    if isValid(m.top.genreFilter)
        if m.view <> "presentation" then
            m.view = "presentation"
        end if
    else
        ' If view is not valid, use default view
        if isStringEqual(m.top.mediaType, "musicartist")
            if not inArray([
                "Artists"
                "Albums"
                "Genres"
            ], m.view) then
                m.view = "Artists"
            end if
        else
            if not inArray([
                "presentation"
                "Genres"
                "Episodes"
            ], m.view) then
                m.view = "presentation"
            end if
        end if
        if isValid(m.top.parentItem.parentFolder)
            if m.view <> "presentation" then
                m.view = "presentation"
            end if
        end if
    end if
    m.filterOptions = ParseJson(m.filterOptions)
    m.loadItemsTask.searchTerm = m.top.searchTerm
    m.loadItemsTask.sortField = m.sortField
    m.loadItemsTask.sortAscending = m.sortAscending
    m.loadItemsTask.filter = m.filter
    m.loadItemsTask.filterOptions = m.filterOptions
    m.loadItemsTask.startIndex = 0
    m.loadItemsTask.studioIds = ""
    m.loadItemsTask.view = ""
    m.loadItemsTask.passToItem = {
        libraryID: getParentItemId()
    }
    if isStringEqual(m.view, "Genres")
        m.loadItemsTask.view = "Genres"
        m.loadItemsTask.genreIds = getParentItemId()
        m.loadItemsTask.itemId = getParentItemId()
        m.loadItemsTask.studioIds = getParentItemId()
        if isStringEqual(m.top.mediaType, "musicvideo")
            m.loadItemsTask.recursive = true
        end if
        ' For music genres, use MusicAlbum as the includeItemTypes
        if isStringEqual(m.top.mediaType, "musicartist")
            m.loadItemsTask.itemType = "MusicAlbum"
        end if
    else if isStringEqual(m.view, "presentation")
        m.loadItemsTask.itemId = getParentItemId()
        m.loadItemsTask.studioIds = ""
        m.loadItemsTask.genreIds = ""
    else if isStringEqual(m.view, "Episodes")
        m.loadItemsTask.itemId = getParentItemId()
        m.loadItemsTask.studioIds = ""
        m.loadItemsTask.genreIds = ""
        if isStringEqual(m.loadItemsTask.sortField, "SortName")
            m.loadItemsTask.sortField = "SeriesSortName,SortName"
        end if
    else if inArray([
        "Artists"
        "Albums"
    ], m.view)
        m.loadItemsTask.itemId = getParentItemId()
        m.loadItemsTask.studioIds = ""
        m.loadItemsTask.genreIds = ""
    end if
    ' Genre browse mode: override task params to filter by selected genre
    if isValid(m.top.genreFilter)
        m.loadItemsTask.view = ""
        m.loadItemsTask.studioIds = ""
        m.loadItemsTask.recursive = true
        if isValidAndNotEmpty(m.top.genreFilter.genreId)
            m.loadItemsTask.genreIds = m.top.genreFilter.genreId
        else if isValidAndNotEmpty(m.top.genreFilter.genreName)
            m.loadItemsTask.genreNames = m.top.genreFilter.genreName
        end if
        if isValidAndNotEmpty(m.top.genreFilter.libraryId)
            m.loadItemsTask.itemId = m.top.genreFilter.libraryId
        end if
        if isValidAndNotEmpty(m.top.genreFilter.itemType)
            m.loadItemsTask.itemType = m.top.genreFilter.itemType
        end if
    else if inArray([
        "boxset"
        "photo"
        "photoalbum"
        "musicvideo"
        "playlist"
        "folder"
    ], m.top.mediaType)
        m.loadItemsTask.recursive = false
        if isStringEqual(m.top.mediaType, "musicvideo")
            m.loadItemsTask.sortField = (bslib_toString(m.sortField))
            m.loadItemsTask.itemType = (bslib_toString("musicvideo") + "," + bslib_toString("folder"))
            m.loadItemsTask.passToItem.addreplace("collectionType", "musicvideo")
        end if
        if isStringEqual(m.top.mediaType, "boxset")
            if not isStringEqual(m.top.parentItem.LookupCI("type"), "boxset")
                if m.loadItemsTask.searchTerm <> ""
                    m.loadItemsTask.itemType = "boxset"
                    m.loadItemsTask.recursive = true
                end if
            end if
        end if
    else if isStringEqual(m.view, "Episodes")
        m.loadItemsTask.recursive = true
        m.loadItemsTask.itemType = "episode"
    else if isStringEqual(m.top.mediaType, "musicartist")
        ' Music library: set itemType based on selected view
        ' Use PascalCase strings to match LoadItemsTask2's case-sensitive checks
        if isStringEqual(m.view, "Albums")
            m.loadItemsTask.itemType = "MusicAlbum"
            m.loadItemsTask.recursive = true
        else
            ' Default: Artists view
            m.loadItemsTask.itemType = "MusicArtist"
        end if
    else
        m.loadItemsTask.itemType = m.top.mediaType
    end if
    ' Exclude collections/boxsets from movie and TV show libraries
    ' CollapseBoxSetItems=false ensures individual movies inside a BoxSet still appear
    collType = getCollectionType()
    if isStringEqual(collType, "movies") or isStringEqual(collType, "tvshows")
        m.loadItemsTask.excludeItemTypes = "BoxSet"
        m.loadItemsTask.collapseBoxSetItems = false
    end if
    ' We're in a genre sub folder
    isGenreSubFolder = isValid(m.top.parentItem.json) and (isStringEqual(m.top.parentItem.json.type, "Genre") or isStringEqual(m.top.parentItem.json.type, "MusicGenre"))
    if isValid(m.top.parentItem.parentFolder) and isGenreSubFolder and not isStringEqual(getCollectionType(), "boxset")
        if not inArray([
            "photoalbum"
            "musicvideo"
        ], m.top.mediaType)
            m.loadItemsTask.passToItem = {
                libraryID: m.top.parentItem.libraryID
            }
            m.loadItemsTask.itemId = m.top.parentItem.parentFolder
            m.loadItemsTask.genreIds = m.top.parentItem.id
        end if
    end if
    ' We're inside a music video genre sub folder
    if isStringEqual(m.top.mediaType, "musicvideo")
        if isStringEqual(chainLookup(m.top.parentItem, "itemType"), (bslib_toString("musicvideo") + "," + bslib_toString("folder")))
            m.loadItemsTask.itemId = m.top.parentItem.id
            m.loadItemsTask.genreIds = m.top.parentItem.id
            m.loadItemsTask.itemType = "musicvideo"
            m.loadItemsTask.recursive = true
        end if
    end if
    ' Layout setup - consistent position for all views
    m.itemGrid.itemSpacing = "[20, 20]"
    m.emptyText.visible = false
    ' Presentation view: show info panel, hide item titles
    m.top.showItemTitles = "hidealways"
    m.infoGroup.visible = true
    m.selectedItemName.visible = true
    posterOrientation = getPosterOrientation()
    ' Configure for specific media types that need landscape layout
    if isStringEqual(m.top.mediaType, "mylist")
        if isStringEqual(posterOrientation, "landscape")
            m.itemGrid.itemComponentName = "GridItemMedium"
            m.itemGrid.itemSize = "[400, 260]"
            m.itemGrid.rowHeights = "[260]"
            m.itemGrid.itemSpacing = "[40, 20]"
            m.itemGrid.numColumns = 4
            m.top.imageDisplayMode = "scaleToZoom"
        end if
    end if
    if isStringEqual(m.top.mediaType, "musicvideo")
        m.itemGrid.itemComponentName = "GridItemMedium"
        m.itemGrid.itemSize = "[400, 260]"
        m.itemGrid.rowHeights = "[260]"
        m.itemGrid.itemSpacing = "[40, 20]"
        m.itemGrid.numColumns = 4
        m.top.imageDisplayMode = "scaleToZoom"
    end if
    if inArray([
        "photo"
        "photoalbum"
    ], m.top.mediaType)
        m.itemGrid.itemComponentName = "GridItemMedium"
        m.itemGrid.itemSize = "[400, 260]"
        m.itemGrid.rowHeights = "[260]"
        m.itemGrid.itemSpacing = "[40, 20]"
        m.itemGrid.numColumns = 4
        m.top.imageDisplayMode = "scaleToZoom"
    end if
    if isStringEqual(m.view, "Episodes")
        m.itemGrid.itemComponentName = "GridItemMedium"
        m.itemGrid.itemSize = "[400, 260]"
        m.itemGrid.rowHeights = "[260]"
        m.itemGrid.itemSpacing = "[40, 20]"
        m.itemGrid.numColumns = 4
        m.top.imageDisplayMode = "scaleToZoom"
    end if
    if isStringEqual(m.top.mediaType, "folder")
        if isStringEqual(posterOrientation, "landscape")
            m.itemGrid.itemComponentName = "GridItemMedium"
            m.itemGrid.itemSize = "[400, 260]"
            m.itemGrid.rowHeights = "[260]"
            m.itemGrid.itemSpacing = "[40, 20]"
            m.itemGrid.numColumns = 4
            m.top.imageDisplayMode = "scaleToZoom"
        end if
    end if
    ' Genres view hides metadata
    if isStringEqual(m.view, "Genres")
        m.infoGroup.visible = false
        m.selectedItemName.visible = false
    end if
    ' Set column sizes based on orientation
    if inArray([
        "photo"
        "photoalbum"
        "musicvideo"
    ], m.top.mediaType) or isStringEqual(m.view, "Episodes")
        setColumnSizes("landscape")
    else if isStringEqual(m.view, "Albums") or isStringEqual(m.top.mediaType, "playlist")
        setColumnSizes("square")
    else if isStringEqual(posterOrientation, "default")
        setColumnSizes("portrait")
    else
        setColumnSizes(posterOrientation)
    end if
    m.loadItemsTask.observeField("content", "ItemDataLoaded")
    m.loadItemsTask.control = "RUN"
    m.getFiltersTask.observeField("filters", "FilterDataLoaded")
    m.getFiltersTask.params = {
        userid: m.global.session.user.id
        parentid: m.top.parentItem.Id
        includeitemtypes: m.loadItemsTask.itemType
    }
    m.getFiltersTask.control = "RUN"
    updateStatusBar()
end sub

sub setColumnSizes(layout = "portrait" as string)
    if isStringEqual(layout, "square")
        ' Square layout uses its own column count and width for 1:1 aspect ratio
        numberOfColumns = chainLookupReturn(m.global.session, "user.settings.numberOfColumnsSquare", "6")
        imageWidthData = val(chainLookupReturn(m.global.session, "user.settings.numberOfColumnsSquareData", "272"))
    else if isStringEqual(layout, "portrait")
        numberOfColumns = chainLookupReturn(m.global.session, "user.settings.numberOfColumnsPortrait", "7")
        imageWidthData = val(chainLookupReturn(m.global.session, "user.settings.numberOfColumnsPortraitData", "230"))
    else
        numberOfColumns = chainLookupReturn(m.global.session, "user.settings.numberOfColumnsLandscape", "4")
        imageWidthData = val(chainLookupReturn(m.global.session, "user.settings.numberOfColumnsLandscapeData", "418"))
    end if
    if isStringEqual(m.top.showItemTitles, "hidealways")
        if isStringEqual(layout, "square")
            aspectRatio = 1.0
        else
            if isStringEqual(layout, "portrait") then
                aspectRatio = 1.52173
            else
                aspectRatio = .56307
            end if
        end if
    else
        if isStringEqual(layout, "square")
            aspectRatio = 1.1
        else
            if isStringEqual(layout, "portrait") then
                aspectRatio = 1.69565
            else
                aspectRatio = .66307
            end if
        end if
    end if
    defaultSize = [
        imageWidthData
        CInt(imageWidthData * aspectRatio)
    ]
    m.itemGrid.itemSize = defaultSize
    m.itemGrid.rowHeights = [
        defaultSize[1]
    ]
    m.itemGrid.numColumns = numberOfColumns
    m.loadItemsTask.numberOfColumns = numberOfColumns
end sub

function setOptions() as object
    if isStringEqual(m.top.mediaType, "movie")
        return setMovieOptions()
    end if
    if isStringEqual(m.top.mediaType, "boxset")
        return setMovieOptions()
    end if
    if isStringEqual(m.top.mediaType, "mylist")
        return setMovieOptions()
    end if
    if isStringEqual(m.top.mediaType, "playlist")
        return setMovieOptions()
    end if
    if isStringEqual(m.top.mediaType, "folder")
        return setMovieOptions()
    end if
    if isStringEqual(m.top.mediaType, "series")
        return setSeriesOptions()
    end if
    if isStringEqual(m.top.mediaType, "musicvideo")
        return setMusicVideoOptions()
    end if
    if inArray([
        "photo"
        "photoalbum"
    ], m.top.mediaType)
        return setPhotoOptions()
    end if
    if isStringEqual(m.top.mediaType, "musicartist")
        return setMusicOptions()
    end if
    return {
        filter: []
    }
end function

' Set view, sort, and filter options
function setMovieOptions() as object
    options = {
        filter: []
    }
    options.views = [
        {
            "Title": tr("Presentation")
            "Name": "presentation"
            "Track": {
                "description": tr("Presentation")
            }
        }
    ]
    if not isStringEqual(m.top.mediaType, "mylist") and not isValid(m.top.genreFilter)
        options.views.push({
            "Title": tr("Genres")
            "Name": "Genres"
            "Track": {
                "description": tr("Genres")
            }
        })
    end if
    options.sort = [
        {
            "Title": tr("TITLE")
            "Name": "SortName"
            "Track": {
                "description": tr("TITLE")
            }
        }
        {
            "Title": tr("Community Rating")
            "Name": "CommunityRating,SortName"
            "Track": {
                "description": tr("Community Rating")
            }
        }
        {
            "Title": tr("Critics Rating")
            "Name": "CriticRating,SortName"
            "Track": {
                "description": tr("Critics Rating")
            }
        }
        {
            "Title": tr("DATE_ADDED")
            "Name": "DateCreated,SortName"
            "Track": {
                "description": tr("DATE_ADDED")
            }
        }
        {
            "Title": tr("DATE_PLAYED")
            "Name": "DatePlayed,SortName"
            "Track": {
                "description": tr("DATE_PLAYED")
            }
        }
        {
            "Title": tr("Parental Rating")
            "Name": "OfficialRating,SortName"
            "Track": {
                "description": tr("Parental Rating")
            }
        }
        {
            "Title": tr("PLAY_COUNT")
            "Name": "PlayCount,SortName"
            "Track": {
                "description": tr("PLAY_COUNT")
            }
        }
        {
            "Title": tr("RELEASE_DATE")
            "Name": "PremiereDate,SortName"
            "Track": {
                "description": tr("RELEASE_DATE")
            }
        }
        {
            "Title": tr("RUNTIME")
            "Name": "Runtime,SortName"
            "Track": {
                "description": tr("RUNTIME")
            }
        }
        {
            "Title": tr("Random")
            "Name": "Random"
            "Track": {
                "description": tr("Random")
            }
        }
    ]
    options.filter = [
        {
            "Title": tr("All")
            "Name": "All"
        }
        {
            "Title": tr("Played")
            "Name": "Played"
        }
        {
            "Title": tr("Unplayed")
            "Name": "Unplayed"
        }
        {
            "Title": tr("Resumable")
            "Name": "Resumable"
        }
        {
            "Title": tr("Favorites")
            "Name": "Favorites"
        }
    ]
    if inArray([
        "boxset"
        "boxsets"
    ], getCollectionType())
        options.views = [
            {
                "Title": tr("Presentation")
                "Name": "presentation"
                "Track": {
                    "description": tr("Presentation")
                }
            }
        ]
    end if
    if inArray([
        "mylist"
    ], getCollectionType())
        options.sort.unshift({
            "Title": tr("Order Added")
            "Name": "OrderAdded"
            "Track": {
                "description": tr("Order Added")
            }
        })
    end if
    if isStringEqual(m.view, "genres")
        options.sort = [
            {
                "Title": tr("TITLE")
                "Name": "SortName"
                "Track": {
                    "description": tr("TITLE")
                }
            }
        ]
        options.filter = [
            {
                "Title": tr("All")
                "Name": "All"
            }
        ]
    end if
    ' If we're in a genre subfolder
    if isValid(m.top.parentItem.parentFolder)
        options.views = [
            {
                "Title": tr("Presentation")
                "Name": "presentation"
                "Track": {
                    "description": tr("Presentation")
                }
            }
        ]
    end if
    return options
end function

function setMusicVideoOptions() as object
    options = {
        filter: []
    }
    options.views = [
        {
            "Title": tr("Presentation")
            "Name": "presentation"
            "Track": {
                "description": tr("Presentation")
            }
        }
    ]
    if not isValid(m.top.genreFilter)
        options.views.push({
            "Title": tr("Genres")
            "Name": "Genres"
            "Track": {
                "description": tr("Genres")
            }
        })
    end if
    options.sort = [
        {
            "Title": tr("TITLE")
            "Name": "SortName"
            "Track": {
                "description": tr("TITLE")
            }
        }
        {
            "Title": tr("Community Rating")
            "Name": "CommunityRating,SortName"
            "Track": {
                "description": tr("Community Rating")
            }
        }
        {
            "Title": tr("Critics Rating")
            "Name": "CriticRating,SortName"
            "Track": {
                "description": tr("Critics Rating")
            }
        }
        {
            "Title": tr("DATE_ADDED")
            "Name": "DateCreated,SortName"
            "Track": {
                "description": tr("DATE_ADDED")
            }
        }
        {
            "Title": tr("DATE_PLAYED")
            "Name": "DatePlayed,SortName"
            "Track": {
                "description": tr("DATE_PLAYED")
            }
        }
        {
            "Title": tr("Folders")
            "Name": "IsFolder,SortName"
            "Track": {
                "description": tr("Folders")
            }
        }
        {
            "Title": tr("Parental Rating")
            "Name": "OfficialRating,SortName"
            "Track": {
                "description": tr("Parental Rating")
            }
        }
        {
            "Title": tr("PLAY_COUNT")
            "Name": "PlayCount,SortName"
            "Track": {
                "description": tr("PLAY_COUNT")
            }
        }
        {
            "Title": tr("RELEASE_DATE")
            "Name": "PremiereDate,SortName"
            "Track": {
                "description": tr("RELEASE_DATE")
            }
        }
        {
            "Title": tr("RUNTIME")
            "Name": "Runtime,SortName"
            "Track": {
                "description": tr("RUNTIME")
            }
        }
        {
            "Title": tr("Random")
            "Name": "Random"
            "Track": {
                "description": tr("Random")
            }
        }
    ]
    options.filter = [
        {
            "Title": tr("All")
            "Name": "All"
        }
        {
            "Title": tr("Played")
            "Name": "Played"
        }
        {
            "Title": tr("Unplayed")
            "Name": "Unplayed"
        }
        {
            "Title": tr("Resumable")
            "Name": "Resumable"
        }
        {
            "Title": tr("Favorites")
            "Name": "Favorites"
        }
    ]
    if isStringEqual(m.view, "genres")
        options.sort = [
            {
                "Title": tr("TITLE")
                "Name": "SortName"
                "Track": {
                    "description": tr("TITLE")
                }
            }
        ]
        options.filter = [
            {
                "Title": tr("All")
                "Name": "All"
            }
        ]
    end if
    ' If we're in a genre subfolder
    if isValid(m.top.parentItem.parentFolder)
        options.views = [
            {
                "Title": tr("Presentation")
                "Name": "presentation"
                "Track": {
                    "description": tr("Presentation")
                }
            }
        ]
    end if
    return options
end function

function setPhotoOptions() as object
    options = {
        filter: []
    }
    options.views = [
        {
            "Title": tr("Presentation")
            "Name": "presentation"
            "Track": {
                "description": tr("Presentation")
            }
        }
    ]
    options.sort = [
        {
            "Title": tr("TITLE")
            "Name": "SortName"
            "Track": {
                "description": tr("TITLE")
            }
        }
        {
            "Title": tr("DATE_ADDED")
            "Name": "DateCreated,SortName"
            "Track": {
                "description": tr("DATE_ADDED")
            }
        }
        {
            "Title": tr("Folders")
            "Name": "IsFolder,SortName"
            "Track": {
                "description": tr("Folders")
            }
        }
        {
            "Title": tr("Random")
            "Name": "Random"
            "Track": {
                "description": tr("Random")
            }
        }
    ]
    options.filter = [
        {
            "Title": tr("All")
            "Name": "All"
        }
        {
            "Title": tr("Favorites")
            "Name": "Favorites"
        }
        {
            "Title": tr("Item Type")
            "Name": "includeItemTypes"
            "Options": [
                "Photo"
                "Photo Album"
                "Video"
            ]
            "Delimiter": ","
            "CheckedState": []
        }
    ]
    return options
end function

function setMusicOptions() as object
    options = {
        filter: []
    }
    options.views = [
        {
            "Title": tr("Artists")
            "Name": "Artists"
            "Track": {
                "description": tr("Artists")
            }
        }
        {
            "Title": tr("Albums")
            "Name": "Albums"
            "Track": {
                "description": tr("Albums")
            }
        }
    ]
    if not isValid(m.top.genreFilter)
        options.views.push({
            "Title": tr("Genres")
            "Name": "Genres"
            "Track": {
                "description": tr("Genres")
            }
        })
    end if
    options.sort = [
        {
            "Title": tr("TITLE")
            "Name": "SortName"
            "Track": {
                "description": tr("TITLE")
            }
        }
        {
            "Title": tr("DATE_ADDED")
            "Name": "DateCreated,SortName"
            "Track": {
                "description": tr("DATE_ADDED")
            }
        }
        {
            "Title": tr("DATE_PLAYED")
            "Name": "DatePlayed,SortName"
            "Track": {
                "description": tr("DATE_PLAYED")
            }
        }
        {
            "Title": tr("Random")
            "Name": "Random"
            "Track": {
                "description": tr("Random")
            }
        }
    ]
    options.filter = [
        {
            "Title": tr("All")
            "Name": "All"
        }
        {
            "Title": tr("Favorites")
            "Name": "Favorites"
        }
    ]
    if isStringEqual(m.view, "genres")
        options.sort = [
            {
                "Title": tr("TITLE")
                "Name": "SortName"
                "Track": {
                    "description": tr("TITLE")
                }
            }
        ]
        options.filter = [
            {
                "Title": tr("All")
                "Name": "All"
            }
        ]
    end if
    return options
end function

function setSeriesOptions() as object
    options = {
        filter: []
    }
    options.views = [
        {
            "Title": tr("Presentation")
            "Name": "presentation"
            "Track": {
                "description": tr("Presentation")
            }
        }
    ]
    if not isValid(m.top.genreFilter)
        options.views.push({
            "Title": tr("Genres")
            "Name": "Genres"
            "Track": {
                "description": tr("Genres")
            }
        })
    end if
    options.views.push({
        "Title": tr("Episodes")
        "Name": "Episodes"
        "Track": {
            "description": tr("Episodes")
        }
    })
    options.sort = [
        {
            "Title": tr("TITLE")
            "Name": "SortName"
            "Track": {
                "description": tr("TITLE")
            }
        }
        {
            "Title": tr("Community Rating")
            "Name": "CommunityRating,SortName"
            "Track": {
                "description": tr("Community Rating")
            }
        }
        {
            "Title": tr("Date Show Added")
            "Name": "DateCreated,SortName"
            "Track": {
                "description": tr("Date Show Added")
            }
        }
        {
            "Title": tr("Date Episode Added")
            "Name": "DateLastContentAdded,SortName"
            "Track": {
                "description": tr("Date Episode Added")
            }
        }
        {
            "Title": tr("DATE_PLAYED")
            "Name": "SeriesDatePlayed,SortName"
            "Track": {
                "description": tr("DATE_PLAYED")
            }
        }
        {
            "Title": tr("OFFICIAL_RATING")
            "Name": "OfficialRating,SortName"
            "Track": {
                "description": tr("OFFICIAL_RATING")
            }
        }
        {
            "Title": tr("RELEASE_DATE")
            "Name": "PremiereDate,SortName"
            "Track": {
                "description": tr("RELEASE_DATE")
            }
        }
        {
            "Title": tr("Random")
            "Name": "Random"
            "Track": {
                "description": tr("Random")
            }
        }
    ]
    options.filter = [
        {
            "Title": tr("All")
            "Name": "All"
        }
        {
            "Title": tr("Played")
            "Name": "Played"
        }
        {
            "Title": tr("Unplayed")
            "Name": "Unplayed"
        }
        {
            "Title": tr("Favorites")
            "Name": "Favorites"
        }
    ]
    if isStringEqual(m.view, "genres")
        options.sort = [
            {
                "Title": tr("TITLE")
                "Name": "SortName"
                "Track": {
                    "description": tr("TITLE")
                }
            }
        ]
        options.filter = [
            {
                "Title": tr("All")
                "Name": "All"
            }
        ]
    end if
    ' If we're in a genre subfolder
    if isValid(m.top.parentItem.parentFolder)
        options.views = [
            {
                "Title": tr("Presentation")
                "Name": "presentation"
                "Track": {
                    "description": tr("Presentation")
                }
            }
        ]
    end if
    return options
end function

' Data to display when options button selected
sub setSelectedOptions(options)
    ' Set selected view option
    for each o in options.views
        if o.Name = m.view
            o.Selected = true
        end if
    end for
    ' Set selected sort option
    for each o in options.sort
        if o.Name = m.sortField
            o.Selected = true
        end if
    end for
    ' Set selected filter
    for each o in options.filter
        if o.Name = m.filter
            o.Selected = true
            m.options.filter = o.Name
        end if
        ' Select selected filter options
        if isValid(o.options) and isValid(m.filterOptions)
            if o.options.Count() > 0 and m.filterOptions.Count() > 0
                if LCase(o.Name) = LCase(m.filterOptions.keys()[0])
                    selectedFilterOptions = m.filterOptions[m.filterOptions.keys()[0]].split(o.delimiter)
                    checkedState = []
                    for each availableFilterOption in o.options
                        matchFound = false
                        for each selectedFilterOption in selectedFilterOptions
                            if LCase(toString(availableFilterOption).trim()) = LCase(selectedFilterOption.trim())
                                matchFound = true
                            end if
                        end for
                        checkedState.push(matchFound)
                    end for
                    o.checkedState = checkedState
                end if
            end if
        end if
    end for
    options.sortAscending = m.sortAscending
    m.options.options = options
end sub

' Filter data loaded from API
sub FilterDataLoaded(msg)
    options = setOptions()
    data = msg.GetData()
    m.getFiltersTask.unobserveField("filters")
    if not isValid(data) then
        return
    end if
    ' Add filters from the API data
    if isStringEqual(m.view, "presentation")
        options.filter.push({
            "Title": tr("Features")
            "Name": "Features"
            "Options": [
                "Subtitles"
                "Special Features"
                "Theme Song"
                "Theme Video"
            ]
            "Delimiter": "|"
            "CheckedState": []
        })
        if isValidAndNotEmpty(data.genres)
            options.filter.push({
                "Title": tr("Genres")
                "Name": "Genres"
                "Options": data.genres
                "Delimiter": "|"
                "CheckedState": []
            })
        end if
        if isValidAndNotEmpty(data.OfficialRatings)
            options.filter.push({
                "Title": tr("Parental Ratings")
                "Name": "OfficialRatings"
                "Options": data.OfficialRatings
                "Delimiter": "|"
                "CheckedState": []
            })
        end if
        if isValidAndNotEmpty(data.Years)
            options.filter.push({
                "Title": tr("Years")
                "Name": "Years"
                "Options": data.Years
                "Delimiter": ","
                "CheckedState": []
            })
        end if
    end if
    setSelectedOptions(options)
    m.options.options = options
end sub

' Handle loaded data, and add to grid
sub ItemDataLoaded(msg)
    itemData = msg.GetData()
    itemCount = itemData.count()
    ' Unobserve to prevent multiple callbacks
    m.loadItemsTask.unobserveField("content")
    m.loadItemsTask.content = []
    if not isValid(itemData)
        if m.loadedItems = 0
            m.emptyText.text = tr("Error loading items. Please check your connection and try again.")
            m.emptyText.visible = true
        end if
        m.Loading = false
        stopLoadingSpinner()
        return
    end if
    ' Client-side fallback: filter out BoxSets (API may not honor ExcludeItemTypes)
    if m.loadItemsTask.excludeItemTypes <> ""
        filteredData = []
        for each item in itemData
            if item.type <> "Boxset" and item.type <> "BoxSet"
                filteredData.push(item)
            end if
        end for
        itemData = filteredData
        itemCount = itemData.count()
    end if
    if isStringEqual(m.view, "Genres")
        ' Reset genre grid data
        m.genreData.removeChildren(m.genreData.getChildren(-1, 0))
        for each item in itemData
            m.genreData.appendChild(item)
        end for
        m.loadedItems = m.genreData.getChildCount()
        m.itemGrid.opacity = 0
        m.genreGrid.opacity = 1
        m.genreGrid.setFocus(true)
        group = m.global.sceneManager.callFunc("getActiveScene")
        group.lastFocus = m.genreGrid
        stopLoadingOperation()
        ' Return focus to options menu if it was opened while library was loading
        if m.options.visible
            m.options.setFocus(true)
            group.lastFocus = m.options
        end if
        if m.loadedItems = 0
            m.emptyText.text = tr("No items found. Try adjusting your selected filters.")
            m.emptyText.visible = true
        end if
        updateStatusBar()
        return
    end if
    m.itemGrid.opacity = "1"
    m.genreGrid.opacity = "0"
    m.itemGrid.setFocus(true)
    m.genreGrid.setFocus(false)
    group = m.global.sceneManager.callFunc("getActiveScene")
    group.lastFocus = m.itemGrid
    if m.data.getChildCount() = 0
        m.itemGrid.jumpToItem = 0
    end if
    m.data.appendChildren(itemData)
    ' Update the stored counts
    m.loadedItems = m.loadedItems + itemCount
    m.loadedRows = m.loadedItems / m.itemGrid.numColumns
    ' If there are no items to display, show message
    if m.loadedItems = 0
        m.infoGroup.visible = false
        m.selectedItemName.visible = false
        SetName("")
        SetOfficialRating("")
        SetProductionYear("")
        setFieldText("runtime", "")
        setFieldText("communityRating", "")
        setFieldText("criticRatingLabel", "")
        m.criticRatingIcon.uri = ""
        m.star.uri = ""
        m.emptyText.text = tr("No items found. Try adjusting your selected filters.")
        m.emptyText.visible = true
    end if
    m.Loading = false
    stopLoadingSpinner()
    ' Return focus to options menu if it was opened while library was loading
    if m.options.visible
        m.options.setFocus(true)
        group = m.global.sceneManager.callFunc("getActiveScene")
        group.lastFocus = m.options
    end if
    updateStatusBar()
end sub

' Set Selected Name
sub SetName(itemName as string)
    m.selectedItemName.text = itemName
end sub

' Set Selected OfficialRating
sub SetOfficialRating(itemOfficialRating as string)
    m.selectedItemOfficialRating.text = itemOfficialRating
end sub

' Set Selected ProductionYear
sub SetProductionYear(itemProductionYear)
    m.selectedItemProductionYear.text = itemProductionYear
end sub

' Handle new item being focused
sub onItemFocused()
    itemInt = m.itemGrid.itemFocused
    if itemInt = -1
        return
    end if
    ' Lazy loading: Load more items when user is near the end
    focusedRow = m.itemGrid.currFocusRow
    if m.loadItemsTask.totalRecordCount > m.loadedItems
        if focusedRow >= m.loadedRows - 3
            loadMoreData()
        end if
    end if
    m.communityRatingGroup.visible = false
    m.criticRatingGroup.visible = false
    setFieldText("criticRatingLabel", "")
    m.criticRatingIcon.uri = ""
    m.criticRatingIcon.width = 0
    m.criticRatingIcon.height = 0
    clearLibraryPluginRatings()
    focusedItem = getItemFocused()
    if not isChainValid(focusedItem, "json")
        return
    end if
    itemData = focusedItem.json
    m.star.uri = "pkg:/images/sharp_star_white_18dp.png"
    if m.global.session.user.settings["ui.itemdetail.showRatings"]
        if isValid(itemData.communityRating)
            setFieldText("communityRating", int(itemData.communityRating * 10) / 10)
            m.communityRatingGroup.visible = true
        end if
        if isValid(itemData.CriticRating) and not moonfinPlugin_IsRatingsEnabled()
            setFieldText("criticRatingLabel", itemData.criticRating)
            tomato = "pkg:/images/rotten.png"
            if itemData.CriticRating > 60
                tomato = "pkg:/images/fresh.png"
            end if
            m.criticRatingIcon.uri = tomato
            m.criticRatingIcon.width = 24
            m.criticRatingIcon.height = 24
            m.criticRatingGroup.visible = true
        end if
    end if
    if moonfinPlugin_IsRatingsEnabled()
        fetchLibraryRatings(itemData)
    end if
    if isValid(itemData.Name)
        SetName(itemData.Name)
    else
        SetName("")
    end if
    ' Show the selected item name
    m.selectedItemName.visible = true
    if isValid(itemData.ProductionYear)
        SetProductionYear(str(itemData.ProductionYear))
    else
        SetProductionYear("")
    end if
    if type(itemData.RunTimeTicks) = "LongInteger"
        setFieldText("runtime", stri(getRuntimeFromTicks(itemData.RunTimeTicks)) + " mins")
    else
        setFieldText("runtime", "")
    end if
    if isValid(itemData.OfficialRating)
        SetOfficialRating(itemData.OfficialRating)
    else
        SetOfficialRating("")
    end if
    updateStatusBar()
end sub

sub clearLibraryPluginRatings()
    if isValid(m.pluginRatings)
        m.pluginRatings.ratingsData = invalid
    end if
    if isValid(m.libraryRatingsTask)
        m.libraryRatingsTask.unobserveFieldScoped("ratings")
        m.libraryRatingsTask = invalid
    end if
end sub

sub fetchLibraryRatings(itemData as object)
    tmdbId = moonfinPlugin_GetTmdbId((function(itemData)
            __bsConsequent = itemData.ProviderIds
            if __bsConsequent <> invalid then
                return __bsConsequent
            else
                return invalid
            end if
        end function)(itemData))
    if tmdbId = "" then
        return
    end if
    itemType = (function(itemData)
            __bsConsequent = itemData.Type
            if __bsConsequent <> invalid then
                return __bsConsequent
            else
                return ""
            end if
        end function)(itemData)
    if itemType = "" then
        return
    end if
    if isValid(m.libraryRatingsTask)
        m.libraryRatingsTask.unobserveFieldScoped("ratings")
        m.libraryRatingsTask = invalid
    end if
    m.libraryRatingsTask = createObject("roSGNode", "FetchRatingsTask")
    m.libraryRatingsTask.itemType = itemType
    m.libraryRatingsTask.tmdbId = tmdbId
    m.libraryRatingsTask.observeFieldScoped("ratings", "onLibraryRatingsLoaded")
    m.libraryRatingsTask.control = "RUN"
end sub

sub onLibraryRatingsLoaded(event as object)
    result = event.getData()
    if not isValid(result) then
        return
    end if
    displayRatings = result.data
    if not isValidAndNotEmpty(displayRatings) then
        return
    end if
    if not isValid(m.pluginRatings) then
        return
    end if
    m.pluginRatings.ratingsData = result
end sub

' Load next batch of items for pagination
sub loadMoreData()
    if m.Loading = true then
        return
    end if
    if m.loadedItems >= m.loadItemsTask.totalRecordCount then
        return
    end if
    startLoadingSpinner(false)
    m.Loading = true
    m.loadItemsTask.startIndex = m.loadedItems
    m.loadItemsTask.observeField("content", "ItemDataLoaded")
    m.loadItemsTask.control = "RUN"
end sub

' Item Selected
sub onItemSelected()
    m.top.selectedItem = m.itemGrid.content.getChild(m.itemGrid.itemSelected)
    m.top.selectedItem = invalid
end sub

' Returns Focused Item
function getItemFocused()
    if m.itemGrid.isinFocusChain()
        return getItemGridFocusedItem(m.itemGrid)
    else if m.genreGrid.isinFocusChain() and m.genreGrid.itemFocused >= 0
        return m.genreGrid.content.getChild(m.genreGrid.itemFocused)
    end if
    return invalid
end function

sub onGenreItemSelected()
    selectedGenre = m.genreGrid.content.getChild(m.genreGrid.itemSelected)
    if not isValid(selectedGenre) or not isValid(selectedGenre.json) then
        return
    end if
    genreData = selectedGenre.json
    m.top.genreItemSelected = {
        genreId: genreData.id
        genreName: genreData.Name
        libraryId: genreData.libraryId
        itemType: genreData.itemType
        mediaType: m.top.mediaType
        collectionType: getCollectionType()
    }
end sub

sub resetDropdownsToDefaultState()
    m.filter = "All"
    m.filterOptions = {}
    if isStringEqual(getCollectionType(), "boxset")
        m.sortField = "PremiereDate,SortName"
    else if isStringEqual(getCollectionType(), "mylist")
        m.sortField = "OrderAdded"
    else
        m.sortField = "SortName"
    end if
    m.sortAscending = true
    set_user_setting("display." + m.top.parentItem.Id + ".sortField", m.sortField)
    set_user_setting("display." + m.top.parentItem.Id + ".sortAscending", "true")
    set_user_setting("display." + m.top.parentItem.Id + ".filter", m.filter)
    set_user_setting("display." + m.top.parentItem.Id + ".filterOptions", FormatJson(m.filterOptions))
    if not isStringEqual(m.view, "Genres")
        set_user_setting(("display." + bslib_toString(m.top.mediaType) + "library.defaultview"), m.view)
    end if
    m.getFiltersTask.control = "RUN"
end sub

sub onSearchTermChanged()
    if isStringEqual(m.loadItemsTask.searchTerm, m.top.searchTerm) then
        return
    end if
    if not isStringEqual(m.top.searchTerm, "")
        resetDropdownsToDefaultState()
    end if
    if m.bypassSearchEvent
        m.bypassSearchEvent = false
        return
    end if
    m.loadedRows = 0
    m.loadedItems = 0
    m.data = createSGNode("ContentNode")
    m.itemGrid.content = m.data
    m.genreData = createSGNode("ContentNode")
    m.genreGrid.content = m.genreData
    loadInitialItems()
end sub

sub alphaSelectedChanged()
    ' Allow user to toggle by clicking letter twice
    if isStringEqual(m.loadItemsTask.nameStartsWith, m.top.alphaSelected)
        m.top.alphaSelected = ""
    end if
    m.loadedRows = 0
    m.loadedItems = 0
    m.data = createSGNode("ContentNode")
    m.itemGrid.content = m.data
    m.genreData = createSGNode("ContentNode")
    m.genreGrid.content = m.genreData
    m.loadItemsTask.nameStartsWith = m.top.alphaSelected
    m.top.searchTerm = ""
    loadInitialItems()
end sub

' Check if options updated and any reloading required
sub onOptionsVisibleChange()
    if m.options.visible then
        return
    end if
    reload = false
    ' Check if view changed
    if isValidAndNotEmpty(m.options.selectedView) and not isStringEqual(m.options.selectedView, m.view)
        previousView = m.view
        m.view = m.options.selectedView
        set_user_setting("display." + m.top.parentItem.Id + ".landing", m.view)
        ' If switching to/from Episodes, recreate the grid for the new component type
        if inArray([
            previousView
            m.view
        ], "Episodes")
            m.top.removeChild(m.itemGrid)
            m.itemGridCounter++
            createItemGrid(("itemGrid" + bslib_toString(m.itemGridCounter)))
        end if
        ' View change requires full reset of sort/filter
        m.bypassSearchEvent = true
        m.top.searchTerm = ""
        m.top.alphaSelected = ""
        m.loadItemsTask.nameStartsWith = " "
        m.loadItemsTask.searchTerm = ""
        m.filter = "All"
        m.filterOptions = {}
        m.sortField = "SortName"
        m.sortAscending = true
        set_user_setting("display." + m.top.parentItem.Id + ".sortField", m.sortField)
        set_user_setting("display." + m.top.parentItem.Id + ".sortAscending", "true")
        set_user_setting("display." + m.top.parentItem.Id + ".filter", m.filter)
        set_user_setting("display." + m.top.parentItem.Id + ".filterOptions", FormatJson(m.filterOptions))
        if not isStringEqual(m.view, "Genres")
            set_user_setting(("display." + bslib_toString(m.top.mediaType) + "library.defaultview"), m.view)
        end if
        reload = true
    end if
    ' Check if sort changed
    sortChanged = isValidAndNotEmpty(m.options.selectedSort) and not isStringEqual(m.options.selectedSort, m.sortField)
    ascendingChanged = m.options.sortAscending <> m.sortAscending
    if sortChanged or ascendingChanged
        if sortChanged
            m.sortField = m.options.selectedSort
            set_user_setting("display." + m.top.parentItem.Id + ".sortField", m.sortField)
        end if
        m.sortAscending = m.options.sortAscending
        set_user_setting("display." + m.top.parentItem.Id + ".sortAscending", bslib_ternary(m.sortAscending, "true", "false"))
        reload = true
    end if
    ' Check if filter changed
    if not isStringEqual(m.options.filter, m.filter)
        m.filter = m.options.filter
        set_user_setting("display." + m.top.parentItem.Id + ".filter", m.options.filter)
        reload = true
    end if
    if not isValid(m.options.filterOptions)
        m.filterOptions = {}
    end if
    if not AssocArrayEqual(m.options.filterOptions, m.filterOptions)
        m.filterOptions = m.options.filterOptions
        reload = true
        set_user_setting("display." + m.top.parentItem.Id + ".filterOptions", FormatJson(m.options.filterOptions))
    end if
    if reload
        m.loadedRows = 0
        m.loadedItems = 0
        m.data = createSGNode("ContentNode")
        m.itemGrid.content = m.data
        loadInitialItems()
    end if
    m.itemGrid.setFocus(m.itemGrid.opacity = 1)
    m.genreGrid.setFocus(m.genreGrid.opacity = 1)
    group = m.global.sceneManager.callFunc("getActiveScene")
    if m.itemGrid.opacity = 1 then
        group.lastFocus = m.itemGrid
    else
        group.lastFocus = m.genreGrid
    end if
    updateStatusBar()
end sub

sub onLibrarySettingsButtonSelected()
    dialog = m.top.getScene().dialog
    if isValid(dialog)
        dialog.close = true
    end if
end sub

sub createItemGrid(itemGridID = "itemGrid" as string)
    m.itemGrid = createObject("rosgnode", "MarkupGrid")
    m.itemGrid.id = itemGridID
    m.itemGrid.itemSpacing = "[20, 20]"
    m.itemGrid.vertFocusAnimationStyle = "fixed"
    m.itemGrid.translation = "[80, 195]"
    m.itemGrid.clippingRect = "[-30, -10, 1880, 850]"
    m.itemGrid.numColumns = 5
    m.itemGrid.observeField("itemFocused", "onItemFocused")
    m.itemGrid.observeFieldScoped("itemSelected", "onItemSelected")
    m.itemGrid.focusBitmapUri = "pkg:/images/hd_focus.9.png"
    m.itemGrid.focusBitmapBlendColor = chainLookupReturn(m.global.session, "user.settings.colorCursor", "0xff6867FF")
    if isStringEqual(m.view, "Episodes")
        m.itemGrid.itemComponentName = "GridItemMedium"
    else
        m.itemGrid.itemComponentName = "GridItemSmall"
    end if
    m.top.insertChild(m.itemGrid, 1)
end sub

' =====================================================================
' STATUS BAR
' =====================================================================
sub updateStatusBar()
    ' Update item count in header
    totalCount = m.loadItemsTask.totalRecordCount
    if totalCount > 0
        m.itemCountLabel.text = (bslib_toString(totalCount) + " Items")
    else
        m.itemCountLabel.text = ""
    end if
    ' Build status text: "Showing [filter] items from '[library]' sorted by [sort]"
    libraryName = ""
    if isValid(m.top.parentItem)
        if isValid(m.top.parentItem.name) then
            libraryName = m.top.parentItem.name
        else
            libraryName = m.top.parentItem.title
        end if
    end if
    if isValidAndNotEmpty(m.filter) then
        filterText = m.filter
    else
        filterText = "All"
    end if
    sortDisplayName = getSortDisplayName(m.sortField)
    if m.sortAscending then
        sortDirection = ""
    else
        sortDirection = " (desc)"
    end if
    m.statusText.text = ("Showing " + bslib_toString(filterText) + " items from '" + bslib_toString(libraryName) + "' sorted by " + bslib_toString(sortDisplayName) + bslib_toString(sortDirection))
    ' Update pagination: "loaded | total"
    if totalCount > 0
        m.paginationText.text = (bslib_toString(m.loadedItems) + " | " + bslib_toString(totalCount))
    else
        m.paginationText.text = ""
    end if
end sub

function getSortDisplayName(sortField as string) as string
    sortMap = {
        "SortName": "Name"
        "CommunityRating,SortName": "Community Rating"
        "CriticRating,SortName": "Critics Rating"
        "DateCreated,SortName": "Date Added"
        "DatePlayed,SortName": "Date Played"
        "OfficialRating,SortName": "Parental Rating"
        "PlayCount,SortName": "Play Count"
        "PremiereDate,SortName": "Release Date"
        "Runtime,SortName": "Runtime"
        "Random": "Random"
        "OrderAdded": "Order Added"
        "IsFolder,SortName": "Folders"
        "DateLastContentAdded,SortName": "Date Episode Added"
        "SeriesDatePlayed,SortName": "Date Played"
        "SeriesSortName,SortName": "Name"
    }
    result = sortMap[sortField]
    if isValid(result) then
        return result
    end if
    return sortField
end function

' =====================================================================
' TOOLBAR FOCUS MANAGEMENT
' =====================================================================
sub focusToolbarItem(index as integer)
    ' Unfocus all toolbar items
    for each btn in m.toolbarButtons
        btn.focus = false
    end for
    m.toolbarFocusIndex = index
    if index >= 0 and index < m.toolbarButtons.count()
        m.toolbarButtons[index].focus = true
        m.toolbarButtons[index].setFocus(true)
        setLastFocus(m.toolbarButtons[index])
    else if index = 3
        ' Alpha picker
        m.alphaGrid.setFocus(true)
        setLastFocus(m.alphaGrid)
    end if
end sub

sub unfocusAllToolbarItems()
    for each btn in m.toolbarButtons
        btn.focus = false
    end for
end sub

' =====================================================================
' KEY EVENT HANDLER
' =====================================================================
function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    ' ---- TOOLBAR ICON NAVIGATION ----
    if m.homeButton.isInFocusChain() or m.sortButton.isInFocusChain() or m.settingsButton.isInFocusChain()
        if isStringEqual(key, "right")
            if m.homeButton.isInFocusChain()
                focusToolbarItem(1)
                return true
            else if m.sortButton.isInFocusChain()
                focusToolbarItem(2)
                return true
            else if m.settingsButton.isInFocusChain()
                ' Move to alpha picker
                unfocusAllToolbarItems()
                focusToolbarItem(3)
                return true
            end if
        end if
        if isStringEqual(key, "left")
            if m.settingsButton.isInFocusChain()
                focusToolbarItem(1)
                return true
            else if m.sortButton.isInFocusChain()
                focusToolbarItem(0)
                return true
            end if
            ' At home button, LEFT does nothing
            return true
        end if
        if isStringEqual(key, "down")
            unfocusAllToolbarItems()
            if m.loadedItems > 0
                m.itemGrid.setFocus(m.itemGrid.opacity = 1)
                m.genreGrid.setFocus(m.genreGrid.opacity = 1)
                setLastFocus((function(__bsCondition, m)
                        if __bsCondition then
                            return m.itemGrid
                        else
                            return m.genreGrid
                        end if
                    end function)(m.itemGrid.opacity = 1, m))
            end if
            return true
        end if
        if isStringEqual(key, "OK")
            if m.homeButton.isInFocusChain()
                reclaimResources()
                m.global.sceneManager.callfunc("popScene")
                return true
            else if m.sortButton.isInFocusChain()
                ' Open combined Sort & Filter dialog
                m.options.visible = true
                viewMenu = m.options.findNode("viewMenu")
                if viewMenu.visible
                    viewMenu.setFocus(true)
                else
                    m.options.findNode("sortMenu").setFocus(true)
                end if
                group = m.global.sceneManager.callFunc("getActiveScene")
                group.lastFocus = m.options
                return true
            else if m.settingsButton.isInFocusChain()
                ' Open library settings dialog (watched checkmark, landscape images)
                dialog = createObject("roSGNode", "LibrarySettingDialog")
                dlgPalette = createObject("roSGNode", "RSGPalette")
                dlgPalette.colors = {
                    DialogBackgroundColor: chainLookupReturn(m.global.session, "user.settings.colorDialogBackground", "#050508")
                    DialogFocusColor: chainLookupReturn(m.global.session, "user.settings.colorCursor", "0xff6867FF")
                    DialogFocusItemColor: chainLookupReturn(m.global.session, "user.settings.colorDialogSelectedText", "#ffffff")
                    DialogSecondaryTextColor: "#FF0000"
                    DialogSecondaryItemColor: chainLookupReturn(m.global.session, "user.settings.colorDialogBorderLine", "#c8fafa")
                    DialogTextColor: chainLookupReturn(m.global.session, "user.settings.colorDialogText", "#ffffff")
                }
                dialog.palette = dlgPalette
                dialog.title = tr("Library Settings")
                dialog.buttons = [
                    tr("OK")
                ]
                dialog.observeField("buttonSelected", "onLibrarySettingsButtonSelected")
                m.top.getScene().dialog = dialog
                return true
            end if
        end if
        if isStringEqual(key, "back")
            reclaimResources()
            m.global.sceneManager.callfunc("popScene")
            return true
        end if
        return false
    end if
    ' ---- ALPHA PICKER NAVIGATION ----
    if m.alphaGrid.isInFocusChain()
        if isStringEqual(key, "left") and m.alphaGrid.itemFocused = 0
            ' Move from alpha to settings icon
            focusToolbarItem(2)
            return true
        end if
        if isStringEqual(key, "down")
            unfocusAllToolbarItems()
            if m.loadedItems > 0
                m.itemGrid.setFocus(m.itemGrid.opacity = 1)
                m.genreGrid.setFocus(m.genreGrid.opacity = 1)
                setLastFocus((function(__bsCondition, m)
                        if __bsCondition then
                            return m.itemGrid
                        else
                            return m.genreGrid
                        end if
                    end function)(m.itemGrid.opacity = 1, m))
            end if
            return true
        end if
        if isStringEqual(key, "back")
            reclaimResources()
            m.global.sceneManager.callfunc("popScene")
            return true
        end if
        return false
    end if
    ' ---- GRID / GENRE GRID NAVIGATION ----
    if m.itemGrid.isinFocusChain() or m.genreGrid.isinFocusChain()
        if isStringEqual(key, "up")
            if m.itemGrid.isinFocusChain() then
                gridComponent = m.itemGrid
            else
                gridComponent = m.genreGrid
            end if
            if gridComponent.itemFocused < gridComponent.numColumns
                ' At top row, move to toolbar
                focusToolbarItem(m.toolbarFocusIndex)
                return true
            end if
        end if
        if isStringEqual(key, "back")
            if m.itemGrid.isinFocusChain() then
                gridComponent = m.itemGrid
            else
                gridComponent = m.genreGrid
            end if
            if gridComponent.itemFocused >= gridComponent.numColumns
                gridComponent.jumpToItem = 0
                return true
            end if
            reclaimResources()
            m.global.sceneManager.callfunc("popScene")
            return true
        end if
        if isStringEqual(key, "play")
            itemToPlay = getItemFocused()
            if isValid(itemToPlay)
                if isStringEqual("photo", chainLookupReturn(itemToPlay, "type", ""))
                    m.itemGrid.itemSelected = m.itemGrid.itemFocused
                    return true
                end if
                m.top.quickPlayNode = itemToPlay
                return true
            end if
        end if
        if isStringEqual(key, "options")
            m.showOptionMenu = true
            focusedItem = getItemFocused()
            if not isValid(focusedItem) then
                return false
            end if
            m.loadItemsTask1.itemId = focusedItem.LookupCI("id")
            m.loadItemsTask1.observeField("content", "onItemDataLoaded")
            m.loadItemsTask1.itemsToLoad = "metaData"
            m.loadItemsTask1.control = "RUN"
            return true
        end if
    end if
    return false
end function

' =====================================================================
' CONTEXT MENU (MY LIST, FAVORITES, WATCHED, ETC.)
' =====================================================================
sub onMyListLoaded()
    isInMyListData = m.isInMyListTask.content
    m.isInMyListTask.unobserveField("content")
    m.isInMyListTask.content = []
    m.isInMyListTask.control = "STOP"
    if not isValidAndNotEmpty(isInMyListData) then
        return
    end if
    focusedItem = getItemFocused()
    if not isValid(focusedItem) then
        return
    end if
    dialogData = []
    if inArray([
        "boxset"
        "boxsets"
    ], getCollectionType())
        dialogData.push(tr("Shuffle Play Collection"))
    end if
    if isInMyListData[0] then
        myListOption = tr("Remove From My List")
    else
        myListOption = tr("Add To My List")
    end if
    dialogData.push(myListOption)
    dialogData.push(m.favoritesOptionText)
    dialogData.push(tr("Add To Playlist"))
    paramData = {
        id: focusedItem.LookupCI("id")
    }
    if isChainValid(focusedItem, "watched")
        if focusedItem.watched
            dialogData.push(tr("Mark As Unplayed"))
        else
            dialogData.push(tr("Watched"))
        end if
    end if
    if inArray([
        "episode"
        "season"
    ], focusedItem.LookupCI("type"))
        dialogData.push(tr("Go To Series"))
        dialogData.push(tr("Go To Season"))
        paramData.SeasonId = focusedItem.json.LookupCI("SeasonId")
        paramData.SeriesId = focusedItem.json.LookupCI("SeriesId")
    end if
    m.global.sceneManager.callFunc("optionDialog", "libraryitem", focusedItem.LookupCI("title"), [], dialogData, paramData)
end sub

sub reclaimResources()
    m.loadItemsTask.control = "STOP"
    m.loadItemsTask.content = []
    m.data = createSGNode("ContentNode")
    m.itemGrid.content = m.data
    m.genreData = createSGNode("ContentNode")
    m.genreGrid.content = m.genreData
end sub
'//# sourceMappingURL=./VisualLibraryScene.brs.map