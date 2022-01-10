ExtensionOptions = {}

local status = "END"

local fade = 0
local oldFade = 0

local animationTimer = Timer.new()

local Name = ""
local extension = nil
local extStatus = nil
local selectedIndex = 0
local controlTimer = Timer.new()
local controlInterval = 400

local easingFunction = EaseInOutCubic

local buttons = {}

local function animationUpdate()
	if status == "START" then
		fade = easingFunction(math.min((Timer.getTime(animationTimer) / 500), 1))
	elseif status == "WAIT" then
		if fade == 0 then
			status = "END"
		end
		fade = 1 - easingFunction(math.min((Timer.getTime(animationTimer) / 500), 1))
	end
end

local CHANGES_TEXT_WIDTH = 350 - 14 * 2
local LINE_HEIGHT = 22

local changesWordList = {}
local langsWordList = {}

local isDownloading = false
local wasDownloading = false
local linkCount = 0

local isCJK = IsCJK

local LANG_COLOR_TABLE = {
	COLOR_ROYAL_BLUE,
	Color.new(255, 74, 58),
	Color.new(178, 0, 255),
	Color.new(0, 188, 18),
	Color.new(255, 106, 0)
}

local function updateChangesText(str, finalWordList)
	str = (str or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local wordList = {}
	for word in str:gmatch("[^ ]+") do
		local newWord = ""
		for i = 1, #word do
			local s = string.sub(word, i, 1)
			if s ~= "" and isCJK(s) or s == "\n" then
				if newWord ~= "" then
					wordList[#wordList + 1] = newWord
					newWord = ""
				end
				wordList[#wordList + 1] = s
			else
				if s:match("[%.,]") then
					newWord = newWord .. s
					wordList[#wordList + 1] = newWord
					newWord = ""
				else
					newWord = newWord .. s
				end
			end
		end
		if newWord ~= "" then
			wordList[#wordList + 1] = newWord
		end
	end
	local lines = finalWordList
	if #wordList > 0 then
		local w = 0
		lines[1] = {}
		for n = 1, #wordList do
			local word = wordList[n]
			local wordWidth = Font.getTextWidth(FONT16, word)
			if word == "\n" then
				w = 0
				lines[#lines].SpaceWidth = 4
				lines[#lines + 1] = {}
			elseif w + wordWidth + 4 > CHANGES_TEXT_WIDTH then
				w = wordWidth
				local spaceWidth = 0
				for i = 1, #lines[#lines] do
					spaceWidth = spaceWidth + lines[#lines][i].Width
				end
				spaceWidth = (CHANGES_TEXT_WIDTH - spaceWidth) / #lines[#lines]
				lines[#lines].SpaceWidth = spaceWidth
				lines[#lines + 1] = {}
			else
				w = w + wordWidth + 4
			end
			if word ~= "\n" then
				lines[#lines][#lines[#lines] + 1] = {Word = word, Width = wordWidth}
			end
		end
		lines[#lines].SpaceWidth = 4
	end
end

function ExtensionOptions.load(id)
	if id and Extensions.getByID(id) ~= nil then
		Name = Extensions.getByID(id).Name
		extension = Extensions.getByID(id)
		extStatus = Extensions.getByID(id).Status or nil
		if extStatus == "Not supported" then
			buttons = {"REMOVE"}
		elseif extStatus == "Installed" then
			buttons = {"UPDATE", "REMOVE"}
		elseif extStatus == "New version" then
			buttons = {"UPDATE", "REMOVE"}
		elseif extStatus == "Available" then
			buttons = {"INSTALL"}
		else
			buttons = {}
		end
		if extension.Type and extension.Type == "Parsers" then
			if type(extension.Link) == "table" then
				linkCount = #extension.Link
			elseif type(extension.Link) == "string" then
				linkCount = 1
			else
				linkCount = 0
			end
		end
		isDownloading = false
		wasDownloading = false
		changesWordList = {}
		langsWordList = {}
		if extension.LatestChanges then
			updateChangesText(extension.LatestChanges, changesWordList)
		end
		if type(extension.Language) == "table" then
			local l = {}
			for i = 1, #extension.Language do
				if not l[extension.Language[i]] then
					l[i] = Str[extension.Language[i]] or extension.Language[i]
					l[extension.Language[i]] = true
				end
			end
			updateChangesText(table.concat(l, " "), langsWordList)
		end
	else
		extension = nil
	end
end

function ExtensionOptions.show()
	if extension == nil then
		Console.error("Extension isn't loaded!")
	else
		if extStatus == nil then
			Console.error("Invalid extension is loaded")
		else
			status = "START"
			oldFade = 1
			Timer.reset(animationTimer)
			selectedIndex = 0
		end
	end
end

function ExtensionOptions.input(pad, oldpad, touch, oldtouch)
	if status == "START" then
		if TOUCH_MODES.MODE == TOUCH_MODES.NONE and oldtouch.x and touch.x and touch.x > 240 then
			TOUCH_MODES.MODE = TOUCH_MODES.READ
		elseif TOUCH_MODES.MODE ~= TOUCH_MODES.NONE and not touch.x then
			if TOUCH_MODES.MODE == TOUCH_MODES.READ and oldtouch.x then
				if oldtouch.x > 960 - 350 * fade * oldFade then
					if oldtouch.y <= 17 + 25 + (#buttons + 2) * 50 - 1 then
						local id = math.floor((oldtouch.y - 25 - 17) / 50) - 1
						if id > 0 and id <= #buttons then
							if buttons[id] == "INSTALL" or (extension and extension.LatestVersion ~= extension.Version and buttons[id] == "UPDATE") then
								Extensions.Install(extension.ID)
							elseif buttons[id] == "REMOVE" then
								Extensions.Remove(extension.ID)
								status = "WAIT"
								Timer.reset(animationTimer)
								oldFade = fade
							end
						end
					end
				end
			end
			TOUCH_MODES.MODE = TOUCH_MODES.NONE
		elseif touch.x then
			if touch.x < 960 - 350 * fade * oldFade then
				status = "WAIT"
				Timer.reset(animationTimer)
				oldFade = fade
			end
		end
		if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
			status = "WAIT"
			Timer.reset(animationTimer)
			oldFade = fade
		elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
			if selectedIndex > 0 then
				if selectedIndex <= #buttons then
					if buttons[selectedIndex] == "INSTALL" or (extension.LatestVersion ~= extension.Version and buttons[selectedIndex] == "UPDATE") then
						Extensions.Install(extension.ID)
					elseif buttons[selectedIndex] == "REMOVE" then
						Extensions.Remove(extension.ID)
						status = "WAIT"
						Timer.reset(animationTimer)
						oldFade = fade
					end
				end
			end
		end
		if touch.x then
			selectedIndex = 0
			controlInterval = 400
		elseif Timer.getTime(controlTimer) > controlInterval or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP)) then
			if Controls.check(pad, SCE_CTRL_DOWN + SCE_CTRL_UP + SCE_CTRL_LEFT + SCE_CTRL_RIGHT) then
				if Controls.check(pad, SCE_CTRL_UP) then
					if selectedIndex == 0 then
						selectedIndex = 1
					elseif selectedIndex > 1 then
						selectedIndex = selectedIndex - 1
					end
				elseif Controls.check(pad, SCE_CTRL_DOWN) then
					if selectedIndex == 0 then
						selectedIndex = 1
					elseif selectedIndex < #buttons then
						selectedIndex = selectedIndex + 1
					end
				end
				if controlInterval > 50 then
					controlInterval = math.max(50, controlInterval / 2)
				end
				Timer.reset(controlTimer)
			else
				controlInterval = 400
			end
		end
	end
end

function ExtensionOptions.update()
	if status ~= "END" then
		animationUpdate()
		if extension then
			isDownloading = Threads.check(extension.ID .. "_INSTALL")
			if isDownloading then
				wasDownloading = true
			elseif wasDownloading then
				ExtensionOptions.load(extension.ID)
				wasDownloading = false
			end
		end
	end
end

function ExtensionOptions.draw()
	if status ~= "END" and extension then
		local M = oldFade * fade
		Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 150 * M))
		Graphics.fillRect(960 - M * 350, 960, 0, 544, Color.new(0, 0, 0))
		for i, v in ipairs(buttons) do
			if v == "UPDATE" then
				if extStatus == "New version" and not isDownloading then
					Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, DownloadIcon.e, Color.new(136, 0, 255))
				else
					Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, DownloadIcon.e, COLOR_GRAY)
				end
			elseif v == "REMOVE" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, RemoveIcon.e, Color.new(255, 74, 58))
			elseif v == "INSTALL" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, DownloadIcon.e, isDownloading and COLOR_GRAY or COLOR_ROYAL_BLUE)
			end
			local text = --[==[Language[Settings.Language].EXTENSIONS[buttons[i]] or ]==] buttons[i] or ""
			if (extStatus == "New version" and v == "UPDATE" or v ~= "UPDATE") and not (isDownloading and (v == "UPDATE" or v == "INSTALL")) then
				Font.print(FONT16, 960 - M * 350 + 52, 17 + 25 + (i + 1) * 50, text, COLOR_WHITE)
			else
				if isDownloading and (v == "UPDATE" or v == "INSTALL") then
					text = Str.labelDownloading or "Downloading..." or ""
				end
				Font.print(FONT16, 960 - M * 350 + 52, 17 + 25 + (i + 1) * 50, text, COLOR_GRAY)
			end
			if i == selectedIndex then
				local y = 2 + 25 + (i + 1) * 50
				local selectedRedColor = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
				local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
				for n = ks, ks + 1 do
					Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, Color.new(255, 0, 51))
					Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, selectedRedColor)
				end
			end
		end
		local height = 0
		Font.print(BOLD_FONT30, 960 - (M - 0.5) * 350 - Font.getTextWidth(BOLD_FONT30, Name) / 2, 4, Name, COLOR_WHITE)
		height = height + Font.getTextHeight(BOLD_FONT30, Name) + 6
		if extension.Link then
			if type(extension.Link) == "table" then
				for i = 1, #extension.Link do
					Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, extension.Link[i]) / 2, 4 + height, extension.Link[i], COLOR_GRAY)
					height = height + Font.getTextHeight(FONT16, extension.Link[i]) + 5
				end
			elseif type(extension.Link) == "string" then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, extension.Link) / 2, 4 + height, extension.Link, COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, extension.Link) + 5
			end
		end
		if extension.Version then
			if extStatus ~= "Available" then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, Str.labelCurrentVersion .. ": v" .. extension.Version) / 2, 4 + height, Str.labelCurrentVersion .. ": v" .. extension.Version, COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, Str.labelCurrentVersion .. ": v" .. extension.Version) + 5
			else
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, Str.labelNotInstalled) / 2, 4 + height, Str.labelNotInstalled, COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, Str.labelNotInstalled) + 5
			end
			if extension.LatestVersion then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, Str.labelLatestVersion .. ": v" .. extension.LatestVersion) / 2, 4 + height, Str.labelLatestVersion .. ": v" .. extension.LatestVersion, extStatus == "New version" and Color.new(136, 0, 255) or COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, Str.labelLatestVersion .. ": v" .. extension.LatestVersion) + 5
			end
			local languageName = ""
			if type(extension.Language) == "table" then
				languageName = Str.DIF or "DIF"
			else
				languageName = Str[extension.Language] or extension.Language or ""
			end
			if extension.NSFW then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, "NSFW") / 2 - Font.getTextWidth(FONT16, " | " .. languageName) / 2, 4 + height, "NSFW", COLOR_ROYAL_BLUE)
				Font.print(FONT16, 960 - (M - 0.5) * 350 + Font.getTextWidth(FONT16, "NSFW") / 2 - Font.getTextWidth(FONT16, " | " .. languageName) / 2, 4 + height, " | " .. languageName, COLOR_GRAY)
			else
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, "SFW") / 2 - Font.getTextWidth(FONT16, " | " .. languageName) / 2, 4 + height, "SFW | " .. languageName, COLOR_GRAY)
			end
		end
		local y = 17 + 25 + (#buttons + 2) * 50
		if #langsWordList > 0 then
			Font.print(BOLD_FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(BOLD_FONT16, Str.labelLanguages) / 2, y, Str.labelLanguages, COLOR_WHITE)
			local descriptionYOffset = y + Font.getTextHeight(BOLD_FONT16, Str.labelLanguages) + 10
			local clr = 0
			for i = 1, #langsWordList do
				local line = langsWordList[i]
				local x = 960 - M * 350 + 14
				for j = 1, #line do
					Font.print(FONT16, x, descriptionYOffset, line[j].Word, LANG_COLOR_TABLE[(clr % #LANG_COLOR_TABLE) + 1])
					x = x + line.SpaceWidth + line[j].Width
					clr = clr + 1
				end
				descriptionYOffset = descriptionYOffset + LINE_HEIGHT
			end
			y = descriptionYOffset
			y = y + 20
		end
		if #changesWordList > 0 then
			Font.print(BOLD_FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(BOLD_FONT16, Str.labelLatestChanges) / 2, y, Str.labelLatestChanges, COLOR_WHITE)
			local descriptionYOffset = y + Font.getTextHeight(BOLD_FONT16, Str.labelLatestChanges) + 10
			for i = 1, #changesWordList do
				local line = changesWordList[i]
				local x = 960 - M * 350 + 14
				for j = 1, #line do
					Font.print(FONT16, x, descriptionYOffset, line[j].Word, COLOR_WHITE)
					x = x + line.SpaceWidth + line[j].Width
				end
				descriptionYOffset = descriptionYOffset + LINE_HEIGHT
			end
		end
	end
end

function ExtensionOptions.getStatus()
	return status
end

function ExtensionOptions.getFade()
	return fade * oldFade
end
