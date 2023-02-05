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

    setFont()
end sub

sub setFont()
    fs = CreateObject("roFileSystem")
    fontlist = fs.Find("tmp:/", "font")
    if fontlist.count() > 0
        m.font.uri = "tmp:/" + fontlist[0]
        m.font.size = 60
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
    label.color = &H000000FF
    label.height = 108
    return label
end function

function newlayout(labels)
    invis = CreateObject("roSGNode", "Label")
    invis.visible = False
    l = labels.count()
    newlg = CreateObject("roSGNode", "LayoutGroup")
    for i = 0 to 7 - l
        newlg.appendchild(invis.clone(True))
    end for
    newlg.appendchildren(labels)
    newlg.horizalignment = "center"
    newlg.vertalignment = "bottom"

    return newlg
end function


sub updateCaption ()
    m.top.currentCaption = []
    if m.top.playerState = "playingOn"
        m.top.currentPos = m.top.currentPos + 100
        texts = []
        for each entry in m.captionList
            if entry["start"] <= m.top.currentPos and m.top.currentPos < entry["end"]
                ' ?m.top.currentPos
                ' ?entry
                t = m.tags.replaceAll(entry["text"], "")
                texts.push(t)
            end if
        end for
        labels = []
        for each text in texts
            labels.push(newlabel (text))
        end for
        lg = newlayout(labels)
        lglist = []
        coords = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1], [0, 0]]
        for p = 0 to 8
            lgg = lg.clone(True)
            lgg.translation = [coords[p][0] * 5, coords[p][1] * 5]
            lglist.push(lgg)
        end for
        for q = 0 to 7
            lglist[8].getchild(q).color = &HFFFFFFFF
        end for
        m.top.currentCaption = lglist
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
