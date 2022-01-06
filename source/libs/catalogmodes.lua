CatalogModes = {}
local status = "END"

local fade = 0
local oldFade = 0

local animationTimer = Timer.new()

local modes = {}
local modesFade = {}
local Name = ""

local currentFilters = {}
local currentChecked = {}
local currentLetters = {}
local currentLettersIndex = 1
local currentFinalLetter = 1
local currentTags = {}
local currentTagsIndex = 1
local currentFinalTag = 1
local currentFinalTagsData = {}

local itemsToDraw = {}

local nowMode = 1
local TOUCH_MODES = TOUCH_MODES
local slider = CreateSlider()
local selectedIndex = 0
local controlTimer = Timer.new()
local controlInterval = 400
local searchData = ""

local function setFinalTags()
	local filter = {}
	for j = 1, #currentFilters do
		local f = currentFilters[j]
		if f.Type == "check" then
			local list = {}
			for i = 1, #currentChecked[j] do
				if currentChecked[j][i] then
					list[#list + 1] = f.Tags[i]
				end
			end
			filter[#filter + 1] = list
			filter[f.Name] = list
		elseif f.Type == "checkcross" then
			local include = {}
			for i = 1, #currentChecked[j] do
				if currentChecked[j][i] == true then
					include[#include + 1] = f.Tags[i]
				end
			end
			local exclude = {}
			for i = 1, #currentChecked[j] do
				if currentChecked[j][i] == "cross" then
					exclude[#exclude + 1] = f.Tags[i]
				end
			end
			filter[#filter + 1] = {
				include = include,
				exclude = exclude
			}
			filter[f.Name] = filter[#filter]
		elseif f.Type == "radio" then
			filter[#filter + 1] = f.Tags[currentChecked[j]] or ""
			filter[f.Name] = f.Tags[currentChecked[j]] or ""
		end
	end
	currentFinalTagsData = filter
end

local function updateItemsDraw()
	itemsToDraw = {}
	for k = 1, #currentFilters do
		local f = currentFilters[k]
		itemsToDraw[#itemsToDraw + 1] = {
			data = f,
			type = "filter"
		}
		if f.visible then
			for i = 1, #f.Tags do
				itemsToDraw[#itemsToDraw + 1] = {
					data = f.Tags[i],
					type = "tag",
					k = k,
					i = i,
					f = f
				}
			end
		end
	end
end

local function getFiltersHeight()
	local h = 0
	for i = 1, #currentFilters do
		local f = currentFilters[i]
		h = h + 50
		if f.visible then
			h = h + 50 * #f.Tags
		end
	end
	return h
end

local function countFilterElements()
	local c = 0
	for i = 1, #currentFilters do
		local f = currentFilters[i]
		c = c + 1
		if f.visible then
			c = c + #f.Tags
		end
	end
	return c
end

---Updates scrolling movement
local function scrollUpdate()
	slider.Y = slider.Y + slider.V
	slider.V = slider.V / 1.12
	if math.abs(slider.V) < 0.1 then
		slider.V = 0
	end
	if slider.Y < 0 then
		slider.Y = 0
		slider.V = 0
	elseif slider.Y > (getFiltersHeight() - 544 + 40 + #modes * 50 + 8 + 6) then
		slider.Y = math.max(0, getFiltersHeight() - 544 + 40 + #modes * 50 + 8 + 6)
	end
end

local easingFunction = EaseInOutCubic

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

function CatalogModes.load(parser)
	if parser and parser.ID and parser.ID ~= "IMPORTED" then
		modes = {}
		Name = parser.Name
		currentFinalLetter = 1
		currentFinalTagsData = {}
		if parser.getPopularManga then
			modes[#modes + 1] = "Popular"
		end
		if parser.getLatestManga then
			modes[#modes + 1] = "Latest"
		end
		if parser.getAZManga then
			modes[#modes + 1] = "Alphabet"
		end
		if parser.getLetterManga and type(parser.Letters) == "table" then
			modes[#modes + 1] = "ByLetter"
			currentLetters = parser.Letters
			currentLettersIndex = 1
		end
		if parser.getTagManga and type(parser.Tags) == "table" then
			modes[#modes + 1] = "ByTag"
			currentTags = parser.Tags
			currentTagsIndex = 1
		end
		if parser.searchManga then
			modes[#modes + 1] = "Search"
		end
		modesFade = {}
		for i = 1, #modes do
			modesFade[modes[i]] = 0
		end
		currentFilters = parser.Filters or {}
		currentChecked = {}
		for k = 1, #currentFilters do
			local f = currentFilters[k]
			f.visible = false
			local default = f.Default
			if f.Type == "check" or f.Type == "checkcross" then
				currentChecked[k] = {}
				for i = 1, #f.Tags do
					currentChecked[k][i] = false
				end
				if default then
					if f.Type == "checkcross" then
						for i = 1, #default.include do
							for e = 1, #f.Tags do
								if f.Tags[e] == default.include[i] then
									currentChecked[k][e] = true
								end
							end
						end
						for i = 1, #default.exclude do
							for e = 1, #f.Tags do
								if f.Tags[e] == default.exclude[i] then
									currentChecked[k][e] = "cross"
								end
							end
						end
					elseif f.Type == "check" then
						for i = 1, #default do
							for e = 1, #f.Tags do
								if f.Tags[e] == default[i] then
									currentChecked[k][e] = true
								end
							end
						end
					end
				end
			elseif f.Type == "radio" then
				currentChecked[k] = 1
				if default then
					for e = 1, #f.Tags do
						if f.Tags[e] == default then
							currentChecked[k] = e
						end
					end
				end
			end
		end
		nowMode = 1
		searchData = ""
		slider.Y = -50
		updateItemsDraw()
	end
end

function CatalogModes.show()
	status = "START"
	oldFade = 1
	Timer.reset(animationTimer)
	selectedIndex = 0
end

local function setMode(id)
	if nowMode ~= id or modes[id] == "Search" or modes[id] == "ByLetter" or modes[id] == "ByTag" then
		if modes[id] == "Search" then
			Keyboard.show(Language[Settings.Language].APP.SEARCH, searchData, 128, TYPE_DEFAULT, MODE_TEXT, OPT_NO_AUTOCAP)
			setFinalTags()
		else
			nowMode = id
			currentFinalLetter = currentLettersIndex
			currentFinalTag = currentTagsIndex
			status = "WAIT"
			Timer.reset(animationTimer)
			oldFade = fade
			Catalogs.terminate()
		end
	end
end

function CatalogModes.input(pad, oldPad, touch, oldTouch)
	if status == "START" then
		if TOUCH_MODES.MODE == TOUCH_MODES.NONE and oldTouch.x and touch.x and touch.x > 240 then
			TOUCH_MODES.MODE = TOUCH_MODES.READ
			slider.TouchY = touch.y
		elseif TOUCH_MODES.MODE ~= TOUCH_MODES.NONE and not touch.x then
			if TOUCH_MODES.MODE == TOUCH_MODES.READ and oldTouch.x then
				if oldTouch.x > 960 - 350 * fade * oldFade then
					if oldTouch.y > 40 + 8 + 50 * #modes then
						local id = math.floor((slider.Y + oldTouch.y - (40 + 8 + 50 * #modes)) / 50) + 1
						if id > 0 then
							for i = 1, #currentFilters do
								local f = currentFilters[i]
								id = id - 1
								if id == 0 then
									f.visible = not f.visible
									updateItemsDraw()
									break
								end
								if f.visible then
									if id <= #f.Tags then
										if f.Type == "check" then
											currentChecked[i][id] = not currentChecked[i][id]
										elseif f.Type == "radio" then
											currentChecked[i] = id
										elseif f.Type == "checkcross" then
											if currentChecked[i][id] == "cross" then
												currentChecked[i][id] = false
											elseif currentChecked[i][id] == false then
												currentChecked[i][id] = true
											elseif currentChecked[i][id] == true then
												currentChecked[i][id] = "cross"
											end
										end
										break
									else
										id = id - #f.Tags
									end
								end
							end
						end
					else
						local id = math.floor((oldTouch.y - 40) / 50) + 1
						if id > 0 and id <= #modes then
							setMode(id)
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
		if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldPad, SCE_CTRL_CIRCLE) or Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldPad, SCE_CTRL_SQUARE) then
			status = "WAIT"
			Timer.reset(animationTimer)
			oldFade = fade
		elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldPad, SCE_CTRL_CROSS) then
			if selectedIndex > 0 then
				if selectedIndex <= #modes then
					setMode(selectedIndex)
				else
					local id = selectedIndex - #modes
					if id > 0 then
						for i = 1, #currentFilters do
							local f = currentFilters[i]
							id = id - 1
							if id == 0 then
								f.visible = not f.visible
								updateItemsDraw()
								break
							end
							if f.visible then
								if id <= #f.Tags then
									if f.Type == "check" then
										currentChecked[i][id] = not currentChecked[i][id]
									elseif f.Type == "radio" then
										currentChecked[i] = id
									elseif f.Type == "checkcross" then
										if currentChecked[i][id] == "cross" then
											currentChecked[i][id] = false
										elseif currentChecked[i][id] == false then
											currentChecked[i][id] = true
										elseif currentChecked[i][id] == true then
											currentChecked[i][id] = "cross"
										end
									end
									break
								else
									id = id - #f.Tags
								end
							end
						end
					end
				end
			end
		end
		if touch.x then
			selectedIndex = 0
			controlInterval = 400
		elseif Timer.getTime(controlTimer) > controlInterval or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldPad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldPad, SCE_CTRL_UP) or ((modes[selectedIndex] == "ByLetter" or modes[selectedIndex] == "ByTag") and (Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldPad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldPad, SCE_CTRL_RIGHT)))) then
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
					elseif selectedIndex < #modes + countFilterElements() then
						selectedIndex = selectedIndex + 1
					end
				elseif Controls.check(pad, SCE_CTRL_RIGHT) then
					if modes[selectedIndex] == "ByLetter" then
						currentLettersIndex = currentLettersIndex + 1
						if currentLettersIndex > #currentLetters then
							currentLettersIndex = 1
						end
					elseif modes[selectedIndex] == "ByTag" then
						currentTagsIndex = currentTagsIndex + 1
						if currentTagsIndex > #currentTags then
							currentTagsIndex = 1
						end
					end
				elseif Controls.check(pad, SCE_CTRL_LEFT) then
					if modes[selectedIndex] == "ByLetter" then
						currentLettersIndex = currentLettersIndex - 1
						if currentLettersIndex < 1 then
							currentLettersIndex = #currentLetters
						end
					elseif modes[selectedIndex] == "ByTag" then
						currentTagsIndex = currentTagsIndex - 1
						if currentTagsIndex < 1 then
							currentTagsIndex = #currentTags
						end
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
		if TOUCH_MODES.MODE == TOUCH_MODES.READ then
			if math.abs(slider.V) > 0.1 or math.abs(touch.y - slider.TouchY) > 10 then
				TOUCH_MODES.MODE = TOUCH_MODES.SLIDE
			end
		elseif TOUCH_MODES.MODE == TOUCH_MODES.SLIDE then
			if touch.x and oldTouch.x then
				slider.V = oldTouch.y - touch.y
			end
		end
	end
end

function CatalogModes.update()
	if status ~= "END" then
		if selectedIndex > 0 then
			slider.Y = slider.Y + ((selectedIndex - #modes) * 50 - 160 - slider.Y) / 8
		end
		animationUpdate()
		for i = 1, #modes do
			local v = modes[i]
			if nowMode == i then
				modesFade[v] = math.min(modesFade[v] + 0.1, 1)
			elseif selectedIndex == i then
				if modesFade[v] > 0.3 then
					modesFade[v] = math.max(modesFade[v] - 0.1, 0.3)
				else
					modesFade[v] = math.min(modesFade[v] + 0.1, 0.3)
				end
			else
				modesFade[v] = math.max(modesFade[v] - 0.1, 0)
			end
		end
		scrollUpdate()
		if Keyboard.getState() ~= RUNNING then
			if Keyboard.getState() == FINISHED then
				local data = Keyboard.getInput()
				Console.write('Searching for "' .. data .. '"')
				Catalogs.terminate()
				for i = 1, #modes do
					if modes[i] == "Search" then
						nowMode = i
						break
					end
				end
				searchData = data
				status = "WAIT"
				Timer.reset(animationTimer)
				oldFade = fade
				if data:gsub("%s", "") ~= "" then
					Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.SEARCHING, data))
				end
			end
			Keyboard.clear()
		end
	end
end

function CatalogModes.draw()
	if status ~= "END" then
		local M = oldFade * fade
		Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 150 * M))
		Graphics.fillRect(960 - M * 350, 960, 40 + 8 + 50 * #modes, 544, Color.new(0, 0, 0))
		local start_i = math.floor((slider.Y - (40 + 8 + 50 * #modes)) / 50) + 1
		local y = 40 + 50 * #modes + 17 - slider.Y + (math.max(1, start_i) - 1) * 50
		for n = math.max(1, start_i), math.min(#itemsToDraw, start_i + 12) do
			if itemsToDraw[n].type == "filter" then
				local f = itemsToDraw[n].data
				Font.print(FONT16, 960 - M * 350 + 52, y, f.Name, COLOR_WHITE)
				if not f.visible then
					Graphics.drawImage(960 - M * 350 + 14, y - 1, ShowIcon.e)
				else
					Graphics.drawImage(960 - M * 350 + 14, y - 1, HideIcon.e)
				end
			elseif itemsToDraw[n].type == "tag" then
				local f = itemsToDraw[n].f
				local k = itemsToDraw[n].k
				local i = itemsToDraw[n].i
				local v = itemsToDraw[n].data
				if y - 1 > 544 then
					break
				end
				if y - 1 + 24 > 8 + 50 * #modes + 8 then
					if f.Type == "check" then
						if currentChecked[k][i] then
							Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, CheckboxCheckedIcon.e)
						else
							Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, CheckboxIcon.e)
						end
					elseif f.Type == "checkcross" then
						if currentChecked[k][i] then
							if currentChecked[k][i] == "cross" then
								Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, CheckboxCrossedIcon.e, Color.new(255, 255, 255, 100))
							else
								Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, CheckboxCheckedIcon.e)
							end
						else
							Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, CheckboxIcon.e)
						end
					elseif f.Type == "radio" then
						if currentChecked[k] == i then
							Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, RadioCheckedIcon.e)
						else
							Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, RadioIcon.e)
						end
					end
					if type(currentChecked[k]) == "table" and currentChecked[k][i] == "cross" then
						Font.print(FONT16, 960 - M * 350 + 52 + 20, y, v, Color.new(255, 255, 255, 100))
					else
						Font.print(FONT16, 960 - M * 350 + 52 + 20, y, v, COLOR_WHITE)
					end
				end
			end
			y = y + 50
		end
		Graphics.fillRect(960 - M * 350, 960, 0, 40 + 8 + 50 * #modes, Color.new(0, 0, 0))
		for i = 1, #modes do
			local v = modes[i]
			if v == "Popular" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + (i - 1) * 50 - 1, HotIcon.e, COLOR_GRADIENT(COLOR_GRAY, Color.new(255, 106, 0), modesFade[v]))
			elseif v == "Latest" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + (i - 1) * 50 - 1, HistoryIcon.e, COLOR_GRADIENT(COLOR_GRAY, Color.new(0, 188, 18), modesFade[v]))
			elseif v == "Search" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + (i - 1) * 50 - 1, SearchIcon.e, COLOR_GRADIENT(COLOR_GRAY, Color.new(255, 74, 58), modesFade[v]))
			elseif v == "ByLetter" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + (i - 1) * 50 - 1, LetterAIcon.e, COLOR_GRADIENT(COLOR_GRAY, Color.new(255, 216, 0), modesFade[v]))
			elseif v == "ByTag" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + (i - 1) * 50 - 1, TagIcon.e, COLOR_GRADIENT(COLOR_GRAY, Color.new(127, 201, 255), modesFade[v]))
			elseif v == "Alphabet" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + (i - 1) * 50 - 1, AZIcon.e, COLOR_GRADIENT(COLOR_GRAY, COLOR_ROYAL_BLUE, modesFade[v]))
			end
			local text = Language[Settings.Language].MODES[modes[i]] or modes[i] or ""
			if modes[i] == "Search" and searchData:gsub("%s", "") ~= "" then
				text = text .. " : " .. searchData
			end
			if modes[i] == "ByLetter" then
				text = text .. " < " .. currentLetters[currentLettersIndex] .. " >"
			end
			if modes[i] == "ByTag" then
				text = text .. " < " .. currentTags[currentTagsIndex] .. " >"
			end
			Font.print(FONT16, 960 - M * 350 + 52, 17 + 40 + (i - 1) * 50, text, COLOR_GRADIENT(COLOR_GRAY, COLOR_WHITE, modesFade[v]))
			if i == selectedIndex then
				local y = 42 + (i - 1) * 50
				local selectedRedColor = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
				local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
				for n = ks, ks + 1 do
					Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, Color.new(255, 0, 51))
					Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, selectedRedColor)
				end
			end
		end
		if selectedIndex > #modes then
			local y = 40 + 50 * #modes - slider.Y + 50 * (selectedIndex - #modes - 1) + 2
			local selectedRedColor = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
			local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
			for n = ks, ks + 1 do
				Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, Color.new(255, 0, 51))
				Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, selectedRedColor)
			end
		end
		Graphics.fillRect(960 - (M - 1) * 350 - 5, 960, 40 + 8 + 50 * #modes, 544, COLOR_BLACK)
		if countFilterElements() > 7 then
			local h = getFiltersHeight() / (544 - 40 - 8 - 50 * #modes)
			Graphics.fillRect(960 - (M - 1) * 350 - 5, 960, 40 + 8 + 50 * #modes + (slider.Y) / h, 8 + 8 + 50 * #modes + (slider.Y + (544 - 8 - 8 - 50 * #modes)) / h, COLOR_WHITE)
		end
		Font.print(BOLD_FONT30, 960 - (M - 0.5) * 350 - Font.getTextWidth(BOLD_FONT30, Name) / 2, 4, Name, COLOR_WHITE)
	end
end

function CatalogModes.getStatus()
	return status
end

function CatalogModes.getFade()
	return fade * oldFade
end

function CatalogModes.getMangaMode()
	return modes[nowMode]
end

function CatalogModes.getSearchData()
	return searchData
end

function CatalogModes.getTagsData()
	return currentFinalTagsData
end

function CatalogModes.getLetter()
	return currentLetters[currentFinalLetter] or ""
end

function CatalogModes.getTag()
	return currentTags[currentFinalTag] or ""
end
