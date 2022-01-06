Import = {}

local listDirectory = System.listDirectory
local doesDirExist = System.doesDirExist

local rootPath = "ux0:data/noboru/import/"
local currentPath = rootPath
local directoryList

---@return table
---Gives folder list of opened directory
---Table elements: {`name`: string, `directory`: boolean, `active`: boolean, `size`: number}
function Import.listDir()
	if directoryList == nil then
		local currentImportPath = currentPath:gsub("^ux0:data/noboru/import/uma0:data/noboru/import/", "uma0:data/noboru/import/")
		local list = listDirectory(currentImportPath) or {}
		local newList = {}
		for i = 1, #list do
			local file = list[i]
			file.active = file.directory or file.name:find("%.cbz$") or file.name:find("%.zip$")
			newList[#newList + 1] = file
		end
		if currentPath ~= rootPath then
			table.insert(
				newList,
				1,
				{
					name = "...",
					directory = true,
					active = true,
					size = 0
				}
			)
		elseif doesDirExist("uma0:") then
			table.insert(
				newList,
				1,
				{
					name = "uma0:data/noboru/import",
					directory = true,
					active = false,
					size = 0
				}
			)
		end
		directoryList = newList
	end
	return directoryList
end

---@param item table
---Opens `item` directory / file
function Import.go(item)
	if item.name == "..." and currentPath ~= rootPath then
		Import.back()
	elseif item.directory then
		currentPath = currentPath .. item.name .. "/"
		directoryList = nil
	elseif item.name:find("%.cbz$") or item.name:find("%.zip$") then
		Reader.load(
			{
				{
					FastLoad = true,
					Name = item.name:match("(.*)%..-$"),
					Link = "AABBCCDDEEFFGG",
					Path = currentPath:gsub("^ux0:data/noboru/import/uma0:data/noboru/import/", "uma0:data/noboru/import/") .. item.name,
					Pages = {},
					Manga = {
						Name = item.name:match("(.*)%..-$"),
						Link = "AABBCCDDEEFFGG",
						ImageLink = "",
						ParserID = "IMPORTED"
					}
				}
			},
			1
		)
		AppMode = READER
	end
end

---@param item table
---@return boolean
---Gives `true` if selected `item` is importable
function Import.canImport(item)
	return item.name ~= "..." and item.active
end

---@param item table
---@return string
---Returns full filepath of given item
function Import.getPath(item)
	return item and currentPath:gsub("^ux0:data/noboru/import/uma0:data/noboru/import/", "uma0:data/noboru/import/") .. item.name
end

---Go parent directory of current directory if it is possible
function Import.back()
	if currentPath ~= rootPath then
		if currentPath == "ux0:data/noboru/import/uma0:data/noboru/import/" then
			currentPath = "ux0:data/noboru/import/"
		else
			currentPath = currentPath:match("(.*/).-/$")
		end
		directoryList = nil
	end
end

---@return boolean
---Says does current directory has accessible parent directory
function Import.canBack()
	return currentPath ~= rootPath
end
