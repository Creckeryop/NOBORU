---Hash table with all parsers
local parserTable = {}

---@class Parser
Parser = {
    getLatestManga = nil,
    getPopularManga = nil,
    getChapters = nil,
    prepareChapter = nil,
    loadChapterPage = nil,
    getMangaUrl = nil
}

---Local variable used in Parser functions
local updated = false

---@param Name string
---@param Link string
---@param Lang string
---@param ID integer
---@return Parser
---Creates/Updates Parser Object
function Parser:new(Name, Link, Lang, ID)
    local p = {
        Name = Name,
        Link = Link,
        Lang = Lang,
        ID = ID
    }
    setmetatable(p, self)
    self.__index = self
    local message = string.format('Parser "%s" %s!', Name, parserTable[ID] and "Updated!" or "Loaded!")
    Console.write(message)
    parserTable[ID] = p
    updated = true
    return p
end

---@param ID integer
---@return Parser
---Gives Parser Object by `ID`
function GetParserByID(ID)
    return parserTable[ID]
end

---Cached Parser List
local cachedList = {}

---@return table
---Gives Parser List
function GetParserList()
    if not updated then return cachedList end
    updated = false
    local list = {}
    for _, v in pairs(parserTable) do
        list[#list + 1] = v
    end
    cachedList = list
    return list
end

function ClearParsers()
    if System.doesDirExist("ux0:data/noboru/parsers") then
        local list = System.listDirectory("ux0:/data/noboru/parsers")
        for _, v in ipairs(list) do
            if not v.is_directory then
                System.deleteFile("ux0:data/noboru/parsers/" .. v.name)
            end
        end
    end
    parserTable = {}
    cachedList = {}
end
