local Point_t = Point_t

local mode = "END"

Details = {}

local TOUCH = TOUCH()
local Slider = Slider()

local Manga = nil

local fade = 0
local old_fade = 1

local point = Point_t(140, 326 / 2 + 85)

local cross = Image:new(Graphics.loadImage("app0:assets/icons/cross.png"))
local menu_icon = Image:new(Graphics.loadImage("app0:assets/icons/menu.png"))
local sort_icons = {
	["N->1"] = Image:new(Graphics.loadImage("app0:assets/icons/sort-9-1.png")),
	["1->N"] = Image:new(Graphics.loadImage("app0:assets/icons/sort-1-9.png"))
}


local ms = 0
local dif = 0
local ms_ch = 0
local dif_ch = 0

local animation_timer = Timer.new()
local name_timer = Timer.new()
local chapter_timer = Timer.new()

local is_notification_showed = false

local Chapters = {}

---Updates scrolling movement
local function scrollUpdate()
	Slider.Y = Slider.Y + Slider.V
	Slider.V = Slider.V / 1.12
	if math.abs(Slider.V) < 0.1 then
		Slider.V = 0
	end
	if Slider.Y < -15 then
		Slider.Y = -15
		Slider.V = 0
	elseif Slider.Y > (#Chapters * 80 - 464) then
		Slider.Y = math.max(-15, #Chapters * 80 - 464)
		Slider.V = 0
	end
end

local easing = EaseInOutCubic

---Updates animation of fade in or out
local function animationUpdate()
	if mode == "START" then
		fade = easing(math.min((Timer.getTime(animation_timer) / 500), 1))
	elseif mode == "WAIT" then
		if fade == 0 then
			mode = "END"
		end
		fade = 1 - easing(math.min((Timer.getTime(animation_timer) / 500), 1))
	end
	if Timer.getTime(name_timer) > 3500 + ms then
		Timer.reset(name_timer)
	end
	if Timer.getTime(chapter_timer) > 3500 + ms_ch then
		Timer.reset(chapter_timer)
	end
end

local DetailsSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return math.floor((Slider.Y - 20 + 90) / 80)
	end
)

local is_chapter_loaded_offline = false

local ContinueChapter

---@param manga table
---Sets Continue button to latest read chapter in given `Manga`
local function updateContinueManga(manga)
	ContinueChapter = 0
	if #Chapters > 0 then
		Chapters[1].Manga.Counter = #Chapters
		local Latest = Cache.getLatestBookmark(manga)
		for i = 1, #Chapters do
			local key = Chapters[i].Link:gsub("%p", "")
			if Latest == key then
				local bookmark = Cache.getBookmark(Chapters[i])
				if bookmark == true then
					ContinueChapter = i + 1
					if not Chapters[ContinueChapter] then
						ContinueChapter = i
					end
					Chapters[1].Manga.Counter = #Chapters - i
				else
					ContinueChapter = i
					Chapters[1].Manga.Counter = #Chapters - i + 1
				end
				break
			end
		end
		if ContinueChapter > 0 then
			local ch_name = Chapters[ContinueChapter].Name or ("Chapter " .. ContinueChapter)
			ms_ch = 25 * string.len(ch_name)
			dif_ch = math.max(Font.getTextWidth(FONT16, ch_name) - 220, 0)
			Timer.reset(chapter_timer)
		end
	end
end

local chapters_loaded = false

---@param manga table
---Sets `manga` to details
function Details.setManga(manga)
	if manga then
		Manga = manga
		ms = 50 * string.len(manga.Name)
		dif = math.max(Font.getTextWidth(BONT30, manga.Name) - 960 + 88 + 88 + 88, 0)
		Chapters = {}
		Slider.Y = -50
		DetailsSelector:resetSelected()
		mode = "START"
		old_fade = 1
		ContinueChapter = nil
		if Cache.isCached(Manga) then
			if not Cache.BookmarksLoaded(Manga) then
				Cache.loadBookmarks(Manga)
			end
		elseif Database.check(Manga) then
			Cache.addManga(Manga, Chapters)
		end
		if Threads.netActionUnSafe(Network.isWifiEnabled) and GetParserByID(manga.ParserID) then
			ParserManager.getChaptersAsync(manga, Chapters)
			is_chapter_loaded_offline = false
		else
			Chapters = Cache.loadChapters(manga)
			is_chapter_loaded_offline = true
		end
		chapters_loaded = false
		is_notification_showed = false
		Timer.reset(animation_timer)
		Timer.reset(name_timer)
	end
end

local function press_add_to_library()
	if Database.check(Manga) then
		Database.remove(Manga)
		Notifications.push(Language[Settings.Language].NOTIFICATIONS.REMOVED_FROM_LIBRARY)
	else
		Database.add(Manga)
		Cache.addManga(Manga)
		Notifications.push(Language[Settings.Language].NOTIFICATIONS.ADDED_TO_LIBRARY)
	end
end

local function press_download(item)
	local connection = Threads.netActionUnSafe(Network.isWifiEnabled)
	item = Chapters[item]
	if item then
		Cache.addManga(Manga, Chapters)
		Cache.makeHistory(Manga)
		if not ChapterSaver.check(item) then
			if ChapterSaver.is_downloading(item) then
				ChapterSaver.stop(item)
			elseif connection then
				ChapterSaver.downloadChapter(item)
			elseif not connection then
				Notifications.pushUnique(Language[Settings.Language].SETTINGS.NoConnection)
			end
		else
			ChapterSaver.delete(item)
		end
	end
end

local function press_manga(item)
	if Chapters[item] then
		Catalogs.shrink()
		Cache.addManga(Manga, Chapters)
		Cache.makeHistory(Manga)
		Reader.load(Chapters, item)
		AppMode = READER
		ContinueChapter = nil
	end
end

function Details.input(oldpad, pad, oldtouch, touch)
	if mode == "START" then
		local oldtouch_mode = TOUCH.MODE
		if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
			TOUCH.MODE = TOUCH.READ
			Slider.TouchY = touch.y
		elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
			if TOUCH.MODE == TOUCH.READ and oldtouch.x then
				if oldtouch.x > 320 and oldtouch.x < 955 and oldtouch.y > 90 then
					local id = math.floor((Slider.Y + oldtouch.y - 20) / 80)
					if Settings.ChapterSorting == "N->1" then
						id = #Chapters - id + 1
					end
					if oldtouch.x < 866 or Manga.ParserID == "IMPORTED" then
						press_manga(id)
					else
						press_download(id)
					end
				end
			end
			TOUCH.MODE = TOUCH.NONE
		end
		DetailsSelector:input(#Chapters, oldpad, pad, touch.x)
		if oldtouch.x and not touch.x then
			if oldtouch.x > 20 and oldtouch.x < 260 and oldtouch.y > 416 and oldtouch.y < 475 then
				press_add_to_library()
			elseif oldtouch.x > 20 and oldtouch.x < 260 and oldtouch.y > 480 then
				if ContinueChapter then
					press_manga(ContinueChapter > 0 and ContinueChapter or 1)
				end
			elseif oldtouch.x > 960 - 88 and oldtouch.y < 90 and chapters_loaded and oldtouch_mode == TOUCH.READ then
				Extra.setChapters(Manga, Chapters)
			elseif oldtouch.x > 960 - 88 - 88 and oldtouch.y < 90 and oldtouch_mode == TOUCH.READ then
				SettingsFunctions.ChapterSorting()
				Settings.save()
			end
		elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
			press_add_to_library()
		elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
			local id = DetailsSelector.getSelected()
			if Settings.ChapterSorting == "N->1" then
				id = #Chapters - id + 1
			end
			press_manga(id)
		elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) or (touch.x and not oldtouch.x and touch.x < 88 and touch.y < 90) then
			mode = "WAIT"
			Loading.setMode("NONE")
			ParserManager.remove(Chapters)
			Timer.reset(animation_timer)
			old_fade = fade
		elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) and Manga.ParserID ~= "IMPORTED" then
			local id = DetailsSelector.getSelected()
			if Settings.ChapterSorting == "N->1" then
				id = #Chapters - id + 1
			end
			press_download(id)
		elseif Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT) then
			if ContinueChapter then
				press_manga(ContinueChapter > 0 and ContinueChapter or 1)
			end
		elseif Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START) and chapters_loaded then
			Extra.setChapters(Manga, Chapters)
		elseif Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldpad, SCE_CTRL_RTRIGGER) and chapters_loaded then
			SettingsFunctions.ChapterSorting()
			Settings.save()
		end
		local new_itemID = 0
		if TOUCH.MODE == TOUCH.READ then
			if math.abs(Slider.V) > 0.1 or math.abs(touch.y - Slider.TouchY) > 10 then
				TOUCH.MODE = TOUCH.SLIDE
			else
				if oldtouch.x > 320 and oldtouch.x < 900 then
					local id = math.floor((Slider.Y - 20 + oldtouch.y) / 80)
					if Settings.ChapterSorting == "N->1" then
						id = #Chapters - id + 1
					end
					if Chapters[id] then
						new_itemID = id
					end
				end
			end
		elseif TOUCH.MODE == TOUCH.SLIDE then
			if touch.x and oldtouch.x then
				Slider.V = oldtouch.y - touch.y
			end
		end
		if Slider.ItemID > 0 and new_itemID > 0 and Slider.ItemID ~= new_itemID then
			TOUCH.MODE = TOUCH.SLIDE
		else
			Slider.ItemID = new_itemID
		end
	end
end

local deleteFile = System.deleteFile
local doesFileExist = System.doesFileExist
function Details.update()
	if mode ~= "END" then
		animationUpdate()
		if ParserManager.check(Chapters) then
			Loading.setMode("WHITE", 580, 250)
		else
			Loading.setMode("NONE")
		end
		local item_selected = DetailsSelector.getSelected()
		if item_selected ~= 0 then
			Slider.Y = Slider.Y + (item_selected * 80 - 272 - Slider.Y) / 8
		end
		scrollUpdate()
		if not is_chapter_loaded_offline and not ParserManager.check(Chapters) then
			if #Chapters > 0 then
				if Cache.isCached(Chapters[1].Manga) then
					is_chapter_loaded_offline = true
					Cache.saveChapters(Chapters[1].Manga, Chapters)
				end
				local manga = Chapters[1].Manga
				if manga.NewImageLink and not CustomCovers.hasCustomCover(manga) and manga.NewImageLink ~= Manga.ImageLink then
					local cover_path = "ux0:data/noboru/cache/" .. Cache.getKey(Manga) .. "/cover.image"
					if doesFileExist(cover_path) then
						deleteFile(cover_path)
					end
					Manga.ImageLink = manga.NewImageLink
					Manga.Image = nil
					Manga.ImageDownload = nil
					collectgarbage("collect")
				end
			end
		end
		if not chapters_loaded and not ParserManager.check(Chapters) then
			chapters_loaded = true
		end
		if AppMode == MENU and not ContinueChapter and not ParserManager.check(Chapters) then
			updateContinueManga(Manga)
		end
		if Extra.doesBookmarksUpdate() then
			ContinueChapter = nil
		end
	end
end

function Details.draw()
	if mode ~= "END" then
		local M = old_fade * fade
		local Alpha = 255 * M
		local BACKGROUND_COLOR = Color.new(0, 0, 0, Alpha)
		local TEXT_COLOR = Color.new(255, 255, 255, Alpha)
		local SECOND_TEXT_COLOR = Color.new(128, 128, 128, Alpha)
		local ADDMANGA_COLOR = Color.new(42, 47, 78, Alpha)
		local DELMANGA_COLOR = Color.new(137, 30, 43, Alpha)
		local CONTINUE_COLOR = Color.new(19, 76, 76, Alpha)
		Graphics.fillRect(20, 260, 90, 544, BACKGROUND_COLOR)
		local start = math.max(1, math.floor(Slider.Y / 80) + 1)
		local shift = (1 - M) * 544
		local y = shift - Slider.Y + start * 80
		local text, color = Language[Settings.Language].DETAILS.ADD_TO_LIBRARY, ADDMANGA_COLOR
		if Database.check(Manga) then
			color = DELMANGA_COLOR
			text = Language[Settings.Language].DETAILS.REMOVE_FROM_LIBRARY
		end
		Graphics.fillRect(20, 260, shift + 416, shift + 475, color)
		Font.print(FONT20, 140 - Font.getTextWidth(FONT20, text) / 2, 444 + shift - Font.getTextHeight(FONT20, text) / 2, text, TEXT_COLOR)
		if ContinueChapter then
			if #Chapters > 0 then
				Graphics.fillRect(30, 250, shift + 480, shift + 539, CONTINUE_COLOR)
				local continue_txt = Language[Settings.Language].DETAILS.START
				local ch_name
				local dy = 0
				if ContinueChapter > 0 and Chapters[ContinueChapter] and (ContinueChapter == 1 and Cache.getBookmark(Chapters[ContinueChapter]) or ContinueChapter ~= 1) then
					continue_txt = Language[Settings.Language].DETAILS.CONTINUE
					dy = -10
					ch_name = Chapters[ContinueChapter].Name or ("Chapter " .. ContinueChapter)
				end
				local width = Font.getTextWidth(FONT20, continue_txt)
				local height = Font.getTextHeight(FONT20, continue_txt)
				Font.print(FONT20, 140 - width / 2, shift + 505 - height / 2 + dy, continue_txt, TEXT_COLOR)
				if ch_name then
					width = math.min(Font.getTextWidth(FONT16, ch_name), 220)
					local t = math.min(math.max(0, Timer.getTime(chapter_timer) - 1500), ms_ch)
					Font.print(FONT16, 140 - width / 2 - dif_ch * t / ms_ch, shift + 505 - height / 2 + 18, ch_name, TEXT_COLOR)
				end
				Graphics.fillRect(20, 30, shift + 480, shift + 539, CONTINUE_COLOR)
				Graphics.fillRect(250, 260, shift + 480, shift + 539, CONTINUE_COLOR)
			end
		end
		Graphics.fillRect(0, 20, 90, 544, BACKGROUND_COLOR)
		if ContinueChapter and #Chapters > 0 then
			Graphics.drawImage(0, shift + 472, textures_16x16.Select.e)
		end
		Graphics.drawImageExtended(20, shift + 420, textures_16x16.Triangle.e, 0, 0, 16, 16, 0, 1, 1)
		DrawDetailsManga(point.x, point.y + 544 * (1 - M), Manga, 326 / MANGA_HEIGHT)
		Graphics.fillRect(260, 890 - 18, 90, 544, BACKGROUND_COLOR)
		local ListCount = #Chapters
		for n = start, math.min(ListCount, start + 8) do
			local i = Settings.ChapterSorting ~= "N->1" and n or ListCount - n + 1
			local bookmark = Cache.getBookmark(Chapters[i])
			if bookmark ~= nil and bookmark ~= true then
				Font.print(FONT16, 290, y + 44, Language[Settings.Language].DETAILS.PAGE .. bookmark, TEXT_COLOR)
				Font.print(BONT16, 290, y + 14, Chapters[i].Name or ("Chapter " .. i), TEXT_COLOR)
			elseif bookmark == true then
				Font.print(FONT16, 290, y + 44, Language[Settings.Language].DETAILS.DONE, SECOND_TEXT_COLOR)
				Font.print(BONT16, 290, y + 14, Chapters[i].Name or ("Chapter " .. i), SECOND_TEXT_COLOR)
			else
				Font.print(BONT16, 290, y + 28, Chapters[i].Name or ("Chapter " .. i), TEXT_COLOR)
			end
			y = y + 80
			if y > 544 then
				break
			end
		end
		Graphics.fillRect(890 - 18, 955, 90, 544, BACKGROUND_COLOR)
		y = shift - Slider.Y + start * 80
		for n = start, math.min(ListCount, start + 8) do
			local i = Settings.ChapterSorting ~= "N->1" and n or ListCount - n + 1
			if Manga.ParserID ~= "IMPORTED" then
				if ChapterSaver.check(Chapters[i]) then
					Graphics.drawImage(920 - 14 - 18, y + 40 - 12, cross.e)
				else
					local t = ChapterSaver.is_downloading(Chapters[i])
					if t then
						local text = "0%"
						if t.page_count and t.page_count > 0 then
							text = math.ceil(100 * t.page / t.page_count) .. "%"
						end
						local width = Font.getTextWidth(FONT20, text)
						Font.print(FONT20, 920 - width / 2 - 18, y + 26, text, COLOR_WHITE)
					else
						Graphics.drawImage(920 - 14 - 18, y + 40 - 12, Download_icon.e)
					end
				end
			end
			if i == Slider.ItemID then
				Graphics.fillRect(270, 945, y, y + 79, Color.new(255, 255, 255, 24 * M))
			end
			y = y + 80
		end
		if mode == "START" and #Chapters == 0 and not ParserManager.check(Chapters) and not is_notification_showed then
			is_notification_showed = true
			Notifications.push(Language[Settings.Language].WARNINGS.NO_CHAPTERS)
		end
		local item = DetailsSelector.getSelected()
		if item ~= 0 then
			y = shift - Slider.Y + item * 80
			local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
			local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
			for i = ks, ks + 1 do
				Graphics.fillEmptyRect(272 + i, 950 - i, y + i + 2, y + 75 - i + 1, Color.new(255, 0, 51))
				Graphics.fillEmptyRect(272 + i, 950 - i, y + i + 2, y + 75 - i + 1, SELECTED_RED)
			end
			if Manga.ParserID ~= "IMPORTED" then
				Graphics.drawImage(929 - ks, y + 5 + ks, textures_16x16.Square.e)
			end
		end
		Graphics.fillRect(88, 960 - 88 - 88, 0, 90, BACKGROUND_COLOR)
		local t = math.min(math.max(0, Timer.getTime(name_timer) - 1500), ms)
		Font.print(BONT30, 88 - dif * t / ms, 70 * M - 63, Manga.Name, TEXT_COLOR)
		Font.print(FONT16, 88, 70 * M - 22, Manga.RawLink, SECOND_TEXT_COLOR)
		Graphics.fillRect(0, 88, 0, 90, BACKGROUND_COLOR)
		Graphics.drawImage(32, 90 * M - 50 - 12, Back_icon.e, COLOR_WHITE)
		Graphics.fillRect(960 - 88 - 88, 960, 0, 90, BACKGROUND_COLOR)
		if sort_icons[Settings.ChapterSorting] then
			Graphics.drawImage(960 - 88 - 32 - 24, 33, sort_icons[Settings.ChapterSorting].e, Color.new(255, 255, 255, Alpha))
			Graphics.drawImage(960 - 88 - 32 - 24, 5 - (1 - M) * 32, textures_16x16.R.e)
		end
		if chapters_loaded then
			Graphics.drawImage(960 - 32 - 24, 33, menu_icon.e, Color.new(255, 255, 255, Alpha))
			Graphics.drawImage(960 - 32 - 24 - 20, 5 - (1 - M) * 32, textures_16x16.Start.e)
		end
		Graphics.fillRect(955, 960, 90, 544, BACKGROUND_COLOR)
		if mode == "START" and #Chapters > 5 then
			local h = #Chapters * 80 / 454
			Graphics.fillRect(955, 960, 90 + (Slider.Y + 20) / h, 90 + (Slider.Y + 464) / h, COLOR_GRAY)
		end
	end
end

function Details.getMode()
	return mode
end

function Details.getFade()
	return fade * old_fade
end

function Details.getManga()
	return Manga
end
