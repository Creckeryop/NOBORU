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
function Database.add(manga, chapters)
    local UniqueKey = manga.ParserID .. manga.Link
    if not base[UniqueKey] then
        base[#base + 1] = manga
        base[UniqueKey] = #base
        UniqueKey = UniqueKey:gsub("%p", "")
        base[#base].Path = UniqueKey .. "/cover.img"
        System.createDirectory("ux0:data/noboru/books/" .. UniqueKey)
        Database.updateChapters(base[#base], chapters)
        Threads.insertTask(tostring(manga) .. "coverDownload", {
            Type = "FileDownload",
            Path = "books/" .. UniqueKey .. "/cover.img",
            Link = manga.ImageLink
        })
    end
end

function Database.updateChapters(manga, chapters)
    local UniqueKey = manga.ParserID .. manga.Link
    local n = base[UniqueKey]
    if n then
        local chaps = {}
        for i = 1, #chapters do
            chaps[i] = {}
            for k, v in pairs(chapters[i]) do
                if k == "Manga" then
                    chaps[i][k] = "10101010101010"
                else
                    chaps[i][k] = v
                end
            end
        end
        local chapter_path = "ux0:data/noboru/books/" .. UniqueKey:gsub("%p", "") .. "/chapter_info.lua"
        if System.doesFileExist(chapter_path) then
            System.deleteFile(chapter_path)
        end
        local fh = System.openFile(chapter_path, FCREATE)
        local save_data = table.serialize(chaps, "chapters")
        System.writeFile(fh, save_data, save_data:len())
        System.closeFile(fh)
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
    local UniqueKey = manga.ParserID .. manga.Link
    if base[UniqueKey] then
        local n = base[UniqueKey]
        table.remove(base, n)
        manga.Path = nil
        base[UniqueKey] = nil
        RemoveDirectory("ux0:data/noboru/books/" .. UniqueKey:gsub("%p", ""))
        for i = n, #base do
            base[base[i].ParserID .. base[i].Link] = base[base[i].ParserID .. base[i].Link] - 1
        end
    end
end

---@param manga table
function Database.getChapters(manga)
    local UniqueKey = manga.ParserID .. manga.Link
    local n = base[UniqueKey]
    if n then
        local chapters_path = "ux0:data/noboru/books/" .. UniqueKey:gsub("%p", "") .. "/chapter_info.lua"
        if System.doesFileExist(chapters_path) then
            local f = System.openFile(chapters_path, FREAD)
            local cs = load("local " .. System.readFile(f, System.sizeFile(f)):gsub("\"10101010101010\"", "...") .. " return chapters")(base[n])
            System.closeFile(f)
            return cs
        end
    end
    return {}
end

---Saves database to `ux0:data/noboru/save.dat`
function Database.save()
    local manga_table = {}
    for k, v in ipairs(base) do
        local UniqueKey = v.ParserID .. v.Link
        manga_table[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink)
        manga_table[k].Data = v.Data
        manga_table[k].Path = UniqueKey:gsub("%p", "") .. "/cover.img"
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
        System.closeFile(f)
        for k, v in ipairs(base) do
            if System.doesFileExist("ux0:data/noboru/books/"..v.Path) then
                local fh = System.openFile("ux0:data/noboru/books/"..v.Path, FREAD)
                local image_size = System.sizeFile(fh)
                System.closeFile(fh)
                if image_size < 100 then
                    System.deleteFile("ux0:data/noboru/books/"..v.Path)
                    Notifications.push("image_error "..v.Path)
                end
            end
        end
    end
end
