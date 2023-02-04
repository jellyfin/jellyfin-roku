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
    fontlist = fs.Find("tmp:/", "font\.(otf|ttf)")
    if fontlist.count() > 0
        m.font.uri = "tmp:/" + fontlist[0]
    else
        m.font = "font:LargeBoldSystemFont"
    end if
    m.font.size = 60
end sub

sub fetchCaption()
    m.captionTimer.control = "stop"
    re = CreateObject("roRegex", "(http.*?\.vtt)", "s")
    url = re.match(m.top.url)[0]
    if url <> invalid
        m.reader.setUrl(url)
        text = m.reader.GetToString()
        m.captionList = parseVTT(text)
        m.captionTimer.control = "start"
    else
        m.captionTimer.control = "stop"
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

function ms(t) as integer
    tt = t.tokenize(":")
    return 3600000 * val(tt[0]) + 60000 * val(tt[1]) + 1000 * val(tt[2]) + val(t.right(3))
end function



function getstart(text)
    return ms(text.left(12))
end function

function getend(text)
    return ms(text)
end function

function isTime(text)
    return text.mid(13, 3) = "-->"
end function

function parseVTT(text)
    captionList = []
    lines = text.tokenize(Chr(0))[0]
    lines = lines.tokenize(Chr(10))
    size = lines.count()
    curStart = 0
    curEnd = 0
    for i = 0 to size - 1
        if isTime(lines[i])
            curStart = ms (lines[i].left(12))
            curEnd = ms(lines[i].mid(17, 12))
        else
            entry = { "start": curStart, "end": curEnd, "text": lines[i].trim() }
            captionList.push(entry)
        end if
    end for
    return captionList
end function
