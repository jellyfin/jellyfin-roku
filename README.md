# Jellyfin app for Roku

Disclaimer: This is a proof of concept for my own ability to learn and write
BrightScript, and not yet intended to be a fully functional Roku app.


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

- [ ] Server Select
- [ ] User Sign In
- [ ] Main Landing "Library Select"
- [ ] Library Items List
- [ ] Preview "About this Item" movie page
- [ ] Video Player


### ToDo - Additional Scenes for TV Shows

- [ ] Preview "About this Item" season page
- [ ] Library Items List for a season
- [ ] Preview "About this Item" episode page (?)


### ToDo - Additional Scenes for Music

- [ ] Preview "About this Item" Artist page
- [ ] Library Items List for an artist
- [ ] Library Items List for an album
- [ ] Preview "About this Item" Album page


### ToDo - Other things

Live TV/PVR? Pictures?
