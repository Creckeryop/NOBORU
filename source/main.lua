LANG = "RUS"

local logo = Graphics.loadImage("app0:assets/images/logo.png")

Graphics.initBlend()
Screen.clear()
Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo)
Graphics.termBlend()

dofile("app0:assets/libs/utils.lua")
dofile("app0:assets/libs/selector.lua")
dofile("app0:assets/libs/console.lua")
dofile("app0:assets/libs/language.lua")
dofile("app0:assets/libs/globals.lua")
dofile("app0:assets/libs/loading.lua")
dofile("app0:assets/libs/net.lua")
dofile("app0:assets/libs/parserhandler.lua")
dofile("app0:assets/libs/reader.lua")
dofile("app0:assets/libs/catalogs.lua")
dofile("app0:assets/libs/details.lua")
dofile("app0:assets/libs/menu.lua")
dofile("app0:assets/libs/panel.lua")
dofile("app0:assets/libs/notifications.lua")
dofile("app0:assets/libs/debug.lua")

Database.load()
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
