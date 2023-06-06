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

    ' TRANSCODING
    ' use strings to preserve order
    mp4AudioCodecs = "aac"
    mp4VideoCodecs = "h264"
    tsAudioCodecs = "aac"
    tsVideoCodecs = "h264"
    ' profileSupport["mp4"]["hevc"]["profile name"]["profile level"]
    profileSupport = {
        mp4: {},
        ts: {}
    }


    ' does the users setup support surround sound?
    maxAudioChannels = "2" ' jellyfin expects this as a string
    ' in order of preference from left to right
    ' aac will be highest priority unless surroundSoundCodec <> "aac"
    audioCodecs = ["mp3", "vorbis", "opus", "flac", "alac", "ac4", "pcm", "wma", "wmapro"]
    surroundSoundCodecs = ["aac", "eac3", "ac3", "vorbis", "dts"]
    surroundSoundCodec = invalid
    if di.GetAudioOutputChannel() = "5.1 surround"
        maxAudioChannels = "6"
        for each codec in surroundSoundCodecs
            if di.CanDecodeAudio({ Codec: codec, ChCnt: 6 }).Result
                surroundSoundCodec = codec
                if di.CanDecodeAudio({ Codec: codec, ChCnt: 8 }).Result
                    maxAudioChannels = "8"
                end if
                exit for
            end if
        end for
    end if

    ' VIDEO CODECS
    '
    ' AVC / h264 / MPEG4 AVC
    h264Profiles = ["main", "high"]
    h264Levels = ["4.1", "4.2"]
    for each container in profileSupport
        for each profile in h264Profiles
            for each level in h264Levels
                if di.CanDecodeVideo({ Codec: "h264", Container: container, Profile: profile, Level: level }).Result
                    profileSupport[container] = updateProfileArray(profileSupport[container], "h264", profile, level)
                end if
                if di.CanDecodeVideo({ Codec: "mpeg4 avc", Container: container, Profile: profile, Level: level }).Result
                    profileSupport[container] = updateProfileArray(profileSupport[container], "mpeg4 avc", profile, level)
                    if container = "mp4"
                        ' check for codec string before adding it
                        if mp4VideoCodecs.Instr(0, ",mpeg4 avc") = -1
                            mp4VideoCodecs = mp4VideoCodecs + ",mpeg4 avc"
                        end if
                    else if container = "ts"
                        ' check for codec string before adding it
                        if tsVideoCodecs.Instr(0, ",mpeg4 avc") = -1
                            tsVideoCodecs = tsVideoCodecs + ",mpeg4 avc"
                        end if
                    end if
                end if
            end for
        end for
    end for

    ' HEVC / h265
    hevcProfiles = ["main", "main 10"]
    hevcLevels = ["4.1", "5.0", "5.1"]
    addHevc = false
    for each container in profileSupport
        for each profile in hevcProfiles
            for each level in hevcLevels
                if di.CanDecodeVideo({ Codec: "hevc", Container: container, Profile: profile, Level: level }).Result
                    addHevc = true
                    profileSupport[container] = updateProfileArray(profileSupport[container], "hevc", profile, level)
                    profileSupport[container] = updateProfileArray(profileSupport[container], "h265", profile, level)
                    if container = "mp4"
                        ' check for codec string before adding it
                        if mp4VideoCodecs.Instr(0, "h265,") = -1
                            mp4VideoCodecs = "h265," + mp4VideoCodecs
                        end if
                        if mp4VideoCodecs.Instr(0, "hevc,") = -1
                            mp4VideoCodecs = "hevc," + mp4VideoCodecs
                        end if
                    else if container = "ts"
                        ' check for codec string before adding it
                        if tsVideoCodecs.Instr(0, "h265,") = -1
                            tsVideoCodecs = "h265," + tsVideoCodecs
                        end if
                        if tsVideoCodecs.Instr(0, "hevc,") = -1
                            tsVideoCodecs = "hevc," + tsVideoCodecs
                        end if
                    end if
                end if
            end for
        end for
    end for

    ' VP9
    vp9Profiles = ["profile 0", "profile 2"]
    addVp9 = false
    for each container in profileSupport
        for each profile in vp9Profiles
            if di.CanDecodeAudio({ Codec: "vp9", Container: container, Profile: profile }).Result
                addVp9 = true
                profileSupport[container] = updateProfileArray(profileSupport[container], "vp9", profile)

                if container = "mp4"
                    ' check for codec string before adding it
                    if mp4VideoCodecs.Instr(0, ",vp9") = -1
                        mp4VideoCodecs = mp4VideoCodecs + ",vp9"
                    end if
                else if container = "ts"
                    ' check for codec string before adding it
                    if tsVideoCodecs.Instr(0, ",vp9") = -1
                        tsVideoCodecs = tsVideoCodecs + ",vp9"
                    end if
                end if
            end if
        end for
    end for

    ' MPEG2
    mpeg2Profiles = ["main", "high"]
    addMpeg2 = false
    if playMpeg2
        for each container in profileSupport
            for each profile in mpeg2Profiles
                if di.CanDecodeVideo({ Codec: "mpeg2", Container: container, Profile: profile }).Result
                    addMpeg2 = true
                    profileSupport[container] = updateProfileArray(profileSupport[container], "mpeg2", profile)
                    if container = "mp4"
                        ' check for codec string before adding it
                        if mp4VideoCodecs.Instr(0, ",mpeg2video") = -1
                            mp4VideoCodecs = mp4VideoCodecs + ",mpeg2video"
                        end if
                    else if container = "ts"
                        ' check for codec string before adding it
                        if tsVideoCodecs.Instr(0, ",mpeg2video") = -1
                            tsVideoCodecs = tsVideoCodecs + ",mpeg2video"
                        end if
                    end if
                end if
            end for
        end for
    end if

    ' AV1
    av1Profiles = ["main", "main 10"]
    av1Levels = ["4.1", "5.0", "5.1"]
    addAv1 = false
    if playAv1
        for each container in profileSupport
            for each profile in av1Profiles
                for each level in av1Levels
                    if di.CanDecodeVideo({ Codec: "av1", Container: container, Profile: profile, Level: level }).Result
                        addAv1 = true
                        profileSupport[container] = updateProfileArray(profileSupport[container], "av1", profile, level)
                        if container = "mp4"
                            ' check for codec string before adding it
                            if mp4VideoCodecs.Instr(0, ",av1") = -1
                                mp4VideoCodecs = mp4VideoCodecs + ",av1"
                            end if
                        else if container = "ts"
                            ' check for codec string before adding it
                            if tsVideoCodecs.Instr(0, ",av1") = -1
                                tsVideoCodecs = tsVideoCodecs + ",av1"
                            end if
                        end if
                    end if
                end for
            end for
        end for
    end if

    ' AUDIO CODECS
    for each container in profileSupport
        for each codec in audioCodecs
            if di.CanDecodeAudio({ Codec: codec, Container: container }).result
                if container = "mp4"
                    ' check for codec string before adding it
                    if mp4VideoCodecs.Instr(0, "," + codec) = -1
                        mp4AudioCodecs = mp4AudioCodecs + "," + codec
                    end if
                else if container = "ts"
                    ' check for codec string before adding it
                    if tsAudioCodecs.Instr(0, "," + codec) = -1
                        tsAudioCodecs = tsAudioCodecs + "," + codec
                    end if
                end if
            end if
        end for
    end for

    ' HDR SUPPORT
    h264VideoRangeTypes = "SDR"
    hevcVideoRangeTypes = "SDR"
    vp9VideoRangeTypes = "SDR"
    av1VideoRangeTypes = "SDR"

    dp = di.GetDisplayProperties()
    if dp.Hdr10
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|HDR10"
        vp9VideoRangeTypes = vp9VideoRangeTypes + "|HDR10"
        av1VideoRangeTypes = av1VideoRangeTypes + "|HDR10"
    end if
    if dp.Hdr10Plus
        av1VideoRangeTypes = av1VideoRangeTypes + "|HDR10+"
    end if
    if dp.HLG
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|HLG"
        vp9VideoRangeTypes = vp9VideoRangeTypes + "|HLG"
        av1VideoRangeTypes = av1VideoRangeTypes + "|HLG"
    end if
    if dp.DolbyVision
        h264VideoRangeTypes = hevcVideoRangeTypes + "|DOVI"
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
            ' {
            '     "Type": "VideoAudio",
            '     "Codec": DirectPlayProfile[1].AudioCodec, ' Use supported MKV Audio list
            '     "Conditions": [
            '         {
            '             "Condition": "LessThanEqual",
            '             "Property": "AudioChannels",
            '             "Value": maxAudioChannels,
            '             "IsRequired": false
            '         }
            '     ]
            ' }
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
    '
    for each audioCodec in mp4AudioCodecs.split(",")
        streamingArray = {
            "Container": audioCodec,
            "Type": "Audio",
            "AudioCodec": audioCodec,
            "Context": "Streaming",
            "Protocol": "http",
            "MaxAudioChannels": maxAudioChannels
        }
        staticArray = {
            "Container": audioCodec,
            "Type": "Audio",
            "AudioCodec": audioCodec,
            "Context": "Static",
            "Protocol": "http",
            "MaxAudioChannels": maxAudioChannels
        }

        ' use ts container for aac
        if audioCodec = "aac"
            if di.CanDecodeAudio({ Codec: audioCodec, Container: "ts", ChCnt: maxAudioChannels.trim().ToInt() }).result
                streamingArray["Container"] = "ts"
                staticArray["Container"] = "ts"

                deviceProfile.TranscodingProfiles.push(streamingArray)
                deviceProfile.TranscodingProfiles.push(staticArray)
            end if
        else
            ' use audioCodec as container for everything else
            if di.CanDecodeAudio({ Codec: audioCodec, Container: audioCodec, ChCnt: maxAudioChannels.trim().ToInt() }).result
                deviceProfile.TranscodingProfiles.push(streamingArray)
                deviceProfile.TranscodingProfiles.push(staticArray)
            end if
        end if
    end for


    tsArray = {
        "Container": "ts",
        "Context": "Streaming",
        "Protocol": "hls",
        "Type": "Video",
        "AudioCodec": tsAudioCodecs,
        "VideoCodec": tsVideoCodecs,
        "MaxAudioChannels": maxAudioChannels,
        "MinSegments": 1,
        "BreakOnNonKeyFrames": false
    }
    mp4Array = {
        "Container": "mp4",
        "Context": "Streaming",
        "Protocol": "hls",
        "Type": "Video",
        "AudioCodec": mp4AudioCodecs,
        "VideoCodec": mp4VideoCodecs,
        "MaxAudioChannels": maxAudioChannels,
        "MinSegments": 1,
        "BreakOnNonKeyFrames": false
    }

    ' surround sound
    ' move preferred surround sound codec to front of string
    if maxAudioChannels.ToInt() > 2
        ' search codec strings for our preferred codec
        tsCodecStringPosition = tsArray.AudioCodec.Instr(0, "," + surroundSoundCodec)
        mp4CodecStringPosition = mp4Array.AudioCodec.Instr(0, "," + surroundSoundCodec)

        if tsCodecStringPosition <> -1
            ' ts supports our prefered codec
            ' remove codec from string
            tsArray.AudioCodec.Replace("," + surroundSoundCodec, "")
            ' put codec in front of string
            tsArray.AudioCodec = surroundSoundCodec + "," + tsArray.AudioCodec
        end if
        if mp4CodecStringPosition <> -1
            ' mp4 supports our prefered codec
            ' remove codec from string
            mp4Array.AudioCodec.Replace("," + surroundSoundCodec, "")
            ' put codec in front of string
            mp4Array.AudioCodec = surroundSoundCodec + "," + mp4Array.AudioCodec
        end if
    end if

    deviceProfile.TranscodingProfiles.push(tsArray)
    deviceProfile.TranscodingProfiles.push(mp4Array)

    ' Build CodecProfiles
    '
    ' H264
    h264Mp4LevelSupported = 0.0
    h264TsLevelSupported = 0.0
    h264AssProfiles = {}
    h264LevelString = invalid
    for each container in profileSupport
        for each profile in profileSupport[container]["h264"]
            h264AssProfiles.AddReplace(profile, true)
            for each level in profileSupport[container]["h264"][profile]
                levelFloat = level.ToFloat()
                if container = "mp4"
                    if levelFloat > h264Mp4LevelSupported
                        h264Mp4LevelSupported = levelFloat
                    end if
                else if container = "ts"
                    if levelFloat > h264TsLevelSupported
                        h264TsLevelSupported = levelFloat
                    end if
                end if
            end for
        end for
    end for

    h264LevelString = h264Mp4LevelSupported
    if h264TsLevelSupported > h264Mp4LevelSupported
        h264LevelString = h264TsLevelSupported
    end if
    ' convert to string
    h264LevelString = h264LevelString.ToStr()
    ' remove decimals
    h264LevelString = removeDecimals(h264LevelString)


    codecProfileArray = {
        "Type": "Video",
        "Codec": "h264",
        "Conditions": [
            {
                "Condition": "NotEquals",
                "Property": "IsAnamorphic",
                "Value": "true",
                "IsRequired": false
            },
            {
                "Condition": "EqualsAny",
                "Property": "VideoProfile",
                "Value": h264AssProfiles.Keys().join("|"),
                "IsRequired": false
            },
            {
                "Condition": "EqualsAny",
                "Property": "VideoRangeType",
                "Value": h264VideoRangeTypes,
                "IsRequired": false
            },
            {
                "Condition": "LessThanEqual",
                "Property": "VideoLevel",
                "Value": h264LevelString,
                "IsRequired": false
            }
        ]
    }
    bitRateArray = GetBitRateLimit("h264")
    if bitRateArray.count() > 0
        codecProfileArray.Conditions.push(bitRateArray)
    end if
    deviceProfile.CodecProfiles.push(codecProfileArray)

    ' MPEG2
    if addMpeg2
        mpeg2Levels = []
        for each container in profileSupport
            for each level in profileSupport[container]["mpeg2"]
                if mpeg2Levels[level] = invalid
                    mpeg2Levels.push(level)
                end if
            end for
        end for

        codecProfileArray = {
            "Type": "Video",
            "Codec": "mpeg2",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoLevel",
                    "Value": mpeg2Levels.join("|"),
                    "IsRequired": false
                }
            ]
        }
        bitRateArray = GetBitRateLimit("mpeg2")
        if bitRateArray.count() > 0
            codecProfileArray.Conditions.push(bitRateArray)
        end if
        deviceProfile.CodecProfiles.push(codecProfileArray)
    end if

    if addAv1
        av1Mp4LevelSupported = 0.0
        av1TsLevelSupported = 0.0
        av1AssProfiles = []
        av1HighestLevel = 0.0
        for each container in profileSupport
            for each profile in profileSupport[container]["av1"]
                av1AssProfiles.AddReplace(profile, true)
                for each level in profileSupport[container]["av1"][profile]
                    levelFloat = level.ToFloat()
                    if container = "mp4"
                        if levelFloat > av1Mp4LevelSupported
                            av1Mp4LevelSupported = levelFloat
                        end if
                    else if container = "ts"
                        if levelFloat > av1TsLevelSupported
                            av1TsLevelSupported = levelFloat
                        end if
                    end if
                end for
            end for
        end for

        av1HighestLevel = av1Mp4LevelSupported
        if av1TsLevelSupported > av1Mp4LevelSupported
            av1HighestLevel = av1TsLevelSupported
        end if



        codecProfileArray = {
            "Type": "Video",
            "Codec": "av1",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": av1AssProfiles.Keys().join("|"),
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
                }
            ]
        }
        bitRateArray = GetBitRateLimit("av1")
        if bitRateArray.count() > 0
            codecProfileArray.Conditions.push(bitRateArray)
        end if
        deviceProfile.CodecProfiles.push(codecProfileArray)
    end if

    if addHevc
        hevcMp4LevelSupported = 0.0
        hevcTsLevelSupported = 0.0
        hevcAssProfiles = {}
        hevcHighestLevel = 0.0
        for each container in profileSupport
            for each profile in profileSupport[container]["hevc"]
                hevcAssProfiles.AddReplace(profile, true)
                for each level in profileSupport[container]["hevc"][profile]
                    levelFloat = level.ToFloat()
                    if container = "mp4"
                        if levelFloat > hevcMp4LevelSupported
                            hevcMp4LevelSupported = levelFloat
                        end if
                    else if container = "ts"
                        if levelFloat > hevcTsLevelSupported
                            hevcTsLevelSupported = levelFloat
                        end if
                    end if
                end for
            end for
        end for

        hevcHighestLevel = hevcMp4LevelSupported
        if hevcTsLevelSupported > hevcMp4LevelSupported
            hevcHighestLevel = hevcTsLevelSupported
        end if

        hevcLevelString = "120"
        if hevcHighestLevel = 5.1
            hevcLevelString = "153"
        end if

        codecProfileArray = {
            "Type": "Video",
            "Codec": "hevc",
            "Conditions": [
                {
                    "Condition": "NotEquals",
                    "Property": "IsAnamorphic",
                    "Value": "true",
                    "IsRequired": false
                },
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoProfile",
                    "Value": profileSupport["ts"]["hevc"].Keys().join("|"),
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
                    "Value": hevcLevelString,
                    "IsRequired": false
                }
            ]
        }

        bitRateArray = GetBitRateLimit("h265")
        if bitRateArray.count() > 0
            codecProfileArray.Conditions.push(bitRateArray)
        end if
        deviceProfile.CodecProfiles.push(codecProfileArray)
    end if

    if addVp9
        vp9Profiles = []
        for each container in profileSupport
            for each profile in profileSupport[container]["vp9"]
                if vp9Profiles[profile] = invalid
                    vp9Profiles.push(profile)
                end if
            end for
        end for

        codecProfileArray = {
            "Type": "Video",
            "Codec": "vp9",
            "Conditions": [
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoLevel",
                    "Value": vp9Profiles.join("|"),
                    "IsRequired": false
                },
                {
                    "Condition": "EqualsAny",
                    "Property": "VideoRangeType",
                    "Value": vp9VideoRangeTypes,
                    "IsRequired": false
                }
            ]
        }

        bitRateArray = GetBitRateLimit("vp9")
        if bitRateArray.count() > 0
            codecProfileArray.Conditions.push(bitRateArray)
        end if
        deviceProfile.CodecProfiles.push(codecProfileArray)
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
            containerString = container

            if container = "mp4"
                containerString = "mp4,mov,m4v"
            else if container = "mkv"
                containerString = "mkv,webm"
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

' Recieves and returns an assArray of supported profiles and levels for each video codec
function updateProfileArray(profileArray as object, videoCodec as string, videoProfile as string, profileLevel = "" as string) as object
    ' validate params
    if profileArray = invalid then return {}
    if videoCodec = "" or videoProfile = "" then return profileArray

    if profileArray[videoCodec] = invalid
        profileArray[videoCodec] = {}
    end if

    if profileArray[videoCodec][videoProfile] = invalid
        profileArray[videoCodec][videoProfile] = {}
    end if

    ' add profileLevel if a value was provided
    if profileLevel <> ""
        if profileArray[videoCodec][videoProfile][profileLevel] = invalid
            profileArray[videoCodec][videoProfile].AddReplace(profileLevel, true)
        end if
    end if

    ' profileSupport[container][codec][profile][level]
    return profileArray
end function

' Remove all decimals from a string
function removeDecimals(value as string) as string
    r = CreateObject("roRegex", "\.", "")
    value = r.ReplaceAll(value, "")
    return value
end function
