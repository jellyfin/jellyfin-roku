sub init()

    ' Max "Overview" lines to show in Preview and Detail
    m.maxPreviewLines = 5
    m.maxDetailLines = 14

    m.detailsView = m.top.findNode("detailsView")

    m.programName = m.top.findNode("programName")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.episodeNumber = m.top.findNode("episodeNumber")
    m.overview = m.top.findNode("overview")

    m.episodeDetailsGroup = m.top.findNode("episodeDetailsGroup")
    m.isLiveGroup = m.top.findNode("isLive")
    m.isRepeatGroup = m.top.findNode("isRepeat")

    m.broadcastDetails = m.top.findNode("broadcastDetails")
    m.duration = m.top.findNode("duration")
    m.channelName = m.top.findNode("channelName")
    m.image = m.top.findNode("image")

    m.focusAnimationOpacity = m.top.findNode("focusAnimationOpacity")
    m.focusAnimation = m.top.findNode("focusAnimation")

    m.viewChannelButton = m.top.findNode("viewChannelButton")

    m.focusAnimation.observeField("state", "onAnimationComplete")

    setupLabels()
end sub


' Set up Live and Repeat label sizes
sub setupLabels()

    boundingRect = m.top.findNode("isLiveText").boundingRect()
    isLiveBackground = m.top.findNode("isLiveBackground")
    isLiveBackground.width = boundingRect.width + 16
    isLiveBackground.height = boundingRect.height + 8
    m.episodeDetailsGroup.removeChildIndex(0)

    boundingRect = m.top.findNode("isRepeatText").boundingRect()
    isRepeatBackground = m.top.findNode("isRepeatBackground")
    isRepeatBackground.width = boundingRect.width + 16
    isRepeatBackground.height = boundingRect.height + 8
    m.episodeDetailsGroup.removeChildIndex(0)

    boundingRect = m.viewChannelButton.boundingRect()
    buttonBackground = m.top.findNode("viewChannelButtonBackground")
    buttonBackground.width = boundingRect.width + 20
    buttonBackground.height = boundingRect.height + 20
end sub

sub programUpdated()

    m.top.watchSelectedChannel = false
    m.overview.maxLines = m.maxDetailLines
    prog = m.top.programDetails

    ' If no program selected, hide details view
    if prog = invalid then
        m.detailsView.visible = "false"
        return
    end if

    m.programName.text = prog.Title
    m.overview.text = prog.description

    m.episodeDetailsGroup.removeChildrenIndex(m.episodeDetailsGroup.getChildCount(), 0)

    if prog.isLive then
        m.episodeDetailsGroup.appendChild(m.isLiveGroup)
    else if prog.isRepeat then
        m.episodeDetailsGroup.appendChild(m.isRepeatGroup)
    end if

    ' Episode Number
    if prog.seasonNumber > 0 and prog.episodeNumber > 0 then
        m.episodeNumber.text = "S" + StrI(prog.seasonNumber).trim() + ":E" + StrI(prog.episodeNumber).trim()
        if prog.episodeTitle <> "" then m.episodeNumber.text = m.episodeNumber.text + " -" ' Add a Dash if showing Episode Number and Title
        m.episodeDetailsGroup.appendChild(m.episodeNumber)
    end if

    if prog.episodeTitle <> invalid and prog.episodeTitle <> "" then
        m.episodeTitle.text = prog.episodeTitle
        m.episodeTitle.visible = true
        m.episodeDetailsGroup.appendChild(m.episodeTitle)
    end if

    m.duration.text = getDurationStringFromSeconds(prog.PlayDuration)

    ' Calculate Broadcast Details
    now = createObject("roDateTime")
    startDate = createObject("roDateTime")
    endDate = createObject("roDateTime")
    startDate.FromISO8601String(prog.StartDate)
    endDate.FromISO8601String(prog.EndDate)

    day = getRelativeDayName(startDate)

    if startDate.AsSeconds() < now.AsSeconds() and endDate.AsSeconds() > now.AsSeconds() then
        if day = "today" then
            m.broadcastDetails.text = tr("Started at") + " " + formatTime(startDate)
        else
            m.broadcastDetails.text = tr("Started") + " " + tr(day) + ", " + formatTime(startDate)
        end if
    else if startDate.AsSeconds() > now.AsSeconds()
        if day = "today" then
            m.broadcastDetails.text = tr("Starts at") + " " + formatTime(startDate)
        else
            m.broadcastDetails.text = tr("Starts") + " " + tr(day) + ", " + formatTime(startDate)
        end if
    else
        if day = "today" then
            m.broadcastDetails.text = tr("Ended at") + " " + formatTime(endDate)
        else
            m.broadcastDetails.text = tr("Ended") + " " + tr(day) + ", " + formatTime(endDate)
        end if
    end if

    m.image.uri = prog.PosterURL

    if prog.channelName <> invalid and prog.channelName <> "" then
        m.channelName.text = prog.channelName
    end if

    m.detailsView.visible = "true"
    
    m.top.height = m.detailsView.boundingRect().height
    m.overview.maxLines = m.maxPreviewLines
end sub

'
' Get relative date name for a date (yesterday, today, tomorrow, or otherwise weekday name )
function getRelativeDayName(date) as string

    now = createObject("roDateTime")

    ' Check for Today
    if now.AsDateString("short-date-dashes") = date.AsDateString("short-date-dashes") then
        return "today"
    end if

    ' Check for Yesterday
    todayMidnight = now.AsSeconds() - (now.AsSeconds() MOD 86400)
    dateMidnight = date.AsSeconds() - (date.AsSeconds() MOD 86400)

    if todayMidnight - dateMidnight = 86400 then
        return "yesterday"
    end if

    if dateMidnight - todayMidnight = 86400 then
        return "tomorrow"
    end if

    return date.GetWeekday()

end function

'
' Get program duratio string (e.g. 1h 20m)
function getDurationStringFromSeconds(seconds) as string

    hours = 0
    minutes = seconds / 60.0

    if minutes > 60 then
        hours = (minutes - (minutes MOD 60)) / 60
        minutes = minutes MOD 60
    end if

    if hours > 0 then
        return "%1h %2m".Replace("%1", StrI(hours).trim()).Replace("%2", StrI(minutes).trim())
    else
        return "%1m".Replace("%1", StrI(minutes).trim())
    end if

end function

'
' Show view channel button when item has Focus
sub focusChanged()
    if m.top.hasFocus = true then 
        m.overview.maxLines = m.maxDetailLines
        m.focusAnimationOpacity.keyValue = [0, 1]
    else
        m.top.watchSelectedChannel = false
        m.focusAnimationOpacity.keyValue = [1, 0]
    end if

    m.focusAnimation.control = "start"

end sub

sub onAnimationComplete() 
    if m.focusAnimation.state = "stopped" and m.top.hasFocus = false then
        m.overview.maxLines = m.maxPreviewLines
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "OK" then
        m.top.watchSelectedChannel = true
        return true
    end if

    if key = "left" or key = "right" or key = "up" or key = "down" then
        return true
    end if

    return false
end function


