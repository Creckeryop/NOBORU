Database = {}

---@type table
---Local table that stores all mangas that is in database
local database = {}

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local doesDirExist = System.doesDirExist

---@param Manga table
---@return string
---Gives key for a given `manga`
local function getKey(Manga)
	return (Manga.ParserID .. Manga.Link):gsub("%p", "")
end

---@return table
---Gets Library manga list
function Database.getMangaList()
	local mangaList = {}
	local uma0_flag = doesDirExist("uma0:data/noboru")
	for i = 1, #database do
		local m = database[i]
		if m.Location ~= "uma0" or uma0_flag then
			mangaList[#mangaList + 1] = m
		end
	end
	if Settings.LibrarySorting == "A-Z" then
		table.sort(
			mangaList,
			function(a, b)
				return a.Name < b.Name
			end
		)
	elseif Settings.LibrarySorting == "Z-A" then
		table.sort(
			mangaList,
			function(a, b)
				return a.Name > b.Name
			end
		)
	end
	return mangaList
end

---@param manga table
---Adds `manga` to database
function Database.addManga(manga)
	local key = getKey(manga)
	if not database[key] then
		database[#database + 1] = manga
		database[key] = #database
		Database.save()
	end
end

---@param manga table
---@return boolean
---Checks if `manga` is in library
function Database.check(manga)
	return database[getKey(manga)] ~= nil
end

---@param key string
---@return boolean
function Database.checkByKey(key)
	return database[key] ~= nil
end

---@param manga table
---Removes `manga` from library
function Database.removeManga(manga)
	local key = getKey(manga)
	if database[key] then
		local n = database[key]
		table.remove(database, n)
		database[key] = nil
		for i = n, #database do
			local k = getKey(database[i])
			database[k] = database[k] - 1
		end
		Database.save()
	end
end

---Saves library to `ux0:data/noboru/save.dat`
function Database.save()
	local mangaTable = {}
	for k = 1, #database do
		local m = database[k]
		local key = getKey(m)
		mangaTable[k] = CreateManga(m.Name, m.Link, m.ImageLink, m.ParserID, m.RawLink, m.BrowserLink)
		mangaTable[k].Data = m.Data
		mangaTable[k].Path = "cache/" .. key .. "/cover.image"
		mangaTable[k].Location = m.Location or "ux0"
		mangaTable[key] = k
	end
	local save = "return " .. table.serialize(mangaTable, true)
	if doesFileExist("ux0:data/noboru/save.dat") then
		deleteFile("ux0:data/noboru/save.dat")
	end
	local f = openFile("ux0:data/noboru/save.dat", FCREATE)
	writeFile(f, save, #save)
	closeFile(f)
end

---Loads library from `ux0:data/noboru/save.dat`
function Database.load()
	if doesFileExist("ux0:data/noboru/save.dat") then
		local f = openFile("ux0:data/noboru/save.dat", FREAD)
		local loadDataFunction = load(readFile(f, sizeFile(f)))
		closeFile(f)
		if loadDataFunction then
			database = loadDataFunction() or {}
		end
	end
	Database.save()
end

---Resets library
function Database.clear()
	database = {}
	Database.save()
end
