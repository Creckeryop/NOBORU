Database = {}

---@type table
---Local table that stores all mangas that is in database
local base = {}

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local doesDirExist = System.doesDirExist

local function get_key(Manga)
    return (Manga.ParserID .. Manga.Link):gsub("%p", "")
end

---Gets Manga list from database
function Database.getMangaList()
    local b = {}
    local uma0_flag = doesDirExist("uma0:data/noboru")
    for k, v in ipairs(base) do
        if v.Location ~= "uma0" or uma0_flag then
            b[#b + 1] = v
        end
    end
    if Settings.LibrarySorting == "A-Z" then
        table.sort(b, function(a, b)
            return a.Name < b.Name
        end)
    elseif Settings.LibrarySorting == "Z-A" then
        table.sort(b, function(a, b)
            return a.Name > b.Name
        end)
    end
    return b
end

---@param manga table
---Adds `manga` to database
function Database.add(manga)
    local key = get_key(manga)
    if not base[key] then
        base[#base + 1] = manga
        base[key] = #base
        Database.save()
    end
end

---@param manga table
---Checks if `manga` is in database
function Database.check(manga)
    return base[get_key(manga)] ~= nil
end

function Database.checkByKey(key)
    return base[key] ~= nil
end

---@param manga table
---Removes `manga` from database
function Database.remove(manga)
    local key = get_key(manga)
    if base[key] then
        local n = base[key]
        table.remove(base, n)
        base[key] = nil
        for i = n, #base do
            local k = get_key(base[i])
            base[k] = base[k] - 1
        end
        Database.save()
    end
end

---Saves database to `ux0:data/noboru/save.dat`
function Database.save()
    local manga_table = {}
    for k, v in ipairs(base) do
        local key = get_key(v)
        manga_table[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink, v.BrowserLink)
        manga_table[k].Data = v.Data
        manga_table[k].Path = "cache/" .. key .. "/cover.image"
        manga_table[k].Location = v.Location or "ux0"
        manga_table[key] = k
    end
    local save = "return " .. table.serialize(manga_table, true)
    if doesFileExist("ux0:data/noboru/save.dat") then
        deleteFile("ux0:data/noboru/save.dat")
    end
    local f = openFile("ux0:data/noboru/save.dat", FCREATE)
    writeFile(f, save, #save)
    closeFile(f)
end

---Loads database from `ux0:data/noboru/save.dat`
function Database.load()
    if doesFileExist("ux0:data/noboru/save.dat") then
        local f = openFile("ux0:data/noboru/save.dat", FREAD)
        local load_data = load(readFile(f, sizeFile(f)))
        closeFile(f)
        if load_data then
            base = load_data() or {}
        end
    end
    Database.save()
end

function Database.clear()
    base = {}
    Database.save()
end
