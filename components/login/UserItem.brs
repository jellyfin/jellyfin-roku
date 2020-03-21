sub init()
end sub

sub ItemContentChanged()
  ItemData = m.top.ItemContent
  if ItemData = invalid then return

  ProfileImage = m.top.findNode("ProfileImage")
  ProfileName = m.top.findNode("ProfileName")

  if ItemData.ImageURL = "" then
    ProfileImage.uri = "pkg://images/baseline_person_white_48dp.png"
  else
    ProfileImage.uri = ItemData.ImageURL
  end if
  ProfileName.text = ItemData.Name
end sub
