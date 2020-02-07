Cache = {}

local data = {}
local history = {}

local function get_key(Manga)
    return (Manga.ParserID .. Manga.Link):gsub("%p", "")
end

function Cache.addManga(Manga, Chapters)
    local key = get_key(Manga)
    if not data[key] then
        data[key] = Manga
        Manga.Path = "cache/" .. key .. "/cover.image"
        if not System.doesDirExist("ux0:data/noboru/cache/" .. key) then
            System.createDirectory("ux0:data/noboru/cache/" .. key)
        end
        if System.doesFileExist("ux0:data/noboru/cache/" .. key .. "/cover.image") then
            System.deleteFile("ux0:data/noboru/cache/" .. key .. "/cover.image")
        end
        if Chapters then
            Cache.saveChapters(Manga, Chapters)
        end
        Threads.insertTask(tostring(Manga) .. "coverDownload", {
            Type = "FileDownload",
            Path = "cache/" .. key .. "/cover.image",
            Link = Manga.ImageLink
        })
        Cache.save()
    end
end

local updated = false
function Cache.makeHistory(Manga)
    local key = get_key(Manga)
    for i, v in ipairs(history) do
        if v == key then
            table.remove(history, i)
            break
        end
    end
    table.insert(history, 1, key)
    Cache.saveHistory()
    updated = true
end

function Cache.removeHistory(Manga)
    local key = get_key(Manga)
    for i, v in ipairs(history) do
        if v == key then
            table.remove(history, i)
            break
        end
    end
    Cache.saveHistory()
    updated = true
end

local cached_history = {}
function Cache.getHistory()
    if updated then
        local new_history = {}
        for k, v in ipairs(history) do
            if data[v] then
                new_history[#new_history + 1] = data[v]
            end
        end
        updated = false
        cached_history = new_history
    end
    return cached_history
end

function Cache.saveHistory()
    if System.doesFileExist("ux0:data/noboru/cache/history.dat") then
        System.deleteFile("ux0:data/noboru/cache/history.dat")
    end
    local fh = System.openFile("ux0:data/noboru/cache/history.dat", FCREATE)
    local serialized_history = "local " .. table.serialize(history, "history") .. "\nreturn history"
    System.writeFile(fh, serialized_history, serialized_history:len())
    System.closeFile(fh)
end

function Cache.loadHistory()
    if System.doesFileExist("ux0:data/noboru/cache/history.dat") then
        local fh = System.openFile("ux0:data/noboru/cache/history.dat", FREAD)
        local suc, new_history = pcall(function() return load(System.readFile(fh, System.sizeFile(fh)))() end)
        System.closeFile(fh)
        if suc then
            history = new_history
        end
    end
    Cache.saveHistory()
    updated = true
end

function Cache.isCached(Manga)
    return Manga and data[get_key(Manga)] ~= nil or false
end

function Cache.saveChapters(Manga, Chapters)
    local key = get_key(Manga)
    local path = "ux0:data/noboru/cache/" .. key .. "/chapters.dat"
    if System.doesFileExist(path) then
        System.deleteFile(path)
    end
    local chlist = {}
    for i = 1, #Chapters do
        chlist[i] = {}
        for k, v in pairs(Chapters[i]) do
            chlist[i][k] = k == "Manga" and "10101010101010" or v
        end
    end
    local fh = System.openFile(path, FCREATE)
    local serialized_chlist = "local " .. table.serialize(chlist, "chlist") .. "\nreturn chlist"
    System.writeFile(fh, serialized_chlist, serialized_chlist:len())
    System.closeFile(fh)
end

function Cache.loadChapters(Manga)
    local key = get_key(Manga)
    if data[key] then
        if System.doesFileExist("ux0:data/noboru/cache/" .. key .. "/chapters.dat") then
            local fh = System.openFile("ux0:data/noboru/cache/" .. key .. "/chapters.dat", FREAD)
            local suc, new_chlist = pcall(function()
                local content = System.readFile(fh, System.sizeFile(fh))
                return load(content:gsub("\"10101010101010\"", "..."))(data[key])
            end)
            System.closeFile(fh)
            if suc then
                return new_chlist
            else
                Console.error(new_chlist)
            end
        end
    end
    return {}
end

function Cache.load()
    data = {}
    if System.doesFileExist("ux0:data/noboru/cache/info.txt") then
        local fh = System.openFile("ux0:data/noboru/cache/info.txt", FREAD)
        local suc, new_data = pcall(function() return load(System.readFile(fh, System.sizeFile(fh)))() end)
        if suc then
            for k, v in pairs(new_data) do
                if System.doesDirExist("ux0:data/noboru/cache/" .. k) then
                    if System.doesFileExist("ux0:data/noboru/" .. v.Path) then
                        local f = System.openFile("ux0:data/noboru/" .. v.Path, FREAD)
                        local image_size = System.sizeFile(f)
                        System.closeFile(f)
                        if image_size < 100 then
                            System.deleteFile("ux0:data/noboru/" .. v.Path)
                            Notifications.push("image_error " .. v.Path)
                        end
                    end
                    data[k] = v
                end
            end
        end
    end
    Cache.save()
end

function Cache.save()
    if System.doesFileExist("ux0:data/noboru/cache/info.txt") then
        System.deleteFile("ux0:data/noboru/cache/info.txt")
    end
    local fh = System.openFile("ux0:data/noboru/cache/info.txt", FCREATE)
    local save_data = {}
    for k, v in pairs(data) do
        save_data[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink)
        save_data[k].Data = v.Data
        save_data[k].Path = "cache/" .. k .. "/cover.image"
    end
    local serialized_data = "local " .. table.serialize(save_data, "data") .. "\nreturn data"
    System.writeFile(fh, serialized_data, serialized_data:len())
    System.closeFile(fh)
end

function Cache.clear(mode)
    mode = mode or "notlibrary"
    if mode == "notlibrary" then
        local d = System.listDirectory("ux0:data/noboru/cache")
        for k, v in ipairs(d) do
            if not Database.checkByKey(v.name) and v.directory then
                RemoveDirectory("ux0:data/noboru/cache/" .. v.name)
                data[v.name] = nil
            end
        end
        local new_history = {}
        for i = 1, #history do
            if data[history[i]] then
                new_history[#new_history + 1] = history[i]
            end
        end
        history = new_history
    elseif mode == "all" then
        RemoveDirectory("ux0:data/noboru/cache")
        System.createDirectory("ux0:data/noboru/cache")
        data = {}
        history = {}
    end
    Cache.saveHistory()
    updated = true
    Cache.save()
end
