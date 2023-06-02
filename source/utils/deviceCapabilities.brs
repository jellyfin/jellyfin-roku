'Device Capabilities for Roku.
'This will likely need further tweaking
function getDeviceCapabilities() as object

    return {
        "PlayableMediaTypes": [
            "Audio",
            "Video",
            "Photo"
        ],
        "SupportedCommands": [],
        "SupportsPersistentIdentifier": false,
        "SupportsMediaControl": false,
        "DeviceProfile": getDeviceProfile()
    }
end function

' Send Device Profile information to server
sub PostDeviceProfile()
    profile = getDeviceCapabilities()
    req = APIRequest("/Sessions/Capabilities/Full")
    req.SetRequest("POST")
    print "profile =", profile
    print "profile.DeviceProfile =", profile.DeviceProfile
    print "profile.DeviceProfile.CodecProfiles ="
    for each prof in profile.DeviceProfile.CodecProfiles
        print prof
        for each cond in prof.Conditions
            print cond
        end for
    end for
    print "profile.DeviceProfile.ContainerProfiles =", profile.DeviceProfile.ContainerProfiles
    print "profile.DeviceProfile.DirectPlayProfiles ="
    for each prof in profile.DeviceProfile.DirectPlayProfiles
        print prof
    end for
    print "profile.DeviceProfile.SubtitleProfiles ="
    for each prof in profile.DeviceProfile.SubtitleProfiles
        print prof
    end for
    print "profile.DeviceProfile.TranscodingProfiles ="
    for each prof in profile.DeviceProfile.TranscodingProfiles
        print prof
    end for
    print "profile.PlayableMediaTypes =", profile.PlayableMediaTypes
    print "profile.SupportedCommands =", profile.SupportedCommands
    postJson(req, FormatJson(profile))
end sub

function getDeviceProfile() as object
    playMpeg2 = m.global.session.user.settings["playback.mpeg2"]
    playAv1 = m.global.session.user.settings["playback.av1"]
    di = CreateObject("roDeviceInfo")

    audioChannelIntegers = [
        2, ' stereo
        6, ' 5.1 channel
        8 ' 7.1 channel
    ]
    transContainers = ["mp4", "hls", "mkv", "ism", "dash", "ts"]
    supportedVideoCodecs = {}
    supportedAudioCodecs = {}
    addH264Profile = false
    addHevcProfile = false
    addMpeg2Profile = false
    addAv1Profile = false
    addVp9Profile = false

    ' AVC / h264
    h264Profiles = ["main", "high"]
    h264Levels = ["4.1", "4.2"]

    for each container in transContainers
        for each profile in h264Profiles
            for each level in h264Levels
                if di.CanDecodeVideo({ Codec: "h264", Container: container, Profile: profile, Level: level }).Result
                    addH264Profile = true
                    if supportedVideoCodecs[container] = invalid
                        supportedVideoCodecs[container] = {}
                    end if
                    if supportedVideoCodecs[container]["h264"] = invalid
                        supportedVideoCodecs[container]["h264"] = {}
                    end if
                    if supportedVideoCodecs[container]["h264"][profile] = invalid
                        supportedVideoCodecs[container]["h264"][profile] = []
                    end if
                    supportedVideoCodecs[container]["h264"][profile].push(level)
                end if
            end for
        end for
    end for

    ' HEVC / h265
    hevcProfiles = ["main", "main 10"]
    hevcLevels = ["4.1", "5.0", "5.1"]

    for each container in transContainers
        for each profile in hevcProfiles
            for each level in hevcLevels
                if di.CanDecodeVideo({ Codec: "hevc", Container: container, Profile: profile, Level: level }).Result
                    addHevcProfile = true
                    ' hevc codec string
                    if supportedVideoCodecs[container] = invalid
                        supportedVideoCodecs[container] = {}
                    end if
                    if supportedVideoCodecs[container]["hevc"] = invalid
                        supportedVideoCodecs[container]["hevc"] = {}
                    end if
                    if supportedVideoCodecs[container]["hevc"][profile] = invalid
                        supportedVideoCodecs[container]["hevc"][profile] = []
                    end if
                    supportedVideoCodecs[container]["hevc"][profile].push(level)
                    ' h265 codec string
                    if supportedVideoCodecs[container] = invalid
                        supportedVideoCodecs[container] = {}
                    end if
                    if supportedVideoCodecs[container]["h265"] = invalid
                        supportedVideoCodecs[container]["h265"] = {}
                    end if
                    if supportedVideoCodecs[container]["h265"][profile] = invalid
                        supportedVideoCodecs[container]["h265"][profile] = []
                    end if
                    supportedVideoCodecs[container]["h265"][profile].push(level)
                end if
            end for
        end for
    end for

    ' MPEG2
    mpeg2Levels = ["main", "high"]
    if playMpeg2
        for each container in transContainers
            for each level in mpeg2Levels
                if di.CanDecodeVideo({ Codec: "mpeg2", Container: container, Level: level }).Result
                    addMpeg2Profile = true
                    if supportedVideoCodecs[container] = invalid
                        supportedVideoCodecs[container] = {}
                    end if
                    if supportedVideoCodecs[container]["mpeg2"] = invalid
                        supportedVideoCodecs[container]["mpeg2"] = []
                    end if
                    supportedVideoCodecs[container]["mpeg2"].push(level)
                end if
            end for
        end for
    end if

    ' AV1
    av1Profiles = ["main", "main 10"]
    av1Levels = ["4.1", "5.0", "5.1"]
    if playAv1
        for each container in transContainers
            for each profile in av1Profiles
                for each level in av1Levels
                    if di.CanDecodeVideo({ Codec: "av1", Container: container, Profile: profile, Level: level }).Result
                        addAv1Profile = true
                        ' av1 codec string
                        if supportedVideoCodecs[container] = invalid
                            supportedVideoCodecs[container] = {}
                        end if
                        if supportedVideoCodecs[container]["av1"] = invalid
                            supportedVideoCodecs[container]["av1"] = {}
                        end if
                        if supportedVideoCodecs[container]["av1"][profile] = invalid
                            supportedVideoCodecs[container]["av1"][profile] = []
                        end if
                        supportedVideoCodecs[container]["av1"][profile].push(level)
                    end if
                end for
            end for
        end for
    end if

    ' VP9
    vp9Profiles = ["profile 0", "profile 2"]

    for each container in transContainers
        for each profile in vp9Profiles
            if di.CanDecodeVideo({ Codec: "vp9", Container: container, Profile: profile }).Result
                addVp9Profile = true
                ' vp9 codec string
                if supportedVideoCodecs[container] = invalid
                    supportedVideoCodecs[container] = {}
                end if
                if supportedVideoCodecs[container]["vp9"] = invalid
                    supportedVideoCodecs[container]["vp9"] = []
                end if
                supportedVideoCodecs[container]["vp9"].push(profile)
            end if
        end for
    end for

    ' eac3
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "eac3", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["eac3"] = invalid or audioChannel > supportedAudioCodecs[container]["eac3"]
                    supportedAudioCodecs[container]["eac3"] = audioChannel
                end if
            end if
        end for
    end for


    ' ac3
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "ac3", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["ac3"] = invalid or audioChannel > supportedAudioCodecs[container]["ac3"]
                    supportedAudioCodecs[container]["ac3"] = audioChannel
                end if
            end if
        end for
    end for

    ' dts
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "dts", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["dts"] = invalid or audioChannel > supportedAudioCodecs[container]["dts"]
                    supportedAudioCodecs[container]["dts"] = audioChannel
                end if
            end if
        end for
    end for

    ' opus
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "opus", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["opus"] = invalid or audioChannel > supportedAudioCodecs[container]["opus"]
                    supportedAudioCodecs[container]["opus"] = audioChannel
                end if
            end if
        end for
    end for

    ' flac
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "flac", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["flac"] = invalid or audioChannel > supportedAudioCodecs[container]["flac"]
                    supportedAudioCodecs[container]["flac"] = audioChannel
                end if
            end if
        end for
    end for

    ' vorbis
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "vorbis", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["vorbis"] = invalid or audioChannel > supportedAudioCodecs[container]["vorbis"]
                    supportedAudioCodecs[container]["vorbis"] = audioChannel
                end if
            end if
        end for
    end for

    ' aac
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "aac", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["aac"] = invalid or audioChannel > supportedAudioCodecs[container]["aac"]
                    supportedAudioCodecs[container]["aac"] = audioChannel
                end if
            end if
        end for
    end for

    ' mp3
    for each container in transContainers
        for each audioChannel in audioChannelIntegers
            if di.CanDecodeAudio({ Codec: "mp3", Container: container, ChCnt: audioChannel }).result
                if supportedAudioCodecs[container] = invalid
                    supportedAudioCodecs[container] = {}
                end if

                if supportedAudioCodecs[container]["mp3"] = invalid or audioChannel > supportedAudioCodecs[container]["mp3"]
                    supportedAudioCodecs[container]["mp3"] = audioChannel
                end if
            end if
        end for
    end for

    hevcVideoRangeTypes = "SDR"
    vp9VideoRangeTypes = "SDR"
    av1VideoRangeTypes = "SDR"

    dp = di.GetDisplayProperties()
    if dp.Hdr10 ' or dp.Hdr10Plus?
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|HDR10"
        vp9VideoRangeTypes = vp9VideoRangeTypes + "|HDR10"
        av1VideoRangeTypes = av1VideoRangeTypes + "|HDR10"
    end if
    if dp.HLG
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|HLG"
        vp9VideoRangeTypes = vp9VideoRangeTypes + "|HLG"
        av1VideoRangeTypes = av1VideoRangeTypes + "|HLG"
    end if
    if dp.DolbyVision
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|DOVI"
        'vp9VideoRangeTypes = vp9VideoRangeTypes + ",DOVI" no evidence that vp9 can hold DOVI
        av1VideoRangeTypes = av1VideoRangeTypes + "|DOVI"
    end if

    DirectPlayProfile = GetDirectPlayProfiles()

    deviceProfile = {
        "MaxStreamingBitrate": 120000000,
        "MaxStaticBitrate": 100000000,
        "MusicStreamingTranscodingBitrate": 192000,
        "DirectPlayProfiles": DirectPlayProfile,
        "TranscodingProfiles": [],
        "ContainerProfiles": [],
        "CodecProfiles": [
            {
                "Type": "VideoAudio",
                "Codec": DirectPlayProfile[1].AudioCodec, ' Use supported MKV Audio list
                "Conditions": [
                    {
                        "Condition": "LessThanEqual",
                        "Property": "AudioChannels",
                        "Value": supportedAudioCodecs["mkv"]["flac"].ToStr(),
                        "IsRequired": false
                    }
                ]
            }
        ],
        "SubtitleProfiles": [
            {
                "Format": "vtt",
                "Method": "External"
            },
            {
                "Format": "srt",
                "Method": "External"
            },
            {
                "Format": "ttml",
                "Method": "External"
            },
            {
                "Format": "sub",
                "Method": "External"
            }
        ]
    }

    ' build TranscodingProfiles
    ' create an audio profile for each audio codec supported by the mp4 container
    for each supportedMp4AudioCodec in supportedAudioCodecs["mp4"]
        ' streaming
        deviceProfile.TranscodingProfiles.push({
            "Container": supportedMp4AudioCodec,
            "Type": "Audio",
            "AudioCodec": supportedMp4AudioCodec,
            "Context": "Streaming",
            "Protocol": "http",
            "MaxAudioChannels": supportedAudioCodecs["mp4"][supportedMp4AudioCodec].ToStr()
        })
        ' static
        deviceProfile.TranscodingProfiles.push({
            "Container": supportedMp4AudioCodec,
            "Type": "Audio",
            "AudioCodec": supportedMp4AudioCodec,
            "Context": "Static",
            "Protocol": "http",
            "MaxAudioChannels": supportedAudioCodecs["mp4"][supportedMp4AudioCodec].ToStr()
        })
    end for
    ' create a video profile for each container in transContainers
    for each container in transContainers
        audioCodecs = []
        videoCodecs = []
        for each codec in supportedAudioCodecs[container]
            audioCodecs.push(codec)
        end for
        for each codec in supportedVideoCodecs[container]
            videoCodecs.push(codec)
        end for
        containerArray = {
            "Container": container,
            "Context": "Static",
            "Type": "Video",
            "AudioCodec": audioCodecs.join(","),
            "VideoCodec": videoCodecs.join(",")
        }
        ' grab max audio channels based on container
        ' order of priority: ac3, aac
        if supportedAudioCodecs[container]["ac3"] <> invalid
            containerArray["MaxAudioChannels"] = supportedAudioCodecs[container]["ac3"].ToStr()
        else
            containerArray["MaxAudioChannels"] = supportedAudioCodecs[container]["aac"].ToStr()
        end if

        if container = "ts"
            containerArray["Context"] = "Streaming"
            containerArray["Protocol"] = "hls"
            containerArray["MinSegments"] = "1"
            containerArray["BreakOnNonKeyFrames"] = true
        else if container = "mp4"
            containerArray["Context"] = "Static"
            containerArray["Protocol"] = "http"
        end if
        deviceProfile.TranscodingProfiles.push(containerArray)
    end for

    ' build CodecProfiles
    if addH264Profile
        ' determine highest level supported
        h264HighestLevel = 0
        for each profile in h264Profiles
            for each level in supportedVideoCodecs["ts"]["h264"][profile]
                levelFloat = level.ToFloat()
                if levelFloat > h264HighestLevel
                    h264HighestLevel = levelFloat
                end if
            end for
        end for

        videoProfiles = []
        for each container in transContainers
            if supportedVideoCodecs[container]["h264"] <> invalid
                for each profile in supportedVideoCodecs[container]["h264"]
                    videoProfiles.push(profile)
                end for
                exit for
            end if
        end for

        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "h264",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": videoProfiles.join("|"),
                    "IsRequired": false
                },
                {
                    "Condition": "LessThanEqual",
                    "Property": "VideoLevel",
                    "Value": (120 * h264HighestLevel).ToStr(),
                    "IsRequired": false
                },
                GetBitRateLimit("h264")
            ]
        })
    end if
    if addMpeg2Profile
        mpeg2Levels = []
        for each container in transContainers
            if supportedVideoCodecs[container] <> invalid
                if supportedVideoCodecs[container]["mpeg2"] <> invalid
                    for each level in supportedVideoCodecs[container]["mpeg2"]
                        mpeg2Levels.push(level)
                    end for
                    if mpeg2Levels.count > 0 then exit for
                end if
            end if
        end for
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "mpeg2",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoLevel",
                    "Value": mpeg2Levels.join("|"),
                    "IsRequired": false
                },
                GetBitRateLimit("mpeg2")
            ]
        })
    end if

    if addAv1Profile
        ' determine highest level supported
        av1HighestLevel = 0.0
        for each profile in av1Profiles
            for each level in supportedVideoCodecs["ts"]["av1"][profile]
                if level.ToFloat() > av1HighestLevel.ToFloat()
                    h264HighestLevel = level
                end if
            end for
        end for

        videoProfiles = []
        for each container in transContainers
            if supportedVideoCodecs[container]["av1"] <> invalid
                for each profile in supportedVideoCodecs[container]["av1"]
                    videoProfiles.push(profile)
                end for
                exit for
            end if
        end for

        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "av1",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": videoProfiles.join("|"),
                    "IsRequired": false
                },
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoRangeType",
                    "Value": av1VideoRangeTypes,
                    "IsRequired": false
                },
                {
                    "Condition": "LessThanEqual",
                    "Property": "VideoLevel",
                    "Value": (120 * av1HighestLevel).ToStr(),
                    "IsRequired": false
                },
                GetBitRateLimit("AV1")
            ]
        })
    end if

    if addHevcProfile
        ' determine highest level supported
        hevcHighestLevel = 0.0
        for each profile in hevcProfiles
            for each level in supportedVideoCodecs["ts"]["hevc"][profile]
                levelFloat = level.ToFloat()
                if levelFloat > hevcHighestLevel
                    hevcHighestLevel = levelFloat
                end if
            end for
        end for

        videoProfiles = []
        for each container in transContainers
            if supportedVideoCodecs[container]["hevc"] <> invalid
                for each profile in supportedVideoCodecs[container]["hevc"]
                    videoProfiles.push(profile)
                end for
                exit for
            end if
        end for

        ' use ts container codecs
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "hevc",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": videoProfiles.join("|"),
                    "IsRequired": false
                },
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoRangeType",
                    "Value": hevcVideoRangeTypes,
                    "IsRequired": false
                },
                {
                    "Condition": "LessThanEqual",
                    "Property": "VideoLevel",
                    "Value": (120 * hevcHighestLevel).ToStr(),
                    "IsRequired": false
                },
                GetBitRateLimit("H265")
            ]
        })
    end if

    if addVp9Profile
        videoProfiles = []
        for each container in transContainers
            if supportedVideoCodecs[container]["vp9"] <> invalid
                for each profile in supportedVideoCodecs[container]["vp9"]
                    videoProfiles.push(profile)
                end for
                exit for
            end if
        end for

        ' use ts container codecs
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "vp9",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": videoProfiles.join("|"),
                    "IsRequired": false
                },
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoRangeType",
                    "Value": vp9VideoRangeTypes,
                    "IsRequired": false
                },
                GetBitRateLimit("vp9")
            ]
        })
    end if

    return deviceProfile
end function


function GetDirectPlayProfiles() as object
    di = CreateObject("roDeviceInfo")
    ' all possible containers
    supportedCodecs = {
        mp4: {
            audio: [],
            video: []
        },
        hls: {
            audio: [],
            video: []
        },
        mkv: {
            audio: [],
            video: []
        },
        ism: {
            audio: [],
            video: []
        },
        dash: {
            audio: [],
            video: []
        },
        ts: {
            audio: [],
            video: []
        }
    }
    ' all possible codecs
    videoCodecs = ["h264", "vp8", "hevc", "vp9"]
    audioCodecs = ["mp3", "pcm", "lpcm", "wav", "ac3", "wma", "flac", "alac", "aac", "opus", "dts", "wmapro", "vorbis", "eac3"]
    ' respect user settings
    if m.global.session.user.settings["playback.mpeg4"]
        videoCodecs.push("mpeg4")
    end if
    if m.global.session.user.settings["playback.mpeg2"]
        videoCodecs.push("mpeg2")
    end if
    ' check video codecs for each container
    for each container in supportedCodecs
        for each videoCodec in videoCodecs
            if di.CanDecodeVideo({ Codec: videoCodec, Container: container }).Result
                if videoCodec = "hevc"
                    supportedCodecs[container]["video"].push("hevc")
                    supportedCodecs[container]["video"].push("h265")
                else if videoCodec = "mpeg2"
                    supportedCodecs[container]["video"].push("mpeg2video")
                else
                    ' device profile string matches codec string
                    supportedCodecs[container]["video"].push(videoCodec)
                end if
            end if
        end for
    end for
    ' check audio codecs for each container
    for each container in supportedCodecs
        for each audioCodec in audioCodecs
            if di.CanDecodeAudio({ Codec: audioCodec, Container: container }).Result
                supportedCodecs[container]["audio"].push(audioCodec)
            end if
        end for
    end for
    ' check audio codecs with no container
    supportedAudio = []
    for each audioCodec in audioCodecs
        if di.CanDecodeAudio({ Codec: audioCodec }).Result
            supportedAudio.push(audioCodec)
        end if
    end for
    ' build return array
    returnArray = []

    for each container in supportedCodecs
        videoCodecString = supportedCodecs[container]["video"].Join(",")
        if videoCodecString <> ""
            containerString = ""
            if container = "mp4"
                containerString = "mp4,mov,m4v"
            else if container = "mkv"
                containerString = "mkv,webm"
            else
                containerString = container
            end if
            returnArray.push({
                "Container": containerString,
                "Type": "Video",
                "VideoCodec": videoCodecString,
                "AudioCodec": supportedCodecs[container]["audio"].Join(",")
            })
        end if
    end for

    returnArray.push({
        "Container": supportedAudio.Join(","),
        "Type": "Audio"
    })
    return returnArray
end function

function GetBitRateLimit(codec as string) as object
    if m.global.session.user.settings["playback.bitrate.maxlimited"] = true
        userSetLimit = m.global.session.user.settings["playback.bitrate.limit"]
        userSetLimit *= 1000000

        if userSetLimit > 0
            return {
                "Condition": "LessThanEqual",
                "Property": "VideoBitrate",
                "Value": userSetLimit.ToStr(),
                "IsRequired": true
            }
        else
            codec = Lcase(codec)
            ' Some repeated values (e.g. same "40mbps" for several codecs)
            ' but this makes it easy to update in the future if the bitrates start to deviate.
            if codec = "h264"
                ' Roku only supports h264 up to 10Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "10000000",
                    "IsRequired": true
                }
            else if codec = "av1"
                ' Roku only supports AV1 up to 40Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "40000000",
                    "IsRequired": true
                }
            else if codec = "h265"
                ' Roku only supports h265 up to 40Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "40000000",
                    "IsRequired": true
                }
            else if codec = "vp9"
                ' Roku only supports VP9 up to 40Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "40000000",
                    "IsRequired": true
                }
            end if
        end if
    end if
    return {}
end function
