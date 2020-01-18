dofile "app0:assets/libs/catalogs.lua"
dofile "app0:assets/libs/details.lua"

LIBRARY_MODE    = 0
CATALOGS_MODE   = 1
SETTINGS_MODE   = 2
local MENU_MODE = -1

local ButtonsAnimX = {1, 1, 1}

Menu = {
    SetMode = function (new_mode)
        if MENU_MODE == new_mode then return end
        if MENU_MODE == CATALOGS_MODE then
            Catalogs.Shrink()
        end
        MENU_MODE = new_mode
    end,
    Input = function (OldPad, Pad, OldTouch, Touch)
        if Details.GetMode() == DETAILS_END then
            if Controls.check(Pad, SCE_CTRL_RTRIGGER) and not Controls.check(OldPad, SCE_CTRL_RTRIGGER) then
                Menu.SetMode(math.min(MENU_MODE + 1, 2))
            end
            if Controls.check(Pad, SCE_CTRL_LTRIGGER) and not Controls.check(OldPad, SCE_CTRL_LTRIGGER) then
                Menu.SetMode(math.max(MENU_MODE - 1, 0))
            end
            if Touch.x and OldTouch.x == nil and Touch.x < 250 then
                if Touch.y < 45 then
                elseif Touch.y < 85 then
                    Menu.SetMode(LIBRARY_MODE)
                elseif Touch.y < 145 then
                    Menu.SetMode(CATALOGS_MODE)
                elseif Touch.y > 460 then
                    Menu.SetMode(SETTINGS_MODE)
                end
            end
            if MENU_MODE == CATALOGS_MODE then
                Catalogs.Input(OldPad, Pad, OldTouch, Touch)
            end
        else
            Details.Input(OldPad, Pad, OldTouch, Touch)
        end
    end,
    Update = function (delta)
        if MENU_MODE == CATALOGS_MODE then
            Catalogs.Update(delta)
        end
        Details.Update(delta)
    end,
    Draw = function ()
        for i = 1, 3 do
            if MENU_MODE + 1 == i then
                ButtonsAnimX[i] = math.max(ButtonsAnimX[i] - 0.1, 0)
            else
                ButtonsAnimX[i] = math.min(ButtonsAnimX[i] + 0.1, 1)
            end
        end
        Screen.clear(Color.new(0, 0, 0))
        Graphics.fillRect(255, 960, 0, 544,Color.new(233,233,233))
        Font.print(FONT30, 30,  45,  Language[LANG].APP.LIBRARY, Color.new(255, 255, 255, 255-128*ButtonsAnimX[1]))
        Font.print(FONT30, 30, 105, Language[LANG].APP.CATALOGS, Color.new(255, 255, 255, 255-128*ButtonsAnimX[2]))
        Font.print(FONT30, 30, 472, Language[LANG].APP.SETTINGS, Color.new(255, 255, 255, 255-128*ButtonsAnimX[3]))
        if Details.GetFade() ~= 1 then
            if MENU_MODE == CATALOGS_MODE then
                Catalogs.Draw()
            end
        end
        Details.Draw()
    end
}

Menu.SetMode(LIBRARY_MODE)