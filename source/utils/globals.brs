' Save information from roAppInfo to m.global.app
sub SaveAppToGlobal()
    appInfo = CreateObject("roAppInfo")
    m.global.addFields({
        app: {
            id: appInfo.GetID(),
            isDev: appInfo.IsDev(),
            version: appInfo.GetVersion()
        }
    })
end sub

' Save information from roDeviceInfo to m.global.device
sub SaveDeviceToGlobal()
    deviceInfo = CreateObject("roDeviceInfo")
    ' remove special characters
    regex = CreateObject("roRegex", "[^a-zA-Z0-9\ \-\_]", "")
    filteredFriendly = regex.ReplaceAll(deviceInfo.getFriendlyName(), "")
    m.global.addFields({
        device: {
            id: deviceInfo.getChannelClientID(),
            uuid: deviceInfo.GetRandomUUID(),
            name: deviceInfo.getModelDisplayName(),
            friendlyName: filteredFriendly,
            model: deviceInfo.GetModel(),
            modelType: deviceInfo.GetModelType(),
            osVersion: deviceInfo.GetOSVersion(),
            locale: deviceInfo.GetCurrentLocale(),
            clockFormat: deviceInfo.GetClockFormat(),
            isAudioGuideEnabled: deviceInfo.IsAudioGuideEnabled(),
            hasVoiceRemote: deviceInfo.HasFeature("voice_remote"),

            displayType: deviceInfo.GetDisplayType(),
            displayMode: deviceInfo.GetDisplayMode()
        }
    })
end sub
