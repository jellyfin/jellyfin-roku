#!/bin/bash

if [ -z "$ROKU_DEV_PASSWORD" ]; then
    echo "You need to set ROKU_DEV_PASSWORD:"
    echo "export ROKU_DEV_PASSWORD=<your dev password>"
    exit 1
fi
if [ -z "$ROKU_DEV_TARGET" ]; then
    echo "You need to set ROKU_DEV_TARGET:"
    echo "export ROKU_DEV_TARGET=<your roku ip>"
    exit 1
fi

[ -f jellyfin-roku.zip ] && rm jellyfin-roku.zip
zip jellyfin-roku.zip manifest -r ./components -r ./source -r ./images

curl -f -sS --user rokudev:$ROKU_DEV_PASSWORD --anyauth -F "mysubmit=Install" -F "archive=@jellyfin-roku.zip" -F "passwd=" http://$ROKU_DEV_TARGET/plugin_install  \
    | python -c 'import sys, re; print("\n".join(re.findall("<font color=\"red\">(.*?)</font>", sys.stdin.read(), re.DOTALL)))'
