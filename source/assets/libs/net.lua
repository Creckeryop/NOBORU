local order = {}
local order_count = 0
local task = nil
NET_MODE_NOW = 1
NET_MODE_IFCAN = 2
Net = {
    update = function ()
        if (order_count == 0 and task == nil) or System.getAsyncState () == 0 then
            return
        end
        if task == nil then
            task = order[1]
            table.remove (order, 1)
            order_count = order_count - 1
            if task.type == 'String' then
                Network.requestStringAsync (task.link)
            elseif task.type == 'Image' then
                Network.downloadFileAsync (task.link, LUA_APPDATA_DIR..'cacheA.img')
            end
            Console.addLine ('NET: #'..(4 - task.retry)..' '..task.link, LUA_COLOR_BLUE)
        else
            Console.addLine ('NET: '..task.link, LUA_COLOR_GREEN) 
            local f_save = function ()
                if task.type == 'String' then
                    task.table[task.index] = System.getAsyncResult ()
                elseif task.type == 'Image' then
                    task.table[task.index] = Graphics.loadImage (LUA_APPDATA_DIR..'cacheA.img')
                    System.deleteFile (LUA_APPDATA_DIR..'cacheA.img')
                end
            end
            local success, err = pcall(f_save)
            if not success then
                Console.addLine ('NET: '..err, LUA_COLOR_RED)
                task.retry = task.retry - 1
                if task.retry > 0 then
                    table.insert(order, task)
                    order_count = order_count + 1
                end
            end
            task = nil
        end
    end,
    clear = function ()
        order_count = 0
        order = {}
    end,
    isDownloadRunning = function ()
        return System.getAsyncState () == 0 or order_count ~= 0 and task ~= nil
    end,
    downloadString = function (link, mode)
        mode = mode or NET_MODE_NOW
        if mode == NET_MODE_IFCAN then
            if (order_count == 0 and task == nil) or System.getAsyncState () == 0 then
                return nil
            end
        elseif mode == NET_MODE_NOW then
            repeat until System.getAsyncState () == 1
        end
        return Network.requestString (link)
    end,
    downloadFile = function (link, path, mode)
        mode = mode or NET_MODE_NOW
        if mode == NET_MODE_IFCAN then
            if (order_count == 0 and task == nil) or System.getAsyncState () == 0 then
                return nil
            end
        elseif mode == NET_MODE_NOW then
            repeat until System.getAsyncState () == 1
        end
        Network.downloadFile (link, path)
    end,
    downloadImage = function (link, mode)
        mode = mode or NET_MODE_NOW
        if mode == NET_MODE_IFCAN then
            if (order_count == 0 and task == nil) or System.getAsyncState () == 0 then
                return nil
            end
        elseif mode == NET_MODE_NOW then
            repeat until System.getAsyncState () == 1
        end
        Network.downloadFile (link, LUA_APPDATA_DIR..'cache.img')
        local image = Graphics.loadImage (LUA_APPDATA_DIR..'cache.img')
        System.deleteFile (LUA_APPDATA_DIR..'cache.img')
        return image
    end,
    downloadStringAsync = function (link, table, index)
        order_count = order_count + 1
        order[#order + 1] = {type = "String", link = link, table = table, index = index, retry = 3}
    end,
    downloadImageAsync = function (link, table, index)
        order_count = order_count + 1
        order[#order + 1] = {type = "Image", link = link, table = table, index = index, retry = 3}
    end
}