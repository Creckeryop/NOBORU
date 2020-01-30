Cache = {}
local Keys = {}
local Order = {}
local Task = nil

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
            local _, precentage, safe = coroutine.resume(Task.F)
            if _ then
                Task.status = precentage
            end
        else
            Notifications.push("Done!")
            Task = nil
        end
    end
end

function Cache.download(chapter)
    local k = key(chapter)
    if not System.doesDirExist("ux0:data/noboru/cache/" .. k) then
        System.createDirectory("ux0:data/noboru/cache/" .. k)
    end
    Order[#Order + 1] = {
        Key = k,
        F = function()
            local t = {}
            ParserManager.prepareChapter(chapter, t)
            while ParserManager.check(t) do
                coroutine.yield(0)
            end
            local parser = GetParserByID(chapter.Manga.ParserID)
            for i = 1, #t do
                coroutine.yield(i / #t)
                local result = {}
                parser:loadChapterPage(t[i], result)
                coroutine.yield(i / #t)
                Threads.insertTask(result, {
                    Type = "FileDownload",
                    Link = result.Link,
                    Path = string.format("cache/%s/%s.image", k, i)
                })
                while Threads.check(result) do
                    coroutine.yield(i / #t)
                end
            end
            local fh = System.openFile("ux0:data/noboru/cache/" .. k .. "/done.txt", FCREATE)
            System.writeFile(fh, #t, string.len(#t))
            System.closeFile(fh)
            Keys[k] = true
            Cache.save()
        end
    }
end

function Cache.check(chapter)
    return Keys[key(chapter)] == true
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
            end
        end
        System.closeFile(fh)
        Cache.save()
    end
end
