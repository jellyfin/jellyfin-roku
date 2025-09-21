function main(args as object) as object
    return roca(args).describe("useTranscodeAudioStream", sub()
        m.it("returns true when playbackInfo has valid mediaSources and TranscodingURL", sub()
            m.assert.isTrue(useTranscodeAudioStream({
                mediaSources: [{
                    TranscodingURL: "http://example.com/transcode"
                }]
            }), "should return true for valid playbackInfo")
        end sub)

        m.it("returns false when playbackInfo has empty mediaSources", sub()
            m.assert.isFalse(useTranscodeAudioStream({
                mediaSources: []
            }), "should return false for empty mediaSources")
        end sub)
    end sub)
end function
