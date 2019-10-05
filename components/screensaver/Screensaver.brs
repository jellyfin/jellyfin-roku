function init()
    ' backgroundUri must be set to an empty string before backgroundColor can be set
    m.top.backgroundUri = ""
    m.top.backgroundColor = &h000000

    m.PosterOne = m.top.findNode("PosterOne")
    m.PosterOne.uri = "pkg:/images/logo.png"

    m.BounceAnimation = m.top.findNode("BounceAnimation")
    m.BounceAnimation.control = "start" 'Start BounceAnimation
end function