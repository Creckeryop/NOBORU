---@class Parser
Parser = {
	getLatestManga = nil,
	getPopularManga = nil,
	getChapters = nil,
	prepareChapter = nil,
	loadChapterPage = nil,
	getMangaUrl = nil
}

---Hash table with all parsers
local parserTable = {}
---Cached Parser List
local cachedList = {}

---Local variable used in Parser functions
local is_parsers_list_updated = false

local listDirectory = System.listDirectory
local doesDirExist = System.doesDirExist
local deleteFile = System.deleteFile

---@param Name string
---@param Link string
---@param Lang string
---@param ID integer
---@return Parser
---Creates/Updates Parser Object
function Parser:new(Name, Link, Lang, ID, Version)
	local p = {
		Name = Name,
		Link = Link,
		Lang = Lang,
		ID = ID,
		Version = Version or 0,
		isChanged = 0,
		Disabled = false
	}
	setmetatable(p, self)
	self.__index = self
	if parserTable[ID] and parserTable[ID].Version < p.Version then
		p.isUpdated = true
		p.isChanged = 1
	elseif parserTable[ID] == nil and LAUNCHED then
		p.isNew = true
		p.isChanged = 2
	end
	local message = 'Parser "' .. Name .. '" ' .. (parserTable[ID] and "Updated!" or "Loaded!") .. "!"
	Console.write(message)
	parserTable[ID] = p
	is_parsers_list_updated = true
	return p
end

---@param ID integer
---@return Parser
---Gives Parser Object by `ID`
function GetParserByID(ID)
	return parserTable[ID]
end

---@return table
---Gives Parser List
function GetParserList()
	if not is_parsers_list_updated then
		return cachedList
	end
	is_parsers_list_updated = false
	local list = {}
	for _, v in pairs(parserTable) do
		if (Settings.NSFW and v.NSFW or not v.NSFW) and not v.Disabled then
			list[#list + 1] = v
		end
	end
	cachedList = list
	table.sort(
		list,
		function(a, b)
			if a.isChanged ~= b.isChanged then
				return a.isChanged > b.isChanged
			else
				return string.upper(a.ID) < string.upper(b.ID)
			end
		end
	)
	return list
end

function GetParserRawList()
	local list = {}
	for _, v in pairs(parserTable) do
		if Settings.NSFW and v.NSFW or not v.NSFW then
			list[#list + 1] = v
		end
	end
	table.sort(
		list,
		function(a, b)
			return string.upper(a.ID) < string.upper(b.ID)
		end
	)
	return list
end

---Sets update flag to `true`, for regenerating parsers list
function ChangeNSFW()
	is_parsers_list_updated = true
end

---Deletes all parsers and their files
function ClearParsers()
	if doesDirExist("ux0:data/noboru/parsers") then
		local list = listDirectory("ux0:/data/noboru/parsers") or {}
		for i = 1, #list do
			local v = list[i]
			if not v.directory then
				deleteFile("ux0:data/noboru/parsers/" .. v.name)
			end
		end
	end
	--[[
    parserTable = {}
    cachedList = {}]]
	for _, v in pairs(parserTable) do
		v.Disabled = true
	end
	is_parsers_list_updated = true
end
