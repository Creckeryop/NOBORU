DEBUG_MODE  = false
LANG        = "RUS"

local logo = Graphics.loadImage("app0:assets/images/logo.png")
Graphics.initBlend()
Screen.clear()
Graphics.drawImage(480-666/2, 272-172/2, logo)
Graphics.termBlend()
dofile("app0:assets/libs/utils.lua")
dofile("app0:assets/libs/console.lua")
dofile("app0:assets/libs/language.lua")
dofile("app0:assets/libs/globals.lua")
dofile("app0:assets/libs/loading.lua")
dofile("app0:assets/libs/net.lua")
dofile("app0:assets/libs/parserhandler.lua")
dofile("app0:assets/libs/reader.lua")
dofile("app0:assets/libs/menu.lua")
dofile("app0:assets/libs/panel.lua")
dofile("app0:assets/libs/notifications.lua")

Database.load()

MENU = 0
READER = 1
AppMode = MENU
TouchLock = false

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
    Font.print(v, 0, 0, "1234567890AaBbCcDdEeFf\nGgHhIiJjKkLlMmNnOoPpQqRr\nSsTtUuVvWwXxYyZzАаБб\nВвГгДдЕеЁёЖжЗзИиЙйКкЛлМм\nНнОоПпРрСсТтУуФфХхЦцЧчШшЩщ\nЫыЪъЬьЭэЮюЯя!@#$%^&*()\n_+-=[]\"\\/.,{}:;'|? №~<>`\r—",COLOR_BLACK)
    Font.print(FONT16, 0, 0, "Loading Fonts "..k.."/"..#fonts, Color.new(100, 100, 100))
    Graphics.drawImage(480-666/2, 272-172/2, logo)
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end

Panel.show()
local Pad = Controls.read()
local OldTouch, Touch = {}, {x = nil, y = nil}
local OldTouch2, Touch2 = {}, {x = nil, y = nil}

local function mem_to_str(bytes, name)
    local str = "Bytes"
    if bytes > 1024 then
        bytes = bytes / 1024
        str = "KBytes"
        if bytes > 1024 then
            bytes = bytes / 1024
            str = "MBytes"
            if bytes > 1024 then
                bytes = bytes / 1024
                str = "GBytes"
            end
        end
    end
    return string.format('%s: %.2f %s', name, bytes, str)
end
local Menu, Reader = Menu, Reader
local fade = 1
while true do
    OldPad, Pad = Pad, Controls.read()
    OldTouch.x, OldTouch.y, OldTouch2.x, OldTouch2.y, Touch.x, Touch.y, Touch2.x, Touch2.y = Touch.x, Touch.y, Touch2.x, Touch2.y, Controls.readTouch()
    if Touch2.x and AppMode ~= READER then
        TouchLock = true
    elseif not Touch.x then
        TouchLock = false
    end

    if TouchLock then
        Touch.x = nil
        Touch.y = nil
        OldTouch.x = nil
        OldTouch.y = nil
        Touch2.x = nil
        Touch2.y = nil
        OldTouch2.x = nil
        OldTouch2.y = nil
    end

    if not StartSearch then
        if AppMode == MENU then
            Menu.Input(OldPad, Pad, OldTouch, Touch)
        elseif AppMode == READER then
            Reader.Input(OldPad, Pad, OldTouch, Touch, OldTouch2, Touch2)
        end
    end
    if fade > 0 then
        fade = fade - fade / 8
        if fade < 0.0001 then
            fade = 0
        end
    end
    if AppMode == MENU then
        Menu.Update(1)
    elseif AppMode == READER then
        Reader.Update(1)
    end

    Notifications.Update()

    Graphics.initBlend()
    if AppMode == MENU then
        Menu.Draw()
    elseif AppMode == READER then
        Reader.Draw()
    end
    Loading.draw()
    Notifications.Draw()
    Panel.draw()

    if DEBUG_MODE then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        Font.print(FONT16, 0, 0, "TASKS "..Threads.GetTasksNum(), COLOR_WHITE)
        local mem_net = mem_to_str(Threads.GetMemoryDownloaded(), "NET")
        Font.print(FONT16, 720 - Font.getTextWidth(FONT16, mem_net)/2, 0, mem_net, Color.new(0, 255, 0))
        local mem_var = mem_to_str(collectgarbage("count") * 1024, "VAR")
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, mem_var)/2, 0, mem_var, Color.new(255, 128, 0))
        local mem_gpu = mem_to_str(GetTextureMemoryUsed(), "GPU")
        Font.print(FONT16, 240 - Font.getTextWidth(FONT16, mem_gpu)/2, 0, mem_gpu, Color.new(0, 0, 255))
        Console.draw()
    end
    if fade > 0 then
        Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 255 * fade))
        Graphics.drawImage(480 - 666 / 2, 272 - 172 / 2, logo, Color.new(255, 255, 255, 255 * fade))
    end
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()

    if bit32.bxor(Pad, SCE_CTRL_START + SCE_CTRL_LEFT) == 0 and bit32.bxor(OldPad, SCE_CTRL_START + SCE_CTRL_LEFT) ~= 0 then
        DEBUG_MODE = not DEBUG_MODE
    end
    Panel.update()
    if fade == 0 then
        Threads.Update()
        ParserManager.Update()
    end
end