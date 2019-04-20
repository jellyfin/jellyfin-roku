function ItemCounts()
  ' Gets counts of a library
  ' Query:
  '   UserId: Get counts from specific user's library
  '   IsFavorite: Get counts of favorite items
  resp = APIRequest("Items/Counts", {})
  data = getJson(resp)
  return data
end function

function LibraryMediaFolders()
  ' Gets all user media folders
  ' Query:
  '   IsHidden: Filter by folders that are marked hidden, or not
  resp = APIRequest("Library/MediaFolders")
  data = getJson(resp)
  return data

end function
