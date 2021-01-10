Reader = {}

local CreatePoint = CreatePoint

local allPages = {
	Page = 0
}

local velX, velY = 0, 0

local TOUCH_IDLE = 0
local TOUCH_MULTI = 1
local TOUCH_MOVE = 2
local TOUCH_READ = 3
local TOUCH_SWIPE = 4
local TOUCH_LOCK = 5
local touchMode = TOUCH_IDLE

local PAGE_NONE = 0
local PAGE_LEFT = 1
local PAGE_RIGHT = 2
local pageMode = PAGE_NONE

local STATE_LOADING = 0
local STATE_READING = 1
local currentState = STATE_LOADING

local maxZoom = 3

local currentPageOffset = CreatePoint(0, 0)
local touchTemp = CreatePoint(0, 0)

local startPage

local orientation
local is_down
local autozoom

local hideCounterTimer = Timer.new()

local doubleClickTimer = Timer.new()
local lastClickPoint = {x = -100, y = -100}
local gestureZoom = false

local ContextMenu = false
local MenuFade = 0
local toggleContextMenu = false
local ToggleContextMenuTimer = Timer.new()
local OnTouchMenu = false
local CursorIndex = -1
local CursorFade = 0
local CursorPoint = CreatePoint(0, 0)
local CursorDestination = CreatePoint(0, 0)
local CursorPlaces = {CreatePoint(32 + 12, 40), CreatePoint(960 - 88 - 88 + 32 + 12, 40), CreatePoint(960 - 32 - 12, 40), CreatePoint(32 + 12, 544 - 40), CreatePoint(0, 0), CreatePoint(960 - 32 - 12, 544 - 40)}

local mangaNameTickerTimer = Timer.new()
local chapterNameTickerTimer = Timer.new()

local leftArrowIcon = Image:new(Graphics.loadImage("app0:assets/icons/left.png"))
local rightArrowIcon = Image:new(Graphics.loadImage("app0:assets/icons/right.png"))

local readDirection = Settings.ReaderDirection

local function gesture_touch_input(touch, oldtouch, page)
	if Settings.DoubleTapReader then
		if gestureZoom then
			touchMode = TOUCH_IDLE
		end
		if not page or not page.Zoom then
			return
		end
		if touch.x == nil and oldtouch.x ~= nil and (not ContextMenu or (oldtouch.y >= 80 and oldtouch.y <= 544 - 80)) and not gestureZoom and touchMode == TOUCH_READ then
			gestureZoom = false
			local update_last = true
			if Timer.getTime(doubleClickTimer) < 300 then
				local len = math.sqrt((lastClickPoint.x - oldtouch.x) * (lastClickPoint.x - oldtouch.x) + (lastClickPoint.y - oldtouch.y) * (lastClickPoint.y - oldtouch.y))
				if len < 80 then
					toggleContextMenu = false
					if page.Zoom >= maxZoom - (maxZoom - page.min_Zoom) / 2 then
						gestureZoom = {
							Zoom = page.start_Zoom,
							x = 480,
							y = 272
						}
					else
						gestureZoom = {
							Zoom = math.min(maxZoom, maxZoom - (maxZoom - page.min_Zoom) / 2),
							x = oldtouch.x,
							y = oldtouch.y
						}
					end
					touchMode = TOUCH_LOCK
					Console.write(gestureZoom.Zoom)
					Console.write(allPages[allPages.Page].Zoom)
					update_last = false
					lastClickPoint = {x = -100, y = -100}
				end
			end
			Timer.reset(doubleClickTimer)
			if update_last then
				lastClickPoint = {x = oldtouch.x, y = oldtouch.y}
			end
		end
	end
end

local function gesture_touch_update()
	if Settings.DoubleTapReader then
		if gestureZoom and allPages[allPages.Page] and currentState == STATE_READING then
			local stop = false
			local old_Zoom = allPages[allPages.Page].Zoom
			if math.abs((allPages[allPages.Page].Zoom - gestureZoom.Zoom) / 4) < 0.01 then
				allPages[allPages.Page].Zoom = gestureZoom.Zoom
				stop = true
			else
				allPages[allPages.Page].Zoom = (allPages[allPages.Page].Zoom + (gestureZoom.Zoom - allPages[allPages.Page].Zoom) / 4)
			end
			allPages[allPages.Page].y = 272 + ((allPages[allPages.Page].y - 272) / old_Zoom) * allPages[allPages.Page].Zoom
			allPages[allPages.Page].x = 480 + ((allPages[allPages.Page].x - 480) / old_Zoom) * allPages[allPages.Page].Zoom
			local n = allPages[allPages.Page].Zoom / old_Zoom
			allPages[allPages.Page].y = allPages[allPages.Page].y - (gestureZoom.y - 272) * (n - 1)
			allPages[allPages.Page].x = allPages[allPages.Page].x - (gestureZoom.x - 480) * (n - 1)
			if stop then
				gestureZoom = false
			end
		end
		if Timer.getTime(doubleClickTimer) > 300 then
			lastClickPoint = {x = -100, y = -100}
		end
	end
end

local function gesture_edge_change_page()
end

local Chapters = {}
local currentChapterNumber = 1

local function updateMeasurements()
	for i = 1, #allPages do
		allPages[i].Zoom = nil
	end
end

local function scale(dZoom, Page)
	if math.abs(1 - dZoom) < 0.005 or not Page.Zoom then
		return
	end
	local oldZoom = Page.Zoom
	Page.Zoom = Page.Zoom * dZoom
	if Page.Zoom < Page.min_Zoom then
		Page.Zoom = Page.min_Zoom
	elseif Page.Zoom > maxZoom then
		Page.Zoom = maxZoom
	end
	Page.y = 272 + ((Page.y - 272) / oldZoom) * Page.Zoom
	Page.x = 480 + ((Page.x - 480) / oldZoom) * Page.Zoom
end

local function deletePageImage(page)
	if allPages[page].Image then
		if type(allPages[page].Image.e or allPages[page].Image) == "table" then
			Threads.remove(allPages[page])
			ParserManager.remove(allPages[page])
			for i = 1, allPages[page].Image.Parts do
				if allPages[page].Image[i] and allPages[page].Image[i].free then
					allPages[page].Image[i]:free()
				end
			end
		else
			if allPages[page].Image and allPages[page].Image.free then
				allPages[page].Image:free()
			end
		end
		allPages[page].Image = nil
		Console.write("Removed " .. tostring(page))
	else
		ParserManager.remove(allPages[page])
		Threads.remove(allPages[page])
	end
end

local function loadPageImage(page)
	local PageTable = allPages[page]
	if not PageTable.Image and not (PageTable.Link == "LoadPrev" or PageTable.Link == "LoadNext") then
		if PageTable.Extract then
			Threads.insertTask(
				PageTable,
				{
					Type = "UnZipFile",
					Path = PageTable.Path,
					Extract = PageTable.Extract,
					DestPath = "ux0:data/noboru/temp/cache.image",
					OnComplete = function()
						Threads.insertTask(
							PageTable,
							{
								Type = "Image",
								Table = PageTable,
								Path = "temp/cache.image",
								Index = "Image"
							}
						)
					end
				}
			)
		elseif PageTable.Path then
			Threads.insertTask(
				PageTable,
				{
					Type = "Image",
					Path = PageTable.Path,
					Table = PageTable,
					Index = "Image"
				}
			)
		elseif PageTable.Link then
			Threads.insertTask(
				PageTable,
				{
					Type = "ImageDownload",
					Link = PageTable.Link,
					Table = PageTable,
					Index = "Image"
				}
			)
		else
			ParserManager.loadPageImage(Chapters[currentChapterNumber].Manga.ParserID, PageTable[1], PageTable, true)
		end
	end
end
---@param page integer
local function changePage(page)
	if page < 0 and currentChapterNumber > 1 or page > #allPages then
		return false
	end
	allPages.PrevPage = allPages.Page
	allPages.Page = page
	if allPages[allPages.Page].Link == "LoadNext" or allPages[allPages.Page].Link == "LoadPrev" then
		return true
	end
	local o = {0}
	for k = 1, #o do
		local p = page + o[k]
		if allPages[p] then
			loadPageImage(p)
		end
	end
	for i = page - 2, page + 2, 4 do
		if i > 0 and i <= #allPages then
			deletePageImage(i)
			local OldOne = allPages[i][1]
			local OldLink = allPages[i].Link
			local OldPath = allPages[i].Path
			local OldExtr = allPages[i].Extract
			for k, _ in pairs(allPages[i]) do
				allPages[i][k] = nil
			end
			allPages[i][1] = OldOne
			allPages[i].Link = OldLink
			allPages[i].Path = OldPath
			allPages[i].Extract = OldExtr
			allPages[i].x = 0
			allPages[i].y = 0
		end
	end
	return true
end

local function changeOrientation()
	orientation = table.next(orientation, {"Horizontal", "Vertical"})
	updateMeasurements()
end

local buttonTimer = Timer.new()
local buttonTimeSpace = 800

---@param direction string | '"LEFT"' | '"RIGHT"'
---Turns the page according to the `direction`
local function swipe(direction)
	if orientation == "Horizontal" then
		if direction == "LEFT" then
			if is_down then
				if allPages.Page ~= #allPages and changePage(allPages.Page + 1) then
					currentPageOffset.y = 544 + currentPageOffset.y
					local page = allPages[allPages.Page - 1]
					if page and page.Zoom then
						if page.Zoom * page.Height >= 544 then
							page.y = -page.Height * page.Zoom / 2
						else
							page.y = -272
						end
					end
				end
			else
				if allPages.Page ~= #allPages and changePage(allPages.Page + 1) then
					currentPageOffset.x = 960 + currentPageOffset.x
					local page = allPages[allPages.Page - 1]
					if page and page.Zoom then
						if page.Zoom * page.Width >= 960 then
							page.x = -page.Width * page.Zoom / 2
						else
							page.x = -480
						end
					end
				end
			end
		elseif direction == "RIGHT" then
			if is_down then
				if allPages[allPages.Page - 1] and changePage(allPages.Page - 1) then
					currentPageOffset.y = -544 + currentPageOffset.y
					local page = allPages[allPages.Page + 1]
					if page and page.Zoom then
						if page.Zoom * page.Height >= 544 then
							page.y = 544 + page.Height * page.Zoom / 2
						else
							page.y = 544 + 272
						end
					end
				end
			else
				if allPages[allPages.Page - 1] and changePage(allPages.Page - 1) then
					currentPageOffset.x = -960 + currentPageOffset.x
					local page = allPages[allPages.Page + 1]
					if page and page.Zoom then
						if page.Zoom * page.Width >= 960 then
							page.x = 960 + page.Width * page.Zoom / 2
						else
							page.x = 960 + 480
						end
					end
				end
			end
		end
	elseif orientation == "Vertical" then
		if direction == "LEFT" then
			if is_down then
				if allPages.Page ~= #allPages and changePage(allPages.Page + 1) then
					currentPageOffset.x = -960 + currentPageOffset.x
					local page = allPages[allPages.Page - 1]
					if page and page.Zoom then
						if page.Zoom * page.Height >= 960 then
							page.x = 960 + page.Height * page.Zoom / 2
						else
							page.x = 960 + 480
						end
					end
				end
			else
				if allPages.Page ~= #allPages and changePage(allPages.Page + 1) then
					currentPageOffset.y = 544 + currentPageOffset.y
					local page = allPages[allPages.Page - 1]
					if page and page.Zoom then
						if page.Zoom * page.Width >= 544 then
							page.y = -page.Width * page.Zoom / 2
						else
							page.y = -272
						end
					end
				end
			end
		elseif direction == "RIGHT" then
			if is_down then
				if allPages[allPages.Page - 1] and changePage(allPages.Page - 1) then
					currentPageOffset.x = 960 + currentPageOffset.x
					local page = allPages[allPages.Page + 1]
					if page and page.Zoom then
						if page.Zoom * page.Height >= 960 then
							page.x = -page.Height * page.Zoom / 2
						else
							page.x = -480
						end
					end
				end
			else
				if allPages[allPages.Page - 1] and changePage(allPages.Page - 1) then
					currentPageOffset.y = -544 + currentPageOffset.y
					local page = allPages[allPages.Page + 1]
					if page and page.Zoom then
						if page.Zoom * page.Width >= 544 then
							page.y = 544 + page.Width * page.Zoom / 2
						else
							page.y = 544 + 272
						end
					end
				end
			end
		end
	end
end

local function exit()
	for i = 1, #allPages do
		deletePageImage(i)
	end
	allPages = {
		Page = 0
	}
	ParserManager.remove((((Chapters or {})[currentChapterNumber or 0] or {}).Pages) or 0)
	collectgarbage("collect")
	AppMode = MENU
	ContextMenu = false
	MenuFade = 0
	toggleContextMenu = false
end

function Reader.input(oldPad, pad, oldTouch, touch, oldTouch2, touch2)
	if Controls.check(pad, SCE_CTRL_CIRCLE) or ContextMenu and touch.x and touch.x < 88 and touch.y < 80 * MenuFade and not oldTouch.x then
		if allPages.Page > 0 then
			local bookmark
			if readDirection == "LEFT" then
				bookmark = allPages.Count - allPages.Page + 1
			else
				bookmark = allPages.Page
			end
			if bookmark == 1 then
				bookmark = nil
			elseif bookmark == allPages.Count then
				bookmark = true
			end
			if Cache.isCached(Chapters[currentChapterNumber].Manga) then
				Cache.setBookmark(Chapters[currentChapterNumber], bookmark)
			end
		end
		exit()
	end
	if currentState == STATE_READING and allPages[allPages.Page] then
		if ContextMenu then
			if touch.x and touch.y < 80 * MenuFade and not oldTouch.x then
				if touch.x > 960 - 88 then
					if allPages[allPages.Page or -1] and (allPages[allPages.Page or -1].Link or allPages[allPages.Page or -1].Path) then
						Extra.setChapters(Chapters[currentChapterNumber].Manga, Chapters[currentChapterNumber], allPages[allPages.Page])
					end
				elseif touch.x > 960 - 88 - 88 then
					if allPages[allPages.Page or -1] then
						deletePageImage(allPages.Page)
						loadPageImage(allPages.Page)
					end
				end
			end
		end
		if touch.x ~= nil or pad ~= 0 then
			Timer.reset(hideCounterTimer)
		end
		local page = allPages[allPages.Page]
		gesture_touch_input(touch, oldTouch, allPages[allPages.Page])
		if page.Zoom then
			local x, y = Controls.readLeftAnalog()
			x = x - 127
			y = y - 127
			if math.abs(x) > SCE_LEFT_STICK_DEADZONE then
				page.x = page.x - SCE_LEFT_STICK_SENSITIVITY * 25 * (x - SCE_LEFT_STICK_DEADZONE * math.sign(x)) / (128 - SCE_LEFT_STICK_DEADZONE)
			end
			if math.abs(y) > SCE_LEFT_STICK_DEADZONE then
				page.y = page.y - SCE_LEFT_STICK_SENSITIVITY * 25 * (y - SCE_LEFT_STICK_DEADZONE * math.sign(y)) / (128 - SCE_LEFT_STICK_DEADZONE)
			end
			if not ContextMenu then
				if Settings.ChangingPageButtons == "LR" then
					if Controls.check(pad, SCE_CTRL_UP) then
						page.y = page.y + 20
					elseif Controls.check(pad, SCE_CTRL_DOWN) then
						page.y = page.y - 20
					end
					if Controls.check(pad, SCE_CTRL_LEFT) then
						page.x = page.x + 20
					elseif Controls.check(pad, SCE_CTRL_RIGHT) then
						page.x = page.x - 20
					end
				end
			end
		end
		if math.abs(currentPageOffset.x) < 80 and math.abs(currentPageOffset.y) < 80 then
			if not ContextMenu then
				if not (Controls.check(pad, SCE_CTRL_RIGHTPAGE) or Controls.check(pad, SCE_CTRL_LEFTPAGE) or (Settings.ChangingPageButtons == "DPAD" and (Controls.check(pad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP)))) then
					buttonTimeSpace = 800
				end
				local right_page_button = Settings.ChangingPageButtons == "DPAD" and (orientation == "Horizontal" and (is_down and SCE_CTRL_DOWN or SCE_CTRL_RIGHT) or (orientation == "Vertical" and (is_down and SCE_CTRL_LEFT or SCE_CTRL_DOWN))) or SCE_CTRL_RIGHTPAGE
				local left_page_button = Settings.ChangingPageButtons == "DPAD" and (orientation == "Horizontal" and (is_down and SCE_CTRL_UP or SCE_CTRL_LEFT) or (orientation == "Vertical" and (is_down and SCE_CTRL_RIGHT or SCE_CTRL_UP))) or SCE_CTRL_LEFTPAGE
				if Controls.check(pad, right_page_button) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldPad, right_page_button)) then
					swipe("LEFT")
					buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
					Timer.reset(buttonTimer)
				elseif Controls.check(pad, left_page_button) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldPad, left_page_button)) then
					swipe("RIGHT")
					buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
					Timer.reset(buttonTimer)
				elseif Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldPad, SCE_CTRL_SELECT) then
					changeOrientation()
				elseif Controls.check(pad, SCE_CTRL_SQUARE) then
					scale(0.95, page)
				elseif Controls.check(pad, SCE_CTRL_TRIANGLE) then
					scale(1.05, page)
				end
			end
			local x, y = Controls.readRightAnalog()
			if orientation == "Horizontal" then
				y = y - 127
				if math.abs(y) > SCE_RIGHT_STICK_DEADZONE then
					y = (y - SCE_RIGHT_STICK_DEADZONE * math.sign(y)) / (128 - SCE_RIGHT_STICK_DEADZONE)
					scale(1 - SCE_LEFT_STICK_SENSITIVITY * y * 0.05, page)
				end
			elseif orientation == "Vertical" then
				x = x - 127
				if math.abs(x) > SCE_RIGHT_STICK_DEADZONE then
					x = (x - SCE_RIGHT_STICK_DEADZONE * math.sign(x)) / (128 - SCE_RIGHT_STICK_DEADZONE)
					scale(1 + SCE_LEFT_STICK_SENSITIVITY * x * 0.05, page)
				end
			end
		end
		if touch.y and oldTouch.y and (not ContextMenu or touch.y < 544 - 80 and touch.y > 80 and oldTouch.y < 544 - 80 and oldTouch.y > 80) then
			if touchMode ~= TOUCH_MULTI then
				if touchMode == TOUCH_IDLE then
					touchTemp.x = touch.x
					touchTemp.y = touch.y
					touchMode = TOUCH_READ
				end
				velX = touch.x - oldTouch.x
				velY = touch.y - oldTouch.y
			end
			if touch2.x and oldTouch2.x and page.Zoom then
				touchMode = TOUCH_MULTI
				local old_Zoom = page.Zoom
				local center = {
					x = (touch.x + touch2.x) / 2,
					y = (touch.y + touch2.y) / 2
				}
				local n = (math.sqrt((touch.x - touch2.x) * (touch.x - touch2.x) + (touch.y - touch2.y) * (touch.y - touch2.y)) / math.sqrt((oldTouch.x - oldTouch2.x) * (oldTouch.x - oldTouch2.x) + (oldTouch.y - oldTouch2.y) * (oldTouch.y - oldTouch2.y)))
				scale(n, page)
				n = page.Zoom / old_Zoom
				page.y = page.y - (center.y - 272) * (n - 1)
				page.x = page.x - (center.x - 480) * (n - 1)
			end
		elseif ContextMenu and ((touch.y and (touch.y >= 544 - 80 or touch.y <= 80)) or (oldTouch.y and (oldTouch.y >= 544 - 80 or oldTouch.y <= 80))) then
			do
			end
		else
			if touchMode == TOUCH_SWIPE then
				if currentPageOffset.x > 90 or currentPageOffset.y > 90 then
					if orientation == "Vertical" and is_down then
						swipe("LEFT")
					else
						swipe("RIGHT")
					end
				elseif currentPageOffset.x < -90 or currentPageOffset.y < -90 then
					if orientation == "Vertical" and is_down then
						swipe("RIGHT")
					else
						swipe("LEFT")
					end
				end
				velX = 0
				velY = 0
				pageMode = PAGE_NONE
			end
			if touchMode ~= TOUCH_LOCK then
				if touchMode == TOUCH_READ then
					if Settings.PressEdgesToChangePage then
						if touchMode == TOUCH_READ and not touch.x and oldTouch.x then
							if orientation == "Vertical" then
								if is_down then
									if oldTouch.x > 480 + 180 then
										swipe("RIGHT")
									elseif oldTouch.x < 480 - 180 then
										swipe("LEFT")
									else
										toggleContextMenu = true
										Timer.reset(ToggleContextMenuTimer)
									end
								else
									if oldTouch.y > 272 + 120 then
										swipe("LEFT")
									elseif oldTouch.y < 272 - 120 then
										swipe("RIGHT")
									else
										toggleContextMenu = true
										Timer.reset(ToggleContextMenuTimer)
									end
								end
							elseif orientation == "Horizontal" then
								if is_down then
									if oldTouch.y > 272 + 120 then
										swipe("LEFT")
									elseif oldTouch.y < 272 - 120 then
										swipe("RIGHT")
									else
										toggleContextMenu = true
										Timer.reset(ToggleContextMenuTimer)
									end
								else
									if oldTouch.x > 480 + 180 then
										swipe("LEFT")
									elseif oldTouch.x < 480 - 180 then
										swipe("RIGHT")
									else
										toggleContextMenu = true
										Timer.reset(ToggleContextMenuTimer)
									end
								end
							end
						end
					else
						toggleContextMenu = true
						Timer.reset(ToggleContextMenuTimer)
					end
				end
				touchMode = TOUCH_IDLE
			end
		end
		if touchMode == TOUCH_READ and touchTemp.x and touch.x then
			local len = math.sqrt((touchTemp.x - touch.x) * (touchTemp.x - touch.x) + (touchTemp.y - touch.y) * (touchTemp.y - touch.y))
			if len > 10 then
				if orientation == "Horizontal" then
					if is_down then
						if not page.Zoom or (page.Width * page.Zoom < 961 or math.abs(touch.y - touchTemp.y) > math.abs(touch.x - touchTemp.x) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.y > touch.y) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.y < touch.y)) then
							touchMode = TOUCH_SWIPE
						else
							touchMode = TOUCH_MOVE
						end
					else
						if not page.Zoom or (page.Height * page.Zoom < 545 or math.abs(touch.x - touchTemp.x) > math.abs(touch.y - touchTemp.y) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.x > touch.x) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.x < touch.x)) then
							touchMode = TOUCH_SWIPE
						else
							touchMode = TOUCH_MOVE
						end
					end
				elseif orientation == "Vertical" then
					if is_down then
						if not page.Zoom or (page.Width * page.Zoom < 545 or math.abs(touch.x - touchTemp.x) > math.abs(touch.y - touchTemp.y) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.x > touch.x) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.x < touch.x)) then
							touchMode = TOUCH_SWIPE
						else
							touchMode = TOUCH_MOVE
						end
					else
						if not page.Zoom or (page.Height * page.Zoom < 961 or math.abs(touch.y - touchTemp.y) > math.abs(touch.x - touchTemp.x) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.y > touch.y) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.y < touch.y)) then
							touchMode = TOUCH_SWIPE
						else
							touchMode = TOUCH_MOVE
						end
					end
				end
			end
		end
	elseif currentState == STATE_LOADING then
		if touch.x == nil and oldTouch.x ~= nil and (not ContextMenu or (oldTouch.y <= 544 - 80 and oldTouch.y >= 80)) then
			toggleContextMenu = true
			Timer.reset(ToggleContextMenuTimer)
		end
	end
	if ContextMenu and ((touch.y and (touch.y >= 544 - 80 or touch.y <= 80)) or (oldTouch.y and (oldTouch.y >= 544 - 80 or oldTouch.y <= 80))) then
		if (touch.y and touch.y >= 544 - 80 or oldTouch.y and oldTouch.y >= 544 - 80) and (touchMode == TOUCH_IDLE or touchMode == TOUCH_READ) then
			if touch.x and touch.x > 180 and touch.x < 780 and allPages.Count and allPages.Count > 1 then
				local newPage = math.min(math.max(1, math.floor((touch.x - 200) / (560 / (allPages.Count - 1)) + 1)), allPages.Count)
				if is_down and orientation == "Vertical" then
					newPage = allPages.Count - newPage + 1
				end
				if newPage < allPages.Page then
					repeat
						swipe("RIGHT")
					until newPage == allPages.Page
					if readDirection == "LEFT" then
						allPages.PrevPage = allPages.Page + 1
					else
						allPages.PrevPage = allPages.Page - 1
					end
				elseif newPage > allPages.Page then
					repeat
						swipe("LEFT")
					until newPage == allPages.Page
					if readDirection == "LEFT" then
						allPages.PrevPage = allPages.Page + 1
					else
						allPages.PrevPage = allPages.Page - 1
					end
				end
			elseif not oldTouch.x and touch.x then
				if readDirection == "LEFT" or is_down and orientation == "Vertical" then
					if touch.x < 88 and currentChapterNumber < #Chapters then
						if Cache.isCached(Chapters[currentChapterNumber].Manga) then
							Cache.setBookmark(Chapters[currentChapterNumber], true)
						end
						Reader.loadChapter(currentChapterNumber + 1)
					elseif touch.x > 960 - 88 and currentChapterNumber > 1 then
						Reader.loadChapter(currentChapterNumber - 1)
						startPage = false
					end
				else
					if touch.x < 88 and currentChapterNumber > 1 then
						Reader.loadChapter(currentChapterNumber - 1)
						startPage = false
					elseif touch.x > 960 - 88 and currentChapterNumber < #Chapters then
						if Cache.isCached(Chapters[currentChapterNumber].Manga) then
							Cache.setBookmark(Chapters[currentChapterNumber], true)
						end
						Reader.loadChapter(currentChapterNumber + 1)
					end
				end
			end
		end
		OnTouchMenu = true
	else
		OnTouchMenu = false
	end
	if ContextMenu then
		if CursorIndex == -1 and (Controls.check(pad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_DOWN)) then
			CursorIndex = 0
			CursorPoint = CreatePoint(32 + 12, 35)
			CursorDestination = CreatePoint(32 + 12, 35)
		elseif CursorIndex >= 0 and CursorIndex < #CursorPlaces then
			if not Controls.check(pad, SCE_CTRL_CROSS) then
				if currentState == STATE_READING then
					if CursorIndex > 2 then
						if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldPad, SCE_CTRL_UP) then
							CursorIndex = CursorIndex - 3
						elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldPad, SCE_CTRL_LEFT) and CursorIndex > 3 then
							CursorIndex = CursorIndex - 1
						elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldPad, SCE_CTRL_RIGHT) and CursorIndex < 5 then
							CursorIndex = CursorIndex + 1
						end
					else
						if Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldPad, SCE_CTRL_DOWN) then
							CursorIndex = CursorIndex + 3
							if CursorIndex == 4 then
								CursorIndex = 5
							end
						elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldPad, SCE_CTRL_LEFT) and CursorIndex > 0 then
							CursorIndex = CursorIndex - 1
						elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldPad, SCE_CTRL_RIGHT) and CursorIndex < 2 then
							CursorIndex = CursorIndex + 1
						end
					end
				elseif currentState == STATE_LOADING then
					if CursorIndex > 2 then
						if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldPad, SCE_CTRL_UP) then
							CursorIndex = 0
						end
					else
						if Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldPad, SCE_CTRL_DOWN) then
							CursorIndex = 3
						elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldPad, SCE_CTRL_LEFT) then
							CursorIndex = 3
						elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldPad, SCE_CTRL_RIGHT) then
							CursorIndex = 5
						end
					end
				end
			end
			if CursorIndex >= 0 then
				if Controls.check(pad, SCE_CTRL_CROSS) then
					if CursorIndex == 4 then
						if not (Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_LEFT)) then
							buttonTimeSpace = 400
						end
						local left = is_down and orientation == "Vertical" and SCE_CTRL_RIGHT or SCE_CTRL_LEFT
						local right = is_down and orientation == "Vertical" and SCE_CTRL_LEFT or SCE_CTRL_RIGHT
						if allPages.Page < allPages.Count and Controls.check(pad, right) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldPad, right)) then
							swipe("LEFT")
							buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
							Timer.reset(buttonTimer)
						elseif allPages.Page > 1 and Controls.check(pad, left) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldPad, left)) then
							swipe("RIGHT")
							buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
							Timer.reset(buttonTimer)
						end
					elseif not Controls.check(oldPad, SCE_CTRL_CROSS) then
						if CursorIndex == 0 then
							if allPages.Page > 0 then
								local bookmark
								if readDirection == "LEFT" then
									bookmark = allPages.Count - allPages.Page + 1
								else
									bookmark = allPages.Page
								end
								if bookmark == 1 then
									bookmark = nil
								elseif bookmark == allPages.Count then
									bookmark = true
								end
								if Cache.isCached(Chapters[currentChapterNumber].Manga) then
									Cache.setBookmark(Chapters[currentChapterNumber], bookmark)
								end
							end
							exit()
						elseif CursorIndex == 1 and currentState == STATE_READING then
							if allPages[allPages.Page or -1] then
								deletePageImage(allPages.Page)
								loadPageImage(allPages.Page)
							end
						elseif CursorIndex == 2 and currentState == STATE_READING then
							if allPages[allPages.Page or -1] and (allPages[allPages.Page or -1].Link or allPages[allPages.Page or -1].Path) then
								Extra.setChapters(Chapters[currentChapterNumber].Manga, Chapters[currentChapterNumber], allPages[allPages.Page])
							end
						else
							if readDirection == "LEFT" or is_down and orientation == "Vertical" then
								if CursorIndex == 3 and currentChapterNumber < #Chapters then
									if Cache.isCached(Chapters[currentChapterNumber].Manga) then
										Cache.setBookmark(Chapters[currentChapterNumber], true)
									end
									Reader.loadChapter(currentChapterNumber + 1)
								elseif CursorIndex == 5 and currentChapterNumber > 1 then
									Reader.loadChapter(currentChapterNumber - 1)
									startPage = false
								end
							else
								if CursorIndex == 3 and currentChapterNumber > 1 then
									Reader.loadChapter(currentChapterNumber - 1)
									startPage = false
								elseif CursorIndex == 5 and currentChapterNumber < #Chapters then
									if Cache.isCached(Chapters[currentChapterNumber].Manga) then
										Cache.setBookmark(Chapters[currentChapterNumber], true)
									end
									Reader.loadChapter(currentChapterNumber + 1)
								end
							end
						end
					end
				end
				if CursorIndex == 4 and currentState == STATE_READING then
					local current_page = allPages.Page
					current_page = math.max(1, math.min(current_page, allPages.Count))
					local point = 0
					if allPages.Count == 1 then
						point = 560
					else
						point = ((current_page - 1) * 560 / (allPages.Count - 1))
					end
					if readDirection == "LEFT" then
						CursorDestination = CreatePoint(200 + point, 544 - 40)
					elseif orientation == "Vertical" and is_down then
						if allPages.Count == 1 then
							point = 560
						else
							point = (((allPages.Count - allPages.Page + 1) - 1) * 560 / (allPages.Count - 1))
						end
						CursorDestination = CreatePoint(200 + point, 544 - 40)
					else
						CursorDestination = CreatePoint(200 + point, 544 - 40)
					end
				else
					CursorDestination = CursorPlaces[CursorIndex + 1]
				end
				CursorPoint.x = CursorPoint.x + (CursorDestination.x - CursorPoint.x) / 4
				CursorPoint.y = CursorPoint.y + (CursorDestination.y - CursorPoint.y) / 4
			end
		end
	end
	if touch.x or not ContextMenu then
		CursorIndex = -1
	end
	if Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldPad, SCE_CTRL_START) then
		ContextMenu = not ContextMenu
	end
end

local counterShift = 0

function Reader.update()
	if toggleContextMenu and Timer.getTime(ToggleContextMenuTimer) > 300 then
		Timer.reset(chapterNameTickerTimer)
		Timer.reset(mangaNameTickerTimer)
		ContextMenu = not ContextMenu
		toggleContextMenu = false
	end
	if currentState == STATE_LOADING then
		if Chapters[currentChapterNumber].Pages.Done then
			if #Chapters[currentChapterNumber].Pages == 0 then
				Console.error("Error loading chapter")
				ParserManager.remove((((Chapters or {})[currentChapterNumber or 0] or {}).Pages) or 0)
				collectgarbage("collect")
				if Threads.netActionUnSafe(Network.isWifiEnabled) then
					Notifications.push("Unknown error (Parser's)")
				else
					Notifications.push("Unknown error (No Connection?)")
				end
				AppMode = MENU
				return
			end
			currentState = STATE_READING
			local chapter = Chapters[currentChapterNumber]
			allPages.Count = #chapter.Pages
			if readDirection == "RIGHT" or is_down then
				for i = 1, #chapter.Pages do
					allPages[#allPages + 1] = {
						chapter.Pages[i],
						Path = chapter.Pages[i].Path,
						Extract = chapter.Pages[i].Extract,
						x = 0,
						y = 0
					}
				end
			elseif readDirection == "LEFT" then
				for i = #chapter.Pages, 1, -1 do
					allPages[#allPages + 1] = {
						chapter.Pages[i],
						Path = chapter.Pages[i].Path,
						Extract = chapter.Pages[i].Extract,
						x = 0,
						y = 0
					}
				end
			end
			if readDirection == "RIGHT" or is_down then
				startPage = startPage and startPage > 0 and startPage <= allPages.Count and startPage or startPage == false and -1 or nil
				if startPage == -1 then
					startPage = false
				end
				if currentChapterNumber ~= 1 then
					allPages[0] = {
						Link = "LoadPrev",
						x = 0,
						y = 0
					}
				end
				if currentChapterNumber < #Chapters then
					allPages[#allPages + 1] = {
						Link = "LoadNext",
						x = 0,
						y = 0
					}
				end
				if startPage then
					allPages.Page = startPage - 1
					changePage(startPage)
				elseif startPage == false then
					allPages.Page = allPages.Count + 1
					changePage(allPages.Count)
				else
					allPages.Page = 0
					changePage(1)
				end
				startPage = nil
			elseif readDirection == "LEFT" then
				startPage = startPage and startPage > 0 and startPage <= allPages.Count and startPage or startPage == false and -1 or nil
				if startPage == -1 then
					startPage = false
				end
				if currentChapterNumber < #Chapters then
					allPages[0] = {
						Link = "LoadNext",
						x = 0,
						y = 0
					}
				end
				if currentChapterNumber ~= 1 then
					allPages[#allPages + 1] = {
						Link = "LoadPrev",
						x = 0,
						y = 0
					}
				end
				if startPage then
					allPages.Page = allPages.Count - startPage + 2
					changePage(allPages.Count + 1 - startPage)
				elseif startPage == false then
					allPages.Page = 0
					changePage(1)
				else
					allPages.Page = allPages.Count + 1
					changePage(allPages.Count)
				end
				startPage = nil
			end
			Timer.reset(hideCounterTimer)
		end
	elseif currentState == STATE_READING then
		if not allPages[allPages.Page] then
			return
		end
		gesture_touch_update()
		if allPages.PrevPage and allPages.PrevPage ~= allPages.Page and (((is_down and currentPageOffset.y or currentPageOffset.x) >= 0 and allPages.PrevPage > allPages.Page or (is_down and currentPageOffset.y or currentPageOffset.x) <= 0 and allPages.PrevPage < allPages.Page) and orientation == "Horizontal" or ((is_down and -currentPageOffset.x or currentPageOffset.y) >= 0 and allPages.PrevPage > allPages.Page or (is_down and -currentPageOffset.x or currentPageOffset.y) <= 0 and allPages.PrevPage < allPages.Page) and orientation == "Vertical") then
			if allPages.PrevPage > 0 and allPages.PrevPage <= #allPages then
				deletePageImage(allPages.PrevPage)
			end
			local p = allPages.Page + math.sign(allPages.Page - allPages.PrevPage)
			if p > 0 and p <= #allPages then
				if not allPages[p].Image and not (allPages[p].Link == "LoadPrev" or allPages[p].Link == "LoadNext") then
					if allPages[p].Extract then
						local new_page = allPages[p]
						Threads.addTask(
							new_page,
							{
								Type = "UnZipFile",
								Path = new_page.Path,
								Extract = new_page.Extract,
								DestPath = "ux0:data/noboru/temp/cache.image",
								OnComplete = function()
									Threads.insertTask(
										new_page,
										{
											Type = "Image",
											Table = new_page,
											Path = "temp/cache.image",
											Index = "Image"
										}
									)
								end
							}
						)
					elseif allPages[p].Path then
						Threads.addTask(
							allPages[p],
							{
								Type = "Image",
								Path = allPages[p].Path,
								Table = allPages[p],
								Index = "Image"
							}
						)
					elseif allPages[p].Link then
						Threads.addTask(
							allPages[p],
							{
								Type = "ImageDownload",
								Link = allPages[p].Link,
								Table = allPages[p],
								Index = "Image"
							}
						)
					else
						ParserManager.loadPageImage(Chapters[currentChapterNumber].Manga.ParserID, allPages[p][1], allPages[p], p, false)
					end
				end
			end
		end
		local o = readDirection == "LEFT" and {1, -1, 0} or {-1, 1, 0}
		for k = 1, #o do
			local i = o[k]
			local page = allPages[allPages.Page + i]
			if page and not page.Zoom and page.Image then
				local Image = page.Image
				if orientation == "Horizontal" then
					if is_down then
						page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480, 272 + i * 544
						Console.write("Added " .. allPages.Page + i)
						if autozoom == "Smart" then
							if page.Width < page.Height then
								page.Zoom = 960 / page.Width
							else
								page.Zoom = 544 / page.Height
							end
						elseif autozoom == "Width" then
							page.Zoom = 960 / page.Width
						elseif autozoom == "Height" then
							page.Zoom = 544 / page.Height
						else
							page.Zoom = 960 / page.Width
						end
						if page.Height * page.Zoom >= 544 then
							if i == 0 then
								if allPages.PrevPage > allPages.Page then
									page.y = page.y + (544 - page.Height * page.Zoom) / 2
								elseif allPages.PrevPage < allPages.Page then
									page.y = page.y - (544 - page.Height * page.Zoom) / 2
								end
							else
								page.y = page.y - i * (544 - page.Height * page.Zoom) / 2
							end
						end
						page.min_Zoom = math.min(544 / page.Height, 960 / page.Width)
						if page.Zoom * page.Width > 960 then
							page.x = 960 - (page.Width * page.Zoom) / 2
						end
						page.start_Zoom = page.Zoom
					else
						page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 + i * 960, 272
						Console.write("Added " .. allPages.Page + i)
						if autozoom == "Smart" then
							if page.Width > page.Height then
								page.Zoom = 544 / page.Height
							else
								page.Zoom = 960 / page.Width
							end
						elseif autozoom == "Width" then
							page.Zoom = 960 / page.Width
						elseif autozoom == "Height" then
							page.Zoom = 544 / page.Height
						end
						if page.Width * page.Zoom >= 960 then
							if i == 0 then
								if allPages.PrevPage > allPages.Page then
									page.x = page.x + (960 - page.Width * page.Zoom) / 2
								elseif allPages.PrevPage < allPages.Page then
									page.x = page.x - (960 - page.Width * page.Zoom) / 2
								end
							else
								page.x = page.x - i * (960 - page.Width * page.Zoom) / 2
							end
						end
						page.min_Zoom = math.min(544 / page.Height, 960 / page.Width)
						if page.Zoom * page.Height > 544 then
							page.y = page.Zoom * page.Height / 2
						end
						page.start_Zoom = page.Zoom
					end
				elseif orientation == "Vertical" then
					if is_down then
						page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 - i * 960, 272
						Console.write("Added " .. allPages.Page + i)
						if autozoom == "Smart" then
							if page.Width > page.Height then
								page.Zoom = 960 / page.Height
							else
								page.Zoom = 544 / page.Width
							end
						elseif autozoom == "Width" then
							page.Zoom = 544 / page.Width
						elseif autozoom == "Height" then
							page.Zoom = 960 / page.Height
						else
							page.Zoom = 544 / page.Width
						end
						if page.Height * page.Zoom >= 960 then
							if i == 0 then
								if allPages.PrevPage > allPages.Page then
									page.x = page.x - (960 - page.Height * page.Zoom) / 2
								elseif allPages.PrevPage < allPages.Page then
									page.x = page.x + (960 - page.Height * page.Zoom) / 2
								end
							else
								page.x = page.x + i * (960 - page.Height * page.Zoom) / 2
							end
						end
						page.min_Zoom = math.min(960 / page.Height, 544 / page.Width)
						if page.Zoom * page.Width > 544 then
							page.y = 544 - (page.Zoom * page.Width) / 2
						end
						page.start_Zoom = page.Zoom
					else
						page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480, 272 + i * 544
						Console.write("Added " .. allPages.Page + i)
						if autozoom == "Smart" then
							if page.Width > page.Height then
								page.Zoom = 960 / page.Height
							else
								page.Zoom = 544 / page.Width
							end
						elseif autozoom == "Width" then
							page.Zoom = 544 / page.Width
						elseif autozoom == "Height" then
							page.Zoom = 960 / page.Height
						end
						if page.Width * page.Zoom >= 544 then
							if i == 0 then
								if allPages.PrevPage > allPages.Page then
									page.y = page.y + (544 - page.Width * page.Zoom) / 2
								elseif allPages.PrevPage < allPages.Page then
									page.y = page.y - (544 - page.Width * page.Zoom) / 2
								end
							else
								page.y = page.y - i * (544 - page.Width * page.Zoom) / 2
							end
						end
						page.min_Zoom = math.min(960 / page.Height, 544 / page.Width)
						if page.Zoom * page.Height > 960 then
							page.x = 960 - (page.Zoom * page.Height) / 2
						end
						page.start_Zoom = page.Zoom
					end
				end
			end
		end
		if touchMode == TOUCH_IDLE or touchMode == TOUCH_MOVE then
			local page = allPages[allPages.Page]
			if page and page.Zoom then
				page.x = page.x + velX
				page.y = page.y + velY
			end
			if touchMode == TOUCH_IDLE or OnTouchMenu then
				velY = velY * 0.9
				velX = velX * 0.9
			end
		elseif touchMode == TOUCH_SWIPE then
			if (orientation == "Horizontal" and not is_down) or (orientation == "Vertical" and is_down) then
				if orientation == "Vertical" then
					currentPageOffset.x = currentPageOffset.x + velX
					if currentPageOffset.x < 0 and not allPages[allPages.Page - 1] then
						currentPageOffset.x = 0
					elseif currentPageOffset.x > 0 and allPages.Page == #allPages then
						currentPageOffset.x = 0
					end
				else
					currentPageOffset.x = currentPageOffset.x + velX
					if currentPageOffset.x > 0 and not allPages[allPages.Page - 1] then
						currentPageOffset.x = 0
					elseif currentPageOffset.x < 0 and allPages.Page == #allPages then
						currentPageOffset.x = 0
					end
				end
			else
				currentPageOffset.y = currentPageOffset.y + velY
				if currentPageOffset.y > 0 and not allPages[allPages.Page - 1] then
					currentPageOffset.y = 0
				elseif currentPageOffset.y < 0 and allPages.Page == #allPages then
					currentPageOffset.y = 0
				end
			end
		end
		if touchMode ~= TOUCH_SWIPE then
			local dir = "x"
			if orientation == "Vertical" and not is_down or orientation == "Horizontal" and is_down then
				dir = "y"
			end
			currentPageOffset[dir] = currentPageOffset[dir] / 1.3
			if math.abs(currentPageOffset[dir]) < 1 then
				currentPageOffset[dir] = 0
				if allPages[allPages.Page] and allPages[allPages.Page].Link == "LoadNext" then
					Cache.setBookmark(Chapters[currentChapterNumber], true)
					Reader.loadChapter(currentChapterNumber + 1)
					return
				end
				if allPages[allPages.Page] and allPages[allPages.Page].Link == "LoadPrev" then
					Cache.setBookmark(Chapters[currentChapterNumber], nil)
					startPage = false
					Reader.loadChapter(currentChapterNumber - 1)
					return
				end
			end
		end
		local page = allPages[allPages.Page]
		if orientation == "Horizontal" then
			if is_down then
				if page.Zoom then
					if page.Width * page.Zoom < 960 then
						page.x = 480
					elseif page.x - page.Width / 2 * page.Zoom > 0 then
						page.x = page.Width / 2 * page.Zoom
					elseif page.x + page.Width / 2 * page.Zoom < 960 then
						page.x = 960 - page.Width / 2 * page.Zoom
					end
					if page.Zoom * page.Height > 545 then
						if page.y - page.Height / 2 * page.Zoom >= 0 then
							page.y = page.Height / 2 * page.Zoom
							if allPages[allPages.Page - 1] then
								pageMode = PAGE_LEFT
							else
								pageMode = PAGE_NONE
							end
						elseif page.y + page.Height / 2 * page.Zoom <= 544 then
							page.y = 544 - page.Height / 2 * page.Zoom
							if allPages.Page ~= #allPages then
								pageMode = PAGE_RIGHT
							else
								pageMode = PAGE_NONE
							end
						else
							pageMode = PAGE_NONE
						end
					else
						page.y = 272
						pageMode = PAGE_LEFT + PAGE_RIGHT
					end
				else
					pageMode = PAGE_LEFT + PAGE_RIGHT
				end
			else
				if page.Zoom then
					if page.Height * page.Zoom < 544 then
						page.y = 272
					elseif page.y - page.Height / 2 * page.Zoom > 0 then
						page.y = page.Height / 2 * page.Zoom
					elseif page.y + page.Height / 2 * page.Zoom < 544 then
						page.y = 544 - page.Height / 2 * page.Zoom
					end
					if page.Zoom * page.Width > 961 then
						if page.x - page.Width / 2 * page.Zoom >= 0 then
							page.x = page.Width / 2 * page.Zoom
							if allPages[allPages.Page - 1] then
								pageMode = PAGE_LEFT
							else
								pageMode = PAGE_NONE
							end
						elseif page.x + page.Width / 2 * page.Zoom <= 960 then
							page.x = 960 - page.Width / 2 * page.Zoom
							if allPages.Page ~= #allPages then
								pageMode = PAGE_RIGHT
							else
								pageMode = PAGE_NONE
							end
						else
							pageMode = PAGE_NONE
						end
					else
						page.x = 480
						pageMode = PAGE_LEFT + PAGE_RIGHT
					end
				else
					pageMode = PAGE_LEFT + PAGE_RIGHT
				end
			end
		elseif orientation == "Vertical" then
			if is_down then
				if page.Zoom then
					if page.Width * page.Zoom < 544 then
						page.y = 272
					elseif page.y - page.Width / 2 * page.Zoom > 0 then
						page.y = page.Width / 2 * page.Zoom
					elseif page.y + page.Width / 2 * page.Zoom < 544 then
						page.y = 544 - page.Width / 2 * page.Zoom
					end
					if page.Zoom * page.Height > 961 then
						if page.x - page.Height / 2 * page.Zoom >= 0 then
							page.x = page.Height / 2 * page.Zoom
							if allPages.Page ~= #allPages then
								pageMode = PAGE_LEFT
							else
								pageMode = PAGE_NONE
							end
						elseif page.x + page.Height / 2 * page.Zoom <= 960 then
							page.x = 960 - page.Height / 2 * page.Zoom
							if allPages[allPages.Page - 1] then
								pageMode = PAGE_RIGHT
							else
								pageMode = PAGE_NONE
							end
						else
							pageMode = PAGE_NONE
						end
					else
						page.x = 480
						pageMode = PAGE_LEFT + PAGE_RIGHT
					end
				else
					pageMode = PAGE_LEFT + PAGE_RIGHT
				end
			else
				if page.Zoom then
					if page.Height * page.Zoom < 960 then
						page.x = 480
					elseif page.x - page.Height / 2 * page.Zoom > 0 then
						page.x = page.Height / 2 * page.Zoom
					elseif page.x + page.Height / 2 * page.Zoom < 960 then
						page.x = 960 - page.Height / 2 * page.Zoom
					end
					if page.Zoom * page.Width > 545 then
						if page.y - page.Width / 2 * page.Zoom >= 0 then
							page.y = page.Width / 2 * page.Zoom
							if allPages[allPages.Page - 1] then
								pageMode = PAGE_LEFT
							else
								pageMode = PAGE_NONE
							end
						elseif page.y + page.Width / 2 * page.Zoom <= 544 then
							page.y = 544 - page.Width / 2 * page.Zoom
							if allPages.Page ~= #allPages then
								pageMode = PAGE_RIGHT
							else
								pageMode = PAGE_NONE
							end
						else
							pageMode = PAGE_NONE
						end
					else
						page.y = 272
						pageMode = PAGE_LEFT + PAGE_RIGHT
					end
				else
					pageMode = PAGE_LEFT + PAGE_RIGHT
				end
			end
		end
		if Timer.getTime(hideCounterTimer) > 1500 or MenuFade > 0 then
			counterShift = math.max(counterShift - 1.5, -30)
		else
			counterShift = math.min(counterShift + 1.5, 0)
		end
	end
	if ContextMenu then
		MenuFade = math.min(MenuFade + 0.1, 1)
	else
		MenuFade = math.max(MenuFade - 0.1, 0)
	end
	if CursorIndex >= 0 then
		CursorFade = math.min(CursorFade + 0.1, 1)
	else
		CursorFade = math.max(CursorFade - 0.1, 0)
	end
end

local PI = math.pi

function Reader.draw()
	Screen.clear(COLOR_BACK)
	if currentState == STATE_LOADING then
		local manga_name = Chapters[currentChapterNumber].Manga.Name
		local prepare_message = Language[Settings.Language].READER.PREPARING_PAGES .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
		local chapter_name = Chapters[currentChapterNumber].Name
		if Font.getTextWidth(BONT30, manga_name) > 960 then
			Font.print(FONT16, 480 - Font.getTextWidth(FONT16, manga_name) / 2, 242, manga_name, COLOR_FONT)
		else
			Font.print(BONT30, 480 - Font.getTextWidth(BONT30, manga_name) / 2, 232, manga_name, COLOR_FONT)
		end
		Font.print(FONT16, 480 - Font.getTextWidth(FONT16, chapter_name) / 2, 264, chapter_name, COLOR_FONT)
		Font.print(FONT16, 480 - Font.getTextWidth(FONT16, prepare_message) / 2, 284, prepare_message, COLOR_FONT)
	elseif currentState == STATE_READING then
		local o = readDirection == "LEFT" and {1, -1, 0} or {-1, 1, 0}
		for j = 1, #o do
			local i = o[j]
			local page = allPages[allPages.Page + i]
			if page and page.Image then
				if type(page.Image.e or page.Image) == "table" then
					for k = 1, page.Image.Parts do
						if page.Image[k] and page.Image[k].e then
							local Height = Graphics.getImageHeight(page.Image[k].e)
							if orientation == "Horizontal" then
								local x, y = math.ceil((currentPageOffset.x + page.x) * 4) / 4, currentPageOffset.y + page.y + (k - 1) * page.Image.SliceHeight * page.Zoom - page.Height / 2 * page.Zoom + page.Image.SliceHeight / 2 * page.Zoom
								Graphics.fillRect(x - page.Width / 2 * page.Zoom, x + page.Width / 2 * page.Zoom, y - Height / 2 * page.Zoom, y + Height / 2 * page.Zoom, COLOR_BLACK)
								Graphics.drawImageExtended(x, y, page.Image[k].e, 0, 0, page.Width, Height, 0, page.Zoom, page.Zoom)
							elseif orientation == "Vertical" then
								local x, y = math.ceil((currentPageOffset.x + page.x) * 4) / 4 - (k - 1) * page.Image.SliceHeight * page.Zoom + page.Height / 2 * page.Zoom - page.Image.SliceHeight / 2 * page.Zoom, currentPageOffset.y + page.y
								Graphics.fillRect(x - Height / 2 * page.Zoom, x + Height / 2 * page.Zoom, y - page.Width / 2 * page.Zoom, y + page.Width / 2 * page.Zoom, COLOR_BLACK)
								Graphics.drawImageExtended(x, y, page.Image[k].e, 0, 0, page.Width, Height, PI / 2, page.Zoom, page.Zoom)
							end
						else
							if orientation == "Horizontal" then
								local loading = Language[Settings.Language].READER.LOADING_SEGMENT .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
								local Width = Font.getTextWidth(FONT16, loading)
								Font.print(FONT16, currentPageOffset.x + 960 * i + 480 - Width / 2, currentPageOffset.y + page.y + (k - 1) * page.Image.SliceHeight * page.Zoom - page.Height / 2 * page.Zoom + 10 * page.Zoom, loading, COLOR_FONT)
							elseif orientation == "Vertical" then
								local loading = Language[Settings.Language].READER.LOADING_SEGMENT .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
								local Width = Font.getTextWidth(FONT16, loading)
								Font.print(FONT16, currentPageOffset.x - Width + page.x - ((k - 1) * page.Image.SliceHeight * page.Zoom - page.Height / 2 * page.Zoom + 10 * page.Zoom), currentPageOffset.y + 272 + 544 * i, loading, COLOR_FONT)
							end
						end
					end
				else
					local x, y = math.ceil((currentPageOffset.x + page.x) * 4) / 4, math.ceil((currentPageOffset.y + page.y) * 4) / 4
					if orientation == "Horizontal" then
						Graphics.fillRect(x - page.Width / 2 * page.Zoom, x + page.Width / 2 * page.Zoom, y - page.Height / 2 * page.Zoom, y + page.Height / 2 * page.Zoom, COLOR_BLACK)
						Graphics.drawImageExtended(x, y, page.Image.e, 0, 0, page.Width, page.Height, 0, page.Zoom, page.Zoom)
					elseif orientation == "Vertical" then
						Graphics.fillRect(x - page.Height / 2 * page.Zoom, x + page.Height / 2 * page.Zoom, y - page.Width / 2 * page.Zoom, y + page.Width / 2 * page.Zoom, COLOR_BLACK)
						Graphics.drawImageExtended(x, y, page.Image.e, 0, 0, page.Width, page.Height, PI / 2, page.Zoom, page.Zoom)
					end
				end
			elseif page then
				local precentage = Threads.getProgress(page)
				local loading = Language[Settings.Language].READER.LOADING_PAGE .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
				local Width = Font.getTextWidth(FONT16, loading)
				if orientation == "Horizontal" then
					Font.print(FONT16, currentPageOffset.x + 960 * (is_down and 0 or i) + 480 - Width / 2, 272 + currentPageOffset.y + 544 * (is_down and i or 0) - 10, loading, COLOR_FONT)
					Graphics.fillEmptyRect(currentPageOffset.x + 960 * (is_down and 0 or i) + 480 - 52, currentPageOffset.x + 960 * (is_down and 0 or i) + 480 + 53, 272 + currentPageOffset.y + 544 * (is_down and i or 0) + 20, 272 + currentPageOffset.y + 544 * (is_down and i or 0) + 32, COLOR_FONT)
					Graphics.fillRect(currentPageOffset.x + 960 * (is_down and 0 or i) + 480 - 50, currentPageOffset.x + 960 * (is_down and 0 or i) + 480 - 50 + 100 * precentage, 272 + currentPageOffset.y + 544 * (is_down and i or 0) + 22, 272 + currentPageOffset.y + 544 * (is_down and i or 0) + 29, COLOR_FONT)
				elseif orientation == "Vertical" then
					Font.print(FONT16, 960 / 2 - Width / 2 + currentPageOffset.x + 960 * (is_down and i or 0), 272 + currentPageOffset.y + 544 * (is_down and 0 or i) - 10, loading, COLOR_FONT)
					Graphics.fillEmptyRect(currentPageOffset.x + 960 * (is_down and i or 0) + 480 - 52, currentPageOffset.x + 960 * (is_down and i or 0) + 480 + 53, 272 + currentPageOffset.y + 544 * (is_down and 0 or i) + 20, 272 + currentPageOffset.y + 544 * (is_down and 0 or i) + 32, COLOR_FONT)
					Graphics.fillRect(currentPageOffset.x + 960 * (is_down and i or 0) + 480 - 50, currentPageOffset.x + 960 * (is_down and i or 0) + 480 - 50 + 100 * precentage, 272 + currentPageOffset.y + 544 * (is_down and 0 or i) + 22, 272 + currentPageOffset.y + 544 * (is_down and 0 or i) + 29, COLOR_FONT)
				end
			end
		end
		if allPages.Page <= (allPages.Count or 0) and allPages.Page > 0 then
			local Counter = allPages.Page .. "/" .. allPages.Count
			if readDirection == "LEFT" then
				Counter = (allPages.Count - allPages.Page + 1) .. "/" .. allPages.Count
			end
			local Width = Font.getTextWidth(FONT16, Counter) + 20
			Graphics.fillRect(960 - Width, 960, counterShift, counterShift + Font.getTextHeight(FONT16, Counter) + 4, Color.new(0, 0, 0, 128))
			Font.print(FONT16, 970 - Width, counterShift, Counter, COLOR_WHITE)
		end
	end
	if MenuFade > 0 then
		local BACK_COLOR = Color.new(0, 0, 0, 255 * MenuFade)
		local GRAY_COLOR = Color.new(128, 128, 128, 255 * MenuFade)
		local BLUE_COLOR = CloneColorWithNewAlpha(COLOR_ROYAL_BLUE, 255 * MenuFade)
		Graphics.fillRect(88, 960 - 88 - 32 - 24 - 32, 0, 80 * MenuFade, BACK_COLOR)
		Graphics.fillRect(0, 960, 544 - 80 * MenuFade, 544, BACK_COLOR)
		if currentState == STATE_READING then
			local current_page = allPages.Page
			current_page = math.max(1, math.min(current_page, allPages.Count))
			local point = 0
			if allPages.Count == 1 then
				point = 560
			else
				point = ((current_page - 1) * 560 / (allPages.Count - 1))
			end
			if readDirection == "LEFT" then
				Graphics.fillRect(200, 760, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, BLUE_COLOR)
				Graphics.fillRect(200, 200 + point, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, GRAY_COLOR)
				Graphics.drawImage(200 + point - 6, 544 - 80 * MenuFade + 40 - 6, CircleIcon.e, BLUE_COLOR)
				current_page = (allPages.Count - allPages.Page + 1)
				current_page = math.max(1, math.min(current_page, allPages.Count))
				Font.print(FONT26, 180 - Font.getTextWidth(FONT26, allPages.Count), 544 - 80 * MenuFade + 23, allPages.Count, COLOR_WHITE)
				Font.print(FONT26, 780, 544 - 80 * MenuFade + 23, current_page, COLOR_WHITE)
			elseif orientation == "Vertical" and is_down then
				if allPages.Count == 1 then
					point = 560
				else
					point = (((allPages.Count - allPages.Page + 1) - 1) * 560 / (allPages.Count - 1))
				end
				Graphics.fillRect(200, 760, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, BLUE_COLOR)
				Graphics.fillRect(200, 200 + point, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, GRAY_COLOR)
				Graphics.drawImage(200 + point - 6, 544 - 80 * MenuFade + 40 - 6, CircleIcon.e, BLUE_COLOR)
				Font.print(FONT26, 180 - Font.getTextWidth(FONT26, allPages.Count), 544 - 80 * MenuFade + 23, allPages.Count, COLOR_WHITE)
				Font.print(FONT26, 780, 544 - 80 * MenuFade + 23, current_page, COLOR_WHITE)
			else
				Graphics.fillRect(200, 760, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, GRAY_COLOR)
				Graphics.fillRect(200, 200 + point, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, BLUE_COLOR)
				Graphics.drawImage(200 + point - 6, 544 - 80 * MenuFade + 40 - 6, CircleIcon.e, BLUE_COLOR)
				Font.print(FONT26, 180 - Font.getTextWidth(FONT26, current_page), 544 - 80 * MenuFade + 23, current_page, COLOR_WHITE)
				Font.print(FONT26, 780, 544 - 80 * MenuFade + 23, allPages.Count, COLOR_WHITE)
			end
		end
		if currentChapterNumber > 1 and not (orientation == "Vertical" and is_down or readDirection == "LEFT") or currentChapterNumber < #Chapters and (orientation == "Vertical" and is_down or readDirection == "LEFT") then
			Graphics.drawImage(32, 544 - 80 * MenuFade + 40 - 12, leftArrowIcon.e, COLOR_WHITE)
		else
			Graphics.drawImage(32, 544 - 80 * MenuFade + 40 - 12, leftArrowIcon.e, COLOR_GRAY)
		end
		if currentChapterNumber < #Chapters and not (orientation == "Vertical" and is_down or readDirection == "LEFT") or currentChapterNumber > 1 and (orientation == "Vertical" and is_down or readDirection == "LEFT") then
			Graphics.drawImage(960 - 32 - 24, 544 - 80 * MenuFade + 40 - 12, rightArrowIcon.e, COLOR_WHITE)
		else
			Graphics.drawImage(960 - 32 - 24, 544 - 80 * MenuFade + 40 - 12, rightArrowIcon.e, COLOR_GRAY)
		end
		if Chapters[currentChapterNumber] then
			local manga_name = Chapters[currentChapterNumber].Manga.Name
			local chapter_name = Chapters[currentChapterNumber].Name
			local dif = math.max(Font.getTextWidth(BONT30, manga_name) - 960 + 88 + 32 + 24 + 32 + 24 + 32 + 32, 0)
			local dif_ch = math.max(Font.getTextWidth(FONT16, chapter_name) - 960 + 88 + 32 + 24 + 32 + 24 + 32 + 32, 0)
			local ms = 50 * string.len(manga_name)
			local ms_ch = 50 * string.len(chapter_name)
			local t = math.min(math.max(0, Timer.getTime(mangaNameTickerTimer) - 1500), ms)
			local t_ch = math.min(math.max(0, Timer.getTime(chapterNameTickerTimer) - 1500), ms_ch)
			Font.print(BONT30, 88 - dif * t / ms, 80 * MenuFade - 73, manga_name, COLOR_WHITE)
			Font.print(FONT16, 88 - dif_ch * t_ch / ms_ch, 80 * MenuFade - 32, chapter_name, COLOR_WHITE)
			Graphics.fillRect(0, 88, 0, 80 * MenuFade, BACK_COLOR)
			Graphics.drawImage(32, 80 * MenuFade - 40 - 12, BackIcon.e, COLOR_WHITE)
			Graphics.fillRect(960 - 88 - 32 - 24 - 32, 960, 0, 80 * MenuFade, BACK_COLOR)
			if currentState == STATE_READING then
				Graphics.drawImage(960 - 32 - 24 - 32 - 32 - 24, 80 * MenuFade - 40 - 12, RefreshIcon.e, COLOR_WHITE)
				if allPages[allPages.Page] and (allPages[allPages.Page].Link or Chapters[currentChapterNumber].Manga.ParserID == "IMPORTED" or allPages[allPages.Page].Path) then
					Graphics.drawImage(960 - 32 - 24, 80 * MenuFade - 40 - 12, OptionsIcon.e, COLOR_WHITE)
				else
					Graphics.drawImage(960 - 32 - 24, 80 * MenuFade - 40 - 12, OptionsIcon.e, COLOR_GRAY)
				end
			end
			if Timer.getTime(mangaNameTickerTimer) > 3500 + ms then
				Timer.reset(mangaNameTickerTimer)
			end
			if Timer.getTime(chapterNameTickerTimer) > 3500 + ms_ch then
				Timer.reset(chapterNameTickerTimer)
			end
		else
			Graphics.fillRect(0, 88, 0, 80 * MenuFade, BACK_COLOR)
			Graphics.fillRect(960 - 88 - 32 - 24 - 32, 960, 0, 80 * MenuFade, BACK_COLOR)
		end
		if CursorFade >= 0 then
			local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
			local shift = 80 * (1 - MenuFade)
			for i = ks, ks + 1 do
				if CursorPoint.y > 272 then
					Graphics.fillEmptyRect(CursorPoint.x - 20 - i, CursorPoint.x + 20 + i + 2, CursorPoint.y - 20 - i + shift, CursorPoint.y + 20 + i + 2 + shift, Color.new(255, 0, 51, 255 * CursorFade))
				else
					Graphics.fillEmptyRect(CursorPoint.x - 20 - i, CursorPoint.x + 20 + i + 2, CursorPoint.y - 20 - i - shift, CursorPoint.y + 20 + i + 2 - shift, Color.new(255, 0, 51, 255 * CursorFade))
				end
			end
		end
	end
end

function Reader.loadChapter(chapter)
	currentState = STATE_LOADING
	if not Chapters[chapter] then
		Console.error("Error loading chapter")
		exit()
		return
	end
	if Chapters and Chapters[currentChapterNumber] then
		ParserManager.remove(Chapters[currentChapterNumber].Pages)
	end
	currentChapterNumber = chapter
	Chapters[chapter].Pages = {}
	allPages = {
		Page = 0
	}
	collectgarbage("collect")
	if ChapterSaver.check(Chapters[chapter]) then
		Chapters[chapter].Pages = ChapterSaver.getChapter(Chapters[chapter])
	else
		ParserManager.prepareChapter(Chapters[chapter], Chapters[chapter].Pages)
	end
	Timer.reset(chapterNameTickerTimer)
	Timer.reset(mangaNameTickerTimer)
end

function Reader.updateSettings()
	local settings = CuSettings.load(Chapters[1].Manga)
	local old_read_dir = readDirection
	if settings then
		readDirection = settings.ReaderDirection == "Default" and Settings.ReaderDirection or settings.ReaderDirection
		is_down = readDirection == "DOWN"
		orientation = settings.Orientation == "Default" and Settings.Orientation or settings.Orientation
		autozoom = settings.ZoomReader == "Default" and Settings.ZoomReader or settings.ZoomReader
	end
	if old_read_dir == "LEFT" and readDirection ~= old_read_dir or (old_read_dir == "RIGHT" or old_read_dir == "DOWN") and readDirection == "LEFT" then
		if allPages and allPages.Count and allPages.Page and allPages.PrevPage then
			local i, j = 1, allPages.Count
			while i < j do
				allPages[i], allPages[j] = allPages[j], allPages[i]
				i = i + 1
				j = j - 1
			end
			local zpage = allPages[0]
			if allPages[#allPages].Link == "LoadNext" or allPages[#allPages].Link == "LoadPrev" then
				allPages[0] = allPages[#allPages]
				allPages[#allPages] = nil
			end
			if zpage then
				allPages[#allPages + 1] = zpage
				if allPages[0] == zpage then
					allPages[0] = nil
				end
			end
			allPages.Page = allPages.Count - allPages.Page + 1
			allPages.PrevPage = allPages.Count - allPages.PrevPage + 1
		end
	end
	updateMeasurements()
end

function Reader.load(chapters, num)
	if not chapters[1] then
		Console.error("Error loading chapter")
		AppMode = MENU
		return
	end
	local settings = CuSettings.load(chapters[1].Manga)
	if settings then
		readDirection = settings.ReaderDirection == "Default" and Settings.ReaderDirection or settings.ReaderDirection
		is_down = readDirection == "DOWN"
		orientation = settings.Orientation == "Default" and Settings.Orientation or settings.Orientation
		autozoom = settings.ZoomReader == "Default" and Settings.ZoomReader or settings.ZoomReader
	end
	Chapters = chapters
	startPage = Cache.getBookmark(chapters[num])
	if startPage == true or startPage == nil then
		startPage = 1
	end
	Reader.loadChapter(num)
end

function Reader.getCurrentPageImageLink()
	local page = allPages[allPages.Page]
	if page then
		if page.Extract then
			return {
				Path = page.Path,
				Extract = page.Extract
			}
		elseif page.Path then
			return {
				Path = page.Path
			}
		elseif page.Link then
			return {
				Link = page.Link
			}
		else
			return {
				ParserID = Chapters[currentChapterNumber].Manga.ParserID,
				Link = page[1]
			}
		end
	end
end
