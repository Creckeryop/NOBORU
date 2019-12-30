DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
dofile 'app0:assets/libs/parser.lua'
dofile 'app0:assets/libs/manga.lua'
dofile 'app0:assets/libs/reader.lua'
Network.init ()
Net.downloadFile ('https://raw.githubusercontent.com/Creckeryop/vsKoob-parsers/master/parsers.lua', LUA_APPDATA_DIR..'parsers.lua')
dofile (LUA_APPDATA_DIR..'parsers.lua')
local manga = ReadManga:getManga(0)[2]
local chapter = ReadManga:getChapters(manga)[2]
local pages = ReadManga:getPagesCount(chapter)
local now_page = 1
local pad = Controls.read ()
local oldpad = pad
local delta = 1
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    Reader.draw ()
    if DEBUG_INFO then
        Graphics.debugPrint (0, 0, 'FPS: '..math.floor (60 / delta), LUA_COLOR_WHITE)
        Console.draw ()
    end
    Graphics.termBlend ()
    Screen.flip ()
    Screen.waitVblankStart ()
end
local function update (delta)
    if chapter.pages[now_page].image ~= Reader.image then
        Reader.setImage(chapter.pages[now_page].image)
    end
end
local function input ()
    Reader.input (pad, oldpad)
    if Controls.check (pad, SCE_CTRL_RIGHT) and not Controls.check (oldpad, SCE_CTRL_RIGHT) then
        if now_page < pages then
            now_page = now_page + 1
            if chapter.pages[now_page].image == nil then
                Net.downloadImageAsync(chapter.pages[now_page][2]..chapter.pages[now_page][3],chapter.pages[now_page],"image")
            end
            if now_page + 1 <= pages then
                Net.downloadImageAsync(chapter.pages[now_page+1][2]..chapter.pages[now_page+1][3],chapter.pages[now_page+1],"image")
            end
        end
    elseif Controls.check (pad, SCE_CTRL_LEFT) and not Controls.check (oldpad, SCE_CTRL_LEFT) then
        if now_page > 1 then
            now_page = now_page - 1
            if chapter.pages[now_page].image == nil then
                Net.downloadImageAsync(chapter.pages[now_page][2]..chapter.pages[now_page][3],chapter.pages[now_page],"image")
            end
        end
    end
    if Controls.check (pad, SCE_CTRL_RTRIGGER) and not Controls.check (oldpad, SCE_CTRL_RTRIGGER) then
        DEBUG_INFO = not DEBUG_INFO
    end
    if Controls.check (pad, SCE_CTRL_START) then
        Network.term ()
        System.exit ()
    end
end
while true do
    local timer = Timer.new ()
    pad = Controls.read ()
    input ()
    update (delta)
    draw ()
    Net.update ()
    oldpad = pad
    delta = Timer.getTime (timer) / 1000 * 60
    Timer.destroy (timer)
end