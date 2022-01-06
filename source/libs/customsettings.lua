CuSettings = {}

local customSettings = {}

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist

---@param manga table
---@return string
---Gives key for specific `manga`
local function getKey(manga)
	return (manga.ParserID .. manga.Link):gsub("%p", "")
end

---@param manga table
---@param key string | nil
---Saves custom settings for specific `manga`
local function save(manga, key)
	key = key or getKey(manga)
	if customSettings[key] then
		if doesFileExist("ux0:data/noboru/cusettings/" .. key .. ".ini") then
			deleteFile("ux0:data/noboru/cusettings/" .. key .. ".ini")
		end
		local fh = openFile("ux0:data/noboru/cusettings/" .. key .. ".ini", FCREATE)
		local serializedData = table.serialize(customSettings[key])
		writeFile(fh, serializedData, #serializedData)
		closeFile(fh)
	end
end

---@param manga table
---@param key string | nil
---@return boolean
---Deletes save file for `manga` if all settings are set to defaults gives `false` if file was deleted
local function resetToDefault(manga, key)
	key = key or getKey(manga)
	for _, v in pairs(customSettings[key]) do
		if v ~= "Default" then
			return true
		end
	end
	if doesFileExist("ux0:data/noboru/cusettings/" .. key .. ".ini") then
		deleteFile("ux0:data/noboru/cusettings/" .. key .. ".ini")
	end
	return false
end

---@param manga table
---@return table
---Gives `manga` custom settings `{Orientation, ReaderDirection, ZoomReader}`
function CuSettings.load(manga)
	local key = getKey(manga)
	if customSettings[key] then
		return customSettings[key]
	end
	if doesFileExist("ux0:data/noboru/cusettings/" .. key .. ".ini") then
		local fh = openFile("ux0:data/noboru/cusettings/" .. key .. ".ini", FREAD)
		local loadSettingsFunction = load("return " .. readFile(fh, sizeFile(fh)))
		closeFile(fh)
		if loadSettingsFunction then
			local loadedCustomSettings =
				loadSettingsFunction() or
				{
					Orientation = "Default",
					ReaderDirection = "Default",
					ZoomReader = "Default"
				}
			customSettings[key] = loadedCustomSettings
			return loadedCustomSettings
		end
	end
	customSettings[key] = {
		Orientation = "Default",
		ReaderDirection = "Default",
		ZoomReader = "Default"
	}
	return customSettings[key]
end

---@param manga table
---Changes orientation settings for `manga`
function CuSettings.changeOrientation(manga)
	local key = getKey(manga)
	customSettings[key].Orientation = table.next(customSettings[key].Orientation, {"Vertical", "Horizontal", "Default"})
	if resetToDefault(manga, key) then
		save(manga, key)
	end
end

---@param manga table
---Changes readDirection settings for `manga`
function CuSettings.changeDirection(manga)
	local key = getKey(manga)
	customSettings[key].ReaderDirection = table.next(customSettings[key].ReaderDirection, {"RIGHT", "LEFT", "DOWN", "Default"})
	if resetToDefault(manga, key) then
		save(manga, key)
	end
end

---@param manga table
---Changes zoom settings for `manga`
function CuSettings.changeZoom(manga)
	local key = getKey(manga)
	customSettings[key].ZoomReader = table.next(customSettings[key].ZoomReader, {"Smart", "Width", "Height", "Default"})
	if resetToDefault(manga, key) then
		save(manga, key)
	end
end
