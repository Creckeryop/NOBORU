ChapterSaver = {}
local allKeys = {}
local taskListOrder = {}
local currentTask = nil
local downloadingList = {}

---Path to saved chapters folder
local CHAPTERS_FOLDER_PATH = "ux0:data/noboru/chapters/"
local CHAPTERS_INFO_FILE_PATH = "ux0:data/noboru/c.c"

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local doesDirExist = System.doesDirExist
local createDirectory = System.createDirectory
local listDirectory = System.listDirectory
local removeDirectory = RemoveDirectory

---@return string
---Creates key for a chapter from it's Manga's `parserID`, `Link` and chapter `Link`
local function getKey(chapter)
	return (chapter.Manga.ParserID .. chapter.Manga.Link):gsub("%p", "") .. "_" .. chapter.Link:gsub("%p", "")
end

ChapterSaver.getKey = getKey
local getFreeSpace = System.getFreeSpace
local isUserNotified = false
local isNotificationsEnabled = true
local isSavedChaptersUpdated = false

---Updates Cache things
function ChapterSaver.update()
	if #taskListOrder == 0 and currentTask == nil then
		isUserNotified = false
		return
	end
	if not currentTask then
		currentTask = table.remove(taskListOrder, 1)
		isSavedChaptersUpdated = false
		if currentTask.Type == "Download" and getFreeSpace("ux0:") < 40 * 1024 * 1024 then
			if not isUserNotified then
				Notifications.push(Language[Settings.Language].NOTIFICATIONS.NO_SPACE_LEFT)
				isUserNotified = true
			end
			downloadingList[currentTask.Key] = nil
			currentTask = nil
			return
		end
		currentTask.F = coroutine.create(currentTask.F)
	else
		if coroutine.status(currentTask.F) ~= "dead" then
			local _, msg, var1, var2 = coroutine.resume(currentTask.F)
			if _ then
				if currentTask.Destroy and msg and msg ~= "update_count+false" then
					if currentTask.Notify and not Settings.SilentDownloads then
						Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.CANCEL_DOWNLOAD, currentTask.MangaName, currentTask.ChapterName))
					end
					downloadingList[currentTask.Key] = nil
					isSavedChaptersUpdated = false
					currentTask = nil
				elseif msg == "update_count" then
					currentTask.page = var1
					currentTask.page_count = var2
				elseif msg == "update_count+false" then
					currentTask.page = var1
					currentTask.page_count = var2
				end
			else
				Console.error("Unknown error with saved chapters: " .. msg)
				downloadingList[currentTask.Key] = nil
				isSavedChaptersUpdated = false
				currentTask = nil
			end
		else
			if not currentTask.Fail then
				if currentTask.Type == "Download" and not Settings.SilentDownloads then
					Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.END_DOWNLOAD, currentTask.MangaName, currentTask.ChapterName))
				elseif currentTask.Type == "Import" then
					Notifications.push(Language[Settings.Language].NOTIFICATIONS.IMPORT_COMPLETED)
				end
			end
			downloadingList[currentTask.Key] = nil
			isSavedChaptersUpdated = false
			currentTask = nil
		end
	end
end

---@param chapter table
---Creates task for downloading `chapter`
function ChapterSaver.downloadChapter(chapter, silent)
	local k = getKey(chapter)
	downloadingList[k] = {
		Type = "Download",
		Key = k,
		MangaName = chapter.Manga.Name,
		ChapterName = chapter.Name,
		Drive = Settings.getSaveDrivePath(),
		F = function()
			local FolderPath = downloadingList[k].Drive .. ":data/noboru/chapters/"
			if not doesDirExist(FolderPath .. k) then
				createDirectory(FolderPath .. k)
			end
			local t = {}
			local connection
			local getChaptersRetryCounter = 0
			while getChaptersRetryCounter < 3 do
				ParserManager.prepareChapter(chapter, t)
				while ParserManager.check(t) do
					coroutine.yield("update_count", 0, 0)
				end
				if #t < 1 then
					Console.error("error getting pages")
					getChaptersRetryCounter = getChaptersRetryCounter + 1
					if getChaptersRetryCounter < 3 then
						connection = Threads.netActionUnSafe(Network.isWifiEnabled)
						if not connection then
							ConnectMessage.show()
						end
						while ConnectMessage.isActive() do
							coroutine.yield(true)
						end
						Console.error("retrying")
					end
				else
					break
				end
				coroutine.yield(true)
			end
			if getChaptersRetryCounter == 3 then
				Notifications.pushUnique(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM .. "\nMaybe chapter has 0 pages")
				removeDirectory(FolderPath .. k)
				downloadingList[k].Fail = true
				downloadingList[k] = nil
				return
			end
			local parser = GetParserByID(chapter.Manga.ParserID)
			for i = 1, #t do
				coroutine.yield("update_count", i - 1, #t)
				local result = {}
				parser:loadChapterPage(t[i], result)
				coroutine.yield(false)
				local retry = 0
				while retry < 3 do
					Threads.insertTask(
						result,
						{
							Type = "FileDownload",
							Link = result.Link,
							Path = FolderPath .. k .. "/" .. i .. ".image"
						}
					)
					while Threads.check(result) do
						local progress = Threads.getProgress(result)
						coroutine.yield("update_count+false", i - 1 + progress, #t)
					end
					if doesFileExist(FolderPath .. k .. "/" .. i .. ".image") then
						local size = System.getPictureResolution(FolderPath .. k .. "/" .. i .. ".image")
						if not size or size <= 0 then
							Console.error("error loading picture for " .. k .. " " .. i)
							retry = retry + 1
							if retry < 3 then
								connection = Threads.netActionUnSafe(Network.isWifiEnabled)
								if not connection then
									ConnectMessage.show()
								end
								while ConnectMessage.isActive() do
									coroutine.yield(true)
								end
								Console.error("retrying")
							end
						else
							break
						end
					else
						Console.error("download of " .. k .. "/" .. i .. ".image failed")
						retry = retry + 1
						if retry < 3 then
							connection = Threads.netActionUnSafe(Network.isWifiEnabled)
							if not connection then
								ConnectMessage.show()
							end
							while ConnectMessage.isActive() do
								coroutine.yield(true)
							end
							Console.error("retrying")
						end
					end
					coroutine.yield(true)
				end
				if retry == 3 then
					Notifications.pushUnique(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM)
					removeDirectory(FolderPath .. k)
					downloadingList[k].Fail = true
					downloadingList[k] = nil
					return
				end
			end
			local fh = openFile(FolderPath .. k .. "/done.txt", FCREATE)
			writeFile(fh, #t, string.len(#t))
			closeFile(fh)
			allKeys[k] = downloadingList[k].Drive
			ChapterSaver.save()
			downloadingList[k] = nil
		end
	}
	isSavedChaptersUpdated = false
	taskListOrder[#taskListOrder + 1] = downloadingList[k]
	if not silent and not Settings.SilentDownloads then
		Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.START_DOWNLOAD, chapter.Manga.Name, chapter.Name))
	end
end

local getTime = System.getTime
local getDate = System.getDate
local copyFile = CopyFile

local listZip = System.listZip
local extractFromZip = System.extractFromZip
local rename = System.rename

function ChapterSaver.importManga(path)
	local h, mn, s = getTime()
	local _, d, mo, y = getDate()
	local Manga = CreateManga(path:match(".*/(.*)%..-$") or path:match(".*/(.-)$"), table.concat({h, mn, s, d, mo, y}, "A"), "", "IMPORTED", "local:book")
	if path:find("^uma0:") then
		Manga.Location = "uma0"
	else
		Manga.Location = "ux0"
	end
	downloadingList[path] = {
		Type = "Import",
		Key = path,
		MangaName = Manga.Name,
		Drive = "ux0",
		ChapterName = "Importing"
	}
	local this = downloadingList[path]
	this.F = function()
		if doesDirExist(path) then
			local dir = listDirectory(path) or {}
			local newDirectory = {}
			local type
			local tempDir = {}
			for _, f in ipairs(dir) do
				if f.directory or f.name:find("%.cbz") or f.name:find("%.zip") or (System.getPictureResolution(path .. "/" .. f.name) or -1) > 0 then
					tempDir[#tempDir + 1] = f
				end
			end
			dir = tempDir
			for _, f in ipairs(dir) do
				local newType
				if f.directory then
					newType = "folder"
				elseif (System.getPictureResolution(path .. "/" .. f.name) or -1) > 0 then
					newType = "image"
				elseif f.name:find("%.cbz$") or f.name:find("%.zip$") then
					newType = "package"
				elseif not f.name:find("%.txt$") and not f.name:find("%.xml$") then
					Notifications.push("ERROR: Unknown type of import pattern")
					downloadingList[path].Fail = true
					downloadingList[path] = nil
					return
				end
				if not type or newType == type then
					type = newType
					if newType then
						newDirectory[#newDirectory + 1] = f
					end
				else
					Notifications.push("ERROR: Unknown type of import pattern")
					downloadingList[path].Fail = true
					downloadingList[path] = nil
					return
				end
			end
			dir = newDirectory
			table.sort(
				dir,
				function(a, b)
					return a.name < b.name
				end
			)
			if type == "folder" then
				local isCoverLoaded = false
				for _, folder in ipairs(dir) do
					local dir_ = listDirectory(path .. "/" .. folder.name) or {}
					tempDir = {}
					for _, f in ipairs(dir_) do
						if f.directory or f.name:find("%.cbz") or f.name:find("%.zip") or (System.getPictureResolution(path .. "/" .. f.name) or -1) > 0 then
							tempDir[#tempDir + 1] = f
						end
					end
					dir_ = tempDir
					for _, file in ipairs(dir_) do
						if (System.getPictureResolution(path .. "/" .. folder.name .. "/" .. file.name) or -1) <= 0 and not file.name:find("%.txt$") and not file.name:find("%.xml$") then
							Notifications.push(Language[Settings.Language].NOTIFICATIONS.BAD_IMAGE_FOUND)
							downloadingList[path].Fail = true
							downloadingList[path] = nil
							return
						end
					end
				end
				local Chapters = {}
				Cache.addManga(Manga)
				for _, folder in ipairs(dir) do
					local Chapter = {
						Name = folder.name,
						Link = table.concat({h, mn, s, d, mo, y, _}, "B"),
						Pages = {},
						Manga = Manga
					}
					local subDir = listDirectory(path .. "/" .. folder.name) or {}
					table.sort(
						subDir,
						function(a, b)
							return a.name < b.name
						end
					)
					local imageLinks = {}
					for _, f in ipairs(subDir) do
						if (System.getPictureResolution(path .. "/" .. folder.name .. "/" .. f.name) or -1) > 0 then
							imageLinks[#imageLinks + 1] = path .. "/" .. folder.name .. "/" .. f.name
						end
					end
					if #imageLinks > 0 then
						Chapters[#Chapters + 1] = Chapter
						if not isCoverLoaded then
							copyFile(imageLinks[1], "ux0:data/noboru/cache/" .. Cache.getMangaHash(Manga) .. "/cover.image")
							isCoverLoaded = true
						end
						imageLinks = table.concat(imageLinks, "\n")
						local k = getKey(Chapter)
						removeDirectory(CHAPTERS_FOLDER_PATH .. k)
						createDirectory(CHAPTERS_FOLDER_PATH .. k)
						local fh = openFile(CHAPTERS_FOLDER_PATH .. k .. "/custom.txt", FCREATE)
						writeFile(fh, imageLinks, #imageLinks)
						closeFile(fh)
						allKeys[k] = true
					else
						Notifications.push(Chapter.Name .. "\nerror: no supported images found")
					end
				end
				if #Chapters > 0 then
					Cache.saveChapters(Manga, Chapters)
					Database.addManga(Manga)
					ChapterSaver.save()
				else
					Cache.removeManga(Manga)
					Notifications.push(path .. "\nerror: no supported chapters found")
					downloadingList[path].Fail = true
				end
				downloadingList[path] = nil
			elseif type == "image" then
				local imageLinks = {}
				for _, f in ipairs(dir) do
					imageLinks[_] = path .. "/" .. f.name
				end
				local Chapter = {
					Name = Manga.Name,
					Link = table.concat({h, mn, s, d, mo, y}, "B"),
					Pages = {},
					Manga = Manga
				}
				if #imageLinks > 0 then
					Cache.addManga(Manga, {Chapter})
					copyFile(imageLinks[1], "ux0:data/noboru/cache/" .. Cache.getMangaHash(Manga) .. "/cover.image")
					imageLinks = table.concat(imageLinks, "\n")
					local k = getKey(Chapter)
					removeDirectory(CHAPTERS_FOLDER_PATH .. k)
					createDirectory(CHAPTERS_FOLDER_PATH .. k)
					local fh = openFile(CHAPTERS_FOLDER_PATH .. k .. "/custom.txt", FCREATE)
					writeFile(fh, imageLinks, #imageLinks)
					closeFile(fh)
					allKeys[k] = true
					Database.addManga(Manga)
					ChapterSaver.save()
				else
					Notifications.push(path .. "\nerror: no supported images found")
					downloadingList[path].Fail = true
				end
				downloadingList[path] = nil
			elseif type == "package" then
				local isCoverLoaded = false
				Cache.addManga(Manga)
				local mk = Cache.getMangaHash(Manga)
				local Chapters = {}
				for _, pack in ipairs(dir) do
					local Chapter = {
						Name = pack.name:match("(.*)%..-$"),
						Link = table.concat({h, mn, s, d, mo, y, _}, "B"),
						Pages = {},
						Manga = Manga
					}
					local zipDir = listZip(path .. "/" .. pack.name) or {}
					table.sort(
						zipDir,
						function(a, b)
							return a.name < b.name
						end
					)
					local isContainImages = false
					for _, file in ipairs(zipDir) do
						Console.write(file.name)
						if file.name:find("%.jpeg$") or file.name:find("%.jpg$") or file.name:find("%.png$") or file.name:find("%.bmp$")  or file.name:find("%.gif$") then
							if not isCoverLoaded then
								extractFromZip(path .. "/" .. pack.name, file.name, "ux0:data/noboru/cache/" .. mk .. "/cover.image")
								isCoverLoaded = true
							end
							isContainImages = true
							break
						end
					end
					if isContainImages then
						Chapters[#Chapters + 1] = Chapter
						local k = getKey(Chapter)
						removeDirectory(CHAPTERS_FOLDER_PATH .. k)
						createDirectory(CHAPTERS_FOLDER_PATH .. k)
						local fh = openFile(CHAPTERS_FOLDER_PATH .. k .. "/custom.txt", FCREATE)
						writeFile(fh, path .. "/" .. pack.name, #(path .. "/" .. pack.name))
						closeFile(fh)
						allKeys[k] = true
					else
						Notifications.push(path .. "/" .. pack.name .. "\nerror: no supported images found")
					end
				end
				if #Chapters > 0 then
					Cache.saveChapters(Manga, Chapters)
					Database.addManga(Manga)
					ChapterSaver.save()
				else
					Cache.removeManga(Manga)
					Notifications.push(Manga.Name .. "\nerror: no supported chapters found")
					downloadingList[path].Fail = true
				end
				downloadingList[path] = nil
			end
		elseif doesFileExist(path) then
			if path:find("%.cbz$") or path:find("%.zip$") then
				Cache.addManga(Manga)
				local mk = Cache.getMangaHash(Manga)
				local Chapter = {
					Name = path:match(".*/(.*)%..-$"),
					Link = table.concat({h, mn, s, d, mo, y, _}, "B"),
					Pages = {},
					Manga = Manga
				}
				local zipDir = listZip(path) or {}
				table.sort(
					zipDir,
					function(a, b)
						return a.name < b.name
					end
				)
				local isCoverLoaded = false
				for _, file in ipairs(zipDir) do
					Console.write(file.name)
					if file.name:find("%.jpeg$") or file.name:find("%.jpg$") or file.name:find("%.png$") or file.name:find("%.bmp$") or file.name:find("%.gif$") then
						extractFromZip(path, file.name, "ux0:data/noboru/cache/" .. mk .. "/cover.image")
						isCoverLoaded = true
						break
					end
				end
				if isCoverLoaded then
					local k = getKey(Chapter)
					removeDirectory(CHAPTERS_FOLDER_PATH .. k)
					createDirectory(CHAPTERS_FOLDER_PATH .. k)
					local fh = openFile(CHAPTERS_FOLDER_PATH .. k .. "/custom.txt", FCREATE)
					writeFile(fh, path, #path)
					closeFile(fh)
					allKeys[k] = true
					Cache.saveChapters(Manga, {Chapter})
					Database.addManga(Manga)
					ChapterSaver.save()
				else
					Cache.removeManga(Manga)
					Notifications(path .. "\nerror: no supported images found")
					downloadingList[path].Fail = true
				end
				downloadingList[path] = nil
			else
				Notifications(path .. "\nerror: this format not supported")
				downloadingList[path].Fail = true
				downloadingList[path] = nil
			end
		end
	end
	isSavedChaptersUpdated = false
	taskListOrder[#taskListOrder + 1] = this
end

---@return boolean
---Gives info if download is running
function ChapterSaver.isDownloadRunning()
	return currentTask ~= nil or #taskListOrder > 0
end

---@param key string
---Stops task by it's key
local function stop(key, silent)
	if downloadingList[key] then
		if downloadingList[key] == currentTask then
			downloadingList[key].Destroy = true
			downloadingList[key].Notify = silent == nil
			Network.stopCurrentDownload()
			local FolderPath = downloadingList[key].Drive .. ":data/noboru/chapters/"
			removeDirectory(FolderPath .. key)
		else
			local newOrder = {}
			for _, v in ipairs(taskListOrder) do
				if v == downloadingList[key] then
					if isNotificationsEnabled and silent == nil and not Settings.SilentDownloads then
						Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.CANCEL_DOWNLOAD, v.MangaName, v.ChapterName))
					end
				else
					newOrder[#newOrder + 1] = v
				end
			end
			taskListOrder = newOrder
		end
		isSavedChaptersUpdated = false
		downloadingList[key] = nil
	end
end

---@param chapters table
---@param silent boolean
---Stops List of `chapters` downloading and notify if `silent == nil`
function ChapterSaver.stopList(chapters, silent)
	local newOrder = {}
	local orderCount = #taskListOrder
	for _, v in ipairs(chapters) do
		local key = getKey(v)
		local d = downloadingList[key]
		if d then
			if d == currentTask then
				d.Destroy = true
				d.Notify = silent == nil
				Network.stopCurrentDownload()
				local FolderPath = downloadingList[key].Drive .. ":data/noboru/chapters/"
				removeDirectory(FolderPath .. key)
			else
				for i, od in pairs(taskListOrder) do
					if od == d then
						taskListOrder[i] = nil
						break
					end
				end
			end
			downloadingList[key] = nil
		end
	end
	for i = 1, orderCount do
		if taskListOrder[i] ~= nil then
			newOrder[#newOrder + 1] = taskListOrder[i]
		end
	end
	taskListOrder = newOrder
	isSavedChaptersUpdated = false
end

---@param chapter table
---@param silent boolean
---Stops `chapter` downloading and notify if `silent == nil`
function ChapterSaver.stop(chapter, silent)
	if chapter then
		stop(getKey(chapter), silent)
	end
end

---@param item table
---Stops `chapter` downloading by List item from `Cache.getDownloadingList` function
function ChapterSaver.stopByListItem(item)
	if item then
		stop(item.Key)
	end
end

---@param chapter table
---Deletes saved chapter
function ChapterSaver.delete(chapter, silent)
	local k = getKey(chapter)
	if allKeys[k] then
		local FolderPath = (allKeys[k] == true and "ux0" or allKeys[k]) .. ":data/noboru/chapters/"
		removeDirectory(FolderPath .. k)
		allKeys[k] = nil
		ChapterSaver.save()
		if not silent and not Settings.SilentDownloads then
			Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.CHAPTER_REMOVE, k))
		end
	end
end

---@param key any
---Deletes saved chapter by key (unsafe only for settings)
function ChapterSaver.removeByKeyUnsafe(key)
	allKeys[key] = nil
	ChapterSaver.save()
end

local cached = {}

---@return table
---Returns all active downloads
function ChapterSaver.getDownloadingList()
	if isSavedChaptersUpdated then
		return cached
	end
	local list = {}
	taskListOrder[0] = currentTask
	for i = currentTask and 0 or 1, #taskListOrder do
		list[#list + 1] = taskListOrder[i]
	end
	isSavedChaptersUpdated = true
	cached = list
	return cached
end

function ChapterSaver.clearDownloadingList()
	if currentTask then
		stop(currentTask.Key, true)
	end
	for i = 1, #taskListOrder do
		local key = taskListOrder[i].Key
		local FolderPath = downloadingList[key].Drive .. ":data/noboru/chapters/"
		downloadingList[key] = nil
		removeDirectory(FolderPath .. key)
	end
	taskListOrder = {}
end

---@param chapter table
---@return boolean
---Gives `true` if chapter is downloaded
function ChapterSaver.check(chapter)
	local key = allKeys[getKey(chapter)]
	return key == true or key == "uma0" and doesDirExist("uma0:data/noboru") or key == "ux0" or chapter and chapter.FastLoad
end

---@param chapter table
---@return boolean
---Gives `true` if chapter is downloading
function ChapterSaver.isChapterDownloading(chapter)
	return downloadingList[getKey(chapter)]
end

local statFile = System.statFile

---@param chapter table
---@return table
---Gives table with all paths to chapters images (pages)
function ChapterSaver.getChapter(chapter)
	if chapter.FastLoad then
		local _table_ = {
			Done = true
		}
		local info = statFile(chapter.Path)
		if info and info.directory then
			local dir = listDirectory(chapter.Path) or {}
			table.sort(
				dir,
				function(a, b)
					return a.name < b.name
				end
			)
			for _, file in ipairs(dir) do
				if not file.directory and (file.name:find("%.jpg$") or file.name:find("%.png$") or file.name:find("%.jpeg$") or file.name:find("%.bmp$") or file.name:find("%.gif$") or file.name:find("%.image$")) then
					_table_[#_table_ + 1] = {
						Path = chapter.Path .. "/" .. file.name
					}
				end
			end
		else
			local zip = listZip(chapter.Path) or {}
			table.sort(
				zip,
				function(a, b)
					return a.name < b.name
				end
			)
			for _, file in ipairs(zip) do
				if not file.directory and (file.name:find("%.jpg$") or file.name:find("%.png$") or file.name:find("%.jpeg$") or file.name:find("%.bmp$") or file.name:find("%.gif$")) then
					_table_[#_table_ + 1] = {
						Extract = file.name,
						Path = chapter.Path
					}
				end
			end
		end
		return _table_
	end
	local k = getKey(chapter)
	local _table_ = {
		Done = true
	}
	if allKeys[k] then
		local FolderPath = (allKeys[k] == true and "ux0" or allKeys[k]) .. ":data/noboru/chapters/"
		if doesFileExist(FolderPath .. k .. "/custom.txt") then
			local fh_2 = openFile(FolderPath .. k .. "/custom.txt", FREAD)
			local paths = readFile(fh_2, sizeFile(fh_2))
			closeFile(fh_2)
			local lines = StringToLines(paths)
			if #lines == 1 and (lines[1]:find("%.cbz$") or lines[1]:find("%.zip$")) then
				local zip = listZip(lines[1]) or {}
				table.sort(
					zip,
					function(a, b)
						return a.name < b.name
					end
				)
				for _, file in ipairs(zip) do
					if not file.directory and (file.name:find("%.jpg$") or file.name:find("%.png$") or file.name:find("%.jpeg$") or file.name:find("%.bmp$") or file.name:find("%.gif$")) then
						_table_[#_table_ + 1] = {
							Extract = file.name,
							Path = lines[1]
						}
					end
				end
			else
				for _, path in ipairs(lines) do
					_table_[_] = {
						Path = path
					}
				end
			end
		else
			local pages = #(listDirectory(FolderPath .. k) or {}) - 1
			for i = 1, pages do
				_table_[i] = {
					Path = FolderPath .. k .. "/" .. i .. ".image"
				}
			end
		end
	end
	return _table_
end

---Saves saved chapters changes
function ChapterSaver.save()
	if doesFileExist(CHAPTERS_INFO_FILE_PATH) then
		deleteFile(CHAPTERS_INFO_FILE_PATH)
	end
	local fh = openFile(CHAPTERS_INFO_FILE_PATH, FCREATE)
	local saveData = "Keys = " .. table.serialize(allKeys, true)
	writeFile(fh, saveData, #saveData)
	closeFile(fh)
end

---Loads saved chapters changes
function ChapterSaver.load()
	allKeys = {}
	if doesFileExist(CHAPTERS_INFO_FILE_PATH) then
		local fh = openFile(CHAPTERS_INFO_FILE_PATH, FREAD)
		local loadKeysFunction = load("local " .. readFile(fh, sizeFile(fh)) .. " return Keys")
		closeFile(fh)
		if loadKeysFunction then
			local keys = loadKeysFunction() or {}
			local cnt = 0
			for _, _ in pairs(keys) do
				cnt = cnt + 1
			end
			local chaptersCounter = 1
			for k, _ in pairs(keys) do
				local FolderPath = (_ == true and "ux0" or _) .. ":data/noboru/chapters/"
				coroutine.yield("ChapterSaver: Checking " .. FolderPath .. k, chaptersCounter / cnt)
				if not Settings.SkipCacheChapterChecking then
					if doesFileExist(FolderPath .. k .. "/custom.txt") then
						local fh2 = openFile(FolderPath .. k .. "/custom.txt", FREAD)
						local paths = readFile(fh2, sizeFile(fh2))
						closeFile(fh2)
						for _, path in ipairs(StringToLines(paths)) do
							if not doesFileExist(path) then
								removeDirectory(FolderPath .. k)
								Notifications.push("here chapters_error\n" .. k)
								break
							end
						end
						allKeys[k] = true
					elseif doesFileExist(FolderPath .. k .. "/done.txt") then
						local fh2 = openFile(FolderPath .. k .. "/done.txt", FREAD)
						local pages = readFile(fh2, sizeFile(fh2))
						closeFile(fh2)
						local lDir = listDirectory(FolderPath .. k) or {}
						if tonumber(pages) == #lDir - 1 then
							--[[
                            -- This code checks all images in cache, their type (more safer)
                            local count = 0
                            for i = 1, #lDir do
                            local width = System.getPictureResolution(FOLDER .. k .. "/" .. lDir[i].name)
                            if not width or width <= 0 then
                            count = count + 1
                            if count == 2 then
                            rem_dir("ux0:data/noboru/chapters/" .. k)
                            Notifications.push("chapters_error_wrong_image\n" .. k)
                            break
                            end
                            end
                            end
                            if count < 2 then
                            Keys[k] = true
                            end]]
							allKeys[k] = _
						else
							removeDirectory(FolderPath .. k)
							Notifications.push("chapters_error\n" .. k)
						end
					else
						removeDirectory(FolderPath .. k)
						Notifications.push("chapters_error\n" .. k)
					end
				else
					allKeys[k] = _
				end
				chaptersCounter = chaptersCounter + 1
			end
			local dirList = listDirectory("ux0:data/noboru/chapters") or {}
			for _, v in ipairs(dirList) do
				if not allKeys[v.name] and v.directory then
					removeDirectory("ux0:data/noboru/chapters/" .. v.name)
				end
			end
			if doesDirExist("uma0:data/noboru") then
				dirList = listDirectory("uma0:data/noboru/chapters") or {}
				for _, v in ipairs(dirList) do
					if not allKeys[v.name] and v.directory then
						removeDirectory("uma0:data/noboru/chapters/" .. v.name)
					end
				end
			end
		end
		ChapterSaver.save()
	end
end

function ChapterSaver.setKey(key)
	allKeys[key] = true
	ChapterSaver.save()
end

---Clears all saved chapters
function ChapterSaver.clear()
	isNotificationsEnabled = false
	local list = ChapterSaver.getDownloadingList()
	for i = 1, #list do
		ChapterSaver.stopByListItem(list[i])
	end
	isNotificationsEnabled = true
	removeDirectory("ux0:data/noboru/chapters")
	createDirectory("ux0:data/noboru/chapters")
	if doesDirExist("uma0:data/noboru") then
		removeDirectory("uma0:data/noboru/chapters")
		createDirectory("uma0:data/noboru/chapters")
	end
	allKeys = {}
	ChapterSaver.save()
	Notifications.push(Language[Settings.Language].NOTIFICATIONS.CHAPTERS_CLEARED)
end
