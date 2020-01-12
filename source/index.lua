DEBUG_MODE  = false
LANG        = "ENG"

dofile "app0:assets/libs/utils.lua"
dofile "app0:assets/libs/console.lua"
dofile "app0:assets/libs/language.lua"
dofile "app0:assets/libs/globals.lua"
dofile "app0:assets/libs/loading.lua"
dofile "app0:assets/libs/parser.lua"
dofile "app0:assets/libs/threads.lua"
dofile "app0:assets/libs/reader.lua"
dofile "app0:assets/libs/menu.lua"

MENU            = 0
READER          = 1
APP_MODE        = MENU

local Pad = Controls.read()
local OldTouch, Touch = {}, {x = nil, y = nil}

local Menu, Reader = Menu, Reader
local texture
while true do
    Graphics.initBlend()
    OldPad, Pad = Pad, Controls.read()
    OldTouch.x, OldTouch.y, Touch.x, Touch.y = Touch.x, Touch.y, Controls.readTouch()
    if APP_MODE == MENU then
        Menu.Input(OldPad, Pad, OldTouch, Touch)
        Menu.Update(1)
        Menu.Draw()
    elseif APP_MODE == READER then
        Reader.Input(OldPad, Pad, OldTouch, Touch)
        Reader.Update(1)
        Reader.Draw()
    end
    if texture ~= nil then
        Graphics.drawImage(0, 0, texture)
    end
    Loading.Draw()
    if DEBUG_MODE then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        Font.print(FONT, 0, 0, "DG_MODE", Color.new(255, 255, 255))
        Console.draw()
    end
    if Controls.check(Pad, SCE_CTRL_SELECT) and not Controls.check(OldPad, SCE_CTRL_SELECT) then
        Loading.SetMode(LOADING_WHITE)
        Threads.AddTask{
            Type = "FileDownload",
            Link = "https://i.ytimg.com/vi/4U3pZG4RXh4/maxresdefault.jpg",
            Path = "image.jpg",
            OnComplete = function()
                if System.doesFileExist("ux0:data/Moondayo/image.jpg") then
                    Threads.InsertTask{
                        Type = "ImageLoad",
                        Path = "image.jpg",
                        Save = function (new_text)
                            texture = new_text
                        end
                    }
                end
            end}
    end
    if Controls.check(Pad, SCE_CTRL_START) and Controls.check(Pad, SCE_CTRL_SQUARE) and not (Controls.check(OldPad, SCE_CTRL_START) and Controls.check(OldPad, SCE_CTRL_SQUARE)) then
        DEBUG_MODE = not DEBUG_MODE
    end
    Threads.Update()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end