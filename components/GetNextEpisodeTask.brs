import "pkg:/source/utils/config.brs"
import "pkg:/source/api/sdk.bs"

sub init()
    m.top.functionName = "getNextEpisodeTask"
end sub

sub getNextEpisodeTask()
    m.nextEpisodeData = api.shows.GetEpisodes(m.top.showID, {
        UserId: get_setting("active_user"),
        StartItemId: m.top.videoID,
        Limit: 2
    })

    m.top.nextEpisodeData = m.nextEpisodeData
end sub
