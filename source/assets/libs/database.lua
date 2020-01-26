local base = {}

Database = {}

function Database.getMangaList()
    local b = {}
    for k, v in ipairs(base) do
        b[k] = v
    end
    return b
end

function Database.add(manga)
    if not base[manga.ParserID .. manga.Link] then
        base[#base+1] = manga
        base[manga.ParserID .. manga.Link] = #base
    end
end

function Database.check(manga)
    return base[manga.ParserID .. manga.Link] ~= nil
end

function Database.remove(manga)
    if base[manga.ParserID .. manga.Link] then
        local n = base[manga.ParserID .. manga.Link]
        table.remove(base, n)
        base[manga.ParserID .. manga.Link] = nil
        for i = n, #base do
            base[base[i].ParserID .. base[i].Link] = base[base[i].ParserID .. base[i].Link] - 1
        end
    end
end

function Database.save()
    local manga_table = {}
    for k, v in ipairs(base) do
        manga_table[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink)
        manga_table[k].Data = v.Data
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

function Database.load()
    if System.doesFileExist("ux0:data/noboru/save.dat") then
        local f = System.openFile("ux0:data/noboru/save.dat", FREAD)
        base = load("local "..System.readFile(f, System.sizeFile(f)) .. " return base")()
        System.closeFile(f)
    end
end