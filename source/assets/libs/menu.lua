Menu = {}

local logoSmall = Image:new(Graphics.loadImage("app0:assets/images/logo-small.png"))

---@param mode string
---Menu mode
local mode

---@param new_mode string | '"LIBRARY"' | '"CATALOGS"' | '"SETTINGS"' | '"DOWNLOAD"'
---Sets menu mode
function Menu.setMode(new_mode)
    if mode == new_mode then return end
    Catalogs.setMode(new_mode)
    mode = new_mode
end

local next_mode = {
    ["LIBRARY"] = "CATALOGS",
    ["CATALOGS"] = "HISTORY",
    ["HISTORY"] = "IMPORT",
    ["IMPORT"] = "DOWNLOAD",
    ["DOWNLOAD"] = "SETTINGS",
    ["SETTINGS"] = "SETTINGS"
}

local prev_mode = {
    ["LIBRARY"] = "LIBRARY",
    ["CATALOGS"] = "LIBRARY",
    ["HISTORY"] = "CATALOGS",
    ["IMPORT"] = "HISTORY",
    ["DOWNLOAD"] = "IMPORT",
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
            elseif touch.y < 157 then
                Menu.setMode("LIBRARY")
            elseif touch.y < 200 then
                Menu.setMode("CATALOGS")
            elseif touch.y < 270 then
                Menu.setMode("HISTORY")
            elseif touch.y > 460 then
                Menu.setMode("SETTINGS")
            elseif touch.y > 400 then
                Menu.setMode("DOWNLOAD")
            elseif touch.y > 340 then
                Menu.setMode("IMPORT")
            end
        end
        Catalogs.input(oldpad, pad, oldtouch, touch)
    else
        if Extra.getMode() == "END" then
            Details.input(oldpad, pad, oldtouch, touch)
        else
            Extra.input(oldpad, pad, oldtouch, touch)
        end
    end
end

function Menu.update()
    Catalogs.update()
    Extra.update()
    Details.update()
end

local button_a = {
    ["LIBRARY"] = 1,
    ["CATALOGS"] = 1,
    ["HISTORY"] = 1,
    ["IMPORT"] = 1,
    ["DOWNLOAD"] = 1,
    ["SETTINGS"] = 1
}

local download_led = 0

function Menu.draw()
    for k, v in pairs(button_a) do
        if k == mode then
            button_a[k] = math.max(v - 0.1, 0)
        else
            button_a[k] = math.min(v + 0.1, 1)
        end
    end
    Screen.clear(Themes[Settings.Theme].COLOR_LEFT_BACK)
    if logoSmall then
        Graphics.drawImage(0, 0, logoSmall.e)
    end
    Graphics.fillRect(255, 960, 0, 544, COLOR_BACK)
    Font.print(FONT30, 30, 107, Language[Settings.Language].APP.LIBRARY, Color.new(255, 255, 255, 255 - 128 * button_a["LIBRARY"]))
    Font.print(FONT30, 30, 167, Language[Settings.Language].APP.CATALOGS, Color.new(255, 255, 255, 255 - 128 * button_a["CATALOGS"]))
    Font.print(FONT30, 30, 227, Language[Settings.Language].APP.HISTORY, Color.new(255, 255, 255, 255 - 128 * button_a["HISTORY"]))
    Font.print(FONT30, 30, 348, Language[Settings.Language].APP.IMPORT, Color.new(255, 255, 255, 255 - 128 * button_a["IMPORT"]))
    Font.print(FONT30, 30, 408, Language[Settings.Language].APP.DOWNLOAD, Color.new(255, 255, 255, 255 - 128 * button_a["DOWNLOAD"]))
    if ChapterSaver.is_download_running() then
        download_led = math.min(download_led + 0.1, 1)
    else
        download_led = math.max(download_led - 0.1, 0)
    end
    Graphics.fillCircle(15, 428, 6, Color.new(65, 105, 226, 255 * download_led - 160 * download_led * math.abs(math.sin(Timer.getTime(GlobalTimer) / 1000))))
    Font.print(FONT30, 30, 468, Language[Settings.Language].APP.SETTINGS, Color.new(255, 255, 255, 255 - 128 * button_a["SETTINGS"]))
    if Details.getFade() ~= 1 then
        Catalogs.draw()
    end
    Details.draw()
    Extra.draw()
end
