Cache = {}

local data = {}
local history = {}
local bookmarks = {}

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
local rem_dir = RemoveDirectory

local function get_key(Manga)
	return (Manga.ParserID .. Manga.Link):gsub("%p", "")
end

Cache.getKey = get_key

---@return table
---Returns all manga in cache
function Cache.getManga()
	local t = {}
	for k, v in pairs(data) do
		t[k] = v
	end
	return t
end

---@param Manga table
---@param Chapters table | nil
---Adds `Manga` to cache if it is not in cache
function Cache.addManga(Manga, Chapters)
	local key = get_key(Manga)
	if not data[key] then
		data[key] = Manga
		Manga.Path = "cache/" .. key .. "/cover.image"
		if not doesDirExist("ux0:data/noboru/cache/" .. key) then
			createDirectory("ux0:data/noboru/cache/" .. key)
		end
		if doesFileExist("ux0:data/noboru/cache/" .. key .. "/cover.image") then
			deleteFile("ux0:data/noboru/cache/" .. key .. "/cover.image")
		end
		if Chapters then
			Cache.saveChapters(Manga, Chapters)
		end
		if Manga.ParserID ~= "IMPORTED" then
			Threads.insertTask(
				tostring(Manga) .. "coverDownload",
				{
					Type = "FileDownload",
					Path = "cache/" .. key .. "/cover.image",
					Link = Manga.ImageLink
				}
			)
		end
		Cache.save()
	end
end

---@param Manga table
---Removes given `Manga` from cache
function Cache.removeManga(Manga)
	local key = get_key(Manga)
	if data[key] then
		data[key] = nil
		Manga.Path = nil
		rem_dir("ux0:data/noboru/cache/" .. key)
		Cache.save()
	end
end

---@param Chapter table
---@param mode integer | boolean
---Set's bookmark for given `Chapter`
function Cache.setBookmark(Chapter, mode)
	Cache.addManga(Chapter.Manga)
	local mkey = get_key(Chapter.Manga)
	local key = Chapter.Link:gsub("%p", "")
	if not bookmarks[mkey] then
		bookmarks[mkey] = {}
	end
	bookmarks[mkey][key] = mode
	bookmarks[mkey].LatestBookmark = key
	if doesFileExist("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat") then
		deleteFile("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat")
	end
	local fh = openFile("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat", FCREATE)
	local serialized_bookmarks = "return " .. table.serialize(bookmarks[mkey], true)
	writeFile(fh, serialized_bookmarks, #serialized_bookmarks)
	closeFile(fh)
end

---@param Chapter table
---@return nil | boolean | number
---Gives latest readed page for `Chapter`
---
---`number` latest readed page, `true` if manga readed full, `nil` if no bookmark on this `Chapter`
function Cache.getBookmark(Chapter)
	local mkey = get_key(Chapter.Manga)
	local key = Chapter.Link:gsub("%p", "")
	return bookmarks[mkey] and bookmarks[mkey][key]
end

---@param Manga table
---@return string
---Gives key for latest closed chapter
function Cache.getLatestBookmark(Manga)
	local mkey = get_key(Manga)
	return bookmarks[mkey] and bookmarks[mkey].LatestBookmark
end

function Cache.getBookmarkKey(Chapter)
	return Chapter.Link:gsub("%p", "")
end

---@param Manga table
---Saves all bookmarks related to given `Manga`
function Cache.saveBookmarks(Manga)
	local mkey = get_key(Manga)
	if doesDirExist("ux0:data/noboru/cache/" .. mkey) then
		if doesFileExist("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat") then
			deleteFile("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat")
		end
		local fh = openFile("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat", FCREATE)
		local serialized_bookmarks = "return " .. table.serialize(bookmarks[mkey], true)
		writeFile(fh, serialized_bookmarks, #serialized_bookmarks)
		closeFile(fh)
	end
end

---@param Manga table
---Loads all bookmarks in cache for given `Manga`
function Cache.loadBookmarks(Manga)
	local mkey = get_key(Manga)
	if doesFileExist("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat") then
		local fh = openFile("ux0:data/noboru/cache/" .. mkey .. "/bookmarks.dat", FREAD)
		local load_bookmarks = load(readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if load_bookmarks then
			bookmarks[mkey] = load_bookmarks() or {}
		end
	end
end

---@param Manga table
---Checks if bookmarks is already loaded (in cache)
function Cache.BookmarksLoaded(Manga)
	local mkey = get_key(Manga)
	return bookmarks[mkey] ~= nil
end

function Cache.clearBookmarks(Manga)
	local mkey = get_key(Manga)
	bookmarks[mkey] = {}
	Cache.saveBookmarks(Manga)
end

local updated = false

---@param Manga table
---Creates/Updates History record
function Cache.makeHistory(Manga)
	local key = get_key(Manga)
	for i = 1, #history do
		if history[i] == key then
			if i == 1 then
				return
			end
			table.remove(history, i)
			break
		end
	end
	table.insert(history, 1, key)
	Cache.saveHistory()
	updated = true
end

---@param Manga table
---Removes given `Manga` from history
function Cache.removeHistory(Manga)
	local key = get_key(Manga)
	local deleted = false
	for i = 1, #history do
		if history[i] == key then
			table.remove(history, i)
			deleted = true
			break
		end
	end
	if deleted then
		Cache.saveHistory()
		updated = true
	end
end

local cached_history = {}

---@return table
---Gives list of all History records
function Cache.getHistory()
	if updated then
		local new_history = {}
		local uma0_flag = doesDirExist("uma0:data/noboru")
		for i = 1, #history do
			local v = history[i]
			if data[v] then
				if data[v].Location ~= "uma0" or uma0_flag then
					new_history[#new_history + 1] = data[v]
				end
			end
		end
		updated = false
		cached_history = new_history
	end
	return cached_history
end

---Saves all History records
function Cache.saveHistory()
	if doesFileExist("ux0:data/noboru/cache/history.dat") then
		deleteFile("ux0:data/noboru/cache/history.dat")
	end
	local fh = openFile("ux0:data/noboru/cache/history.dat", FCREATE)
	local serialized_history = "return " .. table.serialize(history, true)
	writeFile(fh, serialized_history, #serialized_history)
	closeFile(fh)
end

---Loads History records from `history.dat` file
function Cache.loadHistory()
	if doesFileExist("ux0:data/noboru/cache/history.dat") then
		local fh = openFile("ux0:data/noboru/cache/history.dat", FREAD)
		local load_history = load(readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if load_history then
			history = load_history() or {}
		end
	end
	Cache.saveHistory()
	updated = true
end

---@param manga table
---@return boolean
---Gives is manga in history
function Cache.inHistory(manga)
	return history[get_key(manga)] ~= nil
end

---@param Manga table
---Checks if `Manga` is cached
function Cache.isCached(Manga)
	return Manga and data[get_key(Manga)] ~= nil or false
end

---@param Manga table
---@param Chapters table
---Updates `Chapter` List for given `Manga`
function Cache.saveChapters(Manga, Chapters)
	local key = get_key(Manga)
	local path = "ux0:data/noboru/cache/" .. key .. "/chapters.dat"
	if doesFileExist(path) then
		deleteFile(path)
	end
	local chlist = {}
	for i = 1, #Chapters do
		chlist[i] = {}
		for k, v in pairs(Chapters[i]) do
			chlist[i][k] = k == "Manga" and "10101010101010" or v
		end
	end
	local fh = openFile(path, FCREATE)
	local serialized_chlist = "return " .. table.serialize(chlist, true)
	writeFile(fh, serialized_chlist, #serialized_chlist)
	closeFile(fh)
end

---@param Manga table
---@return table
---Gives chapter list for given `Manga`
function Cache.loadChapters(Manga, skiphiding)
	local key = get_key(Manga)
	if data[key] then
		if doesFileExist("ux0:data/noboru/cache/" .. key .. "/chapters.dat") then
			local fh = openFile("ux0:data/noboru/cache/" .. key .. "/chapters.dat", FREAD)
			local suc, new_chlist =
				pcall(
				function()
					local content = readFile(fh, sizeFile(fh))
					return load(content:gsub('"10101010101010"', "..."))(data[key])
				end
			)
			closeFile(fh)
			if suc then
				if skiphiding then
					return new_chlist
				end
				if Settings.HideInOffline then
					local t = {}
					for i = 1, #new_chlist do
						local chapter = new_chlist[i]
						t[#t + 1] = ChapterSaver.check(chapter) and chapter or nil
					end
					return t
				else
					return new_chlist
				end
			else
				Console.error(new_chlist)
			end
		end
	end
	return {}
end

local CACHE_INFO_PATH = "ux0:data/noboru/cache/info.txt"
---Loads Cache
function Cache.load()
	data = {}
	if doesFileExist(CACHE_INFO_PATH) then
		local fh = openFile(CACHE_INFO_PATH, FREAD)
		local load_data = load(readFile(fh, sizeFile(fh)))
		if load_data then
			local new_data = load_data() or {}
			local count = 0
			for _ in pairs(new_data) do
				count = count + 1
			end
			local i = 1
			for k, v in pairs(new_data) do
				local path = "ux0:data/noboru/cache/" .. k
				coroutine.yield("Cache: Checking " .. path, i / count)
				if not Settings.SkipCacheChapterChecking then
					if doesDirExist(path) then
						if doesFileExist("ux0:data/noboru/" .. v.Path) then
							coroutine.yield("Cache: Checking ux0:data/noboru/" .. v.Path, i / count)
							local image_size = System.getPictureResolution("ux0:data/noboru/" .. v.Path)
							if not image_size or image_size <= 0 then
								deleteFile("ux0:data/noboru/" .. v.Path)
							end
						end
						data[k] = v
					else
						Notifications.push("cache_error\n" .. k)
					end
				else
					data[k] = v
				end
				i = i + 1
			end
		end
		closeFile(fh)
	end
	Cache.save()
end

---Saves Cache
function Cache.save()
	if doesFileExist(CACHE_INFO_PATH) then
		deleteFile(CACHE_INFO_PATH)
	end
	local fh = openFile(CACHE_INFO_PATH, FCREATE)
	local save_data = {}
	for k, v in pairs(data) do
		save_data[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink)
		save_data[k].Data = v.Data
		save_data[k].Path = "cache/" .. k .. "/cover.image"
		save_data[k].Location = v.Location or "ux0"
	end
	local serialized_data = "return " .. table.serialize(save_data, true)
	writeFile(fh, serialized_data, #serialized_data)
	closeFile(fh)
end

---@param mode string | '"notlibrary"' | '"all"'
---Clears cache in specific `mode`
function Cache.clear(mode)
	mode = mode or "notlibrary"
	if mode == "notlibrary" then
		local d = listDirectory("ux0:data/noboru/cache") or {}
		for i = 1, #d do
			local f = d[i]
			if not Database.checkByKey(f.name) and f.directory then
				rem_dir("ux0:data/noboru/cache/" .. f.name)
				data[f.name] = nil
			end
		end
		local new_history = {}
		for i = 1, #history do
			if data[history[i]] then
				new_history[#new_history + 1] = history[i]
			end
		end
		history = new_history
	elseif mode == "all" then
		local d = listDirectory("ux0:data/noboru/cache") or {}
		for i = 1, #d do
			local f = d[i]
			if not f.name:find("^IMPORTED") or not Database.checkByKey(f.name) then
				rem_dir("ux0:data/noboru/cache/" .. f.name)
				data[f.name] = nil
			end
		end
		local new_history = {}
		for i = 1, #history do
			if data[history[i]] then
				new_history[#new_history + 1] = history[i]
			end
		end
		history = new_history
		bookmarks = {}
	end
	Cache.saveHistory()
	updated = true
	Cache.save()
end
