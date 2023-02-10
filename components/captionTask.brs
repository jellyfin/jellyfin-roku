sub init()
    m.top.observeField("url", "fetchCaption")
    m.top.currentCaption = []
    m.top.currentPos = 0

    m.captionTimer = m.top.findNode("captionTimer")
    m.captionTimer.ObserveField("fire", "updateCaption")

    m.captionList = []
    m.reader = createObject("roUrlTransfer")
    m.font = CreateObject("roSGNode", "Font")
    m.tags = CreateObject("roRegex", "{\\an\d*}|&lt;.*?&gt;|<.*?>", "s")

    ' Caption Style
    m.fontSizeDict = { "Default": 60, "Large": 60, "Extra Large": 70, "Medium": 50, "Small": 40 }
    m.percentageDict = { "Default": 1.0, "100%": 1.0, "75%": 0.75, "50%": 0.5, "25%": 0.25, "Off": 0 }
    m.textColorDict = { "Default": &HFFFFFFFF, "White": &HFFFFFFFF, "Black": &H000000FF, "Red": &HFF0000FF, "Green": &H008000FF, "Blue": &H0000FFFF, "Yellow": &HFFFF00FF, "Magenta": &HFF00FFFF, "Cyan": &H00FFFFFF }
    m.bgColorDict = { "Default": &H000000FF, "White": &HFFFFFFFF, "Black": &H000000FF, "Red": &HFF0000FF, "Green": &H008000FF, "Blue": &H0000FFFF, "Yellow": &HFFFF00FF, "Magenta": &HFF00FFFF, "Cyan": &H00FFFFFF }

    m.settings = CreateObject("roDeviceInfo")
    m.fontSize = m.fontSizeDict[m.settings.GetCaptionsOption("Text/Size")]
    m.textColor = m.textColorDict[m.settings.GetCaptionsOption("Text/Color")]
    m.textOpac = m.percentageDict[m.settings.GetCaptionsOption("Text/Opacity")]
    m.bgColor = m.bgColorDict[m.settings.GetCaptionsOption("Background/Color")]
    m.bgOpac = m.percentageDict[m.settings.GetCaptionsOption("Background/Opacity")]
    setFont()
end sub

sub setFont()
    fs = CreateObject("roFileSystem")
    fontlist = fs.Find("tmp:/", "font")
    if fontlist.count() > 0
        m.font.uri = "tmp:/" + fontlist[0]
        m.font.size = m.fontSize
        m.top.useThis = True
    end if
end sub

sub fetchCaption()
    if m.top.useThis
        m.captionTimer.control = "stop"
        re = CreateObject("roRegex", "(http.*?\.vtt)", "s")
        url = re.match(m.top.url)[0]
        ?url
        if url <> invalid
            m.reader.setUrl(url)
            text = m.reader.GetToString()
            m.captionList = parseVTT(text)
            m.captionTimer.control = "start"
        else
            m.captionTimer.control = "stop"
        end if
    end if
end sub

function newlabel(txt):
    label = CreateObject("roSGNode", "Label")
    label.text = txt
    label.font = m.font
    label.color = m.textColor
    label.opacity = m.textOpac
    return label
end function

function newLayoutGroup(labels)
    newlg = CreateObject("roSGNode", "LayoutGroup")
    newlg.appendchildren(labels)
    newlg.horizalignment = "center"
    newlg.vertalignment = "bottom"
    return newlg
end function

function newRect(lg)
    rectLG = CreateObject("roSGNode", "LayoutGroup")
    rectxy = lg.BoundingRect()
    rect = CreateObject("roSGNode", "Rectangle")
    rect.color = m.bgColor
    rect.opacity = m.bgOpac
    rect.width = rectxy.width + 50
    rect.height = rectxy.height
    if lg.getchildCount() = 0
        rect.width = 0
        rect.height = 0
    end if
    rectLG.horizalignment = "center"
    rectLG.vertalignment = "bottom"
    rectLG.appendchild(rect)
    return rectLG
end function


sub updateCaption ()
    m.top.currentCaption = []
    if m.top.playerState = "playingOn"
        m.top.currentPos = m.top.currentPos + 100
        texts = []
        for each entry in m.captionList
            if entry["start"] <= m.top.currentPos and m.top.currentPos < entry["end"]
                t = m.tags.replaceAll(entry["text"], "")
                texts.push(t)
            end if
        end for
        labels = []
        for each text in texts
            labels.push(newlabel (text))
        end for
        lines = newLayoutGroup(labels)
        rect = newRect(lines)
        m.top.currentCaption = [rect, lines]
    else if right(m.top.playerState, 4) = "Wait"
        m.top.playerState = "playingOn"
    else
        m.top.currentCaption = []
    end if
end sub

function isTime(text)
    return text.right(1) = chr(31)
end function

function toMs(t)
    t = t.replace(".", ":")
    t = t.left(12)
    timestamp = t.tokenize(":")
    return 3600000 * timestamp[0].toint() + 60000 * timestamp[1].toint() + 1000 * timestamp[2].toint() + timestamp[3].toint()
end function

function parseVTT(lines)
    lines = lines.replace(" --> ", chr(31) + chr(10))
    lines = lines.split(chr(10))
    curStart = -1
    curEnd = -1
    entries = []

    for i = 0 to lines.count() - 1
        if isTime(lines[i])
            curStart = toMs (lines[i])
            curEnd = toMs (lines[i + 1])
            i += 1
        else if curStart <> -1
            trimmed = lines[i].trim()
            if trimmed <> chr(0)
                entry = { "start": curStart, "end": curEnd, "text": trimmed }
                entries.push(entry)
            end if
        end if
    end for
    return entries
end function
