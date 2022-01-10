Catalogs = {}
Panels = {}

local slider = CreateSlider()
local TOUCH_MODES = TOUCH_MODES

local doesFileExist = System.doesFileExist
local doesDirExist = System.doesDirExist
local listDirectory = System.listDirectory
local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local copyFile = CopyFile

local currentParser = nil
local touchTimer = Timer.new()

local status = "CATALOGS"
local keyboardMode = "NONE"
local downloadBarValue = 0

local downloadedImages = {}
local page = 1
local currentMangaList = {}
local parsersList = {}
local extensionsList = {}

local chaptersFolderSize
local cacheFolderSize
local sure_clear_library
local sure_clear_chapters
local sure_clear_all_cache
local sure_clear_cache
local mangaLoadStatus = 0

local smilesList = {"ಥ_ಥ", "ಠ_ಠ", "ヽ(`Д´)ﾉ", "ఠ౬ఠ", "°Д°", "(ó﹏ò｡)", "(╥﹏╥)", "(⊙_⊙)", "(✖╭╮✖)", "ʘ‿ʘ", "(￣ω￣)", "(´• ω •`) ♡", "(⌒_⌒;)", "( ╥ω╥ )", "(✧∀✧)/", "	╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ"}
local smile = nil

local mangaSelector =
	Selector:new(
	-4,
	4,
	-1,
	1,
	function()
		return max(1, floor((slider.Y - 20) / (MANGA_HEIGHT + 12)) * 4 + 1)
	end
)

local parserSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return max(1, floor((slider.Y - 10) / 75))
	end
)

local downloadSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return max(1, floor((slider.Y - 10) / 75))
	end
)

local settingSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return max(1, floor((slider.Y - 10) / 75))
	end
)

local importSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return max(1, floor((slider.Y - 10) / 75))
	end
)

local extensionSelector =
	Selector:new(
	-1,
	1,
	-3,
	3,
	function()
		return max(1, floor((slider.Y - 10) / 75))
	end
)

local function freeMangaImage(manga)
	if manga and manga.ImageDownload then
		Threads.removeTask(manga)
		if manga.Image and manga.Image.free then
			manga.Image:free()
		end
		manga.ImageDownload = nil
	end
end

local function loadMangaImage(manga)
	if CustomCovers.hasCustomCover(manga) then
		local customCoverPath = "ux0:data/noboru/cache/" .. Cache.getMangaHash(manga) .. "/custom_cover.image"
		if doesFileExist(customCoverPath) and System.getPictureResolution(customCoverPath) or -1 > 0 then
			Threads.addTask(
				manga,
				{
					Type = "Image",
					Path = customCoverPath,
					Table = manga,
					MaxHeight = MANGA_HEIGHT * 2,
					Index = "newImage",
					OnFinalComplete = function()
						if manga.Image ~= nil and type(manga.Image) == "table" and manga.Image.Type == "image" then
							manga.Image:free()
						end
						manga.Image = manga.newImage
					end
				}
			)
		else
			if not Cache.isCached(manga) then
				Cache.addManga(manga)
			end
			local cover = CustomCovers.getCustomCover(manga)
			local cacheKey = Cache.getMangaHash(manga)
			local t = {}
			if cover.Path then
				copyFile(cover.Path:find("^...?0:") and cover.Path or ("ux0:data/noboru/" .. cover.Path), "ux0:data/noboru/cache/" .. cacheKey .. "/custom_cover.image")
				Threads.addTask(
					manga,
					{
						Type = "Image",
						Path = customCoverPath,
						Table = manga,
						MaxHeight = MANGA_HEIGHT * 2,
						Index = "newImage",
						OnFinalComplete = function()
							if manga.Image ~= nil and type(manga.Image) == "table" and manga.Image.Type == "image" then
								manga.Image:free()
							end
							manga.Image = manga.newImage
						end
					}
				)
			elseif cover.ParserID then
				Threads.insertTask(
					manga,
					{
						Type = "function",
						OnComplete = function()
							ParserManager.getPageImage(cover.ParserID, cover.Link, t)
							while ParserManager.check(t) do
								coroutine.yield(false)
							end
							Threads.insertTask(
								manga,
								{
									Type = "FileDownload",
									Link = t.Link,
									Path = "ux0:data/noboru/cache/" .. cacheKey .. "/custom_cover.image",
									OnComplete = function()
										Threads.addTask(
											manga,
											{
												Type = "Image",
												Path = customCoverPath,
												Table = manga,
												MaxHeight = MANGA_HEIGHT * 2,
												Index = "newImage",
												OnFinalComplete = function()
													if manga.Image ~= nil and type(manga.Image) == "table" and manga.Image.Type == "image" then
														manga.Image:free()
													end
													manga.Image = manga.newImage
												end
											}
										)
									end
								}
							)
						end
					}
				)
			elseif cover.Link then
				Threads.insertTask(
					manga,
					{
						Type = "FileDownload",
						Link = cover.Link,
						Path = "ux0:data/noboru/cache/" .. cacheKey .. "/custom_cover.image",
						OnComplete = function()
							Threads.addTask(
								manga,
								{
									Type = "Image",
									Path = customCoverPath,
									Table = manga,
									MaxHeight = MANGA_HEIGHT * 2,
									Index = "newImage",
									OnFinalComplete = function()
										if manga.Image ~= nil and type(manga.Image) == "table" and manga.Image.Type == "image" then
											manga.Image:free()
										end
										manga.Image = manga.newImage
									end
								}
							)
						end
					}
				)
			else
				CustomCovers.setMangaCover(manga, nil)
			end
		end
	else
		local path = manga.Path or ("cache/" .. Cache.getMangaHash(manga) .. "/cover.image")
		if path and doesFileExist("ux0:data/noboru/" .. path) and System.getPictureResolution("ux0:data/noboru/" .. path) or -1 > 0 then
			Threads.addTask(
				manga,
				{
					Type = "Image",
					Path = path,
					Table = manga,
					MaxHeight = MANGA_HEIGHT * 2,
					Index = "newImage",
					OnFinalComplete = function()
						if manga.Image ~= nil and type(manga.Image) == "table" and manga.Image.Type == "image" then
							manga.Image:free()
						end
						manga.Image = manga.newImage
					end
				}
			)
		else
			if Library.check(manga) and not Cache.isCached(manga) then
				Cache.addManga(manga)
			end
			Threads.addTask(
				manga,
				{
					Type = "ImageDownload",
					Link = manga.ImageLink,
					Table = manga,
					Index = "newImage",
					OnFinalComplete = function()
						if manga.Image ~= nil and type(manga.Image) == "table" and manga.Image.Type == "image" then
							manga.Image:free()
						end
						manga.Image = manga.newImage
					end,
					MaxHeight = MANGA_HEIGHT * 2,
					Path = Cache.isCached(manga) and path or nil
				}
			)
		end
	end
end

local function UpdateManga()
	if slider.V == 0 and Timer.getTime(touchTimer) > 200 then
		local start = max(1, floor(slider.Y / (MANGA_HEIGHT + 6)) * 4 + 1)
		if #downloadedImages > 12 then
			local newTable = {}
			for _, i in ipairs(downloadedImages) do
				if i < start or i > min(#currentMangaList, start + 11) then
					freeMangaImage(currentMangaList[i])
				else
					newTable[#newTable + 1] = i
				end
			end
			downloadedImages = newTable
		end
		for i = start, min(#currentMangaList, start + 11) do
			local manga = currentMangaList[i]
			if not manga.ImageDownload then
				loadMangaImage(manga)
				manga.ImageDownload = true
				downloadedImages[#downloadedImages + 1] = i
			end
		end
	else
		local newTable = {}
		for _, i in ipairs(downloadedImages) do
			local manga = currentMangaList[i]
			if Threads.check(manga) and (Details.getFade() == 0 or manga ~= Details.getManga()) then
				Threads.removeTask(manga)
				manga.ImageDownload = nil
			else
				newTable[#newTable + 1] = i
			end
		end
		downloadedImages = newTable
	end
end

local function selectManga(index)
	local manga = currentMangaList[index]
	if manga then
		Details.setManga(manga)
	end
end

local function selectParser(index)
	local newParser = GetParserList()[index]
	if newParser then
		currentParser = newParser
		Catalogs.setStatus("MANGA")
		CatalogModes.load(newParser)
	end
end

local function selectExtension(index)
	local extension = Extensions.GetList()[index]
	if extension then
		ExtensionOptions.load(extension.ID)
		ExtensionOptions.show()
	end
end

local function selectSetting(index)
	local item = Settings.list()[index]
	if item and Settings.isTab(item) then
		if Settings.getTab() ~= "AdvancedChaptersDeletion" then
			settingSelector:resetSelected()
			slider.Y = -100
		end
		Settings.setTab(item)
	elseif item then
		if SettingsFunctions[item] then
			if item == "ClearChapters" then
				sure_clear_chapters = sure_clear_chapters + 1
				if sure_clear_chapters == 2 then
					SettingsFunctions[item]()
					chaptersFolderSize = nil
					sure_clear_chapters = 0
				end
			elseif item == "ClearLibrary" then
				sure_clear_library = sure_clear_library + 1
				if sure_clear_library == 2 then
					SettingsFunctions[item]()
					sure_clear_library = 0
				end
			elseif item == "ClearAllCache" then
				sure_clear_all_cache = sure_clear_all_cache + 1
				if sure_clear_all_cache == 2 then
					cacheFolderSize = nil
					SettingsFunctions[item]()
					sure_clear_all_cache = 0
				end
			elseif item == "ClearCache" then
				sure_clear_cache = sure_clear_cache + 1
				if sure_clear_cache == 2 then
					cacheFolderSize = nil
					SettingsFunctions[item]()
					sure_clear_cache = 0
				end
			else
				SettingsFunctions[item]()
				Settings.save()
			end
		end
		if item ~= "ClearChapters" then
			sure_clear_chapters = 0
		end
		if item ~= "ClearCache" then
			sure_clear_cache = 0
		end
		if item ~= "ClearAllCache" then
			sure_clear_all_cache = 0
		end
		if item ~= "ClearLibrary" then
			sure_clear_library = 0
		end
	end
end

local function selectImport(index)
	local list = Import.listDir()
	if index > 0 and index <= #list then
		Import.go(list[index])
	end
end

mangaSelector:xAction(selectManga)
parserSelector:xAction(selectParser)
downloadSelector:xAction(
	function(item)
		ChapterSaver.stopByListItem(ChapterSaver.getDownloadingList()[item])
	end
)
settingSelector:xAction(selectSetting)
importSelector:xAction(selectImport)
extensionSelector:xAction(selectExtension)

function Catalogs.input(oldPad, pad, oldTouch, touch)
	if status == "MANGA" then
		if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldPad, SCE_CTRL_CIRCLE) then
			status = "CATALOGS"
			Catalogs.terminate()
		elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldPad, SCE_CTRL_SQUARE) then
			CatalogModes.show()
		elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldPad, SCE_CTRL_TRIANGLE) then
			Keyboard.show(Str.labelInputValue, 1, 128, TYPE_NUMBER, MODE_TEXT, OPT_NO_AUTOCAP)
			keyboardMode = "JUMP_PAGE"
		end
	elseif status == "CATALOGS" then
		if Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldPad, SCE_CTRL_SELECT) and Debug.getStatus() == 2 then
			local item = parsersList[parserSelector:getSelected()]
			if item then
				ParserChecker.addCheck(item)
			end
		end
		if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldPad, SCE_CTRL_TRIANGLE) then
			local item = parsersList[parserSelector:getSelected()]
			if item and item.ExtID then
				ExtensionOptions.load(item.ExtID)
				ExtensionOptions.show()
			end
		end
	elseif status == "EXTENSIONS" then
		if not Threads.check("EXTENSIONSPARSERSCHECK") then
			if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldPad, SCE_CTRL_TRIANGLE) then
				Extensions.UpdateList()
				extensionSelector:resetSelected()
			end
		end
	elseif status == "HISTORY" then
		if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldPad, SCE_CTRL_SQUARE) then
			local item = currentMangaList[mangaSelector:getSelected()]
			if item then
				Cache.removeHistory(item)
			end
		end
	elseif status == "SETTINGS" then
		if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldPad, SCE_CTRL_CIRCLE) then
			Settings.back()
			settingSelector:resetSelected()
		end
		if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldPad, SCE_CTRL_SQUARE) and Settings.getTab() == "AdvancedChaptersDeletion" then
			local id = settingSelector:getSelected()
			local item = Settings.list()[id]
			if item then
				Settings.delTab(item)
			end
		end
	elseif status == "IMPORT" then
		if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldPad, SCE_CTRL_CIRCLE) then
			Import.back()
			importSelector:resetSelected()
		end
		if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldPad, SCE_CTRL_SQUARE) then
			local item = Import.listDir()[importSelector:getSelected()]
			if item and item.active and item.name ~= "..." then
				ChapterSaver.importManga(Import.getPath(item))
				importSelector:resetSelected()
			end
		end
	elseif status == "LIBRARY" then
		if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldPad, SCE_CTRL_TRIANGLE) then
			ParserManager.updateCounters()
		end
	end
	if slider.V ~= 0 or Controls.check(pad, SCE_CTRL_RTRIGGER) or Controls.check(pad, SCE_CTRL_LTRIGGER) or touch.x then
		Timer.reset(touchTimer)
	end
	if status == "MANGA" or status == "LIBRARY" or status == "HISTORY" then
		mangaSelector:input(#currentMangaList, oldPad, pad, touch.x)
	elseif status == "CATALOGS" then
		parserSelector:input(#parsersList, oldPad, pad, touch.x)
	elseif status == "DOWNLOAD" then
		downloadSelector:input(#ChapterSaver.getDownloadingList(), oldPad, pad, touch.x)
	elseif status == "SETTINGS" then
		settingSelector:input(#Settings.list(), oldPad, pad, touch.x)
	elseif status == "IMPORT" then
		importSelector:input(#Import.listDir(), oldPad, pad, touch.x)
	elseif status == "EXTENSIONS" then
		if not Threads.check("EXTENSIONSPARSERSCHECK") then
			extensionSelector:input(#Extensions.GetList(), oldPad, pad, touch.x)
		end
	end
	if TOUCH_MODES.MODE == TOUCH_MODES.NONE and oldTouch.x and touch.x and touch.x > 240 then
		TOUCH_MODES.MODE = TOUCH_MODES.READ
		slider.TouchY = touch.y
	elseif TOUCH_MODES.MODE ~= TOUCH_MODES.NONE and not touch.x then
		if oldTouch.x then
			if TOUCH_MODES.MODE == TOUCH_MODES.READ then
				if status == "MANGA" or status == "LIBRARY" or status == "HISTORY" then
					local start = max(1, floor((slider.Y - 20) / (MANGA_HEIGHT + 6)) * 4 + 1)
					for i = start, min(#currentMangaList, start + 11) do
						local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 6) + 610
						local uy = floor((i - 1) / 4) * (MANGA_HEIGHT + 6) - slider.Y + 6
						if oldTouch.x > lx and oldTouch.x < lx + MANGA_WIDTH and oldTouch.y > uy and oldTouch.y < uy + MANGA_HEIGHT then
							selectManga(i)
							break
						end
					end
				elseif oldTouch.x > 205 and oldTouch.x < 955 then
					local id = floor((slider.Y - 10 + oldTouch.y) / 75) + 1
					if status == "CATALOGS" then
						selectParser(id)
					elseif status == "EXTENSIONS" then
						selectExtension(id)
					elseif status == "DOWNLOAD" then
						local list = ChapterSaver.getDownloadingList()
						if list[id] then
							ChapterSaver.stopByListItem(list[id])
						end
					elseif status == "SETTINGS" then
						local list = Settings.list()
						if list[id] then
							selectSetting(id)
						end
					elseif status == "IMPORT" then
						if oldTouch.x < 850 then
							local list = Import.listDir()
							if list[id] then
								selectImport(id)
							end
						else
							local item = Import.listDir()[id]
							if item and item.active and item.name ~= "..." then
								ChapterSaver.importManga(Import.getPath(item))
								importSelector:resetSelected()
							end
						end
					end
				end
			end
		end
		TOUCH_MODES.MODE = TOUCH_MODES.NONE
	end
	local newItemID = 0
	if TOUCH_MODES.MODE == TOUCH_MODES.READ then
		if abs(slider.V) > 0.1 or abs(slider.TouchY - touch.y) > 10 then
			TOUCH_MODES.MODE = TOUCH_MODES.SLIDE
		elseif oldTouch.x > 205 and oldTouch.x < 945 then
			local id = floor((slider.Y - 10 + oldTouch.y) / 75) + 1
			if status == "CATALOGS" and GetParserList()[id] then
				newItemID = id
			elseif status == "DOWNLOAD" and ChapterSaver.getDownloadingList()[id] then
				newItemID = id
			elseif status == "SETTINGS" and Settings.list()[id] then
				newItemID = id
			elseif status == "IMPORT" and Import.listDir()[id] then
				newItemID = id
			elseif status == "EXTENSIONS" and Extensions.GetList()[id] then
				newItemID = id
			end
		end
	end
	if slider.ItemID > 0 and newItemID > 0 and slider.ItemID ~= newItemID then
		TOUCH_MODES.MODE = TOUCH_MODES.SLIDE
	else
		slider.ItemID = newItemID
	end
	if TOUCH_MODES.MODE == TOUCH_MODES.SLIDE and oldTouch.x and touch.x and touch.x > 205 then
		slider.V = oldTouch.y - touch.y
	end
end

function GenPanels()
	Panels["MANGA"] = {
		"L\\R",
		"Square",
		"DPad",
		"Cross",
		"Circle",
		"Triangle",
		["L\\R"] = Str.labelPanelChangeSection,
		Square = Str.labelPanelMode,
		Triangle = Str.labelPanelJumpToPage,
		Circle = Str.labelPanelBack,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelSelect
	}
	Panels["IMPORT"] = {
		"L\\R",
		"DPad",
		"Circle",
		"Cross",
		"Square",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelSelect
	}
	Panels["HISTORY"] = {
		"L\\R",
		"DPad",
		"Cross",
		"Square",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelSelect,
		Square = Str.labelPanelDelete
	}
	Panels["LIBRARY"] = {
		"L\\R",
		"DPad",
		"Triangle",
		"Cross",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelSelect,
		Triangle = Str.labelPanelUpdate
	}
	Panels["CATALOGS"] = {
		"L\\R",
		"DPad",
		"Square",
		"Cross",
		"Triangle",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelSelect
	}
	Panels["DOWNLOAD"] = {
		"L\\R",
		"DPad",
		"Cross",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelCancel
	}
	Panels["SETTINGS"] = {
		"L\\R",
		"DPad",
		"Circle",
		"Cross",
		"Square",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Cross = Str.labelPanelSelect
	}
	Panels["EXTENSIONS"] = {
		"L\\R",
		"DPad",
		"Triangle",
		"Cross",
		["L\\R"] = Str.labelPanelChangeSection,
		DPad = Str.labelPanelChoose,
		Triangle = Str.labelPanelUpdate
	}
end

function Catalogs.update()
	if abs(slider.V) < 1 then
		slider.V = 0
	else
		slider.Y = slider.Y + slider.V
		slider.V = slider.V / 1.12
	end
	if status == "MANGA" or status == "LIBRARY" or status == "HISTORY" then
		UpdateManga()
		if ParserManager.check(currentMangaList) then
			mangaLoadStatus = 1
			Loading.setStatus(COLOR_FONT == COLOR_BLACK and "BLACK" or "WHITE", 580, 272)
		elseif Details.getStatus() == "END" then
			Loading.setStatus("NONE")
		end
		local item = mangaSelector:getSelected()
		if item ~= 0 then
			slider.Y = slider.Y + (math.floor((item - 1) / 4) * (MANGA_HEIGHT + 6) + MANGA_HEIGHT / 2 - 232 - slider.Y) / 8
			if status == "MANGA" and not currentMangaList.NoPages and currentParser and item > #currentMangaList - 4 then
				if not ParserManager.check(currentMangaList) then
					ParserManager.getMangaListAsync(CatalogModes.getMangaMode(), currentParser, page, currentMangaList, CatalogModes.getSearchData(), CatalogModes.getTagsData())
					page = page + 1
				end
			end
		end
		if slider.Y < 0 then
			slider.Y = 0
			slider.V = 0
		elseif slider.Y > ceil(#currentMangaList / 4) * (MANGA_HEIGHT + 6) - 512 - 6 then
			slider.Y = max(0, ceil(#currentMangaList / 4) * (MANGA_HEIGHT + 6) - 512 - 6)
			slider.V = 0
			if status == "MANGA" then
				if not currentMangaList.NoPages and currentParser then
					if not ParserManager.check(currentMangaList) then
						ParserManager.getMangaListAsync(CatalogModes.getMangaMode(), currentParser, page, currentMangaList, CatalogModes.getSearchData(), CatalogModes.getTagsData())
						page = page + 1
					end
				end
			end
		end
		if status == "LIBRARY" and #currentMangaList ~= #Library.getMangaList() then
			currentMangaList = Library.getMangaList()
		elseif status == "HISTORY" then
			currentMangaList = Cache.getHistory()
		end
	else
		local list = {}
		local item = 0
		if status == "CATALOGS" then
			--Panels["CATALOGS"].Triangle = list[item] and Str.labelPanelUpdate
			parsersList = GetParserList()
			list = parsersList
			item = parserSelector:getSelected()
		elseif status == "DOWNLOAD" then
			list = ChapterSaver.getDownloadingList()
			item = downloadSelector:getSelected()
		elseif status == "SETTINGS" then
			list = Settings.list()
			Panels["SETTINGS"].Circle = Settings.inTab() and Str.labelPanelBack
			if Settings.getTab() == "AdvancedChaptersDeletion" then
				if #list > 0 then
					Panels["SETTINGS"].Cross = Str.labelPanelRead
					Panels["SETTINGS"].Square = Str.labelPanelDelete
				else
					Panels["SETTINGS"].Cross = nil
					Panels["SETTINGS"].Square = nil
				end
			elseif Settings.getTab() == "DonatorsList" then
				Panels["SETTINGS"].Cross = nil
				Panels["SETTINGS"].Square = nil
			else
				Panels["SETTINGS"].Cross = Str.labelPanelSelect
				Panels["SETTINGS"].Square = nil
			end
			item = settingSelector:getSelected()
		elseif status == "IMPORT" then
			list = Import.listDir()
			item = importSelector:getSelected()
			Panels["IMPORT"].Square = list[item] and Import.canImport(list[item]) and Str.labelPanelImport
			Panels["IMPORT"].Circle = Import.canBack() and Str.labelPanelBack
		elseif status == "EXTENSIONS" then
			list = Extensions.GetList()
			extensionsList = list
			item = extensionSelector:getSelected()
			Panels["EXTENSIONS"].Cross = list[item] and Str.labelPanelSelect or nil
		end
		if status == "SETTINGS" then
			if item ~= 0 then
				slider.Y = slider.Y + (item * 75 - 272 - slider.Y) / 8
			end
			local height = ceil(#list) * 75
			if Settings.getTab() == "About" then
				height = height + 120
			end
			if slider.Y < -10 then
				slider.Y = -10
				slider.V = 0
			elseif slider.Y > height - 514 then
				slider.Y = max(-10, height - 514)
				slider.V = 0
			end
		else
			if item ~= 0 then
				slider.Y = slider.Y + (item * 75 - 272 - slider.Y) / 8
			end
			if slider.Y < -10 then
				slider.Y = -10
				slider.V = 0
			elseif slider.Y > ceil(#list) * 75 - 514 then
				slider.Y = max(-10, ceil(#list) * 75 - 514)
				slider.V = 0
			end
		end
	end
	Panel.set(Panels[status] or {})
	if keyboardMode ~= "NONE" and Keyboard.getState() ~= RUNNING then
		if keyboardMode == "JUMP_PAGE" and Keyboard.getState() == FINISHED then
			local newPage = tonumber(Keyboard.getInput())
			if newPage and newPage > 0 then
				Catalogs.terminate()
				page = newPage
			end
		end
		keyboardMode = "NONE"
		Keyboard.clear()
	end
end

function Catalogs.draw()
	local scrollHeight, item
	local itemHeight = 0
	local centerScreenMessage
	if status == "EXTENSIONS" then
		if #extensionsList == 0 and not Threads.check("EXTENSIONSPARSERSCHECK") then
			centerScreenMessage = Str.labelEmptyCatalog
		end
		local first = max(1, floor((slider.Y - 10) / 75))
		local y = first * 75 - slider.Y
		local last = min(#extensionsList, first + 9)
		for i = first, last do
			local extension = extensionsList[i]
			if slider.ItemID == i then
				Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
			end
			Font.print(FONT26, 225, y - 70, extension.Name, COLOR_FONT)
			local languageText = ""
			if type(extension.Language) == "table" then
				languageText = Str.DIF
			else
				languageText = Str[extension.Language] or extension.Language or ""
			end
			Font.print(FONT16, 935 - Font.getTextWidth(FONT16, languageText), y - 15 - Font.getTextHeight(FONT16, languageText), languageText, COLOR_SUB_FONT)
			local width = Font.getTextWidth(FONT26, extension.Name)
			local text = ""
			local color = COLOR_GRAY
			if extension.Status == "New version" then
				text = Str.labelNewVersionAvailable .. " : v" .. extension.Version .. " → v" .. extension.LatestVersion
				color = Color.new(136, 0, 255)
			elseif extension.Status == "Not supported" then
				text = Str.labelNotSupported
				color = Color.new(255, 74, 58)
			elseif extension.Status == "Installed" then
				text = Str.labelInstalled
				color = COLOR_ROYAL_BLUE
			else
				text = Str.labelNotInstalled
			end
			Font.print(FONT16, 230 + width - 4, y - 70 + Font.getTextHeight(FONT26, extension.Name) - Font.getTextHeight(FONT16, "v" .. extension.Version), "v" .. extension.Version, COLOR_BLACK)
			width = width + Font.getTextWidth(FONT16, "v" .. extension.Version) + 1
			if extension.NSFW then
				Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, extension.Name) - Font.getTextHeight(FONT16, "NSFW"), "NSFW", COLOR_ROYAL_BLUE)
				width = width + Font.getTextWidth(FONT16, "NSFW") + 5
			end
			Font.print(FONT16, 935 - Font.getTextWidth(FONT16, text), y - 65, text, color)
			local linkText = ""
			if type(extension.Link) == "table" then
				linkText = table.concat(extension.Link, ", ")
			elseif type(extension.Link) == "string" then
				linkText = extension.Link
			end
			Font.print(FONT16, 225, y - 23 - Font.getTextHeight(FONT16, linkText), linkText, COLOR_SUB_FONT)
			y = y + 75
		end
		local elementsCount = #extensionsList
		if elementsCount > 7 then
			scrollHeight = elementsCount * 75 / 524
		end
		item = extensionSelector:getSelected()
	elseif status == "CATALOGS" then
		if #parsersList == 0 and not ParserManager.check("UpdateParsers") then
			centerScreenMessage = Str.labelEmptyCatalog
		end
		local first = max(1, floor((slider.Y - 10) / 75))
		local y = first * 75 - slider.Y
		local last = min(#parsersList, first + 9)
		for i = first, last do
			local parser = parsersList[i]
			if slider.ItemID == i then
				Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
			end
			Font.print(FONT26, 225, y - 70, parser.Name, COLOR_FONT)
			local languageText = Str[parser.Language] or parser.Language or ""
			Font.print(FONT16, 935 - Font.getTextWidth(FONT16, languageText), y - 15 - Font.getTextHeight(FONT16, languageText), languageText, COLOR_SUB_FONT)
			local width = Font.getTextWidth(FONT26, parser.Name)
			if parser.NSFW then
				Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "NSFW"), "NSFW", COLOR_ROYAL_BLUE)
				width = width + Font.getTextWidth(FONT16, "NSFW") + 5
			end
			if parser.isNew then
				Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "New"), "New", COLOR_CRIMSON)
			elseif parser.isUpdated then
				Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "Updated"), "Updated", COLOR_CRIMSON)
			end
			--Font.print(FONT16, 935 - Font.getTextWidth(FONT16, "v" .. parser.Version), y - 65, "v" .. parser.Version, COLOR_SUB_FONT)
			local linkText = parser.Link .. "/"
			Font.print(FONT16, 225, y - 23 - Font.getTextHeight(FONT16, linkText), linkText, COLOR_SUB_FONT)
			y = y + 75
		end
		local elementsCount = #parsersList
		if elementsCount > 7 then
			scrollHeight = elementsCount * 75 / 524
		end
		item = parserSelector:getSelected()
	elseif status == "IMPORT" then
		local list = Import.listDir()
		local start = max(1, floor((slider.Y - 10) / 75))
		local y = start * 75 - slider.Y
		for i = start, min(#list, start + 9) do
			local object = list[i]
			if slider.ItemID == i then
				Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
			end
			if object.active then
				Font.print(FONT26, 225, y - 70, object.name, COLOR_FONT)
			elseif object.directory then
				Font.print(FONT26, 225, y - 70, "*" .. Str.labelExternalMemory .. "*", COLOR_ROYAL_BLUE)
			else
				Font.print(FONT26, 225, y - 70, object.name, COLOR_SUB_FONT)
			end
			Graphics.fillRect(945, 955, y - 75, y - 1, COLOR_BACK)
			if object.active and object.name ~= "..." then
				if slider.ItemID == i then
					Graphics.fillRect(925 - 16 - 12 - 34 + 10, 945, y - 75, y - 1, COLOR_SELECTED)
				else
					Graphics.fillRect(925 - 16 - 12 - 34 + 10, 945, y - 75, y - 1, COLOR_BACK)
				end
			end
			local textDis = object.name == "..." and Str.labelGoBack or object.directory and (object.active and Str.labelFolder or Str.labelDrive .. ' "' .. object.name .. '"') or object.active and Str.labelFile or Str.labelUnsupportedFile
			Font.print(FONT16, 225, y - 23 - Font.getTextHeight(FONT16, textDis), textDis, COLOR_SUB_FONT)
			if object.active and object.name ~= "..." then
				Graphics.drawImage(925 - 16 - 12, y - 38 - 14, ImportIcon.e, COLOR_ICON_EXTRACT)
			end
			y = y + 75
		end
		local elementsCount = #list
		if elementsCount > 7 then
			scrollHeight = elementsCount * 75 / 524
		end
		item = importSelector:getSelected()
	elseif status == "DOWNLOAD" then
		local list = ChapterSaver.getDownloadingList()
		if #list > 0 then
			local start = max(1, floor((slider.Y - 10) / 75))
			local y = start * 75 - slider.Y
			for i = start, min(#list, start + 9) do
				local task = list[i]
				local pageCount = task.page_count or 0
				local page = task.page or 0
				if slider.ItemID == i then
					Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
				end
				Font.print(FONT20, 225, y - 70, task.MangaName, COLOR_FONT)
				Font.print(FONT16, 225, y - 44, task.ChapterName, COLOR_FONT)
				if pageCount > 0 then
					local textCounter = math.ceil(page) .. "/" .. pageCount
					local w = Font.getTextWidth(FONT16, textCounter)
					downloadBarValue = page / pageCount
					Graphics.fillRect(220 + 10 + w, 220 + 10 + w + (940 - 220 - 10 - w) * downloadBarValue, y - 20, y - 8, COLOR_ROYAL_BLUE)
					Graphics.fillEmptyRect(220 + 10 + w, 940, y - 20, y - 8, COLOR_FONT)
					Font.print(FONT16, 225, y - 24, textCounter, COLOR_FONT)
				elseif i == 1 then
					downloadBarValue = 0
				end
				y = y + 75
			end
		else
			centerScreenMessage = Str.labelEmptyDownloads
		end
		local elementsCount = #list
		if elementsCount > 7 then
			scrollHeight = elementsCount * 75 / 524
		end
		item = downloadSelector:getSelected()
	elseif status == "SETTINGS" then
		local list = Settings.list()
		local start = max(1, floor((slider.Y - 10) / 75))
		local y = start * 75 - slider.Y
		for i = start, min(#list, start + 9) do
			local task = list[i]
			if slider.ItemID == i then
				local dyForTranslators = list[i] == "Translators" and 145 or 0
				Graphics.fillRect(215, 945, y - 75, y - 1 + dyForTranslators, COLOR_SELECTED)
			end
			if type(task) == "table" then
				if Settings.getTab() == "DonatorsList" then
					if i == 1 then
						Font.print(FONT26, (215 + 945) / 2 - Font.getTextWidth(FONT26, task.name) / 2, y - 45 - Font.getTextHeight(FONT26, task.name) / 2, task.name, COLOR_CRIMSON)
					else
						Font.print(FONT26, (215 + 945) / 2 - Font.getTextWidth(FONT26, task.name) / 2, y - 45 - Font.getTextHeight(FONT26, task.name) / 2, task.name, COLOR_FONT)
					end
				else
					Font.print(FONT20, 225, y - 70, task.name, COLOR_FONT)
					if task.type == "savedChapter" then
						Font.print(FONT16, 225, y - 44, task.info, COLOR_SUB_FONT)
					end
				end
			else
				
				if task == "DonatorsList" then
					Font.print(FONT20, 225, y - 70, Str[SettingsDictionary[task]] or task, Color.new(136, 0, 255))
					--[[
					if Language[Settings.Language].SETTINGS_DESCRIPTION[task] then
						Font.print(FONT16, 225, y - 44, Language[Settings.Language].SETTINGS_DESCRIPTION[task], COLOR_ROYAL_BLUE)
					end
					]]
				else
					Font.print(FONT20, 225, y - 70, Str[SettingsDictionary[task]] or task, COLOR_FONT)
					if SettingsDictionaryDescriptions[task] then
						Font.print(FONT16, 225, y - 44, Str[SettingsDictionaryDescriptions[task]], COLOR_SUB_FONT)
					end
				end
				if task == "Language" then
					Font.print(FONT16, 225, y - 44, Str[Settings.Language] or Settings.Language, COLOR_FONT)
				elseif task == "ClearChapters" then
					if chaptersFolderSize == nil then
						chaptersFolderSize = 0
						local function getDirectorySize(dir)
							local d = listDirectory(dir) or {}
							for k = 1, #d do
								if d[k].directory then
									getDirectorySize(dir .. "/" .. d[k].name)
								else
									chaptersFolderSize = chaptersFolderSize + d[k].size
								end
							end
						end
						getDirectorySize("ux0:data/noboru/chapters")
						if doesDirExist("uma0:data/noboru/chapters") then
							getDirectorySize("uma0:data/noboru/chapters")
						end
					end
					Font.print(FONT16, 225, y - 44, BytesToStr(chaptersFolderSize), COLOR_SUB_FONT)
					if sure_clear_chapters > 0 then
						Font.print(FONT16, 225, y - 24, Str.prefPressAgainToAccept, COLOR_CRIMSON)
					end
				elseif task == "ReaderOrientation" then
					Font.print(FONT16, 225, y - 44, Str["label"..Settings.Orientation], COLOR_SUB_FONT)
				elseif task == "ShowNSFW" then
					Font.print(FONT16, 225, y - 44, Settings.NSFW and Str.labelShowNSFW or Str.labelHideNSFW, Settings.NSFW and COLOR_CRIMSON or COLOR_ROYAL_BLUE)
				elseif task == "HideInOffline" then
					Font.print(FONT16, 225, y - 44, Settings.HideInOffline and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "SkipFontLoading" then
					Font.print(FONT16, 225, y - 44, Settings.SkipFontLoad and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "ZoomReader" then
					Font.print(FONT16, 225, y - 44, Str["label"..Settings.ZoomReader] or Settings.ZoomReader, COLOR_SUB_FONT)
				elseif task == "DoubleTapReader" then
					Font.print(FONT16, 225, y - 44, Settings.DoubleTapReader and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "RefreshLibAtStart" then
					Font.print(FONT16, 225, y - 44, Settings.RefreshLibAtStart and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "SilentDownloads" then
					Font.print(FONT16, 225, y - 44, Settings.SilentDownloads and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "ChangeUI" then
					Font.print(FONT16, 225, y - 44, Settings.Theme, COLOR_SUB_FONT)
				elseif task == "LibrarySorting" then
					Font.print(FONT16, 225, y - 44, Settings.LibrarySorting, COLOR_SUB_FONT)
				elseif task == "ChapterSorting" then
					Font.print(FONT16, 225, y - 44, Settings.ChapterSorting, COLOR_SUB_FONT)
				elseif task == "ConnectionTime" then
					Font.print(FONT16, 225, y - 44, Settings.ConnectionTime, COLOR_ROYAL_BLUE)
				elseif task == "UseProxy" then
					Font.print(FONT16, 225, y - 44, Settings.UseProxy and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "ProxyIP" then
					Font.print(FONT16, 225, y - 44, Settings.ProxyIP, COLOR_SUB_FONT)
				elseif task == "ProxyPort" then
					Font.print(FONT16, 225, y - 44, Settings.ProxyPort, COLOR_SUB_FONT)
				elseif task == "UseProxyAuth" then
					Font.print(FONT16, 225, y - 44, Settings.UseProxyAuth and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "SkipCacheChapterChecking" then
					Font.print(FONT16, 225, y - 44, Settings.SkipCacheChapterChecking and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "PressEdgesToChangePage" then
					Font.print(FONT16, 225, y - 44, Settings.PressEdgesToChangePage and Str.labelYes or Str.labelNo, COLOR_ROYAL_BLUE)
				elseif task == "ProxyAuth" then
					Font.print(FONT16, 225, y - 44, Settings.ProxyAuth, COLOR_SUB_FONT)
				elseif task == "ChapterSorting" then
					Font.print(FONT16, 225, y - 44, Settings.ChapterSorting, COLOR_SUB_FONT)
				elseif task == "LeftStickDeadZone" then
					local x = 0
					for n = 1, #DeadZoneValues do
						Font.print(FONT16, 225 + x, y - 44, DeadZoneValues[n], DeadZoneValues[n] == Settings.LeftStickDeadZone and COLOR_CRIMSON or COLOR_SUB_FONT)
						x = x + Font.getTextWidth(FONT16, DeadZoneValues[n]) + 5
					end
				elseif task == "LeftStickSensitivity" then
					local x = 0
					for n = 1, #SensitivityValues do
						Font.print(FONT16, 225 + x, y - 44, SensitivityValues[n], SensitivityValues[n] == Settings.LeftStickSensitivity and COLOR_CRIMSON or COLOR_SUB_FONT)
						x = x + Font.getTextWidth(FONT16, SensitivityValues[n]) + 5
					end
				elseif task == "RightStickDeadZone" then
					local x = 0
					for n = 1, #DeadZoneValues do
						Font.print(FONT16, 225 + x, y - 44, DeadZoneValues[n], DeadZoneValues[n] == Settings.RightStickDeadZone and COLOR_CRIMSON or COLOR_SUB_FONT)
						x = x + Font.getTextWidth(FONT16, DeadZoneValues[n]) + 5
					end
				elseif task == "RightStickSensitivity" then
					local x = 0
					for n = 1, #SensitivityValues do
						Font.print(FONT16, 225 + x, y - 44, SensitivityValues[n], SensitivityValues[n] == Settings.RightStickSensitivity and COLOR_CRIMSON or COLOR_SUB_FONT)
						x = x + Font.getTextWidth(FONT16, SensitivityValues[n]) + 5
					end
				elseif task == "ChangingPageButtons" then
					Font.print(FONT16, 225, y - 44, Settings.ChangingPageButtons == "LR" and Str.labelLRTriggers or Settings.ChangingPageButtons == "DPAD" and Str.labelUseDPad or Settings.ChangingPageButtons, COLOR_SUB_FONT)
				elseif task == "Translators" then
					
					Font.print(
						FONT16,
						225,
						y - 44,
						("@SamuEDL :- Spanish \n@nguyenmao2101 :- Vietnamese \n@theheroGAC :- Italian \n@Cimmerian_Iter :- French \n@kemalsanli :- Turkish \n@rutantan :- PortugueseBR \n@Qingyu510 :- SimplifiedChinese &- TraditionalChinese \n@tmihai20 :- Romanian \n@tof4 :- Polish \n@lukrynka :- German "):gsub(
							"%- (.-) ",
							function(a)
								return " " .. (Str[a] or a) .. " "
							end
						),
						COLOR_ROYAL_BLUE
					)
				elseif task == "ClearLibrary" then
					if sure_clear_library > 0 then
						Font.print(FONT16, 225, y - 44, Str.prefPressAgainToAccept, COLOR_CRIMSON)
					end
				elseif task == "ClearCache" then
					if sure_clear_cache > 0 then
						Font.print(FONT16, 225, y - 44, Str.prefPressAgainToAccept, COLOR_CRIMSON)
					end
				elseif task == "ClearAllCache" then
					if cacheFolderSize == nil then
						cacheFolderSize = 0
						local function getDirectorySize(dir)
							local d = listDirectory(dir) or {}
							for j = 1, #d do
								local f = d[j]
								if f.directory then
									getDirectorySize(dir .. "/" .. f.name)
								else
									cacheFolderSize = cacheFolderSize + f.size
								end
							end
						end
						getDirectorySize("ux0:data/noboru/cache")
					end
					Font.print(FONT16, 225, y - 44, BytesToStr(cacheFolderSize), COLOR_SUB_FONT)
					if sure_clear_all_cache > 0 then
						Font.print(FONT16, 225, y - 24, Str.prefPressAgainToAccept, COLOR_CRIMSON)
					end
				elseif task == "ShowAuthor" then
					Font.print(FONT16, 225, y - 44, "@creckeryop", COLOR_SUB_FONT)
					Font.print(FONT16, 225, y - 24, "Email: didager@ya.ru", COLOR_ROYAL_BLUE)
				elseif task == "SupportDev" then
					Font.print(FONT16, 225, y - 44, "https://paypal.me/creckeryop", COLOR_SUB_FONT)
				elseif task == "ShowVersion" then
					Font.print(FONT16, 225, y - 44, Settings.Version, COLOR_SUB_FONT)
				elseif task == "ReaderDirection" then
					Font.print(FONT16, 225, y - 44, Str["labelDirection"..Settings.ReaderDirection] or Settings.ReaderDirection, COLOR_SUB_FONT)
				elseif task == "SwapXO" then
					Font.print(FONT16, 225, y - 44, Settings.KeyType == "JP" and Str.labelControlLayoutJP or Settings.KeyType == "EU" and Str.labelControlLayoutEU or Settings.KeyType, COLOR_SUB_FONT)
				elseif task == "CheckUpdate" then
					Font.print(FONT16, 225, y - 44, Str.labelLatestVersion .. Settings.LateVersion, tonumber(Settings.LateVersion) > tonumber(Settings.Version) and COLOR_ROYAL_BLUE or COLOR_SUB_FONT)
				elseif task == "SaveDataPath" then
					Font.print(FONT16, 225, y - 44, Settings.SaveDataPath, COLOR_SUB_FONT)
				elseif task == "AnimatedGif" then
					Font.print(FONT16, 225, y - 44, Settings.AnimatedGif and Str.labelYes or Str.labelNo, COLOR_SUB_FONT)
				elseif task == "LoadSummary" then
					Font.print(FONT16, 225, y - 44, Settings.LoadSummary and Str.labelYes or Str.labelNo, COLOR_SUB_FONT)
				end
			end
			y = y + 75
		end
		local elementsCount = #list
		if elementsCount > 7 then
			scrollHeight = elementsCount * 75 / 524
		end
		item = settingSelector:getSelected()
		itemHeight = list[item] == "Translators" and 145 or 0
	elseif status == "MANGA" or status == "LIBRARY" or status == "HISTORY" then
		if #currentMangaList ~= 0 then
			local start = max(1, floor(slider.Y / (MANGA_HEIGHT + 6)) * 4 + 1)
			for i = start, min(#currentMangaList, start + 15) do
				local x = 580 + (((i - 1) % 4) - 2) * (MANGA_WIDTH + 6) + 3
				local y = -slider.Y + floor((i - 1) / 4) * (MANGA_HEIGHT + 6) + 6
				DrawManga(x + MANGA_WIDTH / 2, y + MANGA_HEIGHT / 2, currentMangaList[i])
				if status == "LIBRARY" and currentMangaList[i].Counter then
					local c = currentMangaList[i].Counter
					if c > 0 then
						Graphics.fillRect(x, x + Font.getTextWidth(BOLD_FONT16, c) + 11, y, y + 24, Themes[Settings.Theme].COLOR_LABEL)
						Font.print(BOLD_FONT16, x + 5, y + 2, tostring(c), COLOR_WHITE)
					end
				end
			end
			local item = mangaSelector:getSelected()
			if item ~= 0 then
				local x = 580 + (((item - 1) % 4) - 2) * (MANGA_WIDTH + 6) + MANGA_WIDTH / 2 + 3
				local y = MANGA_HEIGHT / 2 - slider.Y + floor((item - 1) / 4) * (MANGA_HEIGHT + 6) + 6
				local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
				local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
				for i = ks + 1, ks + 3 do
					Graphics.fillEmptyRect(x - MANGA_WIDTH / 2 + i, x + MANGA_WIDTH / 2 - i + 1, y - MANGA_HEIGHT / 2 + i, y + MANGA_HEIGHT / 2 - i + 1, Themes[Settings.Theme].COLOR_SELECTOR)
					Graphics.fillEmptyRect(x - MANGA_WIDTH / 2 + i, x + MANGA_WIDTH / 2 - i + 1, y - MANGA_HEIGHT / 2 + i, y + MANGA_HEIGHT / 2 - i + 1, wh)
				end
			end
			if #currentMangaList > 4 then
				scrollHeight = ceil(#currentMangaList / 4) * (MANGA_HEIGHT + 14) / 524
			end
		else
			if status == "LIBRARY" then
				centerScreenMessage = Str.labelEmptyLibrary
			elseif status == "MANGA" then
				if not ParserManager.check(currentMangaList) and mangaLoadStatus == 1 then
					centerScreenMessage = Str.labelEmptyCatalog
				end
			elseif status == "HISTORY" then
				centerScreenMessage = Str.labelEmptyHistory
			end
		end
	end
	if centerScreenMessage then
		local lines = StringToLines(centerScreenMessage)
		local height = 0
		for i, line in ipairs(lines) do
			local newLine = {}
			newLine.Height = Font.getTextHeight(FONT16, line)
			newLine.Width = Font.getTextWidth(FONT16, line)
			newLine.Text = line
			lines[i] = newLine
			height = height + newLine.Height + 4
		end
		local dy = 0
		for _, line in ipairs(lines) do
			Font.print(FONT16, 582 - math.floor(line.Width / 2), 272 - math.floor(height / 2) + dy, line.Text, Themes[Settings.Theme].COLOR_SUB_FONT)
			dy = dy + line.Height + 4
		end
		if smile then
			Font.print(FONT26, 582 - math.floor(Font.getTextWidth(FONT26, smile) / 2), 272 - math.floor(height / 2) + dy + 6, smile, Themes[Settings.Theme].COLOR_SUB_FONT)
		end
	end
	if item and item ~= 0 then
		local y = item * 75 - slider.Y
		local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
		local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
		for i = ks, ks + 1 do
			Graphics.fillEmptyRect(218 + i, 942 - i + 1, y - i - 5 + itemHeight, y - 71 + i + 1, Themes[Settings.Theme].COLOR_SELECTOR)
			Graphics.fillEmptyRect(218 + i, 942 - i + 1, y - i - 5 + itemHeight, y - 71 + i + 1, wh)
		end
	end
	Graphics.fillRect(955, 960, 0, 544, COLOR_BACK)
	if scrollHeight then
		Graphics.fillRect(955, 960, slider.Y / scrollHeight, (slider.Y + 524) / scrollHeight, COLOR_FONT)
	else
		Graphics.fillRect(955, 960, 0, 524, COLOR_FONT)
	end
end

---Frees all images loaded in catalog
function Catalogs.shrink()
	for _, i in ipairs(downloadedImages) do
		freeMangaImage(currentMangaList[i])
	end
	collectgarbage("collect")
	ParserManager.remove(currentMangaList)
	Loading.setStatus("NONE")
end

function Catalogs.terminate()
	Catalogs.shrink()
	downloadedImages = {}
	currentMangaList = {}
	page = 1
	slider.Y = -100
	mangaSelector:resetSelected()
	parserSelector:resetSelected()
	downloadSelector:resetSelected()
	settingSelector:resetSelected()
	importSelector:resetSelected()
	extensionSelector:resetSelected()
end

---@param newStatus string | '"CATALOGS"' | '"MANGA"' | '"LIBRARY"' | '"DOWNLOAD"' | '"EXTENSIONS"' | '"IMPORT"' | '"SETTINGS"'
function Catalogs.setStatus(newStatus)
	status = newStatus
	chaptersFolderSize = nil
	cacheFolderSize = nil
	sure_clear_library = 0
	sure_clear_chapters = 0
	sure_clear_cache = 0
	mangaLoadStatus = 0
	sure_clear_all_cache = 0
	local smileIdx = math.random(1, #smilesList)
	if smilesList[smileIdx] then
		smile = smilesList[smileIdx]
	end
	Catalogs.terminate()
end