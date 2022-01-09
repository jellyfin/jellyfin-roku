sub init()
    m.top.functionName = "RecordProgram"
end sub

sub RecordProgram()
    ' Get Live TV default params from server...
    if m.top.programDetails <> invalid
        programId = m.top.programDetails.Id

        url = "LiveTv/Timers/Defaults"
        params = {
            programId: programId
        }
        
        resp = APIRequest(url, params)
        data = getJson(resp)

        if data <> invalid
            ' Create recording timer...
            if m.top.recordSeries = true
                url = "LiveTv/SeriesTimers"
            else
                url = "LiveTv/Timers"
            end if
            resp = APIRequest(url)
            postJson(resp, FormatJson(data))
            m.top.timerCreated = true
        else
            ' Error msg to user?
            print "Error getting Live TV Defaults from Server"
            m.top.timerCreated = false
        end if
    end if

end sub
