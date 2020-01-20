local IMAGE_CACHE_PATH = "ux0:data/Moondayo/cache.img"

local Order         = {}
local OrderCount    = 0
local Task          = nil
local Trash         = {Type = nil, Garbadge = nil}
local NetInited     = false
local bytes         = 0
local Uniques       = {}

threads = {
    Update = function()
        if NetInited and Task == nil and OrderCount == 0 then
            Network.term()
            NetInited = false
        end
        if not NetInited and (OrderCount ~= 0 or Task ~= nil) then
            Network.init()
            NetInited = true
        end
        if (OrderCount == 0 and Task == nil) or System.getAsyncState() == 0 then
            return
        end
        if Task == nil then
            Task = Order[1]
            table.remove(Order, 1)
            OrderCount = OrderCount - 1
            if Task.Type == "String" then
                if Task.HttpMethod then
                    if Task.PostData then
                        if Task.ContentType then
                            Network.requestStringAsync(Task.Link, USERAGENT, Task.HttpMethod, Task.PostData, Task.ContentType)
                        else
                            Network.requestStringAsync(Task.Link, USERAGENT, Task.HttpMethod, Task.PostData)
                        end
                    else
                        Network.requestStringAsync(Task.Link, USERAGENT, Task.HttpMethod)
                    end
                else
                    Network.requestStringAsync(Task.Link)
                end
            elseif Task.Type == "Image" then
                if System.doesFileExist(IMAGE_CACHE_PATH) then
                    System.deleteFile(IMAGE_CACHE_PATH)
                end
                if Task.HttpMethod then
                    if Task.PostData then
                        Network.downloadFileAsync(Task.Link, IMAGE_CACHE_PATH, USERAGENT, Task.HttpMethod, Task.PostData)
                    else
                        Network.downloadFileAsync(Task.Link, IMAGE_CACHE_PATH, USERAGENT, Task.HttpMethod)
                    end
                else
                    Network.downloadFileAsync(Task.Link, IMAGE_CACHE_PATH)
                end
            elseif Task.Type == "File" then
                if Task.HttpMethod then
                    if Task.PostData then
                        Network.downloadFileAsync(Task.Link, Task.Path, USERAGENT, Task.HttpMethod, Task.PostData)
                    else
                        Network.downloadFileAsync(Task.Link, Task.Path, USERAGENT, Task.HttpMethod)
                    end
                else
                    Network.downloadFileAsync(Task.Link, Task.Path)
                end
            elseif Task.Type == "Skip" then
                Task = nil
                Console.writeLine("NET: Skip", Color.new(255, 255, 0))
            end
            if Task then
                Console.writeLine("NET: #" .. (4 - Task.Retry) .. " " .. Task.Link, Color.new(0, 255, 0))
            end
        else
            Console.writeLine("("..Task.Type..")NET: " .. Task.Link, Color.new(0, 255, 0))
            local f_save = function()
                Trash.Type = Task.Type
                Trash.Link = Task.Link
                if Task.Type == "String" then
                    Task.Table[Task.Index] = System.getAsyncResult()
                    bytes = bytes + Task.Table[Task.Index]:len()
                    if (Task.Table[Task.Index]:len() < 100) then
                        Console.writeLine("NET:"..Task.Table[Task.Index])
                    end
                elseif Task.Type == "Image" then
                    if System.doesFileExist(IMAGE_CACHE_PATH) then
                        local handle = System.openFile(IMAGE_CACHE_PATH, FREAD)
                        bytes = bytes + System.sizeFile(handle)
                        System.closeFile(handle)
                        local Width, Height = System.getPictureResolution(IMAGE_CACHE_PATH)
                        Console.writeLine(Width.."x"..Height.." Image got")
                        if Height > 4096 and Height / Width > 2 then
                            if Width == nil or Height == nil then
                                error("measure problem")
                            end
                            Task.Image = {Width = Width, Height = Height, Parts = math.ceil(Height / 4096)}
                            Console.writeLine(Task.Image.Parts)
                            Task.Type = "ImageLoadTable"
                        else
                            Graphics.loadImageAsync(IMAGE_CACHE_PATH)
                            Task.Type = "ImageLoad"
                        end
                    else
                        Uniques[Task.Table or Task.Link] = nil
                        Task = nil
                    end
                    return
                elseif Task.Type == "ImageLoad" then
                    if System.doesFileExist(IMAGE_CACHE_PATH) then
                        Task.Table[Task.Index] = Image:new(System.getAsyncResult())
                        Graphics.setImageFilters(Task.Table[Task.Index].e, FILTER_LINEAR, FILTER_LINEAR)
                    end
                elseif Task.Type == "ImageLoadTable" then
                    if Task.Image.i == nil then
                        Task.Image.i = 0
                        Task.Table[Task.Index] = {}
                        Task.Table[Task.Index].Parts = Task.Image.Parts
                        Task.Table[Task.Index].part_h = math.floor(Task.Image.Height / Task.Image.Parts)
                        Task.Table[Task.Index].Height = Task.Image.Height
                        Task.Table[Task.Index].Width = Task.Image.Width
                    elseif Task.Image.i < Task.Image.Parts then
                        Task.Image.i = Task.Image.i + 1
                        if (Task.Table[Task.Index] == Trash.Garbadge) then
                            Trash.Garbadge = Image:new(System.getAsyncResult())
                            Trash.Type = "ImageLoadTable2"
                            return
                        end
                        Task.Table[Task.Index][Task.Image.i] = Image:new(System.getAsyncResult())
                        if (Task.Table[Task.Index][Task.Image.i] == nil) then
                            error("error with part function")
                        else
                            Console.writeLine("Got " .. Task.Image.i .. " Image")
                        end
                        Graphics.setImageFilters(Task.Table[Task.Index][Task.Image.i].e, FILTER_LINEAR, FILTER_LINEAR)
                    else
                        Uniques[Task.Table or Task.Link] = nil
                        Task = nil
                        return
                    end
                    local Height = math.floor(Task.Image.Height / Task.Image.Parts)
                    if (Task.Image.i == Task.Image.Parts - 1) then
                        Height = Task.Image.Height - (Task.Image.i) * Height
                    end
                    if (Task.Image.i < Task.Image.Parts) then
                        Console.writeLine("Getting " .. (math.floor(Task.Image.Height / Task.Image.Parts) * Task.Image.i) .. " " .. (Task.Image.Width) .. " " .. Height .. " Image")
                        Graphics.loadPartImageAsync(IMAGE_CACHE_PATH, 0, math.floor(Task.Image.Height / Task.Image.Parts) * Task.Image.i, Task.Image.Width, Height)
                    else
                        Uniques[Task.Table or Task.Link] = nil
                        Task = nil
                    end
                    return
                elseif Task.Type == "File" then
                    local handle = System.openFile(Task.Path, FREAD)
                    bytes = bytes + System.sizeFile(handle)
                    System.closeFile(handle)
                elseif Task.Type == "Skip" then
                    Console.writeLine("WOW HOW THAT HAPPENED?", Color.new(255,0,0))
                end
                Uniques[Task.Table or Task.Link] = nil
                Task = nil
            end
            local success, err = pcall(f_save)
            if not success then
                Console.writeLine("NET: " .. err, Color.new(255, 0, 0))
                Task.Retry = Task.Retry - 1
                if Task.Retry > 0 then
                    table.insert(Order, Task)
                    OrderCount = OrderCount + 1
                else
                    Uniques[Task.Table or Task.Link] = nil
                end
                Task = nil
            end
        end
        if Trash.Garbadge then
            if Trash.Type == "ImageLoad" then
                Console.writeLine("NET:(Freeing Image)" .. Trash.Link, Color.new(255,0,255))
                Trash.Garbadge:free()
            elseif Trash.Type == "ImageLoadTable2" then
                Console.writeLine("NET:(Freeing Table Image)" .. Trash.Link, Color.new(255,0,255))
                Trash.Garbadge:free()
            end
            Trash.Garbadge = nil
        end
    end,
    Clear = function()
        OrderCount = 0
        Order = {}
        Uniques = {}
        Task.Table, Task.Index = Trash, "Garbadge"
    end,
    isDownloadRunning = function()
        return System.getAsyncState() == 0 or OrderCount ~= 0 or Task ~= nil
    end,
    DownloadString = function(Link)
        repeat
        until System.getAsyncState() ~= 0
        local content
        if not NetInited then
            Network.init()
            content = Network.requestString(Link)
            Network.term()
        else
            content = Network.requestString(Link)
        end
        return content
    end,
    DownloadFile = function(Link, Path)
        repeat
        until System.getAsyncState() ~= 0
        if not NetInited then
            Network.init()
            Network.downloadFile(Link, Path)
            Network.term()
        else
            Network.downloadFile(Link, Path)
        end
    end,
    DownloadImage = function(Link)
        repeat
        until System.getAsyncState() ~= 0
        local Image
        if not NetInited then
            Network.init()
            Network.downloadFile(Link, IMAGE_CACHE_PATH)
            Image = Image:new(Graphics.loadImage(IMAGE_CACHE_PATH))
            System.deleteFile(IMAGE_CACHE_PATH)
            Network.term()
        else
            Network.downloadFile(Link, IMAGE_CACHE_PATH)
            Image = Image:new(Graphics.loadImage(IMAGE_CACHE_PATH))
            System.deleteFile(IMAGE_CACHE_PATH)
        end
        return Image
    end,
    DownloadStringAsync = function(Link, Table, Index, Insert, HttpMethod, PostData, ContentType)
        if Uniques[Table] then return false end
        OrderCount = OrderCount + 1
        local T = {Type = "String", Link = Link, Table = Table, Index = Index, Retry = 3, HttpMethod = HttpMethod, PostData = PostData, ContentType = ContentType}
        if Insert then
            table.insert(Order, 1, T)
        else
            Order[#Order + 1] = T
        end
        Uniques[Table] = T
        return true
    end,
    DownloadImageAsync = function(Link, Table, Index, Insert, HttpMethod, PostData)
        if Uniques[Table] then return false end
        OrderCount = OrderCount + 1
        local T = {Type = "Image", Link = Link, Table = Table, Index = Index, Retry = 3, HttpMethod = HttpMethod, PostData = PostData}
        if Insert then
            table.insert(Order, 1, T)
        else
            Order[#Order + 1] = T
        end
        Uniques[Table] = T
        return true
    end,
    DownloadFileAsync = function(Link, Path, Insert, HttpMethod, PostData)
        if Uniques[Link] then return false end
        OrderCount = OrderCount + 1
        local T = {Type = "File", Link = Link, Path = Path, Retry = 3, HttpMethod = HttpMethod, PostData = PostData}
        if Insert then
            table.insert(Order, 1, T)
        else
            Order[#Order + 1] = T
        end
        Uniques[Link] = T
        return true
    end,
    Terminate = function()
        if NetInited then
            threads.clear()
            while Task do
                threads.update()
            end
            Network.term()
            NetInited = false
        end
    end,
    Remove = function(Table)
        if Uniques[Table] then
            if Task == Uniques[Table] then
                Task.Table, Task.Index = Trash, "Garbadge"
            else
                Uniques[Table].Type = "Skip"
            end
            Uniques[Table] = nil
        end
    end,
    Check = function(Table)
        return Uniques[Table] ~= nil
    end
}
function threads.GetMemoryDownloaded()
    return bytes
end
function threads.GetTasksNum()
    return OrderCount + (Task and 1 or 0)
end