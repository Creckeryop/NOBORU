Menu = {}

local logoSmall = Image:new(Graphics.loadImage("app0:assets/images/logo-small.png"))

StarIcon = Image:new(Graphics.loadImage("app0:assets/icons/star.png"))
MiniStarIcon = Image:new(Graphics.loadImage("app0:assets/icons/mini_star.png"))
local WebIcon = Image:new(Graphics.loadImage("app0:assets/icons/web.png"))
HistoryIcon = Image:new(Graphics.loadImage("app0:assets/icons/history.png"))
ImportIcon = Image:new(Graphics.loadImage("app0:assets/icons/import.png"))
local ExtensionsIcon = Image:new(Graphics.loadImage("app0:assets/icons/extensions.png"))
HotIcon = Image:new(Graphics.loadImage("app0:assets/icons/hot.png"))
SearchIcon = Image:new(Graphics.loadImage("app0:assets/icons/search.png"))
AZIcon = Image:new(Graphics.loadImage("app0:assets/icons/az.png"))
LetterAIcon = Image:new(Graphics.loadImage("app0:assets/icons/a.png"))
TagIcon = Image:new(Graphics.loadImage("app0:assets/icons/tag.png"))
BackIcon = Image:new(Graphics.loadImage("app0:assets/icons/back.png"))
RefreshIcon = Image:new(Graphics.loadImage("app0:assets/icons/refresh.png"))

CheckboxIcon = Image:new(Graphics.loadImage("app0:assets/icons/checkbox.png"))
CheckboxCheckedIcon = Image:new(Graphics.loadImage("app0:assets/icons/checkbox_checked.png"))
CheckboxCrossedIcon = Image:new(Graphics.loadImage("app0:assets/icons/checkbox_crossed.png"))
RadioIcon = Image:new(Graphics.loadImage("app0:assets/icons/radio.png"))
RadioCheckedIcon = Image:new(Graphics.loadImage("app0:assets/icons/radio_checked.png"))
ShowIcon = Image:new(Graphics.loadImage("app0:assets/icons/show.png"))
HideIcon = Image:new(Graphics.loadImage("app0:assets/icons/hide.png"))

DownloadIcon = Image:new(Graphics.loadImage("app0:assets/icons/download.png"))
OptionsIcon = Image:new(Graphics.loadImage("app0:assets/icons/options.png"))

---@param mode string
---Menu mode
local mode
local downloadIndicatorValue = 0

local buttonsAlpha = {
	["LIBRARY"] = 1,
	["CATALOGS"] = 1,
	["HISTORY"] = 1,
	["EXTENSIONS"] = 1,
	["IMPORT"] = 1,
	["DOWNLOAD"] = 1,
	["SETTINGS"] = 1
}

local NEXT_MODES = {
	["LIBRARY"] = "CATALOGS",
	["CATALOGS"] = "HISTORY",
	["HISTORY"] = "EXTENSIONS",
	["EXTENSIONS"] = "IMPORT",
	["IMPORT"] = "DOWNLOAD",
	["DOWNLOAD"] = "SETTINGS",
	["SETTINGS"] = "SETTINGS"
}

local PREV_MODES = {
	["LIBRARY"] = "LIBRARY",
	["CATALOGS"] = "LIBRARY",
	["HISTORY"] = "CATALOGS",
	["EXTENSIONS"] = "HISTORY",
	["IMPORT"] = "EXTENSIONS",
	["DOWNLOAD"] = "IMPORT",
	["SETTINGS"] = "DOWNLOAD"
}

---@param newMode string | '"LIBRARY"' | '"CATALOGS"' | '"SETTINGS"' | '"DOWNLOAD"'
---Sets menu mode
function Menu.setMode(newMode)
	if mode == newMode then
		return
	end
	Catalogs.setStatus(newMode)
	mode = newMode
end

function Menu.input(oldPad, pad, oldTouch, touch)
	if Details.getStatus() == "END" then
		if ExtensionOptions.getStatus() == "END" then
			if CatalogModes.getStatus() == "END" then
				if Extra.getStatus() == "END" then
					if Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldPad, SCE_CTRL_RTRIGGER) then
						Menu.setMode(NEXT_MODES[mode])
					end
					if Controls.check(pad, SCE_CTRL_LTRIGGER) and not Controls.check(oldPad, SCE_CTRL_LTRIGGER) then
						Menu.setMode(PREV_MODES[mode])
					end
					if touch.x and not oldTouch.x and touch.x < 205 then
						if touch.y >= 85 and touch.y < 135 then
							Menu.setMode("LIBRARY")
						elseif touch.y < 185 then
							Menu.setMode("CATALOGS")
						elseif touch.y < 235 then
							Menu.setMode("HISTORY")
						elseif touch.y < 285 then
							Menu.setMode("EXTENSIONS")
						elseif touch.y > 460 then
							Menu.setMode("SETTINGS")
						elseif touch.y > 410 then
							Menu.setMode("DOWNLOAD")
						elseif touch.y > 360 then
							Menu.setMode("IMPORT")
						end
					end
					Catalogs.input(oldPad, pad, oldTouch, touch)
				else
					Extra.input(oldPad, pad, oldTouch, touch)
				end
			else
				CatalogModes.input(pad, oldPad, touch, oldTouch)
			end
		else
			ExtensionOptions.input(pad, oldPad, touch, oldTouch)
		end
	else
		if Extra.getStatus() == "END" then
			Details.input(oldPad, pad, oldTouch, touch)
		else
			Extra.input(oldPad, pad, oldTouch, touch)
		end
	end
end

function Menu.update()
	Catalogs.update()
	Details.update()
	CatalogModes.update()
	ExtensionOptions.update()
end

function Menu.draw()
	for k, v in pairs(buttonsAlpha) do
		if k == mode then
			buttonsAlpha[k] = math.max(v - 0.1, 0)
		else
			buttonsAlpha[k] = math.min(v + 0.1, 1)
		end
	end
	Screen.clear(Themes[Settings.Theme].COLOR_LEFT_BACK)
	Graphics.drawImage(0, 0, logoSmall.e)
	Graphics.fillRect(205, 960, 0, 544, COLOR_BACK)
	Graphics.drawImage((1 - buttonsAlpha["LIBRARY"]) * 5 + 14, 105, StarIcon.e, COLOR_GRADIENT(Color.new(255, 255, 0), Color.new(255, 255, 255, 128), buttonsAlpha["LIBRARY"]))
	Font.print(FONT16, (1 - buttonsAlpha["LIBRARY"]) * 5 + 52, 107, Language[Settings.Language].APP.LIBRARY, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["LIBRARY"])))
	Graphics.drawImage((1 - buttonsAlpha["CATALOGS"]) * 5 + 14, 155, WebIcon.e, COLOR_GRADIENT(Color.new(0, 148, 255), Color.new(255, 255, 255, 128), buttonsAlpha["CATALOGS"]))
	Font.print(FONT16, (1 - buttonsAlpha["CATALOGS"]) * 5 + 52, 157, Language[Settings.Language].APP.CATALOGS, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["CATALOGS"])))
	Graphics.drawImage((1 - buttonsAlpha["HISTORY"]) * 5 + 14, 205, HistoryIcon.e, COLOR_GRADIENT(Color.new(0, 188, 18), Color.new(255, 255, 255, 128), buttonsAlpha["HISTORY"]))
	Font.print(FONT16, (1 - buttonsAlpha["HISTORY"]) * 5 + 52, 207, Language[Settings.Language].APP.HISTORY, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["HISTORY"])))
	Graphics.drawImage((1 - buttonsAlpha["EXTENSIONS"]) * 5 + 14, 255, ExtensionsIcon.e, COLOR_GRADIENT(Color.new(255, 106, 0), Color.new(255, 255, 255, 128), buttonsAlpha["EXTENSIONS"]))
	if Extensions.GetCounter() > 0 then
		Graphics.drawImage((1 - buttonsAlpha["EXTENSIONS"]) * 5 + 14 + 18, 255 - 6, CircleIcon.e, Color.new(255, 74, 58))
	end
	Font.print(FONT16, (1 - buttonsAlpha["EXTENSIONS"]) * 5 + 52, 257, Language[Settings.Language].APP.EXTENSIONS, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["EXTENSIONS"])))
	Graphics.drawImage((1 - buttonsAlpha["IMPORT"]) * 5 + 14, 376, ImportIcon.e, COLOR_GRADIENT(Color.new(255, 74, 58), Color.new(255, 255, 255, 128), buttonsAlpha["IMPORT"]))
	Font.print(FONT16, (1 - buttonsAlpha["IMPORT"]) * 5 + 52, 378, Language[Settings.Language].APP.IMPORT, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["IMPORT"])))
	if ChapterSaver.is_download_running() then
		downloadIndicatorValue = math.min(downloadIndicatorValue + 0.1, 1)
	else
		downloadIndicatorValue = math.max(downloadIndicatorValue - 0.1, 0)
	end
	Graphics.drawImage((1 - buttonsAlpha["DOWNLOAD"]) * 5 + 14, 426, DownloadIcon.e, COLOR_GRADIENT(COLOR_GRADIENT(COLOR_ROYAL_BLUE, Color.new(255, 255, 255, 128), buttonsAlpha["DOWNLOAD"]), Color.new(178, 0, 255), downloadIndicatorValue * math.abs(math.sin(Timer.getTime(GlobalTimer) / 1000))))
	Font.print(FONT16, (1 - buttonsAlpha["DOWNLOAD"]) * 5 + 52, 428, Language[Settings.Language].APP.DOWNLOAD, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["DOWNLOAD"])))
	Graphics.drawImage((1 - buttonsAlpha["SETTINGS"]) * 5 + 14, 476, OptionsIcon.e, COLOR_GRADIENT(COLOR_WHITE, Color.new(255, 255, 255, 128), buttonsAlpha["SETTINGS"]))
	Font.print(FONT16, (1 - buttonsAlpha["SETTINGS"]) * 5 + 52, 478, Language[Settings.Language].APP.SETTINGS, Color.new(255, 255, 255, 128 + 127 * (1 - buttonsAlpha["SETTINGS"])))
	if Details.getFade() ~= 1 then
		Catalogs.draw()
	end
	CatalogModes.draw()
	ExtensionOptions.draw()
	Details.draw()
end
