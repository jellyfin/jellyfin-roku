sub init()
    m.top.observeField("url", "fetchCaption")
    m.top.currentCaption = CreateObject("roArray", 9, true)
    m.top.currentPos = 0

    m.captionTimer = m.top.findNode("captionTimer")
    m.captionTimer.ObserveField("fire", "updateCaption")

    m.captionList = []
    m.reader = createObject("roUrlTransfer")
    m.font = CreateObject("roSGNode", "Font")
    fetchFont()
end sub


sub fetchFont()
    fs = CreateObject("roFileSystem")
    fontlist = fs.Find("tmp:/", ".*\.(otf|ttf)")
    if fontlist.count() = 0
        re = CreateObject("roRegex", "Name.:.(.*?).,.Size", "s")
        m.filename = APIRequest("FallbackFont/Fonts").GetToString()
        m.filename = re.match(m.filename)
        if m.filename.count() <> 0
            m.filename = m.filename[1]
            APIRequest("FallbackFont/Fonts/" + m.filename).gettofile("tmp:/" + m.filename)
            m.font.uri = "tmp:/" + m.filename
            m.font.size = 60
        else
            m.font = "font:LargeBoldSystemFont"
        end if
    else
        ?"font exists"
        m.font.uri = fontlist[0]
        ?m.font.uri
        m.font.size = 60
    end if
end sub



sub fetchCaption()
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
    ' Stop updating captions if the video isn't playing
    if m.top.playerState = "playing"
        m.top.currentPos = m.top.currentPos + 100
        texts = []
        for each entry in m.captionList
            if entry["start"] <= m.top.currentPos and m.top.currentPos <= entry["end"]
                texts.push(entry["text"])
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
    end if
end sub

function ms(t) as integer
    r = CreateObject("roRegex", ":|\.", "")
    l = r.split(t)
    return 3600000 * val(l[0]) + 60000 * val(l[1]) + 1000 * val(l[2]) + val(l[3])
end function

function splitLines(text)
    r = CreateObject("roRegex", chr(10), "")
    return r.split(text)
end function

function strip(text) as string
    leading = CreateObject("roRegex", "^\s+", "")
    trailing = CreateObject("roRegex", "\s+$", "")
    text = leading.replaceall(text, "")
    text = trailing.replaceall(text, "")
    return text
end function

function parseVTT(text)
    timestamp = "(\d\d:\d\d:\d\d\.\d\d\d) --> (\d\d:\d\d:\d\d\.\d\d\d)"
    re = CreateObject("roRegex", timestamp + " region.*", "")
    timeList = re.matchall (text)
    textList = re.split(text)
    textList.shift()
    captionList = []
    for i = 0 to textList.count() - 1
        textLines = splitLines(strip (textList[i]))
        for each line in textLines
            entry = { "start": ms(timeList[i][1]), "end": ms(timeList[i][2]), "text": strip(line), "color": "" }
            captionList.push(entry)
        end for
    end for
    return captionList
end function
