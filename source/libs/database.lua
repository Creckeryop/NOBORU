Database = {}

---@type table
---Local table that stores all manga that is in database
local mangaList = {}

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local doesDirExist = System.doesDirExist

---@param manga table
---@return string
---Returns `manga` hash
local function getMangaHash(manga)
	return (manga.ParserID .. manga.Link):gsub("%p", "")
end

---@return table
---Gets Library manga list
function Database.getMangaList()
	local tempMangaList = {}
	local isUma0Exists = doesDirExist("uma0:data/noboru")
	for i = 1, #mangaList do
		local manga = mangaList[i]
		if manga.Location ~= "uma0" or isUma0Exists then
			tempMangaList[#tempMangaList + 1] = manga
		end
	end
	if Settings.LibrarySorting == "A-Z" then
		table.sort(
			tempMangaList,
			function(a, b)
				return a.Name < b.Name
			end
		)
	elseif Settings.LibrarySorting == "Z-A" then
		table.sort(
			tempMangaList,
			function(a, b)
				return a.Name > b.Name
			end
		)
	end
	return tempMangaList
end

---@param manga table
---Adds `manga` to database
function Database.addManga(manga)
	local mangaHash = getMangaHash(manga)
	if not mangaList[mangaHash] then
		mangaList[#mangaList + 1] = manga
		mangaList[mangaHash] = #mangaList
		Database.save()
	end
end

---@param manga table
---@return boolean
---Checks if `manga` is in library
function Database.check(manga)
	return mangaList[getMangaHash(manga)] ~= nil
end

---@param mangaHash string
---@return boolean
function Database.checkByHash(mangaHash)
	return mangaList[mangaHash] ~= nil
end

---@param manga table
---Removes `manga` from library
function Database.removeManga(manga)
	local mangaHash = getMangaHash(manga)
	if mangaList[mangaHash] then
		local n = mangaList[mangaHash]
		table.remove(mangaList, n)
		mangaList[mangaHash] = nil
		for i = n, #mangaList do
			local k = getMangaHash(mangaList[i])
			mangaList[k] = mangaList[k] - 1
		end
		Database.save()
	end
end

---Saves library to `ux0:data/noboru/save.dat`
function Database.save()
	local mangaListSave = {}
	for k = 1, #mangaList do
		local manga = mangaList[k]
		local mangaHash = getMangaHash(manga)
		mangaListSave[k] = CreateManga(manga.Name, manga.Link, manga.ImageLink, manga.ParserID, manga.RawLink, manga.BrowserLink)
		mangaListSave[k].Data = manga.Data
		mangaListSave[k].Path = "cache/" .. mangaHash .. "/cover.image"
		mangaListSave[k].Location = manga.Location or "ux0"
		mangaListSave[mangaHash] = k
	end
	local save = "return " .. table.serialize(mangaListSave, true)
	if doesFileExist("ux0:data/noboru/save.dat") then
		deleteFile("ux0:data/noboru/save.dat")
	end
	local fh = openFile("ux0:data/noboru/save.dat", FCREATE)
	writeFile(fh, save, #save)
	closeFile(fh)
end

---Loads library from `ux0:data/noboru/save.dat`
function Database.load()
	if doesFileExist("ux0:data/noboru/save.dat") then
		local fh = openFile("ux0:data/noboru/save.dat", FREAD)
		local loadMangaListFunction = load(readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if loadMangaListFunction then
			mangaList = loadMangaListFunction() or {}
		end
	end
	Database.save()
end

---Resets library
function Database.clear()
	mangaList = {}
	Database.save()
end
