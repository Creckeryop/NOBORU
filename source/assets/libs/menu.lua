Menu = {}

local logoSmall = Graphics.loadImage("app0:assets/images/logo-small.png")

---@param mode string
---Menu mode
local mode

---@param new_mode string | '"LIBRARY"' | '"CATALOGS"' | '"SETTINGS"' | '"DOWNLOAD"'
---Sets menu mode
function Menu.setMode(new_mode)
    if mode == new_mode then return end
    if new_mode == "LIBRARY" then
        Catalogs.setMode("LIBRARY")
    elseif new_mode == "CATALOGS" then
        Catalogs.setMode("PARSERS")
    elseif new_mode == "DOWNLOAD" then
        Catalogs.setMode("DOWNLOAD")
    end
    mode = new_mode
end

local next_mode = {
    ["LIBRARY"] = "CATALOGS",
    ["CATALOGS"] = "DOWNLOAD",
    ["DOWNLOAD"] = "SETTINGS",
    ["SETTINGS"] = "SETTINGS"
}

local prev_mode = {
    ["LIBRARY"] = "LIBRARY",
    ["CATALOGS"] = "LIBRARY",
    ["DOWNLOAD"] = "CATALOGS",
    ["SETTINGS"] = "DOWNLOAD"
}

function Menu.input(oldpad, pad, oldtouch, touch)
    if Details.getMode() == "END" then
        if Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldpad, SCE_CTRL_RTRIGGER) then
            Menu.setMode(next_mode[mode])
        end
        if Controls.check(pad, SCE_CTRL_LTRIGGER) and not Controls.check(oldpad, SCE_CTRL_LTRIGGER) then
            Menu.setMode(prev_mode[mode])
        end
        if touch.x and not oldtouch.x and touch.x < 250 then
            if touch.y < 97 then
                _ = _
            elseif touch.y < 157 then
                Menu.setMode("LIBRARY")
            elseif touch.y < 200 then
                Menu.setMode("CATALOGS")
            elseif touch.y > 460 then
                Menu.setMode("SETTINGS")
            elseif touch.y > 400 then
                Menu.setMode("DOWNLOAD")
            end
        end
        if mode == "CATALOGS" or mode == "LIBRARY" or mode == "DOWNLOAD" then
            Catalogs.input(oldpad, pad, oldtouch, touch)
        end
    else
        Details.input(oldpad, pad, oldtouch, touch)
    end
end

function Menu.update()
    if mode == "CATALOGS" or mode == "LIBRARY" or mode=="DOWNLOAD" then
        Catalogs.update()
    end
    Details.update()
end

local button_a = {
    ["LIBRARY"] = 1,
    ["CATALOGS"] = 1,
    ["DOWNLOAD"] = 1,
    ["SETTINGS"] = 1
}

function Menu.draw()
    for k, v in pairs(button_a) do
        if k == mode then
            button_a[k] = math.max(v - 0.1, 0)
        else
            button_a[k] = math.min(v + 0.1, 1)
        end
    end
    Screen.clear(Color.new(0, 0, 0))
    Graphics.drawImage(0, 0, logoSmall)
    Graphics.fillRect(255, 960, 0, 544, Color.new(245, 245, 245))
    Font.print(FONT30, 30, 107, Language[LANG].APP.LIBRARY, Color.new(255, 255, 255, 255 - 128 * button_a["LIBRARY"]))
    Font.print(FONT30, 30, 167, Language[LANG].APP.CATALOGS, Color.new(255, 255, 255, 255 - 128 * button_a["CATALOGS"]))
    Font.print(FONT30, 30, 414, Language[LANG].APP.DOWNLOAD, Color.new(255, 255, 255, 255 - 128 * button_a["DOWNLOAD"]))
    Font.print(FONT30, 30, 472, Language[LANG].APP.SETTINGS, Color.new(255, 255, 255, 255 - 128 * button_a["SETTINGS"]))
    if Details.getFade() ~= 1 then
        if mode == "CATALOGS" or mode == "LIBRARY" or mode == "DOWNLOAD" then
            Catalogs.draw()
        end
    end
    Details.draw()
end
