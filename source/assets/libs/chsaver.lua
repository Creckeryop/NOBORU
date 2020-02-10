ChapterSaver = {}
local Keys = {}
local Order = {}
local Task = nil
local Downloading = {}

---Path to saved chapters folder
local FOLDER = "ux0:data/noboru/chapters/"

local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local doesDirExist = System.doesDirExist
local createDirectory = System.createDirectory
local listDirectory = System.listDirectory
local rem_dir = RemoveDirectory

---@return string
---Creates key for a chapter from it's Manga's `parserID`, `Link` and chapter `Link`
local function key(chapter)
    return (chapter.Manga.ParserID .. chapter.Manga.Link):gsub("%p", "") .. "_" .. chapter.Link:gsub("%p", "")
end

ChapterSaver.getKey = key

---Updates Cache things
function ChapterSaver.update()
    if #Order == 0 and Task == nil then return end
    if not Task then
        Task = table.remove(Order, 1)
        Task.F = coroutine.create(Task.F)
    else
        if coroutine.status(Task.F) ~= "dead" then
            local _, msg, var1, var2 = coroutine.resume(Task.F)
            if _ then
                if Task.Destroy and msg then
                    Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.CANCEL_DOWNLOAD, Task.MangaName, Task.ChapterName))
                    Task = nil
                elseif msg == "update_count" then
                    Task.page = var1
                    Task.page_count = var2
                end
            else
                Console.error("Unknown error with saved chapters: " .. msg)
                Task = nil
            end
        else
            Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.END_DOWNLOAD, Task.MangaName, Task.ChapterName))
            Task = nil
        end
    end
end

local notify = true

---@param chapter table
---Creates task for downloading `chapter`
function ChapterSaver.downloadChapter(chapter)
    local k = key(chapter)
    if not doesDirExist(FOLDER .. k) then
        createDirectory(FOLDER .. k)
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
                Notifications.push(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM)
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
                local retry = 0
                while retry < 3 do
                    Threads.insertTask(result, {
                        Type = "FileDownload",
                        Link = result.Link,
                        Path = "chapters/" .. k .. "/" .. i .. ".image"
                    })
                    while Threads.check(result) do
                        coroutine.yield(false)
                    end
                    if doesFileExist("ux0:data/noboru/chapters/" .. k .. "/" .. i .. ".image") then
                        local size = System.getPictureResolution("ux0:data/noboru/chapters/" .. k .. "/" .. i .. ".image")
                        if not size or size <= 0 then
                            Console.error("error loading picture for " .. k .. " " .. i)
                            retry = retry + 1
                            if retry < 3 then
                                Console.error("retrying")
                            end
                        else
                            break
                        end
                    else
                        retry = retry + 1
                    end
                end
                if retry == 3 then
                    Notifications.push(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM)
                    rem_dir("ux0:data/noboru/chapters/" .. k)
                    Downloading[k] = nil
                    return
                end
            end
            local fh = openFile(FOLDER .. k .. "/done.txt", FCREATE)
            writeFile(fh, #t, string.len(#t))
            closeFile(fh)
            Keys[k] = true
            ChapterSaver.save()
            Downloading[k] = nil
        end
    }
    Order[#Order + 1] = Downloading[k]
    Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.START_DOWNLOAD, chapter.Manga.Name, chapter.Name))
end

---@return boolean
---Gives info if download is running
function ChapterSaver.is_download_running()
    return Task ~= nil or #Order > 0
end

---@param key string
---Stops task by it's key
local function stop(key)
    if Downloading[key] then
        if Downloading[key] == Task then
            Downloading[key].Destroy = true
        else
            local new_order = {}
            for _, v in ipairs(Order) do
                if v == Downloading[key] then
                    if notify then
                        Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.CANCEL_DOWNLOAD, v.MangaName, v.ChapterName))
                    end
                else
                    new_order[#new_order + 1] = v
                end
            end
            Order = new_order
        end
        Downloading[key] = nil
        rem_dir(FOLDER .. key)
    end
end

---@param chapter table
---Stops `chapter` downloading
function ChapterSaver.stop(chapter)
    if chapter then stop(key(chapter)) end
end

---@param item table
---Stops `chapter` downloading by List item from `Cache.getDownloadingList` function
function ChapterSaver.stopByListItem(item)
    if item then stop(item.Key) end
end

---@param chapter table
---Deletes saved chapter
function ChapterSaver.delete(chapter)
    local k = key(chapter)
    if Keys[k] then
        rem_dir(FOLDER .. k)
        Keys[k] = nil
        ChapterSaver.save()
        Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.CHAPTER_REMOVE, k))
    end
end


---@return table
---Returns all active downloadings
function ChapterSaver.getDownloadingList()
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
function ChapterSaver.check(chapter)
    return Keys[key(chapter)] == true
end


---@param chapter table
---@return boolean
---Gives `true` if chapter is downloading
function ChapterSaver.is_downloading(chapter)
    return Downloading[key(chapter)]
end


---@param chapter table
---@return table
---Gives table with all pathes to chapters images (pages)
function ChapterSaver.getChapter(chapter)
    local k = key(chapter)
    local table = {Done = true}
    if Keys[k] then
        local pages = #listDirectory(FOLDER .. k) - 1
        for i = 1, pages do
            table[i] = {
                Path = "chapters/" .. k .. "/" .. i .. ".image"
            }
        end
    end
    return table
end

---Saves saved chapters changes
function ChapterSaver.save()
    if doesFileExist("ux0:data/noboru/c.c") then
        deleteFile("ux0:data/noboru/c.c")
    end
    local fh = openFile("ux0:data/noboru/c.c", FCREATE)
    local save_data = table.serialize(Keys, "Keys")
    writeFile(fh, save_data, save_data:len())
    closeFile(fh)
end

---Loads saved chapters changes
function ChapterSaver.load()
    Keys = {}
    if doesFileExist("ux0:data/noboru/c.c") then
        local fh = openFile("ux0:data/noboru/c.c", FREAD)
        local suc, keys = pcall(function() return load("local " .. readFile(fh, sizeFile(fh)) .. " return Keys")() end)
        if suc then
            local cnt = 0
            for _, _ in pairs(keys) do
                cnt = cnt + 1
            end
            local i = 1
            for k, _ in pairs(keys) do
                coroutine.yield("ChapterSaver: Checking " .. FOLDER .. k, i / cnt)
                if doesFileExist(FOLDER .. k .. "/done.txt") then
                    local fh_2 = openFile(FOLDER .. k .. "/done.txt", FREAD)
                    local pages = readFile(fh_2, sizeFile(fh_2))
                    closeFile(fh_2)
                    local lDir = listDirectory(FOLDER .. k)
                    if tonumber(pages) == #lDir - 1 then
                        local count = 0
                        for i = 1, #lDir do
                            local width = System.getPictureResolution(FOLDER .. k .. "/" .. lDir[i].name)
                            if not width or width <= 0 then
                                count = count + 1
                                if count == 2 then
                                    rem_dir("ux0:data/noboru/chapters/" .. k)
                                    Notifications.push("chapters_error_wrong_image\n" .. k)
                                    break
                                end
                            end
                        end
                        if count < 2 then
                            Keys[k] = true
                        end
                    else
                        rem_dir("ux0:data/noboru/chapters/" .. k)
                        Notifications.push("chapters_error\n" .. k)
                    end
                else
                    rem_dir("ux0:data/noboru/chapters/" .. k)
                    Notifications.push("chapters_error\n" .. k)
                end
                i = i + 1
            end
            local dir_list = listDirectory("ux0:data/noboru/chapters")
            for _, v in ipairs(dir_list) do
                if not Keys[v.name] and v.directory then
                    rem_dir("ux0:data/noboru/chapters/" .. v.name)
                end
            end
        end
        closeFile(fh)
        ChapterSaver.save()
    end
end

---Clears all saved chapters
function ChapterSaver.clear()
    notify = false
    for _, v in ipairs(ChapterSaver.getDownloadingList()) do
        ChapterSaver.stopByListItem(v)
    end
    notify = true
    rem_dir("ux0:data/noboru/chapters")
    createDirectory("ux0:data/noboru/chapters")
    Keys = {}
    ChapterSaver.save()
    Notifications.push(Language[Settings.Language].NOTIFICATIONS.CHAPTERS_CLEARED)
end
