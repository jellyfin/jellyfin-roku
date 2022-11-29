sub init()
    m.queue = []
end sub

'
' Clear all content from play queue
sub clear()
    m.queue = []
end sub


'
' Delete item from play queue at passed index
sub deleteAtIndex(index)
    m.queue.Delete(index)
end sub

'
' Return the item in the passed index from the play queue
function getItemByIndex(index)
    return m.queue[index]
end function


'
' Return the current play queue
function getQueue()
    return m.queue
end function


'
' Return item at end of play queue without removing
function peek()
    return m.queue.peek()
end function


'
' Play items in queue
sub playQueue()
    nextItem = top()
    nextItemMediaType = invalid

    if isValid(nextItem?.json?.mediatype) and nextItem.json.mediatype <> ""
        nextItemMediaType = LCase(nextItem.json.mediatype)
    else if isValid(nextItem?.type) and nextItem.type <> ""
        nextItemMediaType = LCase(nextItem.type)
    end if

    if not isValid(nextItemMediaType) then return

    if nextItemMediaType = "audio"
        CreateAudioPlayerView()
    end if
end sub


'
' Remove item at end of play queue
sub pop()
    m.queue.pop()
end sub


'
' Push new items to the play queue
sub push(newItem)
    m.queue.push(newItem)
end sub


'
' Return the fitst item in the play queue
function top()
    return getItemByIndex(0)
end function


'
' Replace play queue with passed array
sub set(items)
    m.queue = items
end sub
