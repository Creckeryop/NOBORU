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
READER_MODE     = 3
MODE            = LIBRARY_MODE

Pad = Controls.read()
OldTouch, Touch = {}, {x = nil, y = nil}
while true do
    Graphics.initBlend()
    OldPad, Pad = Pad, Controls.read()
    OldTouch.x, OldTouch.y, Touch.x, Touch.y = Touch.x, Touch.y, Controls.readTouch()
    if MODE ~= READER_MODE then
        Screen.clear(Color.new(20, 24, 46))
        local textColor
        if MODE == LIBRARY_MODE then textColor = Color.new(255, 255, 255) else textColor = Color.new(128, 128, 128) end
        Font.print(FONT32, 40, 25, Language[LANG].APP.LIBRARY, textColor)
        if MODE == CATALOGS_MODE then textColor = Color.new(255, 255, 255) else textColor = Color.new(128, 128, 128) end
        Font.print(FONT32, 80 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY), 25, Language[LANG].APP.CATALOGS, textColor)
        if MODE == SETTINGS_MODE then textColor = Color.new(255, 255, 255) else textColor = Color.new(128, 128, 128) end
        Font.print(FONT32, 920 - Font.getTextWidth(FONT32, Language[LANG].APP.SETTINGS), 25, Language[LANG].APP.SETTINGS, textColor)
    else
        Screen.clear(Color.new(255, 255, 255))
    end
    if DEBUG_MODE then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        Font.print(FONT, 0, 0, "DG_MODE", Color.new(255, 255, 255))
    end
    if MODE ~= READER_MODE then
        if Controls.check(Pad, SCE_CTRL_RTRIGGER) and not Controls.check(OldPad, SCE_CTRL_RTRIGGER) then
            MODE = math.min(MODE + 1, 2)
        end
        if Controls.check(Pad, SCE_CTRL_LTRIGGER) and not Controls.check(OldPad, SCE_CTRL_LTRIGGER) then
            MODE = math.max(MODE - 1, 0)
        end
        if Touch.x ~= nil and OldTouch.x == nil and Touch.y < 90 then
            if Touch.x < 60 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY) then
                MODE = LIBRARY_MODE
            elseif Touch.x < 100 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY) + Font.getTextWidth(FONT32, Language[LANG].APP.CATALOGS) then
                MODE = CATALOGS_MODE
            elseif Touch.x > 920 - Font.getTextWidth(FONT32, Language[LANG].APP.SETTINGS) then
                MODE = SETTINGS_MODE
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