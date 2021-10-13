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

---@param Name string
---@param Link string
---@param Language string
---@param ID string
---@param ExtID string
---@return Parser
---Creates/Updates Parser Object
function Parser:new(Name, Link, Language, ID, ExtID)
	local p = {
		Name = Name,
		Link = Link,
		Language = Language,
		ID = ID,
		ExtID = ExtID
	}
	setmetatable(p, self)
	self.__index = self
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
		if Settings.NSFW or not v.NSFW then
			list[#list + 1] = v
		end
	end
	cachedList = list
	table.sort(
		list,
		function(a, b)
			return string.upper(a.ID) < string.upper(b.ID)
		end
	)
	return list
end

function GetLanguagePriority(code)
	if code == "DIF" then
		return 0
	elseif Language[Settings.Language].Code == code then
		return 1
	else
		return 2
	end
end

---Sets update flag to `true`, for regenerating parsers list
function ChangeNSFW()
	is_parsers_list_updated = true
end

function LoadParser(id, parser)
	Console.write('Parser "' .. parser.Name .. '" ' .. "Loaded!")
	parserTable[id] = parser
	is_parsers_list_updated = true
end

function UnloadParser(id)
	if parserTable[id] then
		parserTable[id] = nil
		is_parsers_list_updated = true
	end
end