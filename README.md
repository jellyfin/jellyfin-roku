# Jellyfin app for Roku

Disclaimer: This is not complete, but making good progress!

Right now the only things stored on your device are server name, server port,
user id, and some user preferences like movie sort order.

At any point, the format that is used to save those settings could change, and
your data could be effectively lost (and you'll have to re-enter it).

In fact, it is likely this early on, as a few design decisions were made before
I knew much about BrightScript format. Patience is appreciated.

### Images

With ImageMagick installed
```
sh make_images.sh
```

This will regenerate the poster and splash images from the jellyfin-ux repo.

### Easy Dev Deployment

There are 2 included scripts, `dev_upload.sh` and `dev_clear.sh`, that are
intended to be quick easy ways to zip up this repo and put it onto your Roku
for you, and clear your Roku of any dev deployment respectively.

You need to enable developer mode on your Roku:
http://sdkdocs.roku.com/display/sdkdoc/Developer+Guide

And then
```
export ROKU_DEV_TARGET=<your roku IP>
export ROKU_DEV_PASSWORD=<your roku password>
```


### ToDo - Scenes for Movie Viewing Only

- [x] Server Select
- [x] User Sign In
- [x] Main Landing "Library Select"
- [x] Library Items List (ie, movie list)
- [x] Infinite scroll or paging  (paging!)
- [x] Preview "About this Item" movie page
- [x] Video Player
- [x] Sign Out (?)


### ToDo - Additional Scenes for TV Shows

- [x] Preview "About this Item" season page
- [ ] Library Items List for a season
- [ ] Preview "About this Item" episode page (?)


### ToDo - Additional Scenes for Music

- [ ] Preview "About this Item" Artist page
- [ ] Library Items List for an artist
- [ ] Library Items List for an album
- [ ] Preview "About this Item" Album page


### ToDo - Other things

- [x] Collections
- [x] Sort order

Live TV/PVR? Pictures?
