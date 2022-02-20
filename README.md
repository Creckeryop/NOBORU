<!--img src="/res/logo.png" width="50%" height="50%"><br-->
# Noboru
Application for PlayStation Vita to read manga or comics<br>
![GitHub All Releases](https://img.shields.io/github/downloads/Creckeryop/NOBORU/total?style=flat-square)
![GitHub](https://img.shields.io/github/license/Creckeryop/NOBORU?style=flat-square)
![GitHub top language](https://img.shields.io/github/languages/top/Creckeryop/NOBORU?style=flat-square)
[![VitaDB](https://img.shields.io/badge/Vita-DB-blue?style=flat-square)](https://vitadb.rinnegatamante.it/#/info/534)
<br>
![Screenshots](/res/screenshots.gif)
## Features
* Browsing dozens of different manga / comics sites
* Build-in self-updater, so you don't need to download new version at VitaDB or GitHub
* Manga / Comics reader
* Manga / Comics downloading
* Vertical orientation in Reader
* Full-Touch support (MultiTouch, Swipes, Double-Tap, etc.)
* Manga / Comics tracking
* Support of longpages without downscaling (downscales only if no enough vram)
* Support of formats such as: .ZIP .CBZ
* Multi-language (English, Russian, Spanish, Vietnamese, Italian, French, Turkish, Portuguese (Brazil), Traditional and Simplified Chinese, Romanian, Polish, German, Japanese)
* Offline mode (if you forgot to track manga / comics you downloaded, check history tab, and don't clear cache)
* Advanced search (Filters, Tags, etc.)
* Custom settings for manga / comics (Orientation, Read Direction, Zoom mode)
* A large number of settings that will help you customize the application for yourself

All issues related to catalogs should be in <a href="https://github.com/Creckeryop/NOBORU-parsers">this repo</a>
## Table of Contents
- [Requirements](#requirements)
- [Data structure](#data-structure)
- [Importing](#importing)
- [Backup](#backup)
- [Known issues](#known-issues)
- [FAQ](#faq)
- [Building](#building)
- [ToDo List](#todo)
- [Credits](#credits)
## Requirements
* 50 - 60 MB memory for online reading
* More than 100 MB memory for offline reading (please make sure you have enough memory)
## Data structure
|Path|Description|
|---|---|
|```ux0:data/noboru/cache/```| folder containing cached manga info (also history) |
|```(ux0/uma0):data/noboru/chapters/```| folder containing saved chapters |
|```(ux0/uma0):data/noboru/import/```| folder where you can store files you want to read locally or import to Library (0.35+) |
|```ux0:data/noboru/parsers/```| folder for catalogs |
|```ux0:data/noboru/cusettings/```| folder for manga's custom settings |
|```ux0:data/noboru/save.dat```| library savefile |
|```ux0:data/noboru/c.c```| saved chapters info |
|```ux0:data/noboru/settings.ini```| application settings |

You can just delete `noboru` folder to reset all settings
## Importing
So if you want to add your manga to library, you have four ways:
* You can import folder with images
* You can import folder with folders with images
* You can import folder with (.cbz, .zip) files
* You can import one (.cbz, .zip) file

Also if you want to read .cbz file directly you can just open file in import section<br><br>
<b>Requirements to .cbz or .zip file:</b>
* Names of images should end with .jpg .jpeg .png .bmp or .gif (webp not supported yet)

<b>Requirements to folders:</b>
* No extra (non-image) files

CBR not supported (I'm working to find the way to support RAR archives, some images brakes and I just can't add that on this moment)
## Backup
If you want to backup, here's what you can backup
|Files|What saves|
|---|---|
|```save.dat```|Library list|
|```settings.ini```|Settings|
|```history.dat + info.txt```|History list|
|```info.txt + cache folders (as many you want)```|Bookmarks + Covers|
|```c.c + chapters folders (as many you want)```|Chapters|
|```cusettings/*.ini```|Custom settings for manga|

*Be careful, if you want to save chapters and don't search this chapter on internet you should backup History list*
## Known issues
<b>Issue</b> After importing archive file, manga / comic shows "Unknown error (Parser's)"<br>
<b>Advice</b> Make sure that archive file you have imported is supported.<br>
## FAQ
- **I've found a bug that ...**
    - You can create issue [here](https://github.com/Creckeryop/NOBORU/issues), give a screenshot with error or error file
- **Catalog is empty / All manga has no chapters / All chapters has no images**
    - First of all check if your catalog version isn't outdated. To make sure if it's last version refresh all catalogs sometimes. If new version of catalog was installed, app will notify you with 'Updated' message on catalog. If that doesn't work, you can write on my email: didager@yandex.ru (please tell me every detail you can, what's catalog, what's manga, what's chapter, what's page). Also you can create issue [here](https://github.com/Creckeryop/NOBORU-parsers/issues)
- **How to open debug console?**
    - DPAD_LEFT + START
- **How to download chapters in background?**
    - There is only one way to download in background, don't press *power* button! Screen will shut by itself
- **Image is loading at the same speed as when downloading from network, is it broken?**
    - It is not broken, if you download chapters at the same time with reading. Image loading and downloading working in the one-thread mode. And your page that you are reading putted in queue, but if first task in queue is active, app can't cancel it not to corrupt data. That's why it is happening. If i will find a way to make it faster, i will make it faster.
- **Reader doesn't load some images**
    - Please create Issue and describe how you have come to this (Parser you used, Manga, Chapter and page). This app supports only JPEG, BMP and PNG formats. Make sure that image that you load isn't a gif or else. You can check network address through debug console.
- **I downloaded app and can't see any catalogs**
    - Go to Catalog tab -> Press Triangle. This will update catalogs list.
- **How to setup proxy?**
    - You can write ip address like '192.169.0.1' or you can specify your proxy kind like 'socks5h://192.168.0.1' or "http", "https", "socks4a", "socks5", "socks5h"
- **Application is lagging sometimes, when new manga is appearing**
    - That's a print function problem, all new characters that appear should be cached. In the first launch, app can't load all glyphs because it's a longtime process, so app loads only Latin and Cryllic symbols.
## Building
Execute `build.bat` to create working .vpk
## TODO
* More languages
## Credits
[Rinnegatamante](https://github.com/Rinnegatamante) - [LuaPlayerPlus_Vita](https://github.com/Rinnegatamante/lpp-vita)
<br>[VitaSDK](https://github.com/vitasdk) - vitaSDK
<br>[xerpi](https://github.com/xerpi) - [libvita2d](https://github.com/xerpi/libvita2d)
<br>[theFloW](https://github.com/theOfficialFlow) - [VitaShell](https://github.com/TheOfficialFloW/VitaShell) for some functions
<br>[SamuEDL](https://github.com/SamuEDL) - Spanish translation
<br>[nguyenmao2101](https://github.com/nguyenmao2101) - Vietnamese translation
<br>[theheroGAC](https://github.com/theheroGAC) - Italian translation
<br>[Cimmerian-Iter](https://github.com/Cimmerian-Iter) - French translation
<br>[Kemal Sanlı](https://github.com/kemalsanli) - Turkish translation
<br>[rutantan](https://github.com/rutantan) - Portuguese (Brazil) translation
<br>[Qingyu510](https://github.com/Qingyu510) - Simplified Chinese & Traditional Chinese translation
<br>[tmihai20](https://github.com/tmihai20) - Romanian translation
<br>[tof4](https://github.com/tof4) - Polish translation
<br>[lukrynka](https://github.com/lukrynka) - German translation
<br>[kuragehime](https://github.com/kuragehimekurara1) - Japanese translation
