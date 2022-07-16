sub init()
    m.spinner = m.top.findNode("spinner")

    m.top.content = getData()
    m.top.setfocus(true)
end sub

function getData()
    if m.top.MusicArtistAlbumData = invalid
        data = CreateObject("roSGNode", "ContentNode")
        return data
    end if

    albumData = m.top.MusicArtistAlbumData
    data = CreateObject("roSGNode", "ContentNode")

    for each song in albumData.items
        songcontent = data.createChild("MusicSongData")
        songcontent.json = song.json
    end for

    m.top.content = data

    hideSpinner()

    return data
end function

sub hideSpinner()
    m.spinner.visible = false
end sub
