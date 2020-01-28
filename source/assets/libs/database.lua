Database = {}

---@type table
---Local table that stores all mangas that is in database
local base = {}

---Gets Manga list from database
function Database.getMangaList()
    local b = {}
    for k, v in ipairs(base) do
        b[k] = v
    end
    return b
end

---@param manga table
---Adds `manga` to database
function Database.add(manga)
    local UniqueKey = manga.ParserID..manga.Link
    if not base[UniqueKey] then
        base[#base + 1] = manga
        base[UniqueKey] = #base
        UniqueKey = UniqueKey:gsub("%p","")
        System.createDirectory("ux0:data/noboru/books/"..UniqueKey)
        Threads.insertTask(tostring(manga).."coverDownload",{
            Type = "FileDownload",
            Path = "books/"..UniqueKey.."/cover.img",
            Link = manga.ImageLink,
            OnComplete = function()
                manga.Path = "books/"..UniqueKey.."/cover.img"
            end
        })
    end
end

---@param manga table
---Checks if `manga` is in database
function Database.check(manga)
    return base[manga.ParserID .. manga.Link] ~= nil
end

---@param manga table
---Removes `manga` from database
function Database.remove(manga)
    local UniqueKey = manga.ParserID..manga.Link
    if base[UniqueKey] then
        local n = base[UniqueKey]
        table.remove(base, n)
        base[UniqueKey] = nil
        UniqueKey = UniqueKey:gsub("%p","")
        deleteFolder("ux0:data/noboru/books/"..UniqueKey)
        for i = n, #base do
            base[base[i].ParserID .. base[i].Link] = base[base[i].ParserID .. base[i].Link] - 1
        end
    end
end

---Saves database to `ux0:data/noboru/save.dat`
function Database.save()
    local manga_table = {}
    for k, v in ipairs(base) do
        manga_table[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink)
        manga_table[k].Data = v.Data
        manga_table[k].Path = v.Path
        manga_table[v.ParserID .. v.Link] = k
    end
    local save = table.serialize(manga_table, "base")
    if System.doesFileExist("ux0:data/noboru/save.dat") then
        System.deleteFile("ux0:data/noboru/save.dat")
    end
    local f = System.openFile("ux0:data/noboru/save.dat", FCREATE)
    System.writeFile(f, save, save:len())
    System.closeFile(f)
end

---Loads database from `ux0:data/noboru/save.dat`
function Database.load()
    if System.doesFileExist("ux0:data/noboru/save.dat") then
        local f = System.openFile("ux0:data/noboru/save.dat", FREAD)
        base = load("local " .. System.readFile(f, System.sizeFile(f)) .. " return base")()
        for k, v in ipairs(base) do
            if v.Path then
                if not System.doesFileExist("ux0:data/noboru/books/"..v.Path) then
                    v.Path = nil
                end
            end
        end
        System.closeFile(f)
    end
end
