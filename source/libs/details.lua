Details = {}

local status = "END"
local selectedManga = nil

local slider = CreateSlider()
local deleteFile = System.deleteFile
local doesFileExist = System.doesFileExist
local isCJK = IsCJK

local descriptionString = nil
local descriptionWordList = {}

local MANGA_COVER_CENTER_POINT = CreatePoint(140, 326 / 2 + 85)
local TOUCH_MODES = TOUCH_MODES
local DESCRIPTION_WIDTH = 670
local LINE_HEIGHT = 22

local chaptersMaxHeightOffset = 0
local descriptionMaxHeightOffset = 0

local fade = 0
local oldFade = 1

RemoveIcon = Image:new(Graphics.loadImage("app0:assets/icons/cross.png"))
local menuIcon = Image:new(Graphics.loadImage("app0:assets/icons/menu.png"))
local sortIcons = {
	["N->1"] = Image:new(Graphics.loadImage("app0:assets/icons/sort-9-1.png")),
	["1->N"] = Image:new(Graphics.loadImage("app0:assets/icons/sort-1-9.png"))
}

local maxMangaNameTickerTimeMs = 0
local maxMangaNameOffset = 0
local maxChapterNameTickerTimeMs = 0
local maxChapterNameOffset = 0

local fadeTimer = Timer.new()
local mangaNameTickerTimer = Timer.new()
local chapterNameTickerTimer = Timer.new()

local isNotified = false
local isDescriptionExpanded = false
local isChapterListLoadedOffline = false
local isChapterListReady = false

local chapterList = {}
local continueChapterNumber
local detailsSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return math.floor((slider.Y - 20 + 90) / 80)
	end
)

---Updates scrolling movement
local function updateScrolling()
	local selectedItem = detailsSelector.getSelected()
	if selectedItem ~= 0 then
		slider.Y = slider.Y + (selectedItem * 80 - (544 - chaptersMaxHeightOffset) / 2 - slider.Y) / 8
	end
	slider.Y = slider.Y + slider.V
	slider.V = slider.V / 1.12
	if math.abs(slider.V) < 0.1 then
		slider.V = 0
	end
	if slider.Y < -15 then
		slider.Y = -15
		slider.V = 0
	elseif slider.Y > (#chapterList * 80 - 464 + chaptersMaxHeightOffset) then
		slider.Y = math.max(-15, #chapterList * 80 - 464 + chaptersMaxHeightOffset)
		slider.V = 0
	end
end

local easingFunction = EaseInOutCubic

---Updates animation of fade in or out
local function updateAnimations()
	if status == "START" then
		fade = easingFunction(math.min((Timer.getTime(fadeTimer) / 500), 1))
	elseif status == "WAIT" then
		if fade == 0 then
			status = "END"
		end
		fade = 1 - easingFunction(math.min((Timer.getTime(fadeTimer) / 500), 1))
	end
	if Timer.getTime(mangaNameTickerTimer) > 3500 + maxMangaNameTickerTimeMs then
		Timer.reset(mangaNameTickerTimer)
	end
	if Timer.getTime(chapterNameTickerTimer) > 3500 + maxChapterNameTickerTimeMs then
		Timer.reset(chapterNameTickerTimer)
	end
	if ParserManager.check(chapterList) then
		Loading.setStatus("WHITE", 580, 250)
	else
		Loading.setStatus("NONE")
	end
end

---Updates `chaptersMaxHeightOffset` depending on if description is expanded
local function updateMangaDescriptionMaxHeight()
	if #descriptionWordList > 0 then
		local linesCount = isDescriptionExpanded and #descriptionWordList or math.min(2, #descriptionWordList)
		local finalOffset = linesCount * LINE_HEIGHT + LINE_HEIGHT + 10
		if linesCount ~= #descriptionWordList or linesCount > 2 then
			finalOffset = finalOffset + LINE_HEIGHT
			chaptersMaxHeightOffset = math.max(LINE_HEIGHT * 4 + 10, math.min(chaptersMaxHeightOffset + (math.min(LINE_HEIGHT * (linesCount + 2) + 10, 544 - 95) - chaptersMaxHeightOffset) / 8, math.min(LINE_HEIGHT * (#descriptionWordList + 2) + 10, 544 - 95)))
			if not isDescriptionExpanded then
				descriptionMaxHeightOffset = descriptionMaxHeightOffset - descriptionMaxHeightOffset / 8
			end
		else
			chaptersMaxHeightOffset = finalOffset
		end
	else
		chaptersMaxHeightOffset = 0
	end
end

---@param newDescription string
---Updates `descriptionString` and `descriptionWordList`
---This function analyzing `newDescription` and creates data to make something like `align-text:justify` on css
local function updateMangaDescription(newDescription)
	descriptionString = (newDescription or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local wordList = {}
	for word in descriptionString:gmatch("[^ ]+") do
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
			elseif w + wordWidth + 4 > DESCRIPTION_WIDTH then
				w = wordWidth
				local spaceWidth = 0
				for i = 1, #lines[#lines] do
					spaceWidth = spaceWidth + lines[#lines][i].Width
				end
				spaceWidth = (DESCRIPTION_WIDTH - spaceWidth) / #lines[#lines]
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
	descriptionWordList = lines
end

---Updates `chaptersList` when it's ready
local function updateChaptersList()
	if not isChapterListLoadedOffline and not ParserManager.check(chapterList) then
		if #chapterList > 0 then
			if Cache.isCached(chapterList[1].Manga) then
				isChapterListLoadedOffline = true
				Cache.saveChapters(chapterList[1].Manga, chapterList)
			end
			local manga = chapterList[1].Manga
			if manga.NewImageLink and not CustomCovers.hasCustomCover(manga) and manga.NewImageLink ~= selectedManga.ImageLink then
				local coverPath = "ux0:data/noboru/cache/" .. Cache.getMangaHash(selectedManga) .. "/cover.image"
				if doesFileExist(coverPath) then
					deleteFile(coverPath)
				end
				selectedManga.ImageLink = manga.NewImageLink
				selectedManga.ImageDownload = nil
				collectgarbage("collect")
			end
		end
	end
	if not isChapterListReady and not ParserManager.check(chapterList) then
		isChapterListReady = true
		if Settings.LoadSummary then
			updateMangaDescription(chapterList.Description or "")
		else
			updateMangaDescription("")
		end
	end
end

---Sets Continue button to latest read chapter in given `Manga`
local function updateContinueChapterNumber()
	if AppMode == MENU and not continueChapterNumber and not ParserManager.check(chapterList) then
		continueChapterNumber = 0
		if #chapterList > 0 then
			chapterList[1].Manga.Counter = #chapterList
			local latestChapter = Cache.getLatestBookmark(selectedManga)
			for i = 1, #chapterList do
				local key = chapterList[i].Link:gsub("%p", "")
				if latestChapter == key then
					local bookmark = Cache.getBookmark(chapterList[i])
					if bookmark == true then
						continueChapterNumber = i + 1
						if not chapterList[continueChapterNumber] then
							continueChapterNumber = i
						end
						chapterList[1].Manga.Counter = #chapterList - i
					else
						continueChapterNumber = i
						chapterList[1].Manga.Counter = #chapterList - i + 1
					end
					break
				end
			end
			if continueChapterNumber > 0 then
				local continueChapterName = chapterList[continueChapterNumber].Name or ("Chapter " .. continueChapterNumber)
				maxChapterNameTickerTimeMs = 25 * string.len(continueChapterName)
				maxChapterNameOffset = math.max(Font.getTextWidth(FONT16, continueChapterName) - 220, 0)
				Timer.reset(chapterNameTickerTimer)
			end
		end
	end
	if Extra.doesBookmarksUpdate() then
		continueChapterNumber = nil
	end
end

---@param manga table
---Sets `manga` to details
function Details.setManga(manga)
	if manga then
		selectedManga = manga
		status = "START"
		oldFade = 1
		slider.Y = -50

		maxMangaNameTickerTimeMs = 50 * string.len(manga.Name)
		maxMangaNameOffset = math.max(Font.getTextWidth(BOLD_FONT30, manga.Name) - 960 + 88 + 88 + 88, 0)

		chapterList = {}
		detailsSelector:resetSelected()

		if Cache.isCached(selectedManga) and not Cache.isBookmarkExist(selectedManga) then
			Cache.loadBookmarks(selectedManga)
		elseif Database.check(selectedManga) then
			Cache.addManga(selectedManga, chapterList)
		end

		continueChapterNumber = nil

		if Threads.netActionUnSafe(Network.isWifiEnabled) and GetParserByID(manga.ParserID) then
			ParserManager.getChaptersAsync(manga, chapterList)
			isChapterListLoadedOffline = false
		else
			chapterList = Cache.loadMangaChapters(manga)
			isChapterListLoadedOffline = true
		end
		isChapterListReady = false
		isNotified = false
		isDescriptionExpanded = false

		descriptionWordList = {}
		descriptionMaxHeightOffset = 0

		Timer.reset(fadeTimer)
		Timer.reset(mangaNameTickerTimer)
	end
end

---Adds / Removes Manga from library
local function addToLibrary()
	if Database.check(selectedManga) then
		Database.removeManga(selectedManga)
		Notifications.push(Language[Settings.Language].NOTIFICATIONS.REMOVED_FROM_LIBRARY)
	else
		Database.addManga(selectedManga)
		Cache.addManga(selectedManga)
		Notifications.push(Language[Settings.Language].NOTIFICATIONS.ADDED_TO_LIBRARY)
	end
end

---@param item integer
---Download / Stop Download / Delete `chapterList[item]` Chapter
local function downloadChapter(item)
	local isWifiEnabled = Threads.netActionUnSafe(Network.isWifiEnabled)
	item = chapterList[item]
	if item then
		Cache.addManga(selectedManga, chapterList)
		Cache.makeHistory(selectedManga)
		if not ChapterSaver.check(item) then
			if ChapterSaver.isChapterDownloading(item) then
				ChapterSaver.stop(item)
			elseif isWifiEnabled then
				ChapterSaver.downloadChapter(item)
			else
				Notifications.pushUnique(Language[Settings.Language].SETTINGS.NoConnection)
			end
		else
			ChapterSaver.delete(item)
		end
	end
end

---@param item integer
---Opens Reader and loads `chapterList` and `item` chapter in
local function readChapter(item)
	if chapterList[item] then
		Catalogs.shrink()
		Cache.addManga(selectedManga, chapterList)
		Cache.makeHistory(selectedManga)
		Reader.load(chapterList, item)
		AppMode = READER
		continueChapterNumber = nil
	end
end

---@param oldPad table
---@param pad table
---@param oldTouch table
---@param touch table
---Updates input for Details menu
function Details.input(oldPad, pad, oldTouch, touch)
	if status == "START" then
		local oldTouchMode = TOUCH_MODES.MODE
		if TOUCH_MODES.MODE == TOUCH_MODES.NONE and oldTouch.x and touch.x and touch.x > 240 then
			TOUCH_MODES.MODE = TOUCH_MODES.READ
			slider.TouchY = touch.y
		elseif TOUCH_MODES.MODE ~= TOUCH_MODES.NONE and not touch.x then
			if TOUCH_MODES.MODE == TOUCH_MODES.READ and oldTouch.x then
				if oldTouch.x > 320 and oldTouch.x < 955 and oldTouch.y > 90 + chaptersMaxHeightOffset then
					local id = math.floor((slider.Y + oldTouch.y - 20 - chaptersMaxHeightOffset) / 80)
					if Settings.ChapterSorting == "N->1" then
						id = #chapterList - id + 1
					end
					if oldTouch.x < 866 or selectedManga.ParserID == "IMPORTED" then
						readChapter(id)
					else
						downloadChapter(id)
					end
				elseif oldTouch.x > 270 and oldTouch.x < 960 and oldTouch.y > 90 and oldTouch.y <= 90 + chaptersMaxHeightOffset then
					isDescriptionExpanded = not isDescriptionExpanded
				end
			end
			TOUCH_MODES.MODE = TOUCH_MODES.NONE
		end
		local isDescriptionScrollable = not (isDescriptionExpanded and #descriptionWordList >= 13)
		if isDescriptionScrollable then
			detailsSelector:input(#chapterList, oldPad, pad, touch.x)
		else
			if Controls.check(pad, SCE_CTRL_UP) then
				descriptionMaxHeightOffset = math.max(descriptionMaxHeightOffset - 3, 0)
			elseif Controls.check(pad, SCE_CTRL_DOWN) then
				descriptionMaxHeightOffset = math.min(descriptionMaxHeightOffset + 3, math.max(0, #descriptionWordList * LINE_HEIGHT - (544 - 95 - 24 - 24 - 10)))
			end
		end
		if oldTouch.x and not touch.x then
			if oldTouch.x > 20 and oldTouch.x < 260 and oldTouch.y > 416 and oldTouch.y < 475 then
				addToLibrary()
			elseif oldTouch.x > 20 and oldTouch.x < 260 and oldTouch.y > 480 then
				if continueChapterNumber then
					readChapter(continueChapterNumber > 0 and continueChapterNumber or 1)
				end
			elseif oldTouch.x > 960 - 88 and oldTouch.y < 90 and isChapterListReady and oldTouchMode == TOUCH_MODES.READ then
				Extra.setChapters(selectedManga, chapterList)
			elseif oldTouch.x > 960 - 88 - 88 and oldTouch.y < 90 and oldTouchMode == TOUCH_MODES.READ then
				SettingsFunctions.ChapterSorting()
				Settings.save()
			end
		elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldPad, SCE_CTRL_TRIANGLE) then
			addToLibrary()
		elseif isDescriptionScrollable and Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldPad, SCE_CTRL_CROSS) then
			local id = detailsSelector.getSelected()
			if Settings.ChapterSorting == "N->1" then
				id = #chapterList - id + 1
			end
			readChapter(id)
		elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldPad, SCE_CTRL_CIRCLE) or (touch.x and not oldTouch.x and touch.x < 88 and touch.y < 90) then
			status = "WAIT"
			Loading.setStatus("NONE")
			ParserManager.remove(chapterList)
			Timer.reset(fadeTimer)
			oldFade = fade
		elseif isDescriptionScrollable and Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldPad, SCE_CTRL_SQUARE) and selectedManga.ParserID ~= "IMPORTED" then
			local id = detailsSelector.getSelected()
			if Settings.ChapterSorting == "N->1" then
				id = #chapterList - id + 1
			end
			downloadChapter(id)
		elseif Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldPad, SCE_CTRL_SELECT) then
			if continueChapterNumber then
				readChapter(continueChapterNumber > 0 and continueChapterNumber or 1)
			end
		elseif Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldPad, SCE_CTRL_START) and isChapterListReady then
			Extra.setChapters(selectedManga, chapterList)
		elseif Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldPad, SCE_CTRL_RTRIGGER) and isChapterListReady then
			SettingsFunctions.ChapterSorting()
			Settings.save()
		elseif Controls.check(pad, SCE_CTRL_LTRIGGER) and not Controls.check(oldPad, SCE_CTRL_LTRIGGER) and isChapterListReady then
			isDescriptionExpanded = not isDescriptionExpanded
		end
		local newItemID = 0
		if TOUCH_MODES.MODE == TOUCH_MODES.READ then
			if math.abs(slider.V) > 0.1 or math.abs(touch.y - slider.TouchY) > 10 then
				TOUCH_MODES.MODE = TOUCH_MODES.SLIDE
			else
				if oldTouch.x > 320 and oldTouch.x < 900 and oldTouch.y > 90 + chaptersMaxHeightOffset then
					local id = math.floor((slider.Y - 20 + oldTouch.y - chaptersMaxHeightOffset) / 80)
					if Settings.ChapterSorting == "N->1" then
						id = #chapterList - id + 1
					end
					if chapterList[id] then
						newItemID = id
					end
				end
			end
		elseif TOUCH_MODES.MODE == TOUCH_MODES.SLIDE then
			if touch.x and oldTouch.x then
				slider.V = oldTouch.y - touch.y
			end
		end
		if slider.ItemID > 0 and newItemID > 0 and slider.ItemID ~= newItemID then
			TOUCH_MODES.MODE = TOUCH_MODES.SLIDE
		else
			slider.ItemID = newItemID
		end
	end
end

---Updates Animations and Events for Details menu
function Details.update()
	if status ~= "END" then
		updateAnimations()
		updateMangaDescriptionMaxHeight()
		updateScrolling()
		updateChaptersList()
		updateContinueChapterNumber()
	end
end

---Draws Details menu
function Details.draw()
	if status ~= "END" then
		local M = oldFade * fade
		local Alpha = 255 * M

		local backgroundColor = Color.new(0, 0, 0, Alpha)
		local textColor = Color.new(255, 255, 255, Alpha)
		local secondTextColor = Color.new(128, 128, 128, Alpha)
		local addMangaButtonColor = Color.new(42, 47, 78, Alpha)
		local removeMangaButtonColor = Color.new(137, 30, 43, Alpha)
		local continueButtonColor = Color.new(19, 76, 76, Alpha)

		Graphics.fillRect(20, 260, 90, 544, backgroundColor)
		local start = math.max(1, math.floor(slider.Y / 80) + 1)
		local shift = (1 - M) * 544
		local y = shift - slider.Y + start * 80 + chaptersMaxHeightOffset
		local color, text = addMangaButtonColor, Language[Settings.Language].DETAILS.ADD_TO_LIBRARY

		if Database.check(selectedManga) then
			color = removeMangaButtonColor
			text = Language[Settings.Language].DETAILS.REMOVE_FROM_LIBRARY
		end
		Graphics.fillRect(20, 260, shift + 416, shift + 475, color)
		Font.print(FONT20, 140 - Font.getTextWidth(FONT20, text) / 2, shift + 444 - Font.getTextHeight(FONT20, text) / 2, text, textColor)
		if continueChapterNumber then
			if #chapterList > 0 then
				Graphics.fillRect(30, 250, shift + 480, shift + 539, continueButtonColor)
				local continueButtonText = Language[Settings.Language].DETAILS.START
				local chapterName
				local dy = 0
				if continueChapterNumber > 0 and chapterList[continueChapterNumber] and (continueChapterNumber == 1 and Cache.getBookmark(chapterList[continueChapterNumber]) or continueChapterNumber ~= 1) then
					continueButtonText = Language[Settings.Language].DETAILS.CONTINUE
					dy = -10
					chapterName = chapterList[continueChapterNumber].Name or ("Chapter " .. continueChapterNumber)
				end
				local continueButtonTextWidth = Font.getTextWidth(FONT20, continueButtonText)
				local continueButtonTextHeight = Font.getTextHeight(FONT20, continueButtonText)
				Font.print(FONT20, 140 - continueButtonTextWidth / 2, shift + 505 - continueButtonTextHeight / 2 + dy, continueButtonText, textColor)
				if chapterName then
					continueButtonTextWidth = math.min(Font.getTextWidth(FONT16, chapterName), 220)
					local chapterNameTickerX = maxChapterNameOffset * math.min(math.max(0, Timer.getTime(chapterNameTickerTimer) - 1500), maxChapterNameTickerTimeMs) / maxChapterNameTickerTimeMs
					Font.print(FONT16, 140 - continueButtonTextWidth / 2 - chapterNameTickerX, shift + 505 - continueButtonTextHeight / 2 + 18, chapterName, textColor)
				end
				Graphics.fillRect(20, 30, shift + 480, shift + 539, continueButtonColor)
				Graphics.fillRect(250, 260, shift + 480, shift + 539, continueButtonColor)
			end
		end
		Graphics.fillRect(0, 20, 90, 544, backgroundColor)
		if continueChapterNumber and #chapterList > 0 then
			Graphics.drawImage(0, shift + 472, ButtonsIcons.Select.e)
		end
		Graphics.drawImageExtended(20, shift + 420, ButtonsIcons.Triangle.e, 0, 0, 16, 16, 0, 1, 1)
		DrawDetailsManga(MANGA_COVER_CENTER_POINT.x, MANGA_COVER_CENTER_POINT.y + 544 * (1 - M), selectedManga, 326 / MANGA_HEIGHT)
		Graphics.fillRect(260, 890 - 18, 90, 95, backgroundColor)
		Graphics.fillRect(260, 890 - 18, 95 + chaptersMaxHeightOffset, 544, backgroundColor)
		local listCount = #chapterList
		for n = start, math.min(listCount, start + 8) do
			if y + 80 > 95 + chaptersMaxHeightOffset then
				local i = Settings.ChapterSorting ~= "N->1" and n or listCount - n + 1
				local bookmark = Cache.getBookmark(chapterList[i])
				if bookmark ~= nil and bookmark ~= true then
					Font.print(FONT16, 290, y + 44, Language[Settings.Language].DETAILS.PAGE .. bookmark, textColor)
					Font.print(BOLD_FONT16, 290, y + 14, chapterList[i].Name or ("Chapter " .. i), textColor)
				elseif bookmark == true then
					Font.print(FONT16, 290, y + 44, Language[Settings.Language].DETAILS.DONE, secondTextColor)
					Font.print(BOLD_FONT16, 290, y + 14, chapterList[i].Name or ("Chapter " .. i), secondTextColor)
				else
					Font.print(BOLD_FONT16, 290, y + 28, chapterList[i].Name or ("Chapter " .. i), textColor)
				end
			end
			y = y + 80
			if y > 544 then
				break
			end
		end
		Graphics.fillRect(890 - 18, 955, 90, 95, backgroundColor)
		Graphics.fillRect(890 - 18, 955, 95 + chaptersMaxHeightOffset, 544, backgroundColor)
		y = shift - slider.Y + start * 80 + chaptersMaxHeightOffset
		for n = start, math.min(listCount, start + 8) do
			if y + 80 > 95 + chaptersMaxHeightOffset then
				local i = Settings.ChapterSorting ~= "N->1" and n or listCount - n + 1
				if selectedManga.ParserID ~= "IMPORTED" then
					if ChapterSaver.check(chapterList[i]) then
						Graphics.drawImage(920 - 14 - 18, y + 40 - 12, RemoveIcon.e)
					else
						local chapterDownloadInfo = ChapterSaver.isChapterDownloading(chapterList[i])
						if chapterDownloadInfo then
							local downloadProgressPercentageText = "0%"
							if chapterDownloadInfo.page_count and chapterDownloadInfo.page_count > 0 then
								downloadProgressPercentageText = math.ceil(100 * chapterDownloadInfo.page / chapterDownloadInfo.page_count) .. "%"
							end
							local width = Font.getTextWidth(FONT20, downloadProgressPercentageText)
							Font.print(FONT20, 920 - width / 2 - 18, y + 26, downloadProgressPercentageText, COLOR_WHITE)
						else
							Graphics.drawImage(920 - 14 - 18, y + 40 - 12, DownloadIcon.e)
						end
					end
				end
				if i == slider.ItemID then
					Graphics.fillRect(270, 945, y, y + 79, Color.new(255, 255, 255, 24 * M))
				end
			end
			y = y + 80
		end
		if status == "START" and #chapterList == 0 and not ParserManager.check(chapterList) and not isNotified then
			isNotified = true
			Notifications.push(Language[Settings.Language].WARNINGS.NO_CHAPTERS)
		end
		local item = detailsSelector.getSelected()
		if item ~= 0 then
			y = shift - slider.Y + item * 80 + chaptersMaxHeightOffset
			if y + 80 > 95 + chaptersMaxHeightOffset then
				local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
				local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
				for i = ks, ks + 1 do
					Graphics.fillEmptyRect(272 + i, 950 - i, y + i + 2, y + 75 - i + 1, Color.new(255, 0, 51))
					Graphics.fillEmptyRect(272 + i, 950 - i, y + i + 2, y + 75 - i + 1, SELECTED_RED)
				end
				if selectedManga.ParserID ~= "IMPORTED" then
					Graphics.drawImage(929 - ks, y + 5 + ks, ButtonsIcons.Square.e)
				end
			end
		end
		if #descriptionWordList > 0 and chaptersMaxHeightOffset > 0 then
			local descriptionLinesCount = isDescriptionExpanded and #descriptionWordList or math.min(2, #descriptionWordList)
			if descriptionLinesCount ~= #descriptionWordList or descriptionLinesCount > 2 then
				Graphics.fillRect(260, 955, 95, 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10, backgroundColor)
			else
				Graphics.fillRect(260, 955, 95, 95 + chaptersMaxHeightOffset, backgroundColor)
			end
			local descriptionYOffset = 95 - descriptionMaxHeightOffset
			Font.print(BOLD_FONT16, (270 + 940) / 2 - Font.getTextWidth(BOLD_FONT16, Language[Settings.Language].DETAILS.SUMMARY) / 2, descriptionYOffset, Language[Settings.Language].DETAILS.SUMMARY, textColor)
			descriptionYOffset = descriptionYOffset + LINE_HEIGHT
			for i = 1, #descriptionWordList do
				if descriptionYOffset + LINE_HEIGHT >= 95 then
					local line = descriptionWordList[i]
					local x = 270
					for j = 1, #line do
						Font.print(FONT16, x, descriptionYOffset, line[j].Word, textColor)
						x = x + line.SpaceWidth + line[j].Width
					end
				end
				descriptionYOffset = descriptionYOffset + LINE_HEIGHT
				if descriptionLinesCount ~= #descriptionWordList or descriptionLinesCount > 2 then
					if descriptionYOffset >= 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10 then
						break
					end
				end
			end
			if descriptionLinesCount ~= #descriptionWordList or descriptionLinesCount > 2 then
				Graphics.fillRect(260, 955, 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10, 95 + chaptersMaxHeightOffset, backgroundColor)
				if descriptionLinesCount ~= #descriptionWordList then
					Font.print(BOLD_FONT16, (270 + 940) / 2 - (Font.getTextWidth(BOLD_FONT16, Language[Settings.Language].DETAILS.EXPAND) + 32) / 2, 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10, Language[Settings.Language].DETAILS.EXPAND, textColor)
					Graphics.drawImage(math.ceil((270 + 940) / 2 + Font.getTextWidth(BOLD_FONT16, Language[Settings.Language].DETAILS.EXPAND) / 2 + 4), 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10, ButtonsIcons.L.e, textColor)
				elseif descriptionLinesCount > 2 then
					Font.print(BOLD_FONT16, (270 + 940) / 2 - (Font.getTextWidth(BOLD_FONT16, Language[Settings.Language].DETAILS.SHRINK) + 32) / 2, 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10, Language[Settings.Language].DETAILS.SHRINK, textColor)
					Graphics.drawImage(math.ceil((270 + 940) / 2 + Font.getTextWidth(BOLD_FONT16, Language[Settings.Language].DETAILS.SHRINK) / 2 + 4), 95 + chaptersMaxHeightOffset - LINE_HEIGHT - 10, ButtonsIcons.L.e, textColor)
				end
			end
		end
		Graphics.fillRect(88, 960 - 88 - 88, 0, 90, backgroundColor)
		local mangaNameTickerX = maxMangaNameOffset * math.min(math.max(0, Timer.getTime(mangaNameTickerTimer) - 1500), maxMangaNameTickerTimeMs) / maxMangaNameTickerTimeMs
		Font.print(BOLD_FONT30, 88 - mangaNameTickerX, 70 * M - 63, selectedManga.Name, textColor)
		Font.print(FONT16, 88, 70 * M - 22, selectedManga.RawLink, secondTextColor)
		Graphics.fillRect(0, 88, 0, 90, backgroundColor)
		Graphics.drawImage(32, 90 * M - 50 - 12, BackIcon.e, COLOR_WHITE)
		Graphics.fillRect(960 - 88 - 88, 960, 0, 90, backgroundColor)
		if sortIcons[Settings.ChapterSorting] then
			Graphics.drawImage(960 - 88 - 32 - 24, 33, sortIcons[Settings.ChapterSorting].e, textColor)
			Graphics.drawImage(960 - 88 - 32 - 24, 5 - (1 - M) * 32, ButtonsIcons.R.e)
		end
		if isChapterListReady then
			Graphics.drawImage(960 - 32 - 24, 33, menuIcon.e, textColor)
			Graphics.drawImage(960 - 32 - 24 - 20, 5 - (1 - M) * 32, ButtonsIcons.Start.e)
		end
		Graphics.fillRect(955, 960, 90, 544, backgroundColor)
		if status == "START" and #chapterList > 5 then
			local h = #chapterList * 80 / 454
			Graphics.fillRect(955, 960, 90 + (slider.Y + 20) / h, 90 + (slider.Y + 464) / h, COLOR_GRAY)
		end
	end
end

---@return '"START"' | '"WAIT"' | '"END"'
---Gives status of Details menu
function Details.getStatus()
	return status
end

---@return number
---Gives fade
function Details.getFade()
	return fade * oldFade
end

---@return table
---Gives `seletctedManga` loaded in Details menu
function Details.getManga()
	return selectedManga
end
