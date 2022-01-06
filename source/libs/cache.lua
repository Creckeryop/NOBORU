Cache = {}

local CACHE_INFO_PATH = "ux0:data/noboru/cache/info.txt"

local mangaCache = {}
local history = {}
local bookmarks = {}
local cachedHistory = {}

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

local isHistoryUpdated = false

---@param manga table
---@return string
---Gives key for a given `manga`
local function getMangaHash(manga)
	return (manga.ParserID .. manga.Link):gsub("%p", "")
end

---@param manga table
---@return string
---Gives key for a given `manga`
Cache.getMangaHash = getMangaHash

---@return table
---Returns all manga in cache
function Cache.getManga()
	local mangaList = {}
	for key, value in pairs(mangaCache) do
		mangaList[key] = value
	end
	return mangaList
end

---@param manga table
---@param chapters table | nil
---Caching `Manga` if it's not
function Cache.addManga(manga, chapters)
	local mangaHash = getMangaHash(manga)
	if not mangaCache[mangaHash] then
		mangaCache[mangaHash] = manga
		manga.Path = "cache/" .. mangaHash .. "/cover.image"
		if not doesDirExist("ux0:data/noboru/cache/" .. mangaHash) then
			createDirectory("ux0:data/noboru/cache/" .. mangaHash)
		end
		if doesFileExist("ux0:data/noboru/cache/" .. mangaHash .. "/cover.image") then
			deleteFile("ux0:data/noboru/cache/" .. mangaHash .. "/cover.image")
		end
		if chapters then
			Cache.saveChapters(manga, chapters)
		end
		if manga.ParserID ~= "IMPORTED" then
			Threads.insertTask(
				tostring(manga) .. "coverDownload",
				{
					Type = "FileDownload",
					Path = "cache/" .. mangaHash .. "/cover.image",
					Link = manga.ImageLink
				}
			)
		end
		Cache.save()
	end
end

---@param manga table
---Removes given `manga` from cache
function Cache.removeManga(manga)
	local mangaHash = getMangaHash(manga)
	if mangaCache[mangaHash] then
		mangaCache[mangaHash] = nil
		manga.Path = nil
		removeDirectory("ux0:data/noboru/cache/" .. mangaHash)
		Cache.save()
	end
end

---@param chapter table
---@param mode integer | boolean
---Set's bookmark for given `Chapter`
function Cache.setBookmark(chapter, mode)
	Cache.addManga(chapter.Manga)
	local mangaHash = getMangaHash(chapter.Manga)
	local chapterHash = chapter.Link:gsub("%p", "")
	if not bookmarks[mangaHash] then
		bookmarks[mangaHash] = {}
	end
	bookmarks[mangaHash][chapterHash] = mode
	bookmarks[mangaHash].LatestBookmark = chapterHash
	if doesFileExist("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat") then
		deleteFile("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat")
	end
	local fh = openFile("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat", FCREATE)
	local serializedBookmarks = "return " .. table.serialize(bookmarks[mangaHash], true)
	writeFile(fh, serializedBookmarks, #serializedBookmarks)
	closeFile(fh)
end

---@param chapter table
---@return nil | boolean | number
---Gives latest read page for `Chapter`
---`number` latest read page, `true` if manga read completely, `nil` if no bookmark on this `Chapter`
function Cache.getBookmark(chapter)
	local mangaHash = getMangaHash(chapter.Manga)
	local chapterHash = chapter.Link:gsub("%p", "")
	return bookmarks[mangaHash] and bookmarks[mangaHash][chapterHash]
end

---@param manga table
---@return string
---Gives key for latest closed chapter
function Cache.getLatestBookmark(manga)
	local mangaHash = getMangaHash(manga)
	return bookmarks[mangaHash] and bookmarks[mangaHash].LatestBookmark
end

function Cache.getBookmarkKey(chapter)
	return chapter.Link:gsub("%p", "")
end

---@param manga table
---Saves all bookmarks related to given `manga`
function Cache.saveBookmarks(manga)
	local mangaHash = getMangaHash(manga)
	if doesDirExist("ux0:data/noboru/cache/" .. mangaHash) then
		if doesFileExist("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat") then
			deleteFile("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat")
		end
		local fh = openFile("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat", FCREATE)
		local serializedBookmarks = "return " .. table.serialize(bookmarks[mangaHash], true)
		writeFile(fh, serializedBookmarks, #serializedBookmarks)
		closeFile(fh)
	end
end

---@param manga table
---Loads all bookmarks in cache for given `manga`
function Cache.loadBookmarks(manga)
	local mangaHash = getMangaHash(manga)
	if doesFileExist("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat") then
		local fh = openFile("ux0:data/noboru/cache/" .. mangaHash .. "/bookmarks.dat", FREAD)
		local loadBookmarksFunction = load(readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if loadBookmarksFunction then
			bookmarks[mangaHash] = loadBookmarksFunction() or {}
		end
	end
end

---@param manga table
---Checks if bookmarks is already loaded (in cache)
function Cache.isBookmarkExist(manga)
	local mangaHash = getMangaHash(manga)
	return bookmarks[mangaHash] ~= nil
end

---@param manga table
---Clears bookmarks for given `manga`
function Cache.clearBookmarks(manga)
	local mangaHash = getMangaHash(manga)
	bookmarks[mangaHash] = {}
	Cache.saveBookmarks(manga)
end

---@param manga table
---Creates/Updates History record
function Cache.makeHistory(manga)
	local mangaHash = getMangaHash(manga)
	for i = 1, #history do
		if history[i] == mangaHash then
			if i == 1 then
				return
			end
			table.remove(history, i)
			break
		end
	end
	table.insert(history, 1, mangaHash)
	Cache.saveHistory()
	isHistoryUpdated = true
end

---@param Manga table
---Removes given `Manga` from history
function Cache.removeHistory(Manga)
	local mangaHash = getMangaHash(Manga)
	for i = 1, #history do
		if history[i] == mangaHash then
			table.remove(history, i)
			Cache.saveHistory()
			isHistoryUpdated = true
			break
		end
	end
end

---@return table
---Gives list of all History records
function Cache.getHistory()
	if isHistoryUpdated then
		local newHistoryList = {}
		local uma0Flag = doesDirExist("uma0:data/noboru")
		for i = 1, #history do
			local file = history[i]
			if mangaCache[file] then
				if mangaCache[file].Location ~= "uma0" or uma0Flag then
					newHistoryList[#newHistoryList + 1] = mangaCache[file]
				end
			end
		end
		isHistoryUpdated = false
		cachedHistory = newHistoryList
	end
	return cachedHistory
end

---Saves all History records
function Cache.saveHistory()
	if doesFileExist("ux0:data/noboru/cache/history.dat") then
		deleteFile("ux0:data/noboru/cache/history.dat")
	end
	local fh = openFile("ux0:data/noboru/cache/history.dat", FCREATE)
	local serializedHistory = "return " .. table.serialize(history, true)
	writeFile(fh, serializedHistory, #serializedHistory)
	closeFile(fh)
end

---Loads History records from `history.dat` file
function Cache.loadHistory()
	if doesFileExist("ux0:data/noboru/cache/history.dat") then
		local fh = openFile("ux0:data/noboru/cache/history.dat", FREAD)
		local loadHistoryFunction = load(readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if loadHistoryFunction then
			history = loadHistoryFunction() or {}
		end
	end
	Cache.saveHistory()
	isHistoryUpdated = true
end

---@param manga table
---@return boolean
---Gives is manga in history
function Cache.inHistory(manga)
	return history[getMangaHash(manga)] ~= nil
end

---@param manga table
---Checks if `manga` is cached
function Cache.isCached(manga)
	return manga and mangaCache[getMangaHash(manga)] ~= nil or false
end

---@param manga table
---@param chapters table
---Updates `chapter` List for given `manga`
function Cache.saveChapters(manga, chapters)
	local mangaHash = getMangaHash(manga)
	local path = "ux0:data/noboru/cache/" .. mangaHash .. "/chapters.dat"
	local chaptersList = {}
	if doesFileExist(path) then
		deleteFile(path)
	end
	for i = 1, #chapters do
		chaptersList[i] = {}
		for k, v in pairs(chapters[i]) do
			chaptersList[i][k] = k == "Manga" and "10101010101010" or v
		end
	end
	chaptersList.Description = chapters.Description or ""
	local fh = openFile(path, FCREATE)
	local serializedChaptersList = "return " .. table.serialize(chaptersList, true)
	writeFile(fh, serializedChaptersList, #serializedChaptersList)
	closeFile(fh)
end

---@param manga table
---@return table
---Gives chapter list for given `manga`
function Cache.loadMangaChapters(manga, skipHiding)
	local mangaHash = getMangaHash(manga)
	if mangaCache[mangaHash] then
		if doesFileExist("ux0:data/noboru/cache/" .. mangaHash .. "/chapters.dat") then
			local fh = openFile("ux0:data/noboru/cache/" .. mangaHash .. "/chapters.dat", FREAD)
			local success, newChaptersList =
				pcall(
				function()
					local content = readFile(fh, sizeFile(fh))
					return load(content:gsub('"10101010101010"', "..."))(mangaCache[mangaHash])
				end
			)
			closeFile(fh)
			if success then
				if skipHiding then
					newChaptersList.Description = newChaptersList.Description or ""
					return newChaptersList
				end
				if Settings.HideInOffline then
					local t = {}
					for i = 1, #newChaptersList do
						local chapter = newChaptersList[i]
						t[#t + 1] = ChapterSaver.check(chapter) and chapter or nil
					end
					t.Description = newChaptersList.Description or ""
					return t
				else
					newChaptersList.Description = newChaptersList.Description or ""
					return newChaptersList
				end
			else
				Console.error(newChaptersList)
			end
		end
	end
	return {}
end

---Loads Cache
function Cache.load()
	mangaCache = {}
	if doesFileExist(CACHE_INFO_PATH) then
		local fh = openFile(CACHE_INFO_PATH, FREAD)
		local loadCacheFunction = load(readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if loadCacheFunction then
			local newMangaCache = loadCacheFunction() or {}
			local count = 0
			for _ in pairs(newMangaCache) do
				count = count + 1
			end
			local num = 1
			for hash, manga in pairs(newMangaCache) do
				local mangaCachePath = "ux0:data/noboru/cache/" .. hash
				coroutine.yield("Cache: Checking " .. mangaCachePath, num / count)
				if not Settings.SkipCacheChapterChecking then
					if doesDirExist(mangaCachePath) then
						if doesFileExist("ux0:data/noboru/" .. manga.Path) then
							coroutine.yield("Cache: Checking ux0:data/noboru/" .. manga.Path, num / count)
							local imageSize = System.getPictureResolution("ux0:data/noboru/" .. manga.Path)
							if not imageSize or imageSize <= 0 then
								deleteFile("ux0:data/noboru/" .. manga.Path)
							end
						end
						mangaCache[hash] = manga
					else
						Notifications.push("Cache error\n" .. hash)
					end
				else
					mangaCache[hash] = manga
				end
				num = num + 1
			end
		end
	end
	Cache.save()
end

---Saves Cache
function Cache.save()
	if doesFileExist(CACHE_INFO_PATH) then
		deleteFile(CACHE_INFO_PATH)
	end
	local fh = openFile(CACHE_INFO_PATH, FCREATE)
	local mangaCacheCopy = {}
	for hash, manga in pairs(mangaCache) do
		mangaCacheCopy[hash] = CreateManga(manga.Name, manga.Link, manga.ImageLink, manga.ParserID, manga.RawLink)
		mangaCacheCopy[hash].Data = manga.Data
		mangaCacheCopy[hash].Path = "cache/" .. hash .. "/cover.image"
		mangaCacheCopy[hash].Location = manga.Location or "ux0"
	end
	local serializedMangaCache = "return " .. table.serialize(mangaCacheCopy, true)
	writeFile(fh, serializedMangaCache, #serializedMangaCache)
	closeFile(fh)
end

---@param mode string | '"notlibrary"' | '"all"'
---Clears cache in specific `mode`
---
---`mode = "notlibrary"` - clears all cache that is not related to library
---
---`mode = "all"` - clears all cache
function Cache.clear(mode)
	mode = mode or "notlibrary"
	if mode == "notlibrary" then
		local cacheDirectory = listDirectory("ux0:data/noboru/cache") or {}
		for i = 1, #cacheDirectory do
			local file = cacheDirectory[i]
			if not Library.checkByHash(file.name) and file.directory then
				removeDirectory("ux0:data/noboru/cache/" .. file.name)
				mangaCache[file.name] = nil
			end
		end
		local newHistory = {}
		for i = 1, #history do
			if mangaCache[history[i]] then
				newHistory[#newHistory + 1] = history[i]
			end
		end
		history = newHistory
	elseif mode == "all" then
		local cacheDirectory = listDirectory("ux0:data/noboru/cache") or {}
		for i = 1, #cacheDirectory do
			local file = cacheDirectory[i]
			if not file.name:find("^IMPORTED") or not Library.checkByHash(file.name) then
				removeDirectory("ux0:data/noboru/cache/" .. file.name)
				mangaCache[file.name] = nil
			end
		end
		local newHistory = {}
		for i = 1, #history do
			if mangaCache[history[i]] then
				newHistory[#newHistory + 1] = history[i]
			end
		end
		history = newHistory
		bookmarks = {}
	end
	Cache.saveHistory()
	isHistoryUpdated = true
	Cache.save()
end
