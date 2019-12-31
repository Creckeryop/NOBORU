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
local manga = ReadManga:getManga(0)[3]
local chapters = ReadManga:getChapters(manga)
local chapter = chapters[1]
local pages = ReadManga:getPagesCount(chapter)
local now_page = 0
local now_chapter = 1
local pad = Controls.read ()
local oldpad = pad
local delta = 1
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    Reader.draw ()
    if DEBUG_INFO then
        Graphics.debugPrint (0, 0, 'FPS: '..math.floor (60 / delta).." "..now_page, LUA_COLOR_WHITE)
        --Console.draw ()
    end
    Graphics.termBlend ()
    Screen.flip ()
    Screen.waitVblankStart ()
end
local function update (delta)
    if now_page > 0 and chapter.pages[now_page].image ~= Reader.image then
        Reader.setImage(chapter.pages[now_page].image)
    end
    Reader.update()
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
                if chapter.pages[now_page + 1].image == nil then
                    Net.downloadImageAsync(chapter.pages[now_page+1][2]..chapter.pages[now_page+1][3],chapter.pages[now_page+1],"image")
                end
            end
            if now_page - 2 > 0 then
                if chapter.pages[now_page - 2].image ~= nil and chapter.pages[now_page - 2].image ~= 0 then
                    Graphics.freeImage(chapter.pages[now_page - 2].image)
                    chapter.pages[now_page - 2].image = nil
                end
            end
        end
    elseif Controls.check (pad, SCE_CTRL_LEFT) and not Controls.check (oldpad, SCE_CTRL_LEFT) then
        if now_page > 1 then
            now_page = now_page - 1
            if chapter.pages[now_page].image == nil then
                Net.downloadImageAsync(chapter.pages[now_page][2]..chapter.pages[now_page][3],chapter.pages[now_page],"image")
            end
            if now_page - 1 > 0 then
                if chapter.pages[now_page - 1].image == nil then
                    Net.downloadImageAsync(chapter.pages[now_page-1][2]..chapter.pages[now_page-1][3],chapter.pages[now_page-1],"image")
                end
            end
            if now_page + 2 <= pages then
                if chapter.pages[now_page + 2].image ~= nil and chapter.pages[now_page + 2].image ~= 0 then
                    Graphics.freeImage(chapter.pages[now_page + 2].image)
                    chapter.pages[now_page + 2].image = nil
                end
            end
        end
    end
    if Controls.check (pad, SCE_CTRL_TRIANGLE) and not Controls.check (oldpad, SCE_CTRL_TRIANGLE) then
        if now_chapter < #chapters then
            now_chapter = now_chapter + 1
            now_page = 0
            for i = 1, #chapter.pages do
                if chapter.pages[i].image ~= nil and chapter.pages[i].image ~= 0 then
                    Graphics.freeImage(chapter.pages[i].image)
                    chapter.pages[i].image = nil
                end
            end
            chapter = chapters[now_chapter]
            pages = ReadManga:getPagesCount(chapter)
            Reader.setImage(nil)
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
Touch = {}
OldTouch = {}
while true do
    local timer = Timer.new ()
    oldpad, pad = pad, Controls.read ()
    OldTouch.x, OldTouch.y, Touch.x, Touch.y = Touch.x, Touch.y, Controls.readTouch ()
    input ()
    update (delta)
    draw ()
    Net.update ()
    delta = Timer.getTime (timer) / 1000 * 60
    Timer.destroy (timer)
end