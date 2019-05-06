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

This will update the poster and splash images from the jellyfin-ux repo.

## Testing and Local Deployment
To test and deploy on your Roku device, it must be in [developer mode](https://blog.roku.com/developer/2016/02/04/developer-setup-guide) first. 
Once there, set two environment variables that make uses.

```bash
export ROKU_DEV_TARGET=192.168.1.234
export ROKU_DEV_PASSWORD=aaaa
```

This is the IP address of your roku and the password you set for the
rokudev account when you put your device in developer mode.

### Testing
Testing is done with the [Rooibos](https://github.com/georgejecook/rooibos/) library. 
This works by including the tests in the deployment and then looking at telnet
for the test results. This testing library requires the [Rooibos Preprocessor](https://github.com/georgejecook/rooibosPreprocessor) 
to create a few of the helper files used during the tests. This can be installed via:

```bash
npm install -g rooibos-preprocessor
```

`make test` will package up the application and tests and the deploy it to the Roku. Test results can be seen via `telnet ${ROKU_DEV_TARGET} 8085` 

### Deployment
To deploy the application to your local roku run `make install`.

This packages up the application, sends it to your Roku and launches it. 