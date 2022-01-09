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
            url = "LiveTv/Timers"
            resp = APIRequest(url)
            success = postJson(resp, FormatJson(data))
            print "success value " success
            ' Indicate success back to our caller
            m.top.timerCreated = true
        else
            ' Error msg to user?
            print "Error getting Live TV Defaults from Server"
            m.top.timerCreated = false
        end if
    end if

end sub
