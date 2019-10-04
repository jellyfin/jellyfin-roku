# Jellyfin app for Roku

**This app is not complete!**

Currently, the data stored on your Roku device are server name, server port,
user id, and some user preferences like movie sort order.

The format that is used to save those settings could change at any time and
your data could be lost and you'd have to re-enter it.

## Getting Started

Follow the steps below or checkout the [Development Guide For New Devs](DEVGUIDE.md)

### Developer Mode

Put your Roku device in [developer mode](https://blog.roku.com/developer/2016/02/04/developer-setup-guide)

### Clone the GitHub Repo

Open a terminal and navigate to where you would like to install the app then run the commands below:

```bash
https://github.com/jellyfin/jellyfin-roku.git
cd jellyfin-roku
```

This will copy all of the application files to a new folder and then change directories

### Login Details

Run the commands below - Replacing the IP and password (using the info from the first step)

```bash
export ROKU_DEV_TARGET=192.168.1.234
export ROKU_DEV_PASSWORD=aaaa
```

This will allow you to test your code without having to manually upload a .zip file every time

### Download Images

Install these packages:

```bash
sudo apt-get install imagemagick wget make nodejs npm
```

Then run this script to download the images from the jellyfin-ux repo:

```bash
sh make_images.sh
```

### Deploy

Run this:

```bash
make install
```

This packages up the application, sends it to your Roku, and launches the channel.

### Testing

Testing is done with the [Rooibos](https://github.com/georgejecook/rooibos/) library.

This works by including the tests in the deployment and then looking at telnet
for the test results. To use the testing library you need to install [rooibos-cli](https://github.com/georgejecook/rooibos-cli):

Run this in the root app directory:

```bash
npm install -g rooibos-cli
```

To deploy the application with tests:

```bash
make test
```

To see test results and crash reports:

```bash
telnet ${ROKU_DEV_TARGET} 8085
```

To exit telnet: `CTRL + ]` and then type `quit + ENTER`
