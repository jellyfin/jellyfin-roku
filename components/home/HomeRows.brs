sub init()
    m.top.itemComponentName = "HomeItem"
    ' My media row should always exist
    m.top.numRows = 1
    m.top.content = CreateObject("roSGNode", "ContentNode")

    m.top.rowFocusAnimationStyle = "fixedFocusWrap"
    m.top.vertFocusAnimationStyle = "floatingFocus"

    m.top.showRowLabel = [true]
    m.top.rowLabelOffset = [0, 20]
    m.top.showRowCounter = [true]

    updateSize()

    m.top.setfocus(true)
end sub

sub updateSize()
    sideborder = 100
    m.top.translation = [111, 155]

    itemWidth = 480
    itemHeight = 330

    m.top.itemSize = [1920 - 111 - 27, itemHeight]
    ' spacing between rows
    m.top.itemSpacing = [0, 105]

    ' size of the item in the row
    m.top.rowItemSize = [itemWidth, itemHeight]
    ' spacing between items in a row
    m.top.rowItemSpacing = [20, 0]

    m.top.visible = true
end sub

sub showLibraryRow()
    libs = m.top.libList

    libraryRow = CreateObject("roSGNode", "ContentNode")
    libraryRow.title = "My Media"

    for i = 1 to libs.TotalRecordCount
        item = libs.Items[i - 1]
        libraryRow.appendChild(item)
    end for
    
    m.top.content.appendChild(libraryRow)
end sub

sub showContinueRow()
    continueItems = m.top.continueList

    if continueItems.TotalRecordCount > 0 then
        continueRow = CreateObject("roSGNode", "ContentNode")
        continueRow.title = "Continue Watching"

        for i = 1 to continueItems.TotalRecordCount
            item = continueItems.Items[i - 1]
            continueRow.appendChild(item)
        end for

        m.top.numRows++
        m.top.content.appendChild(continueRow)
    end if  
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    return false
end function
