sub setFields()
    json = m.top.json

    m.top.id = json.id
    m.top.Title = json.name
    m.top.Type = "Folder"

    m.top.iconUrl = "pkg:/images/media_type_icons/folder_white.png"
end sub
