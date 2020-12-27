CustomCovers = {}

local covers = {}

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist

local function get_key(manga)
	return (manga.ParserID .. manga.Link):gsub("%p", "")
end

local function save()
	if doesFileExist("ux0:data/noboru/cusettings/_covers.ini") then
		deleteFile("ux0:data/noboru/cusettings/_covers.ini")
	end
	local file = openFile("ux0:data/noboru/cusettings/_covers.ini", FCREATE)
	local save_data = table.serialize(covers)
	writeFile(file, save_data, #save_data)
	closeFile(file)
end

function CustomCovers.load()
	if doesFileExist("ux0:data/noboru/cusettings/_covers.ini") then
		local file = openFile("ux0:data/noboru/cusettings/_covers.ini", FREAD)
		local load_covers = load("return " .. readFile(file, sizeFile(file)))
		closeFile(file)
		if load_covers then
			covers = load_covers()
		end
	end
end

function CustomCovers.setMangaCover(manga, link)
	local key = get_key(manga)
	covers[key] = link
	save()
end

function CustomCovers.hasCustomCover(manga)
	local key = get_key(manga)
	return covers[key] ~= nil
end

function CustomCovers.getCustomCover(manga)
	local key = get_key(manga)
	return covers[key]
end