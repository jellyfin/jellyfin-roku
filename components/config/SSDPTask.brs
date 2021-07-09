'
' Task used to scan the network and find jellyfin servers that are broadcasting over the SSDP protocol
'

sub init()
    m.top.functionName = "execute"
end sub

sub execute()
    m.top.content = GetServersViaSSDP()
end sub

function GetServersViaSSDP()
    'brightscript can't escape characters in strings, so create a few vars here so we can use them in the strings below
    Q = Chr(34)
    CRLF = Chr(13) + Chr(10)

    port = CreateObject("roMessagePort")

    ssdpStr = ""
    ssdpStr = ssdpStr + "M-SEARCH * HTTP/1.1" + CRLF
    ssdpStr = ssdpStr + "HOST: 239.255.255.250:1900" + CRLF
    ssdpStr = ssdpStr + "MAN: " + Q + "ssdp:discover" + Q + CRLF
    ssdpStr = ssdpStr + "ST:urn:schemas-upnp-org:device:MediaServer:1" + CRLF
    ssdpStr = ssdpStr + "MX: 2" + CRLF
    ssdpStr = ssdpStr + CRLF

    ssdpAddr = CreateObject("roSocketAddress")
    ssdpAddr.SetAddress("239.255.255.250:1900")

    ssdp = CreateObject("roDatagramSocket")
    ssdp.SetMessagePort(port)
    ssdp.SetSendToAddress(ssdpAddr)
    ssdp.NotifyReadable(True)
    ssdp.SendStr(ssdpStr)

    locationUrls = {}

    ut = CreateObject("roUrlTransfer")
    ut.SetPort(port)

    ts = CreateObject("roTimespan")
    'wait for a maximum time
    maxTimeMs = 2200

    while True
        elapsed = ts.TotalMilliseconds()
        if elapsed >= maxTimeMs
            exit while
        end if

        msg = Wait(maxTimeMs - elapsed, port)

        if Type (msg) = "roSocketEvent" and msg.GetSocketId() = ssdp.GetId() and ssdp.IsReadable() then

            recvStr = ssdp.ReceiveStr(4096)
            match = CreateObject("roRegex", "\r\nLocation:\s*(.*?)\s*\r\n", "i").Match(recvStr)
            if match.Count() = 2
                locationUrl = match[1]
                if not locationUrls.DoesExist(locationUrl)
                    print "found network location: " + locationUrl
                    locationUrls.AddReplace(locationUrl, 0)
                end if
            end if
        end if
    end while

    'download each of the discovered locations and see if any of them are named "Jellfin Server"
    results = []
    for each locationUrl in locationUrls
        http = CreateObject("roUrlTransfer")
        http.SetUrl(locationUrl)
        responseText = http.GetToString()
        xml = CreateObject("roXMLElement")
        'if we successfully parsed the response, process it
        if xml.Parse(responseText) then
            deviceNode = xml.GetNamedElementsCi("device")[0]
            manufacturer = deviceNode.GetNamedElementsCi("manufacturer").GetText()
            'only process jellyfin servers
            if lcase(manufacturer) = "jellyfin" then
                'find the largest icon
                width = 0
                result = invalid
                icons = deviceNode.GetNamedElementsCi("iconList")[0].GetNamedElementsCi("icon")
                for each iconNode in icons
                    iconUrl = iconNode.GetNamedElementsCi("url").GetText()
                    baseUrl = invalid
                    match = CreateObject("roRegex", "(.*?)\/dlna\/", "i").Match(iconUrl)
                    if match.Count() = 2
                        baseUrl = match[1]
                    end if
                    loopResult = {
                        name: deviceNode.GetNamedElementsCi("friendlyName").GetText(),
                        baseUrl: baseUrl,
                        iconUrl: iconUrl,
                        iconWidth: iconNode.GetNamedElementsCi("width")[0].GetText().ToInt(),
                        iconHeight: iconNode.GetNamedElementsCi("height")[0].GetText().ToInt()
                    }
                    if baseUrl <> invalid and loopResult.iconWidth > width then
                        result = loopResult
                    end if
                end for
                results.Push(result)
            end if
        end if
    end for
    return results
end function
