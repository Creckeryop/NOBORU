<img src="/res/logo.png" width="50%" height="50%"><br>
# NOBORU
Application for PlayStation Vita to read manga or comics<br>
![GitHub All Releases](https://img.shields.io/github/downloads/Creckeryop/NOBORU/total?style=flat-square)
![GitHub](https://img.shields.io/github/license/Creckeryop/NOBORU?style=flat-square)
![GitHub top language](https://img.shields.io/github/languages/top/Creckeryop/NOBORU?style=flat-square)
[![VitaDB](https://img.shields.io/badge/Vita-DB-blue?style=flat-square)](https://vitadb.rinnegatamante.it/#/info/534)
<br>
![Screenshots](/res/screenshots.gif)
## Features
* Browsing manga sites
* Searching
* Build-in updater
* Reading manga (with Vertical or Horizontal mode!)
* MultiTouch, Swipes and other touch things
* Adding manga to library
* Loading longpages (webmanga) without downscaling (thanks to my [piclib](https://github.com/Creckeryop/piclib))
* Supports CBZ format
* Multilanguage
* Reading without network (Offline mode !!Don't forget to add manga in library!! (you can also check `History` tab))

All issues with parsers should be in <a href="https://github.com/Creckeryop/NOBORU-parsers">this repo</a>
## Table of Contents
- [Requirements](#requirements)
- [Data structure](#data-structure)
- [Importing](#importing-035)
- [Backup](#backup)
- [Known issues](#known-issues)
- [FAQ](#faq)
- [Compiling](#compiling)
- [ToDo List](#todo)
- [Credits](#credits)
## Requirements
* At least 50-60 MB memory (for online reading) or more (for offline reading)
## Data structure
```
ux0:data/noboru/cache/ - folder that holds cached manga info (also history)
ux0:data/noboru/chapters/ - folder that holds chapters saved
ux0:data/noboru/import/ - folder where you can store files you want to read locally or import to Library (0.35+)
ux0:data/noboru/parsers/ - folder for parsers
ux0:data/noboru/save.dat - library savefile
ux0:data/noboru/c.c - saved chapters info
ux0:data/noboru/settings.ini - application settings
```
You can simply delete `noboru` folder to reset all settings
## Importing (0.35+)
So if you want to add your manga to library, you have four ways:
* You can import folder with images
* You can import folder with folders with images
* You can import folder with (.cbz, .zip) files
* You can import one (.cbz, .zip) file

Also if you want to read directly .cbz file you can just open file in import section<br><br>
<b>Requirements to .cbz or .zip file:</b>
* Names of images should end .jpg .jpeg .png or .bmp (webp not supported yet)

<b>Requirements to folders:</b>
* No extra (non-image) files

CBR not supported (im working on the way to support RAR archives, some images brakes and i just can't add that on this moment)
## Backup
If you want to backup here's what you can backup
|Files|What saves|
|---|---|
|save.dat|Library list|
|settings.ini|Settings|
|history.dat + info.txt|History list|
|info.txt + cache folders (as many you want)|Bookmarks + Covers|
|c.c + chapters folders (as many you want)|Chapters|

*Be careful, if you want to save chapters and don't search this chapter from internet you should backup History list*
## Known issues
<b>Issue</b> After importing archive file, manga/comic shows "Unknown error (Parser's)"<br>
<b>Advice</b> Make sure that archive file you imported is supported.<br>
## FAQ
- **I found bug that ...**
    - You can create issue [here](https://github.com/Creckeryop/NOBORU/issues), give screenshot with error or error file
- **How to view debug console?**
    - DPAD_LEFT + START
- **How to download chapters in background?**
    - There is only one way to download in background, don't press Power button! screen will shut by itself
- **Image loading is the same speed as downloading from network, is it broken?**
    - It is not broken, if you download chapters at the same time with reading. Image loading and downloading working in the one-thread mode. And your page that you are reading putted in queue, but if first task in queue is active, app can't cancel it not to corrupt data. That's why it is happening. If i will find a way to make it faster, i will make it faster.
- **Reader doesn't load some images**
    - Please create Issue and describe how you come to this (Parser you used, Manga, Chapter and page). This app supports only JPEG, BMP and PNG formats. Make sure that image you loading isn't gif or else. You can check network address through debug console.
- **I downloaded app and can't see any parsers**
    - Press Triangle to update parser list, so if that won't help create issue [here](https://github.com/Creckeryop/NOBORU/issues)
- **How to setup proxy?**
    - You can write ip address like '192.169.0.1' or you can specify your proxy kind like 'socks5h://192.168.0.1' or "http", "https", "socks4a", "socks5", "socks5h"
- **Application slows down sometimes, when new manga appears**
    - That's a print function problem, all new characters that appears should be cached. In first launch, app can't load all glyphs because it's longtime process, so i load only Latin and Cryllic symbols.
## Compiling
Execute `build.bat` to create working .vpk
## TODO
* More languages
## Credits
[Rinnegatamante](https://github.com/Rinnegatamante) - [LuaPlayerPlus_Vita](https://github.com/Rinnegatamante/lpp-vita)
<br>[VitaSDK](https://github.com/vitasdk) - vitaSDK
<br>[xerpi](https://github.com/xerpi) - [libvita2d](https://github.com/xerpi/libvita2d)
<br>[theFloW](https://github.com/theOfficialFlow) - [VitaShell](https://github.com/TheOfficialFloW/VitaShell) for some functions
<br>[SamuEDL98](https://github.com/SamuEDL98) - Spanish translation
<br>[nguyenmao2101](https://github.com/nguyenmao2101) - Vietnamese translation
<br>[theheroGAC](https://github.com/theheroGAC) - Italian translation
<br>[Cimmerian-Iter](https://github.com/Cimmerian-Iter) - French translation
<br>[Kemal Sanlı](https://github.com/kemalsanli) - Turkish translation
