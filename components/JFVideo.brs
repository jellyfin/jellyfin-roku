sub init()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  if not press then return false

  if m.top.Subtitles.count() and key = "down" then
    m.top.selectSubtitlePressed = true
    return true
  end if

  return false
end function
