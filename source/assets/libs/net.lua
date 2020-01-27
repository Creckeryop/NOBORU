Threads = {}

local IMAGE_CACHE_PATH = "ux0:data/noboru/cache.img"

local Order = {}
local OrderCount = 0
local Task = nil

local Trash = {
    Type = nil,
    Garbadge = nil
}

local net_inited = false
local bytes = 0
local uniques = {}

function Threads.Update()
    if net_inited and not Task and OrderCount == 0 then
        Network.term()
        net_inited = false
    end
    if not net_inited and (OrderCount ~= 0 or Task) then
        Network.init()
        net_inited = true
    end
    if (OrderCount == 0 and not Task) or System.getAsyncState() == 0 then
        return
    end
    if not Task then
        Task = table.remove(Order, 1)
        OrderCount = OrderCount - 1
        if Task.Type == "String" then
            if Task.HttpMethod then
                if Task.PostData then
                    if Task.ContentType then
                        if Task.Cookie then
                            Network.requestStringAsync(Task.Link, USERAGENT, Task.HttpMethod, Task.PostData, Task.ContentType, Task.Cookie)
                        else
                            Network.requestStringAsync(Task.Link, USERAGENT, Task.HttpMethod, Task.PostData, Task.ContentType)
                        end
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
            if System.doesFileExist(Task.Path) then
                System.deleteFile(Task.Path)
            end
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
            Console.write("NET: Skip", Color.new(255, 255, 0))
        end
        if Task then
            Console.write("NET: #" .. (4 - Task.Retry) .. " " .. Task.Link, Color.new(0, 255, 0))
        end
    else
        Console.write("(" .. Task.Type .. ")NET: " .. Task.Link, Color.new(0, 255, 0))
        local f_save = function()
            Trash.Type = Task.Type
            Trash.Link = Task.Link
            if Task.Type == "String" then
                Task.Table[Task.Index] = System.getAsyncResult()
                bytes = bytes + Task.Table[Task.Index]:len()
                if Task.Table[Task.Index]:len() < 100 then
                    Console.write("NET:" .. Task.Table[Task.Index])
                end
            elseif Task.Type == "Image" then
                if System.doesFileExist(IMAGE_CACHE_PATH) then
                    local handle = System.openFile(IMAGE_CACHE_PATH, FREAD)
                    bytes = bytes + System.sizeFile(handle)
                    System.closeFile(handle)
                    local Width, Height = System.getPictureResolution(IMAGE_CACHE_PATH)
                    Console.write(Width .. "x" .. Height .. " Image got")
                    if GetTextureMemoryUsed() + bit32.band(bit32.bor(Width, 7), bit32.bnot(7)) * Height * 4 > 96 * 1024 * 1024 then
                        Console.error("No enough memory to load image")
                        uniques[Task.Table or Task.Link] = nil
                        Task = nil
                    else
                        if Height > 4096 and Height / Width > 2 then
                            if not (Width and Height) then
                                error("measure problem")
                            end
                            Task.Image = {
                                Width = Width,
                                Height = Height,
                                Parts = math.ceil(Height / 4096)
                            }
                            Console.write(Task.Image.Parts)
                            Task.Type = "ImageLoadTable"
                        else
                            Graphics.loadImageAsync(IMAGE_CACHE_PATH)
                            Task.Type = "ImageLoad"
                        end
                    end
                else
                    uniques[Task.Table or Task.Link] = nil
                    Task = nil
                end
                return
            elseif Task.Type == "ImageLoad" then
                if System.doesFileExist(IMAGE_CACHE_PATH) then
                    Task.Table[Task.Index] = Image:new(System.getAsyncResult())
                    Graphics.setImageFilters(Task.Table[Task.Index].e, FILTER_LINEAR, FILTER_LINEAR)
                end
            elseif Task.Type == "ImageLoadTable" then
                if not Task.Image.i then
                    Task.Image.i = 0
                    Task.Table[Task.Index] = {}
                    Task.Table[Task.Index].Parts = Task.Image.Parts
                    Task.Table[Task.Index].part_h = math.floor(Task.Image.Height / Task.Image.Parts)
                    Task.Table[Task.Index].Height = Task.Image.Height
                    Task.Table[Task.Index].Width = Task.Image.Width
                elseif Task.Image.i < Task.Image.Parts then
                    Task.Image.i = Task.Image.i + 1
                    if Task.Table[Task.Index] == Trash.Garbadge then
                        Trash.Garbadge = Image:new(System.getAsyncResult())
                        Trash.Type = "ImageLoadTable2"
                        return
                    end
                    Task.Table[Task.Index][Task.Image.i] = Image:new(System.getAsyncResult())
                    if not Task.Table[Task.Index][Task.Image.i] then
                        error("error with part function")
                    else
                        Console.write("Got " .. Task.Image.i .. " Image")
                    end
                    Graphics.setImageFilters(Task.Table[Task.Index][Task.Image.i].e, FILTER_LINEAR, FILTER_LINEAR)
                else
                    uniques[Task.Table or Task.Link] = nil
                    Task = nil
                    return
                end
                local Height = Task.Table[Task.Index].part_h
                if Task.Image.i == Task.Image.Parts - 1 then
                    Height = Task.Image.Height - (Task.Image.i) * Height
                end
                if Task.Image.i < Task.Image.Parts then
                    Console.write("Getting " .. (Task.Table[Task.Index].part_h * Task.Image.i) .. " " .. (Task.Image.Width) .. " " .. Height .. " Image")
                    Graphics.loadPartImageAsync(IMAGE_CACHE_PATH, 0, Task.Table[Task.Index].part_h * Task.Image.i, Task.Image.Width, Height)
                else
                    uniques[Task.Table or Task.Link] = nil
                    Task = nil
                end
                return
            elseif Task.Type == "File" then
                local handle = System.openFile(Task.Path, FREAD)
                bytes = bytes + System.sizeFile(handle)
                System.closeFile(handle)
            elseif Task.Type == "Skip" then
                Console.error("WOW HOW THAT HAPPENED?")
            end
            uniques[Task.Table or Task.Link] = nil
            Task = nil
        end
        local success, err = pcall(f_save)
        if not success then
            Console.error("NET: " .. err)
            Task.Retry = Task.Retry - 1
            if Task.Retry > 0 then
                table.insert(Order, Task)
                OrderCount = OrderCount + 1
            else
                uniques[Task.Table or Task.Link] = nil
            end
            Task = nil
        end
    end
    if Trash.Garbadge then
        if Trash.Type == "ImageLoad" then
            Console.write("NET:(Freeing Image)" .. Trash.Link, Color.new(255, 0, 255))
            Trash.Garbadge:free()
        elseif Trash.Type == "ImageLoadTable2" then
            Console.write("NET:(Freeing Table Image)" .. Trash.Link, Color.new(255, 0, 255))
            Trash.Garbadge:free()
        end
        Trash.Garbadge = nil
    end
end

function Threads.Clear()
    OrderCount = 0
    Order = {}
    uniques = {}
    Task.Table = Trash
    Task.Index = "Garbadge"
end

function Threads.isDownloadRunning()
    return System.getAsyncState() == 0 or OrderCount ~= 0 or Task ~= nil
end

function Threads.DownloadString(Link)
    repeat
    until System.getAsyncState() ~= 0
    if not net_inited then
        Network.init()
        local content = Network.requestString(Link)
        Network.term()
        return content
    else
        return Network.requestString(Link)
    end
end

function Threads.DownloadFile(Link, Path)
    repeat
    until System.getAsyncState() ~= 0
    if not net_inited then
        Network.init()
        Network.downloadFile(Link, Path)
        Network.term()
    else
        Network.downloadFile(Link, Path)
    end
end

function Threads.DownloadImage(Link)
    repeat
    until System.getAsyncState() ~= 0
    local Image
    if not net_inited then
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
end

local function addThread(UniqueKey, T, Insert)
    OrderCount = OrderCount + 1
    if Insert then
        table.insert(Order, 1, T)
    else
        Order[#Order + 1] = T
    end
    uniques[UniqueKey] = T
end

function Threads.DownloadStringAsync(Link, Table, Index, Insert, HttpMethod, PostData, ContentType, Cookie)
    if uniques[Table] then return false end
    addThread(Table, {
        Type = "String",
        Link = Link,
        Table = Table,
        Index = Index,
        Retry = 3,
        HttpMethod = HttpMethod,
        PostData = PostData,
        ContentType = ContentType,
        Cookie = Cookie
    }, Insert)
    return true
end

function Threads.DownloadImageAsync(Link, Table, Index, Insert, HttpMethod, PostData)
    if uniques[Table] then return false end
    addThread(Table, {
        Type = "Image",
        Link = Link,
        Table = Table,
        Index = Index,
        Retry = 3,
        HttpMethod = HttpMethod,
        PostData = PostData
    }, Insert)
    return true
end

function Threads.DownloadFileAsync(Link, Path, Insert, HttpMethod, PostData)
    if uniques[Link] then return false end
    addThread(Link, {
        Type = "File",
        Link = Link,
        Path = Path,
        Retry = 3,
        HttpMethod = HttpMethod,
        PostData = PostData
    }, Insert)
    return true
end

function Threads.Terminate()
    if net_inited then
        Threads.clear()
        while Task do
            Threads.update()
        end
        Network.term()
        net_inited = false
    end
end

---@param UniqueKey string
---Removes task by `UniqueKey` = `Table` or `Link` (if no `Table`)
function Threads.Remove(UniqueKey)
    if uniques[UniqueKey] then
        if Task == uniques[UniqueKey] then
            Task.Table, Task.Index = Trash, "Garbadge"
        else
            uniques[UniqueKey].Type = "Skip"
        end
        uniques[UniqueKey] = nil
    end
end

---@param UniqueKey string
---Checks if task is in order by `UniqueKey` = `Table` or `Link` (if no `Table`)
function Threads.Check(UniqueKey)
    return uniques[UniqueKey] ~= nil
end

---@return number
---Returns count of bytes downloaded by Threads functions
function Threads.GetMemoryDownloaded()
    return bytes
end

---@return integer number of tasks
---Returns quantity of tasks in order
function Threads.GetTasksNum()
    return OrderCount + (Task and 1 or 0)
end
