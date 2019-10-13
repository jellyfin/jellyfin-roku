sub init()
    itemText = m.top.findNode("itemText")
    itemText.text = "Loading..."
end sub

function itemContentChanged() as void
    itemData = m.top.itemContent
    if itemData = invalid then return

    itemText = m.top.findNode("itemText")
    itemText.text = itemData.name
    itemPoster = m.top.findNode("itemPoster")
    if itemData.type = "livetv" then
        itemPoster.width = "96"
        itemPoster.height = "96"
        itemPoster.translation = "[192, 88]"
        itemPoster.uri = "pkg:/images/baseline_live_tv_white_48dp.png"
    else if itemData.type = "music" then
        itemPoster.width = "96"
        itemPoster.height = "96"
        itemPoster.translation = "[192, 88]"
        itemPoster.uri = "pkg:/images/baseline_library_music_white_48dp.png"
    else
        itemPoster.uri = itemData.imageURL
    end if
end function