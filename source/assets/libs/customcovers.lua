CustomCovers = {}

local covers = {}

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist

local function getKey(manga)
	return (manga.ParserID .. manga.Link):gsub("%p", "")
end

local function save()
	if doesFileExist("ux0:data/noboru/cusettings/_covers.ini") then
		deleteFile("ux0:data/noboru/cusettings/_covers.ini")
	end
	local file = openFile("ux0:data/noboru/cusettings/_covers.ini", FCREATE)
	local saveData = table.serialize(covers)
	writeFile(file, saveData, #saveData)
	closeFile(file)
end

function CustomCovers.load()
	if doesFileExist("ux0:data/noboru/cusettings/_covers.ini") then
		local file = openFile("ux0:data/noboru/cusettings/_covers.ini", FREAD)
		local loadCoversFunction = load("return " .. readFile(file, sizeFile(file)))
		closeFile(file)
		if loadCoversFunction then
			covers = loadCoversFunction()
		end
	end
end

function CustomCovers.setMangaCover(manga, link)
	local key = getKey(manga)
	covers[key] = link
	save()
end

function CustomCovers.hasCustomCover(manga)
	local key = getKey(manga)
	return covers[key] ~= nil
end

function CustomCovers.getCustomCover(manga)
	local key = getKey(manga)
	return covers[key]
end