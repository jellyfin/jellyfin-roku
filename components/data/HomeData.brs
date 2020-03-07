sub setData()
    ' We keep json around just as a reference,
    ' but ideally everything should be going through one of the interfaces
    datum = m.top.json

    m.top.id = datum.id
    m.top.name = datum.name
    if datum.CollectionType = invalid then
        m.top.type = datum.type
    else 
        m.top.type = datum.CollectionType
    end if
end sub