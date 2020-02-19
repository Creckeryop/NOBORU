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
- [Known issues](#known-issues)
- [FAQ](#faq)
- [Compiling](#compiling)
- [ToDo List](#todo)
- [Credits](#credits)
## Requirements
* At least 50-100 MB memory (for online reading) or more (for offline reading)
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
## Known issues
<b>Issue</b> Download freezes if you go sleeping mode, and after that app need in restarting to enable downloading<br>
<b>Advice</b> Please don't shut vita screen untill blue LED turns off. I hope i'll find better solution
## FAQ
- **I found bug that ...**
    - You can create issue [here](https://github.com/Creckeryop/NOBORU/issues), give screenshot with error or error file
- **How to view debug console?**
    - DPAD_LEFT + START
- **Reader doesn't load some images**
    - Please create Issue and describe how you come to this (Parser you used, Manga, Chapter and page)
- **I downloaded app and can't see any parsers**
    - Press Triangle to update parser list, so if that won't help create issue [here](https://github.com/Creckeryop/NOBORU/issues)
## Compiling
Execute `build.bat` to create working .vpk
## TODO
* Settings for parserlist (sorting by languages or else, hide some)
* Sort chapters by 1->N or N->1
* Add new way of controls for changing page (DPAD)
* Add up to down scroll
* More languages
## Credits
[Rinnegatamante](https://github.com/Rinnegatamante) - [LuaPlayerPlus_Vita](https://github.com/Rinnegatamante/lpp-vita)
<br>[VitaSDK](https://github.com/vitasdk) - vitaSDK
<br>[xerpi](https://github.com/xerpi) - [libvita2d](https://github.com/xerpi/libvita2d)
<br>[theFloW](https://github.com/theOfficialFlow) - [VitaShell](https://github.com/TheOfficialFloW/VitaShell) for some functions
