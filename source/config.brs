' "Registry" is where Roku stores config


' Generic registry accessors
function registry_read(key, section=invalid)
    if section = invalid then return invalid
    reg = CreateObject("roRegistrySection", section)
    if reg.exists(key) then return reg.read(key)
    return invalid
end function

function registry_write(key, value, section=invalid)
    if section = invalid then return invalid
    reg = CreateObject("roRegistrySection", section)
    reg.write(key, value)
    reg.flush()
end function

function registry_delete(key, section=invalid)
    if section = invalid then return invalid
    reg = CreateObject("roRegistrySection", section)
    reg.delete(key)
    reg.flush()
end function


' "Jellyfin" registry accessors for the default global settings
function get_setting(key)
    return registry_read(key, "Jellyfin")
end function

function set_setting(key, value)
    registry_write(key, value, "Jellyfin")
end function

function unset_setting(key)
    registry_delete(key, "Jellyfin")
end function


' User registry accessors for the currently active user
function get_user_setting(key)
    if get_setting("active_user") = invalid then return invalid
    return registry_read(key, get_setting("active_user"))
end function

function set_user_setting(key, value)
    if get_setting("active_user") = invalid then return invalid
    registry_write(key, value, get_setting("active_user"))
end function

function unset_user_setting(key)
    if get_setting("active_user") = invalid then return invalid
    registry_delete(key, get_setting("active_user"))
end function
