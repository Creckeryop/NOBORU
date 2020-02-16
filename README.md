# NOBORU
![GitHub All Releases](https://img.shields.io/github/downloads/Creckeryop/NOBORU/total)
![GitHub](https://img.shields.io/github/license/Creckeryop/NOBORU)
![GitHub top language](https://img.shields.io/github/languages/top/Creckeryop/NOBORU)
[![VitaDB](https://img.shields.io/badge/Vita-DB-blue)](https://vitadb.rinnegatamante.it/#/info/534)
<br>
<img src="/res/logo.png" width="50%" height="50%"><br>
App for PSVita to read manga or comic<br>
All issues with parsers should be in <a href="https://github.com/Creckeryop/NOBORU-parsers">this repo</a>
```diff
- There is a lot of problems with performance, i don't think i can solve 'em all
```
### Requirements:
* At least 10-20 MB memory (for online reading) or more (for offline reading)
### Data structure:
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
## Importing (0.35+):
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
## Features:
* Browsing manga sites
* Searching
* Build-in updater
* Reading manga (with Vertical or Horizontal mode!)
* MultiTouch, Swipes and other touch things
* Adding manga to library
* Loading longpages (webmanga) without downscaling (thanks to my [piclib](https://github.com/Creckeryop/piclib))
* Multilanguage
* Reading without network (Offline mode !!Don't forget to add manga in library!! (you can also check `History` tab))
## TODO:
* Settings for parserlist (sorting by languages or else, hide some)
* Sort chapters by 1->N or N->1
* Add new way of controls for changing page (DPAD)
* Add up to down scroll
* More languages
## Known issues:
<b>Issue</b> Download freezes if you go sleeping mode, and after that app need in restarting to enable downloading<br>
<b>Advice</b> Please don't shut vita screen untill blue LED turns off. I hope i'll find better solution
## Screenshots:
![s1](/res/screenshot1.png)
![s2](/res/screenshot2.png)
![s3](/res/screenshot3.png)
![s4](/res/screenshot4.png)
![s5](/res/screenshot5.png)
## FAQ:
<b>Q</b>: I found bug that ...<br>
<b>A</b>: You can create issue [here](https://github.com/Creckeryop/NOBORU/issues), give screenshot with error or error file<br>
<br>
<b>Q</b>: Is it safe to use?<br>
<b>A</b>: I'm really don't know, i don't visit any of not NOBORU app folders<br>
<br>
<b>Q</b>: How to view debug console?<br>
<b>A</b>: DPAD_LEFT + START<br>
<br>
<b>Q</b>: App crashes with...<br>
<b>A</b>: Again, create issue [here](https://github.com/Creckeryop/NOBORU/issues)<br>
<br>
<b>Q</b>: Reader doesn't load some images<br>
<b>A</b>: Please create Issue and describe how you come to this (Parser you used, Manga, Chapter and page)<br>
<br>
<b>Q</b>: I downloaded app and can't see any parsers<br>
<b>A</b>: Press Triangle to update parser list, so if that won't help create issue [here](https://github.com/Creckeryop/NOBORU/issues)<br>
## Compile
	Execute `build.bat`
## Credits:
[Rinnegatamante](https://github.com/Rinnegatamante) - [LuaPlayerPlus_Vita](https://github.com/Rinnegatamante/lpp-vita)
<br>[VitaSDK](https://github.com/vitasdk) - vitaSDK
<br>[xerpi](https://github.com/xerpi) - [libvita2d](https://github.com/xerpi/libvita2d)
<br>[theFloW](https://github.com/theOfficialFlow) - [VitaShell](https://github.com/TheOfficialFloW/VitaShell) for some functions
