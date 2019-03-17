sub ShowServerSelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("ConfigScene")
  screen.show()

  themeScene(scene)
  scene.findNode("prompt").text = "Connect to Server"

  config = scene.findNode("configOptions")
  items = [
    {"field": "server", "label": "Host", "type": "string"},
    {"field": "port", "label": "Port", "type": "string"}
  ]
  config.callfunc("setData", items)

  button = scene.findNode("submit")
  button.observeField("buttonSelected", port)

  server_hostname = config.content.getChild(0)
  server_port = config.content.getChild(1)

  while(true)
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
      return
    else if type(msg) = "roSGNodeEvent"
      node = msg.getNode()
      if node = "submit"
        set_setting("server", server_hostname.value)
        set_setting("port", server_port.value)
        return
      end if
    end if
  end while
end sub

sub ShowSignInSelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("ConfigScene")
  screen.show()

  themeScene(scene)
  scene.findNode("prompt").text = "Sign In"

  config = scene.findNode("configOptions")
  items = [
    {"field": "username", "label": "Username", "type": "string"},
    {"field": "password", "label": "Password", "type": "password"}
  ]
  config.callfunc("setData", items)

  button = scene.findNode("submit")
  button.observeField("buttonSelected", port)

  config = scene.findNode("configOptions")

  username = config.content.getChild(0)
  password = config.content.getChild(1)

  while(true)
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
      return
    else if type(msg) = "roSGNodeEvent"
      node = msg.getNode()
      if node = "submit"
        ' Validate credentials
        get_token(username.value, password.value)
        if get_setting("active_user") <> invalid then return
        print "Login attempt failed..."
      end if
    end if
  end while
end sub

sub ShowLibrarySelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Library")

  screen.show()

  themeScene(scene)

  library = scene.findNode("LibrarySelect")
  libs = LibraryList()
  library.libList = libs

  library.observeField("itemSelected", port)

  search = scene.findNode("search")
  search.observeField("escape", port)
  search.observeField("search_value", port)

  while(true)
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      exit while
    else if nodeEventQ(msg, "escape") and msg.getNode() = "search"
      library.setFocus(true)
    else if nodeEventQ(msg, "search_value")
      query = msg.getRoSGNode().search_value
      if query <> invalid or query <> ""
        ShowSearchOptions(query)
      end if
      search.search_value = ""
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      if target.libraryType = "movies"
        ShowMovieOptions(target.data)
      else if target.libraryType = "tvshows"
        ShowTVShowOptions(target.data)
      else
        scene.dialog = make_dialog("This library type is not yet implemented")
        scene.dialog.observeField("buttonSelected", port)
      end if
    else if nodeEventQ(msg, "buttonSelected")
      if msg.getNode() = "popup"
        msg.getRoSGNode().close = true
      end if
    else
      print msg
    end if
  end while
end sub

sub ShowMovieOptions(library)
  library_id = library.id
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Movies")

  screen.show()

  overhang = scene.findNode("overhang")
  overhang.title = library.name

  themeScene(scene)

  options = scene.findNode("MovieSelect")
  options.library = library

  page_num = 1
  page_size = 30

  sort_order = get_user_setting("movie_sort_order", "Descending")
  sort_field = get_user_setting("movie_sort_field", "DateCreated,SortName")

  options_list = ItemList(library_id, {"limit": page_size,
    "StartIndex": page_size * (page_num - 1),
    "SortBy": sort_field,
    "SortOrder": sort_order })
  options.movieData = options_list

  options.observeField("itemSelected", port)

  pager = scene.findNode("pager")
  pager.currentPage = page_num
  pager.maxPages = options_list.TotalRecordCount / page_size
  if pager.maxPages = 0 then pager.maxPages = 1

  pager.observeField("escape", port)
  pager.observeField("pageSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "escape") and msg.getNode() = "pager"
      options.setFocus(true)
    else if nodeEventQ(msg, "pageSelected") and pager.pageSelected <> invalid
      pager.pageSelected = invalid
      page_num = int(val(msg.getData().id))
      pager.currentPage = page_num
      options_list = ItemList(library_id, {"limit": page_size,
        "StartIndex": page_size * (page_num - 1),
        "SortBy": sort_order,
        "SortOrder": sort_field })
      options.movieData = options_list
      options.setFocus(true)
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      ShowMovieDetails(target.movieID)
    else
      print msg
      print msg.getField()
      print msg.getData()
    end if
  end while
end sub

sub ShowMovieDetails(movie_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("MovieItemDetailScene")

  screen.show()

  themeScene(scene)

  content = createObject("roSGNode", "MovieData")
  content.full_data = ItemMetaData(movie_id)
  scene.itemContent = content

  buttons = scene.findNode("buttons")
  for each b in buttons.getChildren(-1, 0)
    b.observeField("buttonSelected", port)
  end for

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "buttonSelected")
      if msg.getNode() = "play-button"
        showVideoPlayer(movie_id)
      else if msg.getNode() = "watched-button"
        if content.watched
          UnmarkItemWatched(movie_id)
        else
          MarkItemWatched(movie_id)
        end if
        content.watched = not content.watched
      else if msg.getNode() = "favorite-button"
        if content.favorite
          UnmarkItemFavorite(movie_id)
        else
          MarkItemFavorite(movie_id)
        end if
        content.favorite = not content.favorite
      end if
    else
      print msg
      print type(msg)
    end if
  end while
end sub

sub ShowTVShowOptions(library)
  library_id = library.ID
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("TVShows")

  screen.show()

  overhang = scene.findNode("overhang")
  overhang.title = library.name

  themeScene(scene)

  options = scene.findNode("TVShowSelect")
  options.library = library

  page_num = 1
  page_size = 30

  sort_order = get_user_setting("tvshow_sort_order", "Descending")
  sort_field = get_user_setting("tvshow_sort_field", "DateCreated,SortName")

  options_list = ItemList(library_id, {"limit": page_size,
    "page": page_num,
    "SortBy": sort_field,
    "SortOrder": sort_order })
  options.TVShowData = options_list

  options.observeField("itemSelected", port)

  pager = scene.findNode("pager")
  pager.currentPage = page_num
  pager.maxPages = options_list.TotalRecordCount / page_size
  if pager.maxPages = 0 then pager.maxPages = 1

  pager.observeField("escape", port)
  pager.observeField("pageSelected", port)

  while true
    msg = wait(0, port)
    if nodeEventQ(msg, "escape") and msg.getNode() = "pager"
      options.setFocus(true)
    else if nodeEventQ(msg, "pageSelected") and pager.pageSelected <> invalid
      pager.pageSelected = invalid
      page_num = int(val(msg.getData().id))
      pager.currentPage = page_num
      options_list = ItemList(library_id, {"limit": page_size,
        "StartIndex": page_size * (page_num - 1),
        "SortBy": sort_field,
        "SortOrder": sort_order })
      options.TVShowData = options_list
      options.setFocus(true)
    else if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      ShowTVShowDetails(target.showID)
    end if
  end while
end sub

sub ShowTVShowDetails(show_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("TVShowItemDetailScene")

  screen.show()

  themeScene(scene)

  content = createObject("roSGNode", "TVShowData")
  content.full_data = ItemMetaData(show_id)
  scene.itemContent = content
  x = TVSeasons(show_id)
  scene.itemContent.seasons = TVSeasons(show_id)

  'buttons = scene.findNode("buttons")
  'buttons.observeField("buttonSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "buttonSelected")
      ' What button could we even be watching yet
    else
      print msg
      print type(msg)
    end if
  end while
end sub

sub ShowSearchOptions(query)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("SearchResults")

  screen.show()

  themeScene(scene)

  options = scene.findNode("SearchSelect")

  sort_order = get_user_setting("search_sort_order", "Descending")
  sort_field = get_user_setting("search_sort_field", "DateCreated,SortName")

  results = SearchMedia(query)
  options.itemData = results
  options.query = query

  options.observeField("itemSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      ' TODO - swap this based on target.mediatype
      ' types: [ Episode, Movie, Audio, Person, Studio, MusicArtist ]
      ShowMovieDetails(target.mediaID)
    else
      print msg
      print msg.getField()
      print msg.getData()
    end if
  end while
end sub

sub showVideoPlayer(id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Scene")

  screen.show()

  themeScene(scene)

  VideoPlayer(scene, id)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    end if
  end while

end sub
