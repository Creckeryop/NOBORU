CuSettings = {}

local custom_settings = {}

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

local function save(manga, key)
	key = key or get_key(manga)
	if custom_settings[key] then
		if doesFileExist("ux0:data/noboru/cusettings/" .. key .. ".ini") then
			deleteFile("ux0:data/noboru/cusettings/" .. key .. ".ini")
		end
		local file = openFile("ux0:data/noboru/cusettings/" .. key .. ".ini", FCREATE)
		local save_data = table.serialize(custom_settings[key])
		writeFile(file, save_data, #save_data)
		closeFile(file)
	end
end

local function clearDefs(manga, key)
	key = key or get_key(manga)
	for _, v in pairs(custom_settings[key]) do
		if v ~= "Default" then
			return true
		end
	end
	if doesFileExist("ux0:data/noboru/cusettings/" .. key .. ".ini") then
		deleteFile("ux0:data/noboru/cusettings/" .. key .. ".ini")
	end
	return false
end

function CuSettings.load(manga)
	local key = get_key(manga)
	if custom_settings[key] then
		return custom_settings[key]
	end
	if doesFileExist("ux0:data/noboru/cusettings/" .. key .. ".ini") then
		local file = openFile("ux0:data/noboru/cusettings/" .. key .. ".ini", FREAD)
		local load_settings = load("return " .. readFile(file, sizeFile(file)))
		closeFile(file)
		if load_settings then
			local settings =
				load_settings() or
				{
					Orientation = "Default",
					ReaderDirection = "Default",
					ZoomReader = "Default"
				}
			custom_settings[key] = settings
			return settings
		end
	end
	custom_settings[key] = {
		Orientation = "Default",
		ReaderDirection = "Default",
		ZoomReader = "Default"
	}
	return custom_settings[key]
end

function CuSettings.changeOrientation(manga)
	local key = get_key(manga)
	custom_settings[key].Orientation = table.next(custom_settings[key].Orientation, {"Vertical", "Horizontal", "Default"})
	if clearDefs(manga, key) then
		save(manga, key)
	end
end

function CuSettings.changeDirection(manga)
	local key = get_key(manga)
	custom_settings[key].ReaderDirection = table.next(custom_settings[key].ReaderDirection, {"RIGHT", "LEFT", "DOWN", "Default"})
	if clearDefs(manga, key) then
		save(manga, key)
	end
end

function CuSettings.changeZoom(manga)
	local key = get_key(manga)
	custom_settings[key].ZoomReader = table.next(custom_settings[key].ZoomReader, {"Smart", "Width", "Height", "Default"})
	if clearDefs(manga, key) then
		save(manga, key)
	end
end
