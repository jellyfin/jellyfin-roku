sub init()
    m.top.functionName = "loadProgramDetails"
    
end sub

sub loadProgramDetails()

    channelIndex = m.top.ChannelIndex
    programIndex = m.top.ProgramIndex

    params = {
        UserId: get_setting("active_user"),
    }

    url = Substitute("LiveTv/Programs/{0}", m.top.programId)

    resp = APIRequest(url, params)
    data = getJson(resp)

    if data = invalid then
        m.top.programDetails = {}
        return
    end if

    program = createObject("roSGNode", "ScheduleProgramData")
    program.json = data
    program.channelIndex = ChannelIndex
    program.programIndex = ProgramIndex
    program.fullyLoaded = true
    m.top.programDetails = program

end sub