local logo = Graphics.loadImage("app0:assets/images/logo.png")

Graphics.initBlend()
Screen.clear()
Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo)
Graphics.termBlend()

loadlib("utils")
loadlib("selector")
loadlib("console")
loadlib("language")
loadlib("globals")
loadlib("loading")
loadlib("net")
loadlib("parserhandler")
loadlib("reader")
loadlib("catalogs")
loadlib("details")
loadlib("menu")
loadlib("panel")
loadlib("notifications")
loadlib("debug")
loadlib("cache")

Settings:load()
Database.load()
Cache.load()
Menu.setMode("LIBRARY")
Panel.show()

MENU = 0
READER = 1
AppMode = MENU

local TouchLock = false

local fonts = {
    FONT12,
    FONT16,
    FONT20,
    FONT26,
    FONT30
}
Screen.flip()
Screen.waitVblankStart()
for k, v in ipairs(fonts) do
    Graphics.initBlend()
    Screen.clear()
    Font.print(v, 0, 0, '1234567890AaBbCcDdEeFf\nGgHhIiJjKkLlMmNnOoPpQqRr\nSsTtUuVvWwXxYyZzАаБб\nВвГгДдЕеЁёЖжЗзИиЙйКкЛлМм\nНнОоПпРрСсТтУуФфХхЦцЧчШшЩщ\nЫыЪъЬьЭэЮюЯя!@#$%^&*()\n_+-=[]"\\/.,{}:;\'|? №~<>`\r—', COLOR_BLACK)
    Font.print(FONT16, 0, 0, "Loading Fonts " .. k .. "/" .. #fonts, Color.new(100, 100, 100))
    Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo)
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
        Cache.update()
    end
    if fade > 0 then
        fade = fade - fade / 8
        if fade < 1/254 then
            fade = 0
        end
    end
    if AppMode == MENU then
        Menu.update()
    elseif AppMode == READER then
        Reader.update()
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
    Notifications.draw()
    Panel.draw()
    Debug.draw()
    if fade > 0 then
        Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 255 * fade))
        Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo, Color.new(255, 255, 255, 255 * fade))
    end
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end

while true do
    input()
    update()
    draw()
end
