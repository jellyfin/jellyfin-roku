sub init()
  m.top.observeFieldScoped("text", "onTextChanged")
  m.top.iconUri = ""
  m.top.focusedIconUri = ""
  m.top.showFocusFootprint = true
  m.top.minWidth = 0
end sub

sub onTextChanged()
  addSpaceAfter = true
  minChars = m.top.minChars
  if minChars = invalid then minChars = 50
  while m.top.text.Len() < minChars
    if addSpaceAfter then
      m.top.text = m.top.text + Chr(160)
    else
      m.top.text = Chr(160) + m.top.text
    end if
    addSpaceAfter = addSpaceAfter = false
  end while
end sub
