Menu = {}

local logoSmall = Image:new(Graphics.loadImage("app0:assets/images/logo-small.png"))

Star_icon = Image:new(Graphics.loadImage("app0:assets/icons/star.png"))
Mini_star_icon = Image:new(Graphics.loadImage("app0:assets/icons/mini_star.png"))
local web_icon = Image:new(Graphics.loadImage("app0:assets/icons/web.png"))
History_icon = Image:new(Graphics.loadImage("app0:assets/icons/history.png"))
Import_icon = Image:new(Graphics.loadImage("app0:assets/icons/import.png"))
Hot_icon = Image:new(Graphics.loadImage("app0:assets/icons/hot.png"))
Search_icon = Image:new(Graphics.loadImage("app0:assets/icons/search.png"))
Az_icon = Image:new(Graphics.loadImage("app0:assets/icons/az.png"))
A_icon = Image:new(Graphics.loadImage("app0:assets/icons/a.png"))
Tag_icon = Image:new(Graphics.loadImage("app0:assets/icons/tag.png"))
Back_icon = Image:new(Graphics.loadImage("app0:assets/icons/back.png"))
Refresh_icon = Image:new(Graphics.loadImage("app0:assets/icons/refresh.png"))

Checkbox_icon = Image:new(Graphics.loadImage("app0:assets/icons/checkbox.png"))
Checkbox_checked_icon = Image:new(Graphics.loadImage("app0:assets/icons/checkbox_checked.png"))
Checkbox_crossed_icon = Image:new(Graphics.loadImage("app0:assets/icons/checkbox_crossed.png"))
Radio_icon = Image:new(Graphics.loadImage("app0:assets/icons/radio.png"))
Radio_checked_icon = Image:new(Graphics.loadImage("app0:assets/icons/radio_checked.png"))
Show_icon = Image:new(Graphics.loadImage("app0:assets/icons/show.png"))
Hide_icon = Image:new(Graphics.loadImage("app0:assets/icons/hide.png"))

Download_icon = Image:new(Graphics.loadImage("app0:assets/icons/download.png"))
Options_icon = Image:new(Graphics.loadImage("app0:assets/icons/options.png"))
---@param mode string
---Menu mode
local mode

---@param new_mode string | '"LIBRARY"' | '"CATALOGS"' | '"SETTINGS"' | '"DOWNLOAD"'
---Sets menu mode
function Menu.setMode(new_mode)
	if mode == new_mode then
		return
	end
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
		if CatalogModes.getMode() == "END" then
			if Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldpad, SCE_CTRL_RTRIGGER) then
				Menu.setMode(next_mode[mode])
			end
			if Controls.check(pad, SCE_CTRL_LTRIGGER) and not Controls.check(oldpad, SCE_CTRL_LTRIGGER) then
				Menu.setMode(prev_mode[mode])
			end
			if touch.x and not oldtouch.x and touch.x < 205 then
				if touch.y < 85 then
					do
					end
				elseif touch.y < 135 then
					Menu.setMode("LIBRARY")
				elseif touch.y < 185 then
					Menu.setMode("CATALOGS")
				elseif touch.y < 235 then
					Menu.setMode("HISTORY")
				elseif touch.y > 460 then
					Menu.setMode("SETTINGS")
				elseif touch.y > 410 then
					Menu.setMode("DOWNLOAD")
				elseif touch.y > 360 then
					Menu.setMode("IMPORT")
				end
			end
			Catalogs.input(oldpad, pad, oldtouch, touch)
		else
			CatalogModes.input(pad, oldpad, touch, oldtouch)
		end
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
	Details.update()
	CatalogModes.update()
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
	Graphics.drawImage(0, 0, logoSmall.e)
	Graphics.fillRect(205, 960, 0, 544, COLOR_BACK)
	Graphics.drawImage((1 - button_a["LIBRARY"]) * 5 + 14, 105, Star_icon.e, COLOR_GRADIENT(Color.new(255, 255, 0), Color.new(255, 255, 255, 128), button_a["LIBRARY"]))
	Font.print(FONT16, (1 - button_a["LIBRARY"]) * 5 + 52, 107, Language[Settings.Language].APP.LIBRARY, Color.new(255, 255, 255, 128 + 127 * (1 - button_a["LIBRARY"])))
	Graphics.drawImage((1 - button_a["CATALOGS"]) * 5 + 14, 155, web_icon.e, COLOR_GRADIENT(Color.new(0, 148, 255), Color.new(255, 255, 255, 128), button_a["CATALOGS"]))
	Font.print(FONT16, (1 - button_a["CATALOGS"]) * 5 + 52, 157, Language[Settings.Language].APP.CATALOGS, Color.new(255, 255, 255, 128 + 127 * (1 - button_a["CATALOGS"])))
	Graphics.drawImage((1 - button_a["HISTORY"]) * 5 + 14, 205, History_icon.e, COLOR_GRADIENT(Color.new(0, 188, 18), Color.new(255, 255, 255, 128), button_a["HISTORY"]))
	Font.print(FONT16, (1 - button_a["HISTORY"]) * 5 + 52, 207, Language[Settings.Language].APP.HISTORY, Color.new(255, 255, 255, 128 + 127 * (1 - button_a["HISTORY"])))
	Graphics.drawImage((1 - button_a["IMPORT"]) * 5 + 14, 376, Import_icon.e, COLOR_GRADIENT(Color.new(255, 74, 58), Color.new(255, 255, 255, 128), button_a["IMPORT"]))
	Font.print(FONT16, (1 - button_a["IMPORT"]) * 5 + 52, 378, Language[Settings.Language].APP.IMPORT, Color.new(255, 255, 255, 128 + 127 * (1 - button_a["IMPORT"])))
	if ChapterSaver.is_download_running() then
		download_led = math.min(download_led + 0.1, 1)
	else
		download_led = math.max(download_led - 0.1, 0)
	end
	Graphics.drawImage((1 - button_a["DOWNLOAD"]) * 5 + 14, 426, Download_icon.e, COLOR_GRADIENT(COLOR_GRADIENT(COLOR_ROYAL_BLUE, Color.new(255, 255, 255, 128), button_a["DOWNLOAD"]), Color.new(178, 0, 255), download_led * math.abs(math.sin(Timer.getTime(GlobalTimer) / 1000))))
	Font.print(FONT16, (1 - button_a["DOWNLOAD"]) * 5 + 52, 428, Language[Settings.Language].APP.DOWNLOAD, Color.new(255, 255, 255, 128 + 127 * (1 - button_a["DOWNLOAD"])))
	Graphics.drawImage((1 - button_a["SETTINGS"]) * 5 + 14, 476, Options_icon.e, COLOR_GRADIENT(COLOR_WHITE, Color.new(255, 255, 255, 128), button_a["SETTINGS"]))
	Font.print(FONT16, (1 - button_a["SETTINGS"]) * 5 + 52, 478, Language[Settings.Language].APP.SETTINGS, Color.new(255, 255, 255, 128 + 127 * (1 - button_a["SETTINGS"])))
	if Details.getFade() ~= 1 then
		Catalogs.draw()
	end
	CatalogModes.draw()
	Details.draw()
end
