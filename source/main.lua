local ffi = require 'ffi'
DEBUG_MODE  = false
LANG        = "RUS"

dofile "app0:assets/libs/utils.lua"
dofile "app0:assets/libs/console.lua"
dofile "app0:assets/libs/language.lua"
dofile "app0:assets/libs/globals.lua"
dofile "app0:assets/libs/loading.lua"
dofile "app0:assets/libs/parser.lua"
dofile "app0:assets/libs/net.lua"
dofile "app0:assets/libs/parserhandler.lua"
dofile "app0:assets/libs/reader.lua"
dofile "app0:assets/libs/menu.lua"
dofile "ux0:data/vsKoob/parsers.lua"

MENU            = 0
READER          = 1
APP_MODE        = MENU
TOUCH_LOCK      = false
local fonts = {FONT12, FONT, FONT26, FONT30}
for i = 1, 4 do
    Graphics.initBlend()
    Screen.clear()
    Font.print(fonts[i],0,0,"1234567890AaBbCcDdEeFf\nGgHhIiJjKkLlMmNnOoPpQqRr\nSsTtUuVvWwXxYyZzАаБб\nВвГгДдЕеЁёЖжЗзИиЙйКкЛлМм\nНнОоПпРрСсТтУуФфХхЦцЧчШшЩщ\nЫыЪъЬьЭэЮюЯя!@#$%^&*()\n_+-=[]\"\\/.,{}:;'|? №~<>`\r—",COLOR_WHITE)
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end
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

while true do
    Graphics.initBlend()
    OldPad, Pad = Pad, Controls.read()
    OldTouch.x, OldTouch.y, OldTouch2.x, OldTouch2.y, Touch.x, Touch.y, Touch2.x, Touch2.y = Touch.x, Touch.y, Touch2.x, Touch2.y, Controls.readTouch()
    if Touch2.x and APP_MODE ~= READER then
        TOUCH_LOCK = true
    end
    if Touch.x == nil then
        TOUCH_LOCK = false
    end
    if TOUCH_LOCK then
        Touch.x = nil
        Touch.y = nil
        Touch2.x = nil
        Touch2.y = nil
    end

    if APP_MODE == MENU then
        Menu.Input(OldPad, Pad, OldTouch, Touch)
    elseif APP_MODE == READER then
        Reader.Input(OldPad, Pad, OldTouch, Touch, OldTouch2, Touch2)
    end
    
    if APP_MODE == MENU then
        Menu.Update(1)
    elseif APP_MODE == READER then
        Reader.Update(1)
    end

    if APP_MODE == MENU then
        Menu.Draw()
    elseif APP_MODE == READER then
        Reader.Draw()
    end

    Loading.Draw()

    if DEBUG_MODE then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        Font.print(FONT, 0, 0, "DG_MODE "..threads.GetTasksNum(), COLOR_WHITE)
        local mem_net = mem_to_str(threads.GetMemoryDownloaded(), "NET")
        Font.print(FONT,  940 - Font.getTextWidth(FONT, mem_net), 0, mem_net, Color.new(0,255,0))
        local mem_var = mem_to_str(collectgarbage("count") * 1024, "VAR")
        Font.print(FONT,  480 - Font.getTextWidth(FONT, mem_var)/2, 0, mem_var, Color.new(255,128,0))
        Console.draw()
    end

    if Controls.check(Pad, SCE_CTRL_SELECT) and not Controls.check(OldPad, SCE_CTRL_SELECT) then
        Loading.SetMode(LOADING_WHITE)
    end

    if bit32.bxor(Pad, SCE_CTRL_START + SCE_CTRL_SQUARE) == 0 and bit32.bxor(OldPad, SCE_CTRL_START + SCE_CTRL_SQUARE) ~= 0 then
        DEBUG_MODE = not DEBUG_MODE
    end
    threads.Update()
    ParserManager.Update()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end