Cache = {}
local Keys = {}
local Order = {}
local Task = nil
local Downloading = {}

---Path to cache folder
local FOLDER = "ux0:data/noboru/cache/"

---@return string
---Creates key for a chapter from it's Manga's `parserID`, `Link` and chapter `Link`
local function key(chapter)
    return string.gsub(chapter.Manga.ParserID .. chapter.Manga.Link .. chapter.Link, "%p", "")
end

---Updates Cache things
function Cache.update()
    if #Order == 0 and Task == nil then return end
    if not Task then
        Task = table.remove(Order, 1)
        Task.F = coroutine.create(Task.F)
    else
        if coroutine.status(Task.F) ~= "dead" then
            local _, msg, var1, var2 = coroutine.resume(Task.F)
            if _ then
                if Task.Destroy and msg then
                    Notifications.push(string.format(Language[LANG].NOTIFICATIONS.CANCEL_DOWNLOAD, Task.MangaName, Task.ChapterName))
                    Task = nil
                elseif msg == "update_count" then
                    Task.page = var1
                    Task.page_count = var2
                end
            else
                Console.error("Unknown error with cache: " .. msg)
                Task = nil
            end
        else
            Notifications.push(string.format(Language[LANG].NOTIFICATIONS.END_DOWNLOAD, Task.MangaName, Task.ChapterName))
            Task = nil
        end
    end
end

---@param chapter table
---Creates task for downloading `chapter`
function Cache.downloadChapter(chapter)
    local k = key(chapter)
    if not System.doesDirExist(FOLDER .. k) then
        System.createDirectory(FOLDER .. k)
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
                    Path = "cache/"..k.."/"..i..".image"
                })
                while Threads.check(result) do
                    coroutine.yield(false)
                end
            end
            local fh = System.openFile(FOLDER .. k .. "/done.txt", FCREATE)
            System.writeFile(fh, #t, string.len(#t))
            System.closeFile(fh)
            Keys[k] = true
            Cache.save()
            Downloading[k] = nil
        end
    }
    Order[#Order + 1] = Downloading[k]
    Notifications.push(string.format(Language[LANG].NOTIFICATIONS.START_DOWNLOAD, chapter.Manga.Name, chapter.Name))
end

---@return boolean
---Gives info if download is running
function Cache.is_download_running()
    return Task ~= nil or #Order > 0
end

---@param key string
---Stops task by it's key
local function stop(key)
    if Downloading[key] then
        if Downloading[key] == Task then
            Downloading[key].Destroy = true
            RemoveDirectory(FOLDER .. key)
        else
            local new_order = {}
            for _, v in ipairs(Order) do
                if v == Downloading[key] then
                    Notifications.push(string.format(Language[LANG].NOTIFICATIONS.CANCEL_DOWNLOAD, v.MangaName, v.ChapterName))
                else
                    new_order[#new_order + 1] = v
                end
            end
            Order = new_order
        end
        Downloading[key] = nil
    end
end

---@param chapter table
---Stops `chapter` downloading
function Cache.stop(chapter)
    if chapter then stop(key(chapter)) end
end

---@param item table
---Stops `chapter` downloading by List item from `Cache.getDownloadingList` function
function Cache.stopByListItem(item)
    if item then stop(item.Key) end
end

---@param chapter table
---Deletes cache of downloaded chapter
function Cache.delete(chapter)
    local k = key(chapter)
    if Keys[k] then
        RemoveDirectory(FOLDER .. k)
        Keys[k] = nil
        Cache.save()
        Notifications.push(string.format(Language[LANG].NOTIFICATIONS.CHAPTER_REMOVE, k))
    end
end

---@return table
---Returns all active downloadings
function Cache.getDownloadingList()
    local list = {}
    Order[0] = Task
    for i = Task and 0 or 1, #Order do
        local task = Order[i]
        list[#list + 1] = {
            Manga = task.MangaName,
            Chapter = task.ChapterName,
            page = task.page or 0,
            page_count = task.page_count or 0,
            Key = task.Key
        }
    end
    return list
end

---@param chapter table
---@return boolean
---Gives `true` if chapter is downloaded
function Cache.check(chapter)
    return Keys[key(chapter)] == true
end


---@param chapter table
---@return boolean
---Gives `true` if chapter is downloading
function Cache.is_downloading(chapter)
    return Downloading[key(chapter)]
end


---@param chapter table
---@return table
---Gives table with all pathes to cached images
function Cache.getChapter(chapter)
    local k = key(chapter)
    local table = {Done = true}
    if Keys[k] then
        local pages = #System.listDirectory(FOLDER .. k) - 1
        for i = 1, pages do
            table[i] = {
                Path = "cache/" .. k .. "/" .. i .. ".image"
            }
        end
    end
    return table
end

---Saves cache changes
function Cache.save()
    if System.doesFileExist("ux0:data/noboru/c.c") then
        System.deleteFile("ux0:data/noboru/c.c")
    end
    local fh = System.openFile("ux0:data/noboru/c.c", FCREATE)
    local save_data = table.serialize(Keys, "Keys")
    System.writeFile(fh, save_data, save_data:len())
    System.closeFile(fh)
end

---Loads cache changes
function Cache.load()
    Keys = {}
    if System.doesFileExist("ux0:data/noboru/c.c") then
        local fh = System.openFile("ux0:data/noboru/c.c", FREAD)
        local suc, keys = pcall(load("local " .. System.readFile(fh, System.sizeFile(fh)) .. " return Keys"))
        if suc then
            for k, _ in pairs(keys) do
                if System.doesFileExist(FOLDER .. k .. "/done.txt") then
                    local fh_2 = System.openFile(FOLDER .. k .. "/done.txt", FREAD)
                    local pages = System.readFile(fh_2, System.sizeFile(fh_2))
                    System.closeFile(fh_2)
                    if tonumber(pages) == #System.listDirectory(FOLDER .. k) - 1 then
                        Keys[k] = true
                    else
                        Notifications.push("cache_error " .. k)
                    end
                else
                    Notifications.push("cache_error " .. k)
                end
            end
        end
        System.closeFile(fh)
        Cache.save()
    end
end
