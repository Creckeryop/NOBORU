local doesDirExist = System.doesDirExist
local listDirectory = System.listDirectory
local createDirectory = System.createDirectory
loadlib("utils")
loadlib("image")

local logo = Image:new(Graphics.loadImage("app0:assets/images/logo.png"))

Graphics.initBlend()
Screen.clear()
if logo then
    Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo.e)
end
Graphics.termBlend()

loadlib("changes")
loadlib("selector")
loadlib("console")
loadlib("language")
loadlib("globals")
loadlib("loading")
loadlib("net")
loadlib("parserhandler")
loadlib("settings")
loadlib("database")
loadlib("parser")
loadlib("catalogs")
loadlib("details")
loadlib("menu")
loadlib("panel")
loadlib("notifications")
loadlib("debug")
loadlib("chsaver")
loadlib("cache")
loadlib("reader")
loadlib("import")

os = nil
debug = nil
package = nil
require = nil
RemoveDirectory = nil


System = {
    getLanguage = System.getLanguage,
    extractZipAsync = System.extractZipAsync,
    getAsyncState = System.getAsyncState,
    getPictureResolution = System.getPictureResolution,
    extractFromZipAsync = System.extractFromZipAsync
}
if doesDirExist("ux0:data/noboru/parsers") then
    local path = "ux0:data/noboru/parsers/"
    local files = listDirectory(path) or {}
    for _, file in pairs(files) do
        if not file.directory then
            local suc, err = pcall(function()
                dofile(path .. file.name)
            end)
            if not suc then
                Console.error("Cant load " .. path .. ":" .. err)
            end
        end
    end
else
    createDirectory("ux0:data/noboru/parsers")
end

local fonts = {
    FONT12,
    FONT16,
    FONT20,
    FONT26,
    FONT30,
    BONT30,
    BONT16
}

local function preload_data()
    coroutine.yield("Loading settings")
    local suc, err = pcall(Settings.load, Settings)
    if not suc then Console.error(err) end
    if not Settings.SkipFontLoad then
        for k, v in ipairs(fonts) do
            coroutine.yield("Loading fonts " .. k .. "/" .. #fonts)
            Font.print(v, 0, 0, '1234567890AaBbCcDdEeFf\nGgHhIiJjKkLlMmNnOoPpQqRr\nSsTtUuVvWwXxYyZzАаБб\nВвГгДдЕеЁёЖжЗзИиЙйКкЛлМм\nНнОоПпРрСсТтУуФфХхЦцЧчШшЩщ\nЫыЪъЬьЭэЮюЯя!@#$%^&*()\n_+-=[]"\\/.,{}:;\'|? №~<>`\r—', COLOR_BLACK)
        end
    end
    coroutine.yield("Loading cache, checking existing data")
    suc, err = pcall(Cache.load)
    if not suc then Console.error(err) end
    coroutine.yield("Loading history")
    suc, err = pcall(Cache.loadHistory)
    if not suc then Console.error(err) end
    coroutine.yield("Loading library")
    suc, err = pcall(Database.load)
    if not suc then Console.error(err) end
    coroutine.yield("Checking saved chapters")
    suc, err = pcall(ChapterSaver.load)
    if not suc then Console.error(err) end
    Menu.setMode("LIBRARY")
    Panel.show()
    coroutine.yield("Checking for update")
    suc, err = pcall(Settings.checkUpdate, Settings)
    if not suc then Console.error(err) end
end

Screen.flip()
Screen.waitVblankStart()

MENU = 0
READER = 1
AppMode = MENU

local TouchLock = false

local f = coroutine.create(preload_data)

while coroutine.status(f) ~= "dead" do
    Graphics.initBlend()
    Screen.clear()
    local _, text, prog = coroutine.resume(f)
    if not _ then
        Console.error(text)
    end
    if text then
        Font.print(FONT16, 5, 518, text, Color.new(100, 100, 100))
    end
    if prog then
        Graphics.fillRect(0, 960 * prog, 542, 544, COLOR_WHITE)
    end
    if logo then
        Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo.e)
    end
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end

local pad, oldpad = Controls.read()
local oldtouch, touch = {}, {x = nil, y = nil}
local oldtouch2, touch2 = {}, {x = nil, y = nil}

local fade = 1

local function input()
    oldpad, pad = pad, Controls.read()
    oldtouch.x, oldtouch.y, oldtouch2.x, oldtouch2.y, touch.x, touch.y, touch2.x, touch2.y = touch.x, touch.y, touch2.x, touch2.y, Controls.readTouch()
    if Changes.isActive() then
        if touch.x or pad ~= 0 then
            oldpad = Changes.close(pad) or 0
        end
        pad = oldpad
        TouchLock = true
    end
    if touch2.x and AppMode ~= READER then
        TouchLock = true
    elseif not touch.x then
        TouchLock = false
    end

    if TouchLock then
        touch.x = nil
        touch.y = nil
        oldtouch.x = nil
        oldtouch.y = nil
        touch2.x = nil
        touch2.y = nil
        oldtouch2.x = nil
        oldtouch2.y = nil
    end

    if not StartSearch then
        if AppMode == MENU then
            Menu.input(oldpad, pad, oldtouch, touch)
        elseif AppMode == READER then
            Reader.input(oldpad, pad, oldtouch, touch, oldtouch2, touch2)
        end
    end
    Debug.input(oldpad, pad)
end

local function update()
    if fade == 0 then
        Panel.update()
        Threads.update()
        ParserManager.update()
        ChapterSaver.update()
        Changes.update()
    end
    if fade > 0 then
        fade = fade - fade / 8
        if fade < 1 / 254 then
            fade = 0
        end
    end
    if AppMode == MENU then
        Menu.update()
        if Details.getMode() == "END" then
            Panel.show()
        else
            Panel.hide()
        end
    elseif AppMode == READER then
        Reader.update()
        Panel.hide()
    end
    Notifications.update()
end

local function draw()
    Graphics.initBlend()
    if AppMode == MENU then
        Menu.draw()
    elseif AppMode == READER then
        Reader.draw()
    end
    Loading.draw()
    if fade > 0 then
        Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 255 * fade))
        if logo then
            Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo.e, Color.new(255, 255, 255, 255 * fade))
        end
    elseif logo then
        logo:free()
        logo = nil
        Changes.draw()
    end
    Notifications.draw()
    Panel.draw()
    Debug.draw()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end

while true do
    input()
    update()
    draw()
end
