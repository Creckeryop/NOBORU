local order = {}
local order_count = 0
local task = nil
local trash = {type = nil, garbadge = nil}
local net_inited = false
local memory = 0
Net = {
    update = function()
        if net_inited and task == nil and order_count == 0 then
            Network.term()
            net_inited = false
        end
        if not net_inited and (order_count ~= 0 or task ~= nil) then
            Network.init()
            net_inited = true
        end
        if (order_count == 0 and task == nil) or System.getAsyncState() == 0 then
            return
        end
        if task == nil then
            task = order[1]
            table.remove(order, 1)
            order_count = order_count - 1
            if task.type == "String" then
                Network.requestStringAsync(task.link)
            elseif task.type == "Image" then
                Network.downloadFileAsync(task.link, LUA_APPDATA_DIR .. "cacheA.img")
            elseif task.type == "File" then
                Network.downloadFileAsync(task.link, task.path)
            elseif task.type == "Skip" then
                task = nil
            end
            if task ~= nil then
                Console.addLine("NET: #" .. (4 - task.retry) .. " " .. task.link, LUA_COLOR_BLUE)
            end
        else
            Console.addLine("NET: " .. task.link, LUA_COLOR_GREEN)
            local f_save = function()
                trash.type = task.type
                trash.link = task.link
                if task.type == "String" then
                    task.table[task.index] = System.getAsyncResult()
                    memory = memory + task.table[task.index]:len()
                elseif task.type == "Image" then
                    if System.doesFileExist(LUA_APPDATA_DIR .. "cacheA.img") then
                        Graphics.loadImageAsync(LUA_APPDATA_DIR .. "cacheA.img")
                        local handle = System.openFile(LUA_APPDATA_DIR .. "cacheA.img", FREAD)
                        memory = memory + System.sizeFile(handle)
                        System.closeFile(handle)
                    else
                        error("File doesn't exists")
                    end
                    task.type = "ImageLoad"
                    return
                elseif task.type == "ImageLoad" then
                    task.table[task.index] = System.getAsyncResult()
                    if System.doesFileExist(LUA_APPDATA_DIR .. "cacheA.img") then
                        Graphics.setImageFilters(task.table[task.index], FILTER_LINEAR, FILTER_LINEAR)
                        System.deleteFile(LUA_APPDATA_DIR .. "cacheA.img")
                    end
                elseif task.type == "File" then
                    local handle = System.openFile(task.path, FREAD)
                    memory = memory + System.sizeFile(handle)
                    System.closeFile(handle)
                elseif task.type == "Skip" then
                    Console.addLine("WOW HOW THAT HAPPENED?", LUA_COLOR_RED)
                end
                task = nil
            end
            local success, err = pcall(f_save)
            if not success then
                Console.addLine("NET: " .. err, LUA_COLOR_RED)
                task.retry = task.retry - 1
                if task.retry > 0 then
                    table.insert(order, task)
                    order_count = order_count + 1
                end
                task = nil
            end
        end
        if trash.garbadge ~= nil then
            if trash.type == "ImageLoad" then
                Graphics.freeImage(trash.garbadge)
                Console.addLine("NET:(Freeing image)" .. trash.link, LUA_COLOR_PURPLE)
            end
            trash.garbadge = nil
        end
    end,
    clear = function()
        order_count = 0
        order = {}
        task.table, task.index = trash, "garbadge"
    end,
    isDownloadRunning = function()
        return System.getAsyncState() == 0 or order_count ~= 0 or task ~= nil
    end,
    downloadString = function(link)
        repeat
        until System.getAsyncState() ~= 0
        local content
        if not net_inited then
            Network.init()
            content = Network.requestString(link)
            Network.term()
        else
            content = Network.requestString(link)
        end
        return content
    end,
    downloadFile = function(link, path)
        repeat
        until System.getAsyncState() ~= 0
        if not net_inited then
            Network.init()
            Network.downloadFile(link, path)
            Network.term()
        else
            Network.downloadFile(link, path)
        end
    end,
    downloadImage = function(link)
        repeat
        until System.getAsyncState() ~= 0
        local image
        if not net_inited then
            Network.init()
            Network.downloadFile(link, LUA_APPDATA_DIR .. "cache.img")
            image = Graphics.loadImage(LUA_APPDATA_DIR .. "cache.img")
            System.deleteFile(LUA_APPDATA_DIR .. "cache.img")
            Network.term()
        else
            Network.downloadFile(link, LUA_APPDATA_DIR .. "cache.img")
            image = Graphics.loadImage(LUA_APPDATA_DIR .. "cache.img")
            System.deleteFile(LUA_APPDATA_DIR .. "cache.img")
        end
        return image
    end,
    downloadStringAsync = function(link, table, index)
        if task ~= nil and task.table == table and task.index == index then
            return false
        end
        for _, v in pairs(order) do
            if v.table == table and v.index == index then
                return false
            end
        end
        order_count = order_count + 1
        order[#order + 1] = {type = "String", link = link, table = table, index = index, retry = 3}
        return true
    end,
    downloadImageAsync = function(link, table, index)
        if task ~= nil and task.table == table and task.index == index then
            return false
        end
        for _, v in pairs(order) do
            if v.table == table and v.index == index then
                return false
            end
        end
        order_count = order_count + 1
        order[#order + 1] = {type = "Image", link = link, table = table, index = index, retry = 3}
        return true
    end,
    downloadFileAsync = function(link, path)
        if task ~= nil and task.path == path then
            return false
        end
        for _, v in pairs(order) do
            if v.path == path then
                return false
            end
        end
        order_count = order_count + 1
        order[#order + 1] = {type = "File", link = link, path = path, retry = 3}
        return true
    end,
    Terminate = function()
        if net_inited then
            Net.clear()
            while task ~= nil do
                Net.update()
            end
            Network.term()
            net_inited = false
        end
    end,
    remove = function(table, index)
        if task ~= nil and task.table == table and task.index == index then
            task.table, task.index = trash, "garbadge"
        end
        for _, v in pairs(order) do
            if v.table == table and v.index == index then
                v.type = "Skip"
            end
        end
    end,
    check = function(table, index)
        if task ~= nil and (task.table == table or task.link == table) and (task.index == index or task.path == index) then
            return task.type ~= "Skip"
        end
        for _, v in pairs(order) do
            if (v.table == table or v.link == table) and (v.index == index or v.path == index) then
                return v.type ~= "Skip"
            end
        end
        return false
    end,
    getMemoryDownloaded = function()
        return memory
    end
}
