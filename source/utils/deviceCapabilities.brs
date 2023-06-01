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
        "SupportsPersistentIdentifier": true,
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
    playMpeg2 = get_user_setting("playback.mpeg2") = "true"
    playAv1 = get_user_setting("playback.av1") = "true"
    di = CreateObject("roDeviceInfo")

    maxAudioChannels = "2" ' Currently Jellyfin server expects this as a string
    tsVideoCodecs = "h264"
    tsAudioCodecs = "aac"

    'Check if 5.1 Audio Output connected
    if di.GetAudioOutputChannel() = "5.1 surround"
        maxAudioChannels = "6"
    end if

    ' HEVC
    addHevcProfile = false
    hevcProfileString = ""
    hevcHighestLevel = 4.1

    if di.CanDecodeVideo({ Codec: "hevc", Container: "ts" }).Result = true
        tsVideoCodecs = "h265,hevc," + tsVideoCodecs
        addHevcProfile = true

        hevcProfiles = ["main", "main 10"]
        hevcLevels = ["4.1", "5.0", "5.1"]
        supportArray = {}

        for each profile in hevcProfiles
            for each level in hevcLevels
                if di.CanDecodeVideo({ Codec: "hevc", Container: "ts", Profile: profile, Level: level }).Result
                    if supportArray[profile] = invalid
                        supportArray[profile] = []
                        if hevcProfileString = ""
                            hevcProfileString = profile
                        else
                            hevcProfileString = hevcProfileString + "|" + profile
                        end if
                    end if

                    supportArray[profile].Push(level)
                end if
            end for
        end for

        for each prof in supportArray
            highestLevelString = supportArray[prof].Pop()
            if highestLevelString = "5"
                hevcHighestLevel = 5
            end if
            if highestLevelString = "5.1"
                hevcHighestLevel = 5.1
            end if
        end for
    end if

    ' MPEG2
    addMpeg2Profile = false
    mpeg2LevelString = ""
    if playMpeg2 and di.CanDecodeVideo({ Codec: "mpeg2", Container: "ts" }).Result = true
        tsVideoCodecs = tsVideoCodecs + ",mpeg2video"
        addMpeg2Profile = true

        mpeg2Levels = ["main", "high"]

        for each level in mpeg2Levels
            if di.CanDecodeVideo({ Codec: "mpeg2", Container: "ts", Level: level }).Result
                if mpeg2LevelString = ""
                    mpeg2LevelString = level
                else
                    mpeg2LevelString = mpeg2LevelString + "|" + level
                end if
            end if
        end for
    end if

    if di.CanDecodeAudio({ Codec: "mp3", Container: "ts" }).result
        tsAudioCodecs = tsAudioCodecs + ",mp3"
    end if

    if di.CanDecodeAudio({ Codec: "dts", Container: "ts" }).result
        tsAudioCodecs = "dts," + tsAudioCodecs
    end if

    if di.CanDecodeAudio({ Codec: "ac3", Container: "ts" }).result
        tsAudioCodecs = "ac3," + tsAudioCodecs
    end if

    ' prefer eac3 over all other audio codecs
    if di.CanDecodeAudio({ Codec: "eac3", Container: "ts" }).result
        tsAudioCodecs = "eac3," + tsAudioCodecs
    end if

    addAv1Profile = false
    if playAv1 and di.CanDecodeVideo({ Codec: "av1", Container: "ts" }).result
        tsVideoCodecs = tsVideoCodecs + ",av1"
        addAv1Profile = true
    end if

    addVp9Profile = false
    if di.CanDecodeVideo({ Codec: "vp9", Container: "ts" }).result
        tsVideoCodecs = tsVideoCodecs + ",vp9"
        addVp9Profile = true
    end if

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
        "TranscodingProfiles": [
            {
                "Container": "aac",
                "Type": "Audio",
                "AudioCodec": "aac",
                "Context": "Streaming",
                "Protocol": "http",
                "MaxAudioChannels": maxAudioChannels
            },
            {
                "Container": "mp3",
                "Type": "Audio",
                "AudioCodec": "mp3",
                "Context": "Streaming",
                "Protocol": "http",
                "MaxAudioChannels": "2"
            },
            {
                "Container": "mp3",
                "Type": "Audio",
                "AudioCodec": "mp3",
                "Context": "Static",
                "Protocol": "http",
                "MaxAudioChannels": "2"
            },
            {
                "Container": "aac",
                "Type": "Audio",
                "AudioCodec": "aac",
                "Context": "Static",
                "Protocol": "http",
                "MaxAudioChannels": maxAudioChannels
            },
            {
                "Container": "ts",
                "Type": "Video",
                "AudioCodec": tsAudioCodecs,
                "VideoCodec": tsVideoCodecs,
                "Context": "Streaming",
                "Protocol": "hls",
                "MaxAudioChannels": maxAudioChannels,
                "MinSegments": "1",
                "BreakOnNonKeyFrames": true
            },
            {
                "Container": "mp4",
                "Type": "Video",
                "AudioCodec": "aac,opus,flac,vorbis",
                "VideoCodec": "h264",
                "Context": "Static",
                "Protocol": "http"
            }
        ],
        "ContainerProfiles": [],
        "CodecProfiles": [
            {
                "Type": "VideoAudio",
                "Codec": DirectPlayProfile[1].AudioCodec, ' Use supported MKV Audio list
                "Conditions": [
                    {
                        "Condition": "LessThanEqual",
                        "Property": "AudioChannels",
                        "Value": maxAudioChannels,
                        "IsRequired": false
                    }
                ]
            },
            {
                "Type": "Video",
                "Codec": "h264",
                "Conditions": [
                    {
                        "Condition": "EqualsAny",
                        "Property": "VideoProfile",
                        "Value": "high|main",
                        "IsRequired": false
                    },
                    {
                        "Condition": "LessThanEqual",
                        "Property": "VideoLevel",
                        "Value": "41",
                        "IsRequired": false
                    },
                    GetBitRateLimit("H264")
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
    if addMpeg2Profile
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "mpeg2",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoLevel",
                    "Value": mpeg2LevelString,
                    "IsRequired": false
                }
            ]
        })
    end if
    if addAv1Profile
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "av1",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoRangeType",
                    "Value": av1VideoRangeTypes,
                    "IsRequired": false
                },
                GetBitRateLimit("AV1")
            ]
        })
    end if
    if addHevcProfile
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "hevc",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": hevcProfileString,
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
        deviceProfile.CodecProfiles.push({
            "Type": "Video",
            "Codec": "vp9",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoRangeType",
                    "Value": vp9VideoRangeTypes,
                    "IsRequired": false
                },
                GetBitRateLimit("VP9")
            ]
        })
    end if

    return deviceProfile
end function


function GetDirectPlayProfiles() as object

    mp4Video = "h264"
    mp4Audio = "mp3,pcm,lpcm,wav"
    mkvVideo = "h264,vp8"
    mkvAudio = "mp3,pcm,lpcm,wav"
    audio = "mp3,pcm,lpcm,wav"

    playMpeg2 = get_user_setting("playback.mpeg2") = "true"

    di = CreateObject("roDeviceInfo")

    'Check for Supported Video Codecs
    if di.CanDecodeVideo({ Codec: "hevc" }).Result = true
        mp4Video = mp4Video + ",h265,hevc"
        mkvVideo = mkvVideo + ",h265,hevc"
    end if

    if di.CanDecodeVideo({ Codec: "vp9" }).Result = true
        mkvVideo = mkvVideo + ",vp9"
    end if

    if playMpeg2 and di.CanDecodeVideo({ Codec: "mpeg2" }).Result = true
        mp4Video = mp4Video + ",mpeg2video"
        mkvVideo = mkvVideo + ",mpeg2video"
    end if

    if get_user_setting("playback.mpeg4") = "true"
        mp4Video = mp4Video + ",mpeg4"
    end if

    ' Check for supported Audio
    if di.CanDecodeAudio({ Codec: "ac3" }).result
        mkvAudio = mkvAudio + ",ac3"
        mp4Audio = mp4Audio + ",ac3"
        audio = audio + ",ac3"
    end if

    if di.CanDecodeAudio({ Codec: "wma" }).result
        audio = audio + ",wma"
    end if

    if di.CanDecodeAudio({ Codec: "flac" }).result
        mkvAudio = mkvAudio + ",flac"
        audio = audio + ",flac"
    end if

    if di.CanDecodeAudio({ Codec: "alac" }).result
        mkvAudio = mkvAudio + ",alac"
        mp4Audio = mp4Audio + ",alac"
        audio = audio + ",alac"
    end if

    if di.CanDecodeAudio({ Codec: "aac" }).result
        mkvAudio = mkvAudio + ",aac"
        mp4Audio = mp4Audio + ",aac"
        audio = audio + ",aac"
    end if

    if di.CanDecodeAudio({ Codec: "opus" }).result
        mkvAudio = mkvAudio + ",opus"
    end if

    if di.CanDecodeAudio({ Codec: "dts" }).result
        mkvAudio = mkvAudio + ",dts"
        audio = audio + ",dts"
    end if

    if di.CanDecodeAudio({ Codec: "wmapro" }).result
        audio = audio + ",wmapro"
    end if

    if di.CanDecodeAudio({ Codec: "vorbis" }).result
        mkvAudio = mkvAudio + ",vorbis"
    end if

    if di.CanDecodeAudio({ Codec: "eac3" }).result
        mkvAudio = mkvAudio + ",eac3"
        mp4Audio = mp4Audio + ",eac3"
        audio = audio + ",eac3"
    end if

    return [
        {
            "Container": "mp4,m4v,mov",
            "Type": "Video",
            "VideoCodec": mp4Video,
            "AudioCodec": mp4Audio
        },
        {
            "Container": "mkv,webm",
            "Type": "Video",
            "VideoCodec": mkvVideo,
            "AudioCodec": mkvAudio
        },
        {
            "Container": audio,
            "Type": "Audio"
        }
    ]

end function

function GetBitRateLimit(codec as string)
    if get_user_setting("playback.bitrate.maxlimited") = "true"
        userSetLimit = get_user_setting("playback.bitrate.limit").ToInt()
        userSetLimit *= 1000000

        if userSetLimit > 0
            return {
                "Condition": "LessThanEqual",
                "Property": "VideoBitrate",
                "Value": userSetLimit.ToStr(),
                "IsRequired": true
            }
        else
            ' Some repeated values (e.g. same "40mbps" for several codecs)
            ' but this makes it easy to update in the future if the bitrates start to deviate.
            if codec = "H264"
                ' Roku only supports h264 up to 10Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "10000000",
                    "IsRequired": true
                }
            else if codec = "AV1"
                ' Roku only supports AV1 up to 40Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "40000000",
                    "IsRequired": true
                }
            else if codec = "H265"
                ' Roku only supports h265 up to 40Mpbs
                return {
                    "Condition": "LessThanEqual",
                    "Property": "VideoBitrate",
                    "Value": "40000000",
                    "IsRequired": true
                }
            else if codec = "VP9"
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
