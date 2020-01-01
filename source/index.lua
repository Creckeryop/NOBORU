DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
dofile 'app0:assets/libs/parser.lua'
dofile 'app0:assets/libs/manga.lua'
dofile 'app0:assets/libs/reader.lua'
Net.downloadFile ('https://raw.githubusercontent.com/Creckeryop/vsKoob-parsers/master/parsers.lua', LUA_APPDATA_DIR..'parsers.lua')
dofile (LUA_APPDATA_DIR..'parsers.lua')
local manga = ReadManga:getManga(0)[3]
local chapters = ReadManga:getChapters(manga)
local chapter = chapters[1]
local pages = ReadManga:getPagesCount(chapter)
local links = {}
for i = 1, pages do
    links[i] = chapter.pages[i][2]..chapter.pages[i][3]
end 
Reader.load(links)
local pad = Controls.read ()
local oldpad = pad
local delta = 1
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    Reader.draw ()
    if DEBUG_INFO then
        Graphics.fillRect(0, 0, 960, 20,Color.new(0,0,0,100))
        Graphics.debugPrint (0, 0, 'FPS: '..math.floor (60 / delta), LUA_COLOR_WHITE)
        Console.draw ()
    end
    Graphics.termBlend ()
    Screen.flip ()
    Screen.waitVblankStart ()
end
local function update (delta)
    Reader.update()
end
local function input ()
    Reader.input (pad, oldpad)
    if Controls.check (pad, SCE_CTRL_SQUARE) and not Controls.check (oldpad, SCE_CTRL_SQUARE) then
        DEBUG_INFO = not DEBUG_INFO
    end
    if Controls.check (pad, SCE_CTRL_START) then
        Net.shutDown ()
        System.exit ()
    end
end
Touch = {}
OldTouch = {}
Touch2 = {}
OldTouch2 = {}
while true do
    local timer = Timer.new ()
    oldpad, pad = pad, Controls.read ()
    OldTouch.x, OldTouch.y,OldTouch2.x,OldTouch2.y, Touch.x, Touch.y,Touch2.x, Touch2.y = Touch.x, Touch.y,Touch2.x, Touch2.y, Controls.readTouch ()
    input ()
    update (delta)
    draw ()
    Net.update ()
    delta = Timer.getTime (timer) / 1000 * 60
    Timer.destroy (timer)
end