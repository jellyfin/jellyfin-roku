#!/bin/bash

BRANDING_ROOT=https://raw.githubusercontent.com/jellyfin/jellyfin-ux/master/branding/SVG

ICON_SOURCE=icon-transparent.svg
BANNER_SOURCE=banner-dark.svg

OUTPUT_DIR=./images

# Don't need to keep re-downloading things we already have
if [ ! -e $ICON_SOURCE ]; then
    wget $BRANDING_ROOT/$ICON_SOURCE > /dev/null
    wget $BRANDING_ROOT/$BANNER_SOURCE > /dev/null
fi

# Channel Posters
convert -background "#000b25" -gravity center -scale 350x350 -extent 540x405 $ICON_SOURCE $OUTPUT_DIR/channel-poster_fhd.png
convert -background "#000b25" -gravity center -scale 190x190 -extent 290x218 $ICON_SOURCE $OUTPUT_DIR/channel-poster_hd.png
convert -background "#000b25" -gravity center -scale 140x140 -extent 214x144 $ICON_SOURCE $OUTPUT_DIR/channel-poster_sd.png

# Splash screens
convert -background "#000b25" -gravity center -scale 540x540 -extent 1920x1080 $BANNER_SOURCE $OUTPUT_DIR/splash-screen_fhd.jpg
convert -background "#000b25" -gravity center -scale 360x360 -extent 1280x720 $BANNER_SOURCE $OUTPUT_DIR/splash-screen_hd.jpg
convert -background "#000b25" -gravity center -scale 240x240 -extent 720x480 $BANNER_SOURCE $OUTPUT_DIR/splash-screen_sd.jpg

# Figure out when we want to clean up after ourselves
if [ "$skip" = "true" ]; then
    rm $ICON_SOURCE
    rm $BANNER_SOURCE
fi
