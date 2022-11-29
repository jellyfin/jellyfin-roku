' Play Audio
sub CreateAudioPlayerView()

    view = CreateObject("roSGNode", "AudioPlayerView")
    view.observeField("state", m.port)
    songIDArray = CreateObject("roArray", 0, true)

    ' All we need is an array of Song IDs the user selected to play.
    for each song in m.global.queueManager.callFunc("getQueue")
        songIDArray.push(song.id)
    end for

    view.pageContent = songIDArray
    view.musicArtistAlbumData = m.global.queueManager.callFunc("getQueue")

    m.global.sceneManager.callFunc("pushScene", view)
end sub
