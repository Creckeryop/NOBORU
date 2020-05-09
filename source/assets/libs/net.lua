Threads = {}

local IMAGE_CACHE_PATH = "ux0:data/noboru/cache.image"

local Order = {}
local Task = nil

local Trash = {
    Type = nil,
    Garbadge = nil
}

local net_inited = false
local bytes = 0
local uniques = {}

local getAsyncResult = System.getAsyncResult
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local rem_dir = RemoveDirectory

local function img2bytes(Width, Height, DScale)
    return bit32.band(Width + 7, bit32.bnot(7)) * Height * 4 / (DScale * DScale) + 1024
end

MAX_VRAM_MEMORY = 88 * 1024 * 1024

---Updates threads tasks
function Threads.update()
    if net_inited and not Task and #Order == 0 then
        Network.term()
        net_inited = false
    end
    if not net_inited and (#Order ~= 0 or Task) then
        Network.init()
        net_inited = true
    end
    if (#Order == 0 and not Task) or System.getAsyncState() == 0 then
        return
    end
    if not Task then
        local new_order = {}
        for _, v in ipairs(Order) do
            if v.Type == "Skip" then
                Console.write("NET: Skip", Color.new(255, 255, 0))
            else
                new_order[#new_order + 1] = v
            end
        end
        Order = new_order
        if #Order == 0 then
            return
        end
        Task = table.remove(Order, 1)
        if Task.Type == "StringRequest" then
            if Task.Link then
                Network.requestStringAsync(Task.Link, USERAGENT, Task.HttpMethod, Task.PostData, Task.ContentType, Task.Cookie, Task.Header1, Task.Header2, Task.Header3, Task.Header4, Task.Proxy, Task.ProxyAuth)
            else
                Console.error("No Link given or internet connection problem")
                uniques[Task.UniqueKey] = nil
                Task = nil
            end
        elseif Task.Type == "FileDownload" or Task.Type == "ImageDownload" then
            if doesFileExist(Task.Path) then
                deleteFile(Task.Path)
            end
            if Task.Link then
                if Task.Path then
                    Network.downloadFileAsync(Task.Link, Task.Path, USERAGENT, Task.HttpMethod, Task.PostData, Task.ContentType, Task.Cookie, Task.Header1, Task.Header2, Task.Header3, Task.Header4, Task.Proxy, Task.ProxyAuth)
                    if Task.Type == "ImageDownload" then
                        Task.Type = "Image"
                    end
                else
                    Console.error("No Path given")
                    uniques[Task.UniqueKey] = nil
                    Task = nil
                end
            else
                Console.error("No Link given or internet connection problem")
                uniques[Task.UniqueKey] = nil
                Task = nil
            end
        elseif Task.Type == "UnZip" then
            if Task.DestPath then
                rem_dir(Task.DestPath)
                if Task.Path then
                    System.extractZipAsync(Task.Path, Task.DestPath)
                else
                    Console.error("No Path given")
                    uniques[Task.UniqueKey] = nil
                    Task = nil
                end
            else
                Console.error("No DestPath given")
                uniques[Task.UniqueKey] = nil
                Task = nil
            end
        elseif Task.Type == "UnZipFile" then
            if Task.Extract then
                if Task.DestPath then
                    if Task.Path then
                        System.extractFromZipAsync(Task.Path, Task.Extract, Task.DestPath)
                    else
                        Console.error("No Path given")
                        uniques[Task.UniqueKey] = nil
                        Task = nil
                    end
                else
                    Console.error("No DestPath given")
                    uniques[Task.UniqueKey] = nil
                    Task = nil
                end
            else
                Console.error("No Extract file path given")
                uniques[Task.UniqueKey] = nil
                Task = nil
            end
        end
        if Task then
            Console.write(string.format("NET: #%s %s", 4 - Task.Retry, Task.Link or Task.Path or Task.UniqueKey), Color.new(0, 255, 0))
        end
    else
        Console.write("(" .. Task.Type .. ")" .. (Task.Link or Task.Path or Task.UniqueKey), Color.new(0, 255, 0))
        local f_save = function()
            Trash.Type = Task.Type
            Trash.Link = Task.Link
            if Task.Type == "StringRequest" then
                Task.Table[Task.Index] = getAsyncResult() or ""
                local len = #Task.Table[Task.Index]
                if len > 0 then
                    bytes = bytes + len
                    if len < 100 then
                        Console.write("NET:" .. Task.Table[Task.Index])
                    end
                end
            elseif Task.Type == "Image" then
                if doesFileExist(Task.Path) then
                    local Width, Height = System.getPictureResolution(Task.Path)
                    if not Width or Width < 0 then
                        Task.Type = Task.Link and "ImageDownload" or Task.Type
                        if Task.Type == "ImageDownload" then
                            error("Redownloading file")
                        elseif Task.Type == "Image" then
                            Console.error("File you loading isn't picture")
                            uniques[Task.UniqueKey] = nil
                            Task = nil
                            return
                        end
                    end
                    Console.write(Width .. "x" .. Height .. " Image got")

                    if GetTextureMemoryUsed() + img2bytes(Width, Height, 1) > MAX_VRAM_MEMORY and Height <= 4096 and Height/Width<=2 then
                        Console.error("No enough memory to load image")
                        uniques[Task.UniqueKey] = nil
                        Task = nil
                    else
                        if Height > 4096 and Height / Width > 2 then
                            if GetTextureMemoryUsed() + img2bytes(Width, Height, 1) > MAX_VRAM_MEMORY then
                                if GetTextureMemoryUsed() + img2bytes(Width, Height, 2) > MAX_VRAM_MEMORY then
                                    Console.error("No enough memory to load image")
                                    uniques[Task.UniqueKey] = nil
                                    Task = nil
                                else
                                        Task.Image = {
                                        Width = Width / 2,
                                        Height = Height / 2,
                                        RealWidth = Width,
                                        RealHeight = Height,
                                        Parts = math.ceil(Height / 8192)
                                    }
                                end
                            else
                                Task.Image = {
                                    Width = Width,
                                    Height = Height,
                                    RealWidth = Width,
                                    RealHeight = Height,
                                    Parts = math.ceil(Height / 4096)
                                }
                            end
                            Console.write(Task.Image.Parts)
                            Task.Type = "ImageLoadTable"
                        else
                            local scale = 1
                            if Task.MaxWidth and Task.MaxHeight then
                                if Width > Height then
                                    scale = Width / Task.MaxWidth
                                else
                                    scale = Height / Task.MaxHeight
                                end
                            elseif Task.MaxWidth then
                                scale = Width / Task.MaxWidth
                            elseif Task.MaxHeight then
                                scale = Height / Task.MaxHeight
                            end
                            if scale <= 1 then
                                scale = 1
                            elseif scale <= 2 then
                                scale = 2
                            elseif scale <= 4 then
                                scale = 4
                            else
                                scale = 8
                            end
                            Graphics.loadImageAsync(Task.Path, scale)
                            Task.Type = "ImageLoad"
                        end
                    end
                else
                    Task.Type = Task.Link and "ImageDownload" or Task.Type
                    if Task.Type == "ImageDownload" then
                        error("(Image)File not found")
                    elseif Task.Type == "Image" then
                        Console.error("(Image)File not found")
                        uniques[Task.UniqueKey] = nil
                        Task = nil
                        return
                    end
                end
                return
            elseif Task.Type == "ImageLoad" then
                if doesFileExist(Task.Path) then
                    Task.Table[Task.Index] = Image:new(getAsyncResult(), FILTER_LINEAR)
                else
                    Console.error("(ImageLoad)File not found")
                end
            elseif Task.Type == "ImageLoadTable" then
                if not Task.Image.i then
                    Task.Image.i = 0
                    Task.Table[Task.Index] = {}
                    Task.Table[Task.Index].Parts = Task.Image.Parts
                    Task.Table[Task.Index].SliceHeight = math.floor(Task.Image.Height / Task.Image.Parts)
                    Task.Table[Task.Index].Height = Task.Image.Height
                    Task.Table[Task.Index].Width = Task.Image.Width
                elseif Task.Image.i < Task.Image.Parts then
                    Task.Image.i = Task.Image.i + 1
                    if Task.Table[Task.Index] == Trash.Garbadge then
                        Trash.Garbadge = Image:new(getAsyncResult())
                        Trash.Type = "ImageLoadTable2"
                        return
                    end
                    Task.Table[Task.Index][Task.Image.i] = Image:new(getAsyncResult(), FILTER_LINEAR)
                    if not Task.Table[Task.Index][Task.Image.i] then
                        error("error with part function")
                    else
                        Console.write(string.format("Got %s image", Task.Image.i))
                    end
                else
                    uniques[Task.UniqueKey] = nil
                    Task = nil
                    return
                end
                local sliceHeight = math.floor(Task.Image.RealHeight / Task.Image.Parts)
                local Height = sliceHeight
                if Task.Image.i == Task.Image.Parts - 1 then
                    Height = Task.Image.RealHeight - (Task.Image.i) * Height
                end
                if Task.Image.i < Task.Image.Parts then
                    Console.write(string.format("Getting %s %sx%s Image", sliceHeight * Task.Image.i, Task.Image.RealWidth, Height))
                    Graphics.loadPartImageAsync(Task.Path, 0, sliceHeight * Task.Image.i, Task.Image.RealWidth, Height)
                else
                    uniques[Task.UniqueKey] = nil
                    Task = nil
                end
                return
            elseif Task.Type == "FileDownload" then
                if doesFileExist(Task.Path) then
                    local handle = openFile(Task.Path, FREAD)
                    bytes = bytes + sizeFile(handle)
                    closeFile(handle)
                end
            elseif Task.Type == "Skip" then
                Console.error("WOW HOW THAT HAPPENED?")
            end
            uniques[Task.UniqueKey] = nil
            Task = nil
        end
        local TempTask = Task
        local success, err = pcall(f_save)
        if success then
            if Task == nil then
                if TempTask.OnComplete then
                    TempTask.OnComplete()
                    Console.write("OnComplete executing for " .. TempTask.Type .. " " .. (TempTask.Link or TempTask.Path or TempTask.UniqueKey))
                end
            end
        else
            Console.error("NET: " .. err)
            Task.Retry = Task.Retry - 1
            if Task.Retry > 0 then
                table.insert(Order, Task)
            else
                uniques[Task.UniqueKey] = nil
            end
            Task = nil
        end
    end
    if Trash.Garbadge then
        if Trash.Type == "ImageLoad" then
            Console.write("NET:(Freeing Image)", Color.new(255, 0, 255))
            Trash.Garbadge:free()
        elseif Trash.Type == "ImageLoadTable2" then
            Console.write("NET:(Freeing Table Image)", Color.new(255, 0, 255))
            Trash.Garbadge:free()
        end
        Trash.Garbadge = nil
    end
end

---Delete all traces
function Threads.clear()
    Order = {}
    uniques = {}
    if Task ~= nil then
        Task.Table = Trash
        Task.Index = "Garbadge"
    end
end

---Gives boolean that is any task is running
function Threads.isDownloadRunning()
    return System.getAsyncState() == 0 or #Order ~= 0 or Task ~= nil
end

---You can use Network function in here if you sure that your function is safe
function Threads.netActionUnSafe(foo)
    if not net_inited then
        Network.init()
        local result = foo()
        Network.term()
        return result
    else
        return foo()
    end
end

---Add Network function that uses curl in Task and execute it
function Threads.netActionSafe(foo)
    repeat until System.getAsyncState() ~= 0
    return Threads.netActionUnSafe(foo)
end

---Checks if given parameters is enough to execute task
local function taskcheck(T)
    local task = T
    if task.Type == "FileDownload" then
        if task.Link and task.Path then
            return true
        end
    else
        return true
    end
    return false
end

---@param UniqueKey any
---@param T table of parameters
---@param foo function
---Adds task to order with given `T` parameters
local function taskete(UniqueKey, T, foo)
    if UniqueKey and uniques[UniqueKey] and taskcheck(T) or not UniqueKey then
        return false
    end
    local newTask = {
        Type = T.Type,
        Link = T.Link,
        Table = T.Table,
        Index = T.Index,
        DestPath = T.DestPath,
        Header1 = T.Header1 or "",
        Header2 = T.Header2 or "",
        Header3 = T.Header3 or "",
        Header4 = T.Header4 or "",
        MaxHeight = T.MaxHeight,
        MaxWidth = T.MaxWidth,
        OnComplete = T.OnComplete,
        Extract = T.Extract,
        Path = T.Path and ("ux0:data/noboru/" .. T.Path) or IMAGE_CACHE_PATH,
        Retry = 3,
        HttpMethod = T.HttpMethod or GET_METHOD,
        PostData = T.PostData or "",
        ContentType = T.ContentType or XWWW,
        Cookie = T.Cookie or "",
        UniqueKey = UniqueKey
    }
    if type(newTask.Link) == "table" then
        local t = newTask.Link
        newTask.Link = t.Link
        newTask.Header1 = t.Header1 or newTask.Header1 or ""
        newTask.Header2 = t.Header2 or newTask.Header2 or ""
        newTask.Header3 = t.Header3 or newTask.Header3 or ""
        newTask.Header4 = t.Header4 or newTask.Header4 or ""
        newTask.HttpMethod = t.HttpMethod or newTask.HttpMethod or GET_METHOD
        newTask.PostData = t.PostData or newTask.PostData or ""
        newTask.ContentType = t.ContentType or newTask.ContentType or XWWW
        newTask.Cookie = t.Cookie or newTask.Cookie or ""
    end
    if type(newTask.Link) == "string" then
        newTask.Link = newTask.Link:match("^(.-)%s*$") or ""
        newTask.Link = newTask.Link:gsub("([^%%])%%([^%%])", "%1%%%%%2"):gsub(" ", "%%%%20"):gsub("([^%%])%%$", "%1%%%%"):gsub("^%%([^%%])", "%%%%%1")
    end
    newTask.Proxy = Settings.UseProxy and (Settings.ProxyIP..":"..Settings.ProxyPort) or "";
    newTask.ProxyAuth = Settings.UseProxyAuth and Settings.ProxyAuth or "";
    foo(newTask)
    uniques[UniqueKey] = newTask
    return true
end

local function taskinsert(task)
    table.insert(Order, 1, task)
end

---@param UniqueKey string
---@param T table
---@return boolean
---Inserts task to threads
function Threads.insertTask(UniqueKey, T)
    return taskete(UniqueKey, T, taskinsert)
end

local function task_add(task)
    Order[#Order + 1] = task
end

---@param UniqueKey string
---@param T table
---@return boolean
---Adds task to threads
function Threads.addTask(UniqueKey, T)
    return taskete(UniqueKey, T, task_add)
end

---Terminates Threads functions and net features
function Threads.terminate()
    if net_inited then
        Threads.clear()
        while Task do
            Threads.update()
        end
        Network.term()
        net_inited = false
    end
end

function Threads.getProgress(UniqueKey)
    local task = uniques[UniqueKey]
    if task then
        if Task == task then
            if task.Type == "ImageDownload" or task.Type == "StringRequest" or task.Type == "FileDownload" or (task.Type == "Image" and task.Link) then
                return math.max(math.min(1, Network.getDownloadedBytes() / Network.getTotalBytes()), 0)
            else
                return 1
            end
        else
            return 0
        end
    end
    return 0
end

---@param UniqueKey string
---Removes task by `UniqueKey`
function Threads.remove(UniqueKey)
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
---Checks if task is in order by `UniqueKey`
function Threads.check(UniqueKey)
    return uniques[UniqueKey] ~= nil
end

---@return number
---Returns count of bytes downloaded by Threads functions
function Threads.getMemoryDownloaded()
    return bytes
end

---@return integer number of tasks
---Returns quantity of tasks in order
function Threads.getTasksNum()
    return #Order + (Task and 1 or 0)
end
