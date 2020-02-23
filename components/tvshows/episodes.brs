sub init()
  m.top.overhangTitle = "Season"
end sub

sub setSeason()
  m.top.overhangTitle = m.top.seasonData.SeriesName + " - " + m.top.seasonData.name
end sub
