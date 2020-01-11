DEBUG_MODE  = false
LANG        = "RUS"

dofile "app0:assets/libs/utils.lua"
dofile "app0:assets/libs/console.lua"
dofile "app0:assets/libs/language.lua"
dofile "app0:assets/libs/globals.lua"
dofile "app0:assets/libs/parser.lua"

LIBRARY_MODE    = 0
CATALOGS_MODE   = 1
SETTINGS_MODE   = 2
MENU_MODE       = LIBRARY_MODE

MENU            = 0
READER          = 1
APP_MODE        = MENU

local ButtonsAnimX = {1, 1, 1}

Pad = Controls.read()
OldTouch, Touch = {}, {x = nil, y = nil}
while true do
    Graphics.initBlend()
    OldPad, Pad = Pad, Controls.read()
    OldTouch.x, OldTouch.y, Touch.x, Touch.y = Touch.x, Touch.y, Controls.readTouch()
    if APP_MODE == MENU then
        local bax = ButtonsAnimX
        for i = 1, 3 do
            if MENU_MODE + 1 == i then
                bax[i] = math.max(bax[i] - 0.075, 0)
            else
                bax[i] = math.min(bax[i] + 0.075, 1)
            end
        end
        Screen.clear(Color.new(20, 24, 46))
        Font.print(FONT32, 40, 25, Language[LANG].APP.LIBRARY, Color.new(255, 255, 255, 255-128*bax[1]))
        Font.print(FONT32, 80 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY), 25, Language[LANG].APP.CATALOGS, Color.new(255, 255, 255, 255-128*bax[2]))
        Font.print(FONT32, 920 - Font.getTextWidth(FONT32, Language[LANG].APP.SETTINGS), 25, Language[LANG].APP.SETTINGS, Color.new(255, 255, 255, 255-128*bax[3]))
    elseif APP_MODE == READER then
        Screen.clear(Color.new(255, 255, 255))
    end
    if DEBUG_MODE then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        Font.print(FONT, 0, 0, "DG_MODE", Color.new(255, 255, 255))
    end
    if APP_MODE == MENU then
        if Controls.check(Pad, SCE_CTRL_RTRIGGER) and not Controls.check(OldPad, SCE_CTRL_RTRIGGER) then
            MENU_MODE = math.min(MENU_MODE + 1, 2)
        end
        if Controls.check(Pad, SCE_CTRL_LTRIGGER) and not Controls.check(OldPad, SCE_CTRL_LTRIGGER) then
            MENU_MODE = math.max(MENU_MODE - 1, 0)
        end
        if Touch.x ~= nil and OldTouch.x == nil and Touch.y < 90 then
            if Touch.x < 60 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY) then
                MENU_MODE = LIBRARY_MODE
            elseif Touch.x < 100 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY) + Font.getTextWidth(FONT32, Language[LANG].APP.CATALOGS) then
                MENU_MODE = CATALOGS_MODE
            elseif Touch.x > 920 - Font.getTextWidth(FONT32, Language[LANG].APP.SETTINGS) then
                MENU_MODE = SETTINGS_MODE
            end
        end
    end
    if Controls.check(Pad, SCE_CTRL_START) and Controls.check(Pad, SCE_CTRL_SQUARE) and not (Controls.check(OldPad, SCE_CTRL_START) and Controls.check(OldPad, SCE_CTRL_SQUARE)) then
        DEBUG_MODE = not DEBUG_MODE
    end
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end