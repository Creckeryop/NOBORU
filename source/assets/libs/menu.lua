LIBRARY_MODE    = 0
CATALOGS_MODE   = 1
SETTINGS_MODE   = 2
local MENU_MODE = -1
local ButtonsAnimX = {1, 1, 1}

Menu = {
    SetMode = function (new_mode)
        if MENU_MODE == new_mode then return end
        MENU_MODE = new_mode
        if MENU_MODE == LIBRARY_MODE then
            Loading.SetMode(LOADING_WHITE)
        else
            Loading.SetMode(LOADING_NONE)
        end
    end,
    Input = function (OldPad, Pad, OldTouch, Touch)
        if Controls.check(Pad, SCE_CTRL_RTRIGGER) and not Controls.check(OldPad, SCE_CTRL_RTRIGGER) then
            Menu.SetMode(math.min(MENU_MODE + 1, 2))
        end
        if Controls.check(Pad, SCE_CTRL_LTRIGGER) and not Controls.check(OldPad, SCE_CTRL_LTRIGGER) then
            Menu.SetMode(math.max(MENU_MODE - 1, 0))
        end
        if Touch.x ~= nil and OldTouch.x == nil and Touch.y < 90 then
            if Touch.x < 60 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY) then
                Menu.SetMode(LIBRARY_MODE)
            elseif Touch.x < 100 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY) + Font.getTextWidth(FONT32, Language[LANG].APP.CATALOGS) then
                Menu.SetMode(CATALOGS_MODE)
            elseif Touch.x > 920 - Font.getTextWidth(FONT32, Language[LANG].APP.SETTINGS) then
                Menu.SetMode(SETTINGS_MODE)
            end
        end
    end,
    Update = function (delta)
        
    end,
    Draw = function ()
        local bax = ButtonsAnimX
        for i = 1, 3 do
            if MENU_MODE + 1 == i then
                bax[i] = math.max(bax[i] - 0.1, 0)
            else
                bax[i] = math.min(bax[i] + 0.1, 1)
            end
        end
        Screen.clear(Color.new(20, 24, 46))
        Font.print(FONT32, 40, 25, Language[LANG].APP.LIBRARY, Color.new(255, 255, 255, 255-128*bax[1]))
        Font.print(FONT32, 80 + Font.getTextWidth(FONT32, Language[LANG].APP.LIBRARY), 25, Language[LANG].APP.CATALOGS, Color.new(255, 255, 255, 255-128*bax[2]))
        Font.print(FONT32, 920 - Font.getTextWidth(FONT32, Language[LANG].APP.SETTINGS), 25, Language[LANG].APP.SETTINGS, Color.new(255, 255, 255, 255-128*bax[3]))
    end
}

Menu.SetMode(LIBRARY_MODE)