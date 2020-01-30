Cache = {}

local Order = {}
local Task = nil

local function key(chapter)
    return string.gsub(chapter.Manga.ParserID..chapter.Manga.Link..chapter.Link, "%p", "")
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
    if not System.doesDirExist("ux0:data/noboru/cache/"..k) then
        System.createDirectory("ux0:data/noboru/cache/"..k) 
    end
    Order[#Order+1] = {
        Key = k,
        F = function()
            local t = {}
            ParserManager.prepareChapter(chapter, t)
            while ParserManager.check(t) do
                coroutine.yield(0)
            end
            local parser = GetParserByID(chapter.Manga.ParserID)
            for i = 1, #t do
                coroutine.yield(i/#t)
                local result = {}
                parser:loadChapterPage(t[i], result)
                coroutine.yield(i/#t)
                Threads.insertTask(result, {
                    Type = "FileDownload",
                    Link = result.Link,
                    Path = string.format("cache/%s/%s.image", k, i)
                })
                while Threads.check(result) do
                    coroutine.yield(i/#t)
                end
            end
            local fh = System.openFile("ux0:data/noboru/cache/"..k.."/done.txt", FCREATE)
            System.closeFile(fh)
        end
    }
end

function Cache.check(chapter)
    return System.doesFileExist("ux0:data/noboru/cache/"..key(chapter).."/done.txt")
end

function Cache.getChapter(chapter)
    local k = key(chapter)
    local path = "ux0:data/noboru/cache/"..k
    if System.doesFileExist(path.."/done.txt") then
        local pathes = {}
        local pages = #System.listDirectory(path) - 1
        for i = 1, pages do
            pathes[i] = {
                Path = "cache/"..k.."/"..i..".image"
            }
        end
        pathes.Done = true
        return pathes
    end
    return {
        Done = true
    }
end