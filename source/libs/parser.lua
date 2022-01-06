---@class Parser
Parser = {
	getLatestManga = nil,
	getPopularManga = nil,
	getChapters = nil,
	prepareChapter = nil,
	loadChapterPage = function(self, link, dt)
		dt.Link = link
	end
}

---Hash table with all parsers
local parserTable = {}
---Cached Parser List
local cachedList = {}

---Local variable used in Parser functions
local isParsersListUpdated = false

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

local sortFunction = function(a, b)
	if a.Type == b.Type then
		local aLang = type(a.Language) == "table" and "DIF" or a.Language
		local bLang = type(b.Language) == "table" and "DIF" or b.Language
		local scoreA = GetLanguagePriority(aLang)
		local scoreB = GetLanguagePriority(bLang)
		if scoreA == scoreB then
			if aLang == bLang then
				return string.upper(a.ID) < string.upper(b.ID)
			else
				return aLang < bLang
			end
		else
			return scoreA < scoreB
		end
	else
		return a.Type < b.Type
	end
end

---@return table
---Gives Parser List
function GetParserList()
	if not isParsersListUpdated then
		return cachedList
	end
	isParsersListUpdated = false
	local list = {}
	for _, v in pairs(parserTable) do
		if Settings.NSFW or not v.NSFW then
			list[#list + 1] = v
		end
	end
	cachedList = list
	table.sort(list, sortFunction)
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
	isParsersListUpdated = true
end

function LoadParser(id, parser)
	Console.write('Parser "' .. parser.Name .. '" ' .. "Loaded!")
	parserTable[id] = parser
	isParsersListUpdated = true
end

function UnloadParser(id)
	if parserTable[id] then
		parserTable[id] = nil
		isParsersListUpdated = true
	end
end
