import "pkg:/source/utils/config.brs"

sub init()
    m.rows = m.top.findNode("tvEpisodeRow")
    m.tvListOptions = m.top.findNode("tvListOptions")

    m.rows.observeField("doneLoading", "rowsDoneLoading")
end sub

sub setupRows()
    objects = m.top.objects
    m.rows.objects = objects
end sub

sub rowsDoneLoading()
    m.top.doneLoading = true
end sub

sub SetUpVideoOptions(streams)
    videos = []

    for i = 0 to streams.Count() - 1
        if streams[i].VideoType = "VideoFile"
            ' Create options for user to switch between video tracks
            videos.push({
                "Title": streams[i].Name,
                "Description": tr("Video"),
                "Selected": m.top.objects.items[m.currentSelected].selectedVideoStreamId = streams[i].id,
                "StreamID": streams[i].id,
                "video_codec": streams[i].mediaStreams[0].displayTitle
            })
        end if
    end for

    if videos.count() >= 1
        options = {}
        options.videos = videos
        m.tvListOptions.options = options
    end if
end sub

sub SetUpAudioOptions(streams)
    tracks = []

    for i = 0 to streams.Count() - 1
        if streams[i].Type = "Audio"
            tracks.push({ "Title": streams[i].displayTitle, "Description": streams[i].Title, "Selected": m.top.objects.items[m.currentSelected].selectedAudioStreamIndex = i, "StreamIndex": i })
        end if
    end for

    if tracks.count() >= 1
        options = {}
        if m.tvListOptions.options <> invalid and m.tvListOptions.options.videos <> invalid
            options.videos = m.tvListOptions.options.videos
        end if
        options.audios = tracks
        m.tvListOptions.options = options
    end if
end sub

'
'Check if options updated and any reloading required
sub audioOptionsClosed()
    if m.currentSelected <> invalid
        ' If the user opened the audio options, we report back even if they left the selection alone.
        ' Otherwise, the users' lang peference from the server will take over.
        ' To do this, we interpret anything other than "0" as the user opened the audio options.
        m.top.objects.items[m.currentSelected].selectedAudioStreamIndex = m.tvListOptions.audioStreamIndex = 0 ? 1 : m.tvListOptions.audioStreamIndex
    end if
end sub

'
' Check if options were updated
sub videoOptionsClosed()
    if m.tvListOptions.videoStreamId <> m.top.objects.items[m.currentSelected].selectedVideoStreamId
        m.rows.objects.items[m.currentSelected].selectedVideoStreamId = m.tvListOptions.videoStreamId
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "options" and m.rows.focusedChild <> invalid and m.rows.focusedChild.rowItemFocused <> invalid
        m.currentSelected = m.rows.focusedChild.rowItemFocused[0]
        mediaStreams = m.rows.objects.items[m.currentSelected].json.MediaStreams
        mediaSources = m.rows.objects.items[m.currentSelected].json.MediaSources
        if m.rows.objects.items[m.currentSelected].selectedVideoStreamId <> ""
            for each source in mediaSources
                if source.id = m.rows.objects.items[m.currentSelected].selectedVideoStreamId
                    mediaStreams = source.MediaStreams
                    exit for
                end if
            end for
        end if
        if mediaSources <> invalid
            SetUpVideoOptions(mediaSources)
        end if
        if mediaStreams <> invalid
            SetUpAudioOptions(mediaStreams)
        end if
        if m.tvListOptions.options <> invalid
            m.tvListOptions.visible = true
            m.tvListOptions.setFocus(true)
        end if
        return true
    else if m.tvListOptions.visible = true and key = "back" or key = "options"
        m.tvListOptions.setFocus(false)
        m.tvListOptions.visible = false
        m.rows.setFocus(true)
        videoOptionsClosed()
        audioOptionsClosed()
        return true
    else if key = "up" and m.rows.hasFocus() = false
        m.rows.setFocus(true)
    else if key = "down" and m.rows.hasFocus() = false
        m.rows.setFocus(true)
    end if

    return false
end function
