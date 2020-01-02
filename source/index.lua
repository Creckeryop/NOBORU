DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
dofile 'app0:assets/libs/parser.lua'
dofile 'app0:assets/libs/manga.lua'
dofile 'app0:assets/libs/reader.lua'
dofile 'app0:assets/libs/parsermanager.lua'
ParserManager.updateParserList()
while #ParserManager.getParserList()==0 do
    Net.update ()
    ParserManager.update ()
end
ParserManager.setParser(ParserManager.getParserList()[1])
Mangas = {}
ParserManager.getMangaListAsync(1, Mangas, 'manga')
local BROWSING_MODE = 1
local READING_MODE  = 2
local MODE          = 0
local pad = Controls.read ()
local oldpad = pad
local delta = 1
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    if Mangas.manga[#Mangas.manga] ~= "dead" then
        local loading = "Loading"..string.sub("...",1,(Timer.getTime(GlobalTimer)/400)%3+1)
        local width = Font.getTextWidth(LUA_FONT, loading)
        Font.print(LUA_FONT, 480 - width / 2, 272 - 10, loading, LUA_COLOR_WHITE)
    elseif Mangas.manga[3].chapters == nil then
        ParserManager.getChaptersAsync(Mangas.manga[3])
        while #Mangas.manga[3].chapters == 0 do
            Net.update()
            ParserManager.update()
        end
    elseif t == nil then
        ParserManager.getChapterInfoAsync(Mangas.manga[3].chapters[1])
        t = 1
    elseif Mangas.manga[3].chapters[1].pages[#Mangas.manga[3].chapters[1].pages] ~= 'dead' then
        local loading = "Loading"..string.sub("...",1,(Timer.getTime(GlobalTimer)/400)%3+1)
        local width = Font.getTextWidth(LUA_FONT, loading)
        Font.print(LUA_FONT, 480 - width / 2, 272 - 10, loading, LUA_COLOR_WHITE)
        Font.print(LUA_FONT, 0, 0, #Mangas.manga[3].chapters[1].pages, LUA_COLOR_WHITE)
    elseif Reader.p == nil then
        Reader.load(Mangas.manga[3].chapters[1].pages)
        Reader.p = 1
    else
        Reader.draw ()
    end
    Font.print(LUA_FONT, 0, 0, #Mangas.manga, LUA_COLOR_WHITE)
    if DEBUG_INFO then
        Graphics.fillRect(0, 960, 0, 20,Color.new(0,0,0,100))
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
    ParserManager.update ()
    delta = Timer.getTime (timer) / 1000 * 60
    Timer.destroy (timer)
end