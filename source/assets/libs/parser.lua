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
    local message = 'Parser "' .. Name .. '" ' .. (parserTable[ID] and "Updated!" or "Loaded!") .. '!'
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
        if (Settings.NSFW and v.NSFW or not v.NSFW) and not v.Disabled and (Settings.ParserLanguage == "DIF" or v.Lang == Settings.ParserLanguage) then
            list[#list + 1] = v
        end
    end
    cachedList = list
    table.sort(list, function(a, b)
        if a.isChanged ~= b.isChanged then
            return a.isChanged > b.isChanged
        else
            return a.Name < b.Name
        end
    end)
    return list
end

function GetParserLanguages()
    local t = {}
    for _, v in pairs(parserTable) do
        if not v.Disabled then
            t[v.Lang] = true
        end
    end
    t["DIF"] = nil
    local new_t = {}
    for k, _ in pairs(t) do
        new_t[#new_t + 1] = k
    end
    table.sort(new_t, function(a, b) return a < b end)
    table.insert(new_t, 1, "DIF")
    return new_t
end

---Sets update flag to `true`, for regenerating parsers list
function ChangeNSFW()
    updated = true
end

---Deletes all parsers and their files
function ClearParsers()
    if doesDirExist("ux0:data/noboru/parsers") then
        local list = listDirectory("ux0:/data/noboru/parsers") or {}
        for _, v in ipairs(list) do
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
    updated = true
end
