sub init()
    m.top.observeField("url", "fetchCaption")
    m.top.currentCaption = []
    m.top.currentPos = 0

    m.captionTimer = m.top.findNode("captionTimer")
    m.captionTimer.ObserveField("fire", "updateCaption")

    m.captionList = []
    m.reader = createObject("roUrlTransfer")

    m.font = CreateObject("roSGNode", "Font")
    m.font.uri = "pkg:/fonts/noto.otf"
    m.font.size = 50
end sub

sub fetchCaption()
    re = CreateObject("roRegex", "(http.*?\.vtt)", "s")
    url = re.match(m.top.url)[0]
    if url <> invalid then
        m.reader.setUrl(url)
        text = m.reader.GetToString()
        m.captionList = parseVTT(text)
        m.captionTimer.control = "start"
    else
        m.captionTimer.control = "stop"
    end if
end sub

sub updateCaption ()
    ' Stop updating captions if the video isn't playing
    if m.top.playerState = "playing" then
        m.top.currentPos = m.top.currentPos + 100
        tmp = []
        for each entry in m.captionList
            if entry["start"] <= m.top.currentPos and m.top.currentPos <= entry["end"] then
                label = CreateObject("roSGNode", "Label")
                label.text = entry["text"]
                label.font = m.font
                tmp.push(label)
            end if
        end for
        m.top.currentCaption = tmp
    end if
    ' end if
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