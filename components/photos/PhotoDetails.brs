sub init()
    m.top.optionsAvailable = false ' Change once Shuffle option is added
    m.top.overhangVisible = false
    itemContentChanged()
end sub

sub itemContentChanged()
    if isValidToContinue(m.top.itemIndex)
        m.LoadLibrariesTask = createObject("roSGNode", "LoadPhotoTask")
        itemContent = m.top.items.content.getChild(m.top.itemIndex)
        m.LoadLibrariesTask.itemContent = itemContent
        m.LoadLibrariesTask.observeField("results", "onPhotoLoaded")
        m.LoadLibrariesTask.control = "RUN"
    end if
end sub

sub onPhotoLoaded()
    if m.LoadLibrariesTask.results <> invalid
        photo = m.top.findNode("photo")
        photo.uri = m.LoadLibrariesTask.results
    else
        'Show user error here (for example if it's not a supported image type)
        message_dialog("This image type is not supported.")
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "right"
        if isValidToContinue(m.top.itemIndex + 1)
            m.top.itemIndex++
        end if
        return true
    end if

    if key = "left"
        if isValidToContinue(m.top.itemIndex - 1)
            m.top.itemIndex--
        end if
        return true
    end if

    return false
end function

function isValidToContinue(index as integer)
    if isValid(m.top.items) and isValid(m.top.items.content)
        if index >= 0 and index < m.top.items.content.getChildCount()
            return true
        end if
    end if

    return false
end function
