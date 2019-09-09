# JellyFin Roku Development
###### The Ramblings of a Learning Man

#### The GIT Portion
1.  Install git
2.  Fork [jellyfin-roku](https://github.com/jellyfin/jellyfin-roku) repo to your own.  
3.  Clone your repo to local  
  3a.  ````git clone ssh://github.com/username/jellyfin-roku.git````
4.  Create a branch for your fix  
  4a.  ````git checkout -B issue007````
5.  Set remote repo so you can stay current with other dev changes  
  5a.  ````git remote add upstream https://github.com/jellyfin/jellyfin-roku.git````
6.  Fetch remote changes from other devs often  
  6a.  ````git fetch upstream````
7.  After making changes, push local branch to github repo  
  7a.  ````git add --all````  
  7b.  ````git commit -m "description of changes for commit"````  
  7c.  ````git push -u origin issue007````  

Congrats, you are now forked and ready to perform pull requests.  You can do so via [github webui](https://help.github.com/en/articles/creating-a-pull-request-from-a-fork)

#### Jellyfin Portion - via Docker  

For this portion, I will not go into any depth on [docker](https://www.docker.com/) nor [portainer](https://www.portainer.io/), but they are what I chose to use to have a dev install of jellyfin for working on.  

Via the portainer condole I created an app template using the jellyfin/jellyfin:latest [docker image](https://hub.docker.com/r/jellyfin/jellyfin/) as per the instructions from the [Jellyfin Install Docs](https://jellyfin.readthedocs.io/en/latest/administrator-docs/installing/).  I applied the following:  
*  Port mapping - host port 8098; container port 8096.  
I did this so it will not conflict with my 'prod' installation and both can be accessed in parallel.  
*  Volume mapping - /media, /config, /cache directories mapped according to my needs.  

At this point, I can create a new image as needed for updating to the latest version all simply by deleting the existing image and recreating which will pull the latest from docker registry and persist the configs.

#### The Roku Portion  
*  Put your Roku in [Dev Mode](https://blog.roku.com/developer/developer-setup-guide)
*  I use [Atom](https://atom.io).
*  I installed [roku-develop](https://atom.io/packages/roku-develop) for Atom.
*  Read the [Roku Developer Docs](https://developer.roku.com/docs/developer-program/getting-started)

###### Instructions:  
*  Install [ImageMagick](https://www.imagemagick.org/script/download.php).  
*  Install [wget](https://www.gnu.org/software/wget/).  
*  Install [make](https://www.gnu.org/software/make/).  
*  Install [nodejs and npm](https://www.npmjs.com/get-npm).  
*  Ensure npm requirements are installed:
````
cd /path/to/git/repo/  
npm install  
````  
*  Update branding images from jellyfin repo:  
 ````sh make_images.sh````  
  You should see something similar to the following:  
````
 --2019-09-08 12:45:02-- https://raw.githubusercontent.com/jellyfin/jellyfin-ux/master/branding/SVG/icon-transparent.svg  
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.128.133, 151.101.192.133, 151.101.0.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.128.133|:443... connected.
HTTP request sent, awaiting response... 200 OK  
````  

#### Actual Build and Deploy to Roku:  
````  
cd /path/to/local/git/repo
make install  
````
