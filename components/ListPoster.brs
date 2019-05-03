sub init()
    m.title = m.top.findNode("title")
    m.poster = m.top.findNode("poster")
    m.backdrop = m.top.findNode("backdrop")

    m.backdrop.color = "#404040FF"

    updateSize()
end sub

sub updateSize()
    m.title = m.top.findNode("title")
    m.poster = m.top.findNode("poster")
    m.backdrop = m.top.findNode("backdrop")

    ' TODO - abstract this in case the parent doesnt have itemSize
    maxSize = m.top.getParent().itemSize

    m.poster.width = int(maxSize[0]) - 4
    m.poster.height = m.poster.width * 1.5

    m.backdrop.width = m.poster.width
    m.backdrop.height = m.poster.height

    m.title.wrap = true
    m.title.maxLines = 2
    m.title.width = m.poster.width
    m.title.height = int(maxSize[1]) - m.poster.height
    m.title.translation = [0, m.poster.height]

end sub

function itemContentChanged() as void
    updateSize()

    m.title = m.top.findNode("title")
    m.poster = m.top.findNode("poster")
    itemData = m.top.itemContent

    m.title.text = itemData.title
    m.poster.uri = itemData.posterUrl

    if itemData.mediaType = "Episode"
        m.poster.height = m.poster.width * 9/16
        m.poster.translation = [2, m.poster.width / 2]
    end if
end function