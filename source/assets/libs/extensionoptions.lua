ExtensionOptions = {}

local status = "END"

local fade = 0
local oldFade = 0

local animationTimer = Timer.new()

local Name = ""
local extension = {}
local isInstalled = false
local parserStatus = ""
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

local changesString = nil
local changesWordList = {}

local isCJK = IsCJK

local function updateChangesText(newChangesString)
	changesString = (newChangesString or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local wordList = {}
	for word in changesString:gmatch("[^ ]+") do
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
	local lines = {}
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
	changesWordList = lines
end

function ExtensionOptions.load(parser)
	if parser and parser.ID then
		Name = parser.Name
		extension = parser
		isInstalled = parser and parser.Installed == true
		parserStatus = parser and parser.Status or ""
		buttons = {}
		if isInstalled then
			if parserStatus == "Not supported" then
				buttons[#buttons + 1] = "REMOVE"
			else
				buttons[#buttons + 1] = "UPDATE"
				buttons[#buttons + 1] = "REMOVE"
			end
		else
			buttons[#buttons + 1] = "INSTALL"
		end
		changesString = nil
		changesWordList = {}
		if parser.LastChange then
			updateChangesText(parser.LastChange)
		end
	end
end

function ExtensionOptions.show()
	if parserStatus == "" then
		Console.error("Invalid parser")
	else
		status = "START"
		oldFade = 1
		Timer.reset(animationTimer)
		selectedIndex = 0
	end
end

function ExtensionOptions.input(pad, oldpad, touch, oldtouch)
	if status == "START" then
		if TOUCH_MODES.MODE == TOUCH_MODES.NONE and oldtouch.x and touch.x and touch.x > 240 then
			TOUCH_MODES.MODE = TOUCH_MODES.READ
		elseif TOUCH_MODES.MODE ~= TOUCH_MODES.NONE and not touch.x then
			if TOUCH_MODES.MODE == TOUCH_MODES.READ and oldtouch.x then
				if oldtouch.x > 960 - 350 * fade * oldFade then
					if oldtouch.y <= 25 + 8 + 50 * #buttons then
						local id = math.floor((oldtouch.y - 25) / 50) - 1
						if id > 0 and id <= #buttons then
						--
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
				--
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
	end
end

function ExtensionOptions.draw()
	if status ~= "END" then
		local M = oldFade * fade
		Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 150 * M))
		Graphics.fillRect(960 - M * 350, 960, 0, 544, Color.new(0, 0, 0))
		for i = 1, #buttons do
			local is_downloading = false
			local v = buttons[i]
			if v == "UPDATE" then
				if parserStatus == "New version" and not is_downloading then
					Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, DownloadIcon.e, Color.new(136, 0, 255))
				else
					Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, DownloadIcon.e, COLOR_GRAY)
				end
			elseif v == "REMOVE" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, RemoveIcon.e, Color.new(255, 74, 58))
			elseif v == "INSTALL" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 25 + (i + 1) * 50 - 1, DownloadIcon.e, is_downloading and COLOR_GRAY or COLOR_ROYAL_BLUE)
			end
			local text = Language[Settings.Language].EXTENSIONS[buttons[i]] or buttons[i] or ""
			if (parserStatus == "New version" and v == "UPDATE" or v ~= "UPDATE") and not (is_downloading and (v == "UPDATE" or v == "INSTALL")) then
				Font.print(FONT16, 960 - M * 350 + 52, 17 + 25 + (i + 1) * 50, text, COLOR_WHITE)
			else
				if is_downloading and (v == "UPDATE" or v == "INSTALL") then
					text = Language[Settings.Language].EXTENSIONS.DOWNLOADING or "Downloading..." or ""
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
		Font.print(BONT30, 960 - (M - 0.5) * 350 - Font.getTextWidth(BONT30, Name) / 2, 4, Name, COLOR_WHITE)
		height = height + Font.getTextHeight(BONT30, Name) + 6
		if extension.Link then
			Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, extension.Link .. "/") / 2, 4 + height, extension.Link .. "/", COLOR_GRAY)
			height = height + Font.getTextHeight(FONT16, extension.Link .. "/") + 5
		end
		if extension.Version then
			if parserStatus ~= "Installable" then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, Language[Settings.Language].EXTENSIONS.CURRENT_VERSION .. ": v" .. extension.Version) / 2, 4 + height, Language[Settings.Language].EXTENSIONS.CURRENT_VERSION .. ": v" .. extension.Version, COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, Language[Settings.Language].EXTENSIONS.CURRENT_VERSION .. ": v" .. extension.Version) + 5
			else
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, Language[Settings.Language].EXTENSIONS.NOT_INSTALLED) / 2, 4 + height, Language[Settings.Language].EXTENSIONS.NOT_INSTALLED, COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, Language[Settings.Language].EXTENSIONS.NOT_INSTALLED) + 5
			end
			if extension.NewVersion then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, Language[Settings.Language].EXTENSIONS.LATEST_VERSION .. ": v" .. extension.NewVersion) / 2, 4 + height, Language[Settings.Language].EXTENSIONS.LATEST_VERSION .. ": v" .. extension.NewVersion, parserStatus == "New version" and Color.new(136, 0, 255) or COLOR_GRAY)
				height = height + Font.getTextHeight(FONT16, Language[Settings.Language].EXTENSIONS.LATEST_VERSION .. ": v" .. extension.NewVersion) + 5
			end
			if extension.NSFW then
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, "NSFW") / 2 - Font.getTextWidth(FONT16, " | " .. (Language[Settings.Language].PARSERS[extension.Lang] or "")) / 2, 4 + height, "NSFW", COLOR_ROYAL_BLUE)
				Font.print(FONT16, 960 - (M - 0.5) * 350 + Font.getTextWidth(FONT16, "NSFW") / 2 - Font.getTextWidth(FONT16, " | " .. (Language[Settings.Language].PARSERS[extension.Lang] or "")) / 2, 4 + height, " | " .. (Language[Settings.Language].PARSERS[extension.Lang] or ""), COLOR_GRAY)
			else
				Font.print(FONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(FONT16, "SFW") / 2 - Font.getTextWidth(FONT16, " | " .. (Language[Settings.Language].PARSERS[extension.Lang] or "")) / 2, 4 + height, "SFW | " .. (Language[Settings.Language].PARSERS[extension.Lang] or ""), COLOR_GRAY)
			end
		end
		if #changesWordList > 0 then
			local y = 17 + 25 + (#buttons + 2) * 50
			Font.print(BONT16, 960 - (M - 0.5) * 350 - Font.getTextWidth(BONT16, Language[Settings.Language].EXTENSIONS.LATEST_CHANGES) / 2, y, Language[Settings.Language].EXTENSIONS.LATEST_CHANGES, COLOR_WHITE)
			local descriptionYOffset = y + Font.getTextHeight(BONT16, Language[Settings.Language].EXTENSIONS.LATEST_CHANGES) + 10
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
