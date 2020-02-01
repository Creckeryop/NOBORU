Cache = {}
local Keys = {}
local Order = {}
local Task = nil
local Downloading = {}

local function key(chapter)
    return string.gsub(chapter.Manga.ParserID .. chapter.Manga.Link .. chapter.Link, "%p", "")
end

function Cache.update()
    if #Order == 0 and Task == nil then return end
    if not Task then
        Task = table.remove(Order, 1)
        Task.F = coroutine.create(Task.F)
    else
        if coroutine.status(Task.F) ~= "dead" then
            local _, msg, page, page_count = coroutine.resume(Task.F)
            if _ then
                if msg then
                    if msg == "update_count" then
                        Task.page = page
                        Task.page_count = page_count
                    end
                    if Task.Destroy then
                        Notifications.push(string.format(Language[LANG].NOTIFICATIONS.CANCEL_DOWNLOAD, Task.MangaName, Task.ChapterName))
                        Task = nil
                    end
                end
            else
                Console.error("Unknown error with cache: "..msg)
                Task = nil
            end
        else
            Notifications.push(string.format(Language[LANG].NOTIFICATIONS.END_DOWNLOAD, Task.MangaName, Task.ChapterName))
            Task = nil
        end
    end
end

function Cache.download(chapter)
    local k = key(chapter)
    if not System.doesDirExist("ux0:data/noboru/cache/" .. k) then
        System.createDirectory("ux0:data/noboru/cache/" .. k)
    end
    Downloading[k] = {
        Key = k,
        MangaName = chapter.Manga.Name,
        ChapterName = chapter.Name,
        F = function()
            local t = {}
            local connection = Threads.netActionUnSafe(Network.isWifiEnabled)
            if connection then
                ParserManager.prepareChapter(chapter, t)
            else
                Notifications.push(Language[LANG].NOTIFICATIONS.NET_PROBLEM)
                Downloading[k] = nil
                return
            end
            while ParserManager.check(t) do
                coroutine.yield("update_count", 0, 0)
            end
            local parser = GetParserByID(chapter.Manga.ParserID)
            for i = 1, #t do
                coroutine.yield("update_count", i, #t)
                local result = {}
                parser:loadChapterPage(t[i], result)
                coroutine.yield(false)
                Threads.insertTask(result, {
                    Type = "FileDownload",
                    Link = result.Link,
                    Path = string.format("cache/%s/%s.image", k, i)
                })
                while Threads.check(result) do
                    coroutine.yield(false)
                end
            end
            local fh = System.openFile("ux0:data/noboru/cache/" .. k .. "/done.txt", FCREATE)
            System.writeFile(fh, #t, string.len(#t))
            System.closeFile(fh)
            Keys[k] = true
            Cache.save()
            Downloading[k] = nil
        end
    }
    Order[#Order + 1] = Downloading[k]
    Notifications.push(string.format(Language[LANG].NOTIFICATIONS.START_DOWNLOAD, chapter.Manga.Name,chapter.Name))
end

function Cache.is_download_running()
    return Task~=nil or #Order > 0
end

local function stop(key)
    if Downloading[key] then
        if Downloading[key] == Task then
            Downloading[key].Destroy = true
            RemoveDirectory("ux0:data/noboru/cache/"..key)
        else
            for i, v in ipairs(Order) do
                if v == Downloading[key] then
                    Notifications.push(string.format(Language[LANG].NOTIFICATIONS.CANCEL_DOWNLOAD, Order[i].MangaName, Order[i].ChapterName))
                    table.remove(Order, i)
                    break
                end
            end
        end
        Downloading[key] = nil
    end
end

function Cache.stop(chapter)
    if chapter then stop(key(chapter)) end
end

function Cache.stopByListItem(item)
    if item.Key then stop(item.Key) end
end

function Cache.delete(chapter)
    local k = key(chapter)
    if Keys[k] then
        RemoveDirectory("ux0:data/noboru/cache/"..k)
        Keys[k] = nil
        Cache.save()
        Notifications.push(string.format(Language[LANG].NOTIFICATIONS.CHAPTER_REMOVE, k))
    end
end

function Cache.getDownloadingList()
    local list = {}
    if Task~=nil then
        list[#list+1] = { Manga = Task.MangaName, Chapter = Task.ChapterName, page = Task.page or 0, page_count = Task.page_count or 0, Key = Task.Key }
    end
    for i = 1, #Order do
        list[#list+1] = { Manga = Order[i].MangaName, Chapter = Order[i].ChapterName, page = 0, page_count = 0, Key = Order[i].Key }
    end
    return list
end

function Cache.check(chapter)
    return Keys[key(chapter)] == true
end

function Cache.is_downloading(chapter)
    return Downloading[key(chapter)]
end

function Cache.getChapter(chapter)
    local k = key(chapter)
    if Keys[k] then
        local pathes = {}
        local pages = #System.listDirectory("ux0:data/noboru/cache/" .. k) - 1
        for i = 1, pages do
            pathes[i] = {
                Path = "cache/" .. k .. "/" .. i .. ".image"
            }
        end
        pathes.Done = true
        return pathes
    end
    return {
        Done = true
    }
end

function Cache.save()
    if System.doesFileExist("ux0:data/noboru/c.c") then
        System.deleteFile("ux0:data/noboru/c.c")
    end
    local fh = System.openFile("ux0:data/noboru/c.c", FCREATE)
    local save_data = table.serialize(Keys, "Keys")
    System.writeFile(fh, save_data, save_data:len())
    System.closeFile(fh)
end

function Cache.load()
    if System.doesFileExist("ux0:data/noboru/c.c") then
        local fh = System.openFile("ux0:data/noboru/c.c", FREAD)
        local keys = load("local " .. System.readFile(fh, System.sizeFile(fh)) .. " return Keys")()
        for k, _ in pairs(keys) do
            if System.doesFileExist("ux0:data/noboru/cache/" .. k .. "/done.txt") then
                local fh_2 = System.openFile("ux0:data/noboru/cache/" .. k .. "/done.txt", FREAD)
                local pages = System.readFile(fh_2, System.sizeFile(fh_2))
                System.closeFile(fh_2)
                if tonumber(pages) == #System.listDirectory("ux0:data/noboru/cache/" .. k) - 1 then
                    Keys[k] = true
                else
                    Notifications.push("cache_error " .. k)
                end
            else
                Notifications.push("cache_error " .. k)
            end
        end
        System.closeFile(fh)
        Cache.save()
    end
end
