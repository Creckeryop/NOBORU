local Uniques       = {}
local Order         = {}
local OrderCount    = 0
local Num           = 0
local NetInited     = false
local InsideF       = false

local bytes = 0

local CreateTask = function (params)
    local Task = {
        Type = params.Type or "Skip",
        Path = params.Path,
        Link = params.Link,
        F = params.F,
        Save = params.Save,
        Unique = params.Unique or false,
        OnLaunch = params.OnLaunch or function () end
    }
    if params.Unique == false then
        Console.writeLine("Task Creation Error: UniqueKey = \"false\" bad idea", Color.new(255, 0, 0))
        return nil
    end
    if (Task.Type == "FileDownload" or Task.Type == "StringDownload") and Task.Link == nil then
        Console.writeLine("Task Creation Error: No Link given ", Color.new(255, 0, 0))
        return nil
    end
    if Task.Type == "FileDownload" then
        if Task.Path == nil then
            Console.writeLine("Task Creation Error: No Path value found ", Color.new(255, 0, 0))
            return nil
        else
            Task.Path = "ux0:data/Moondayo/"..Task.Path
        end
    elseif Task.Type == "StringDownload" then
        if Task.Save == nil then
            Console.writeLine("Task Creation Error: No Save function found ", Color.new(255, 0, 0))
            return nil
        end
    elseif Task.Type == "ImageLoad" then
        if Task.Save == nil then
            Console.writeLine("Task Creation Error: No Save function found ", Color.new(255, 0, 0))
            return nil
        elseif Task.Path == nil then
            Console.writeLine("Task Creation Error: No Path value found ", Color.new(255, 0, 0))
            return nil
        else
            Task.Path = "ux0:data/Moondayo/"..Task.Path
        end
    elseif Task.Type == "Coroutine" then
        if type(Task.F) ~= "function" then
            Console.writeLine("Task Creation Error: No Coroutine function found ", Color.new(255, 0, 0))
            return nil
        else
            Task.F = coroutine.create(Task.F)
        end
    elseif Task.Type == "Skip" then
        return nil
    end
    if Task.Unique then
        if Uniques[Task.Unique] == nil then
            Uniques[Task.Unique] = Task
        else
            Console.writeLine("Task Creation Error: Task isn't unique ", Color.new(255, 0, 0))
            return nil
        end
    end
    Task.Num = Num
    Task.OnComplete = function ()
        if params.OnComplete then
            params.OnComplete()
        end
        Console.writeLine(string.format('[0x%05X] "%s" Task Completed!', Task.Num, Task.Type),Color.new(0,0,255))
    end
    Console.writeLine(string.format('[0x%05X] "%s" Task Created!', Task.Num, Task.Type),Color.new(0,255,0))
    Num = Num + 1
    return Task
end

Threads = {
    Update = function ()
        if OrderCount == 0 or System.getAsyncState() == 0 then
            return
        end
        local Task = Order[1]
        if not Task.Launched then
            if Task.Type == "StringDownload" then
                Network.init()
                NetInited = true
                Network.requestStringAsync(Task.Link)
            elseif Task.Type == "FileDownload" then
                if System.doesFileExist(Task.Path) then
                    System.deleteFile(Task.Path)
                end
                Network.init()
                NetInited = true
                Network.downloadFileAsync(Task.Link, Task.Path)
            elseif Task.Type == "ImageLoad" then
                if System.doesFileExist(Task.Path) then
                    Graphics.loadImageAsync(Task.Path)
                else
                    Console.writeLine(string.format('File for ImageLoad not Found [0x%05X] "%s"',Task.Num,Task.Type),Color.new(255,0,0))
                    Task.Type = "Skip"
                end
            end
            Task.Launched = true
            if Task.Type ~= "Skip" then
                Task.OnLaunch()
            end
        else
            if Task.Type == "StringDownload" or Task.Type == "FileDownload" then
                Network.term()
                NetInited = false
            end
            if Task.Type == "StringDownload" then
                local content = System.getAsyncResult()
                bytes = bytes + string.len(content)
                Task.Save(content)
            elseif Task.Type == "ImageLoad" then
                Task.Save(System.getAsyncResult())
            elseif Task.Type == "FileDownload" then
                if System.doesFileExist(Task.Path) then
                    local f = System.openFile(Task.Path, FREAD)
                    bytes = bytes + System.sizeFile (f)
                    System.closeFile(f)
                else
                    Console.writeLine(string.format('[0x%05X]File "%s" not downloaded', Task.Num, Task.Path), Color.new(255,0,0))
                    Task.OnComplete = function() end
                end
            elseif Task.Type == "Coroutine" then
                if coroutine.status(Task.F) ~= "dead" then
                    InsideF = true
                    Task.Result = {coroutine.resume(Task.F)}
                    InsideF = false
                    if not (Task.Result[2] and Task.Destroy) then
                        return
                    else
                        if Task.Destroy then
                            Console.writeLine(string.format('[0x%05X] skiping task!',Task.Num),Color.new(255,255,0))
                        end
                    end
                else
                    if Task.Save and Task.Result and Task.Result[1] then
                        Task.Save(select(2, unpack(Task.Result)))
                    end
                    if Task.Result and not Task.Result[1] then
                        Console.writeLine("Coroutine error: "..Task.Result[2])
                        Task.OnComplete = function() end
                    end
                end
            end
            if Task.Unique then
                Uniques[Task.Unique] = nil
            end
            if Task.Type == "Skip" then
                Console.writeLine(string.format('[0x%05X] skiping task!',Task.Num),Color.new(255,255,0))
            end
            table.remove(Order, 1)
            OrderCount = OrderCount - 1
            while OrderCount>0 and Order[1].Type == "Skip" do
                if Order[1].Unique then
                    Uniques[Order[1].Unique] = nil
                end
                Console.writeLine(string.format('[0x%05X] skiping task!',Order[1].Num),Color.new(255,255,0))
                table.remove(Order, 1)
                OrderCount = OrderCount - 1
            end
            Task.OnComplete()
        end
    end,
    Clear = function ()
        if OrderCount == 0 then return end
        local Task = Order[1]
        if Task.Launched then
            if Task.Type == "StringDownload" then
                Task.Save = function(a) end
            elseif Task.Type == "ImageDownload" then
                Task.Save = function(p) if p~=nil then Graphics.freeImage(p) end end
            elseif Task.Type == "Coroutine" then
                Task.Save = function (a) end
            end
            Task.OnComplete = function () end
            Task.Destroy = true
            OrderCount = 1
        else
            if NetInited then
                Network.term()
                NetInited = false
            end
            OrderCount = 0
        end
        for i = 2, #Order do
            if Order[i].Unique then
                Uniques[Order[i].Unique] = nil
            end
            Order[i] = nil
        end
    end,
    DeleteUnique = function (UniqueKey)
        if Uniques[UniqueKey] ~= nil then
            local Task = Uniques[UniqueKey]
            if Task.Launched then
                if Task.Type == "StringDownload" then
                    Task.Save = function (a) end
                elseif Task.Type == "ImageDownload" then
                    Task.Save = function (p) if p~=nil then Graphics.freeImage(p) end end
                elseif Task.Type == "Coroutine" then
                    Task.Save = function (a) end
                end
            else
                Task.Type = "Skip"
            end
            Task.OnComplete = function () end
            Task.Destroy = true
            Uniques[UniqueKey] = nil
        end
    end,
    DeleteById = function (ID)
        for i = 1, #Order do
            if Order[i].Num == ID then
                local Task = Order[i]
                if Task.Launched then
                    if Task.Type == "StringDownload" then
                        Task.Save = function (a) end
                    elseif Task.Type == "ImageDownload" then
                        Task.Save = function (p) if p~=nil then Graphics.freeImage(p) end end
                    elseif Task.Type == "Coroutine" then
                        Task.Save = function (a) end
                    end
                else
                    Task.Type = "Skip"
                end
                Task.OnComplete = function () end
                Task.Destroy = true
                if Task.Unique then
                    Uniques[Task.Unique] = nil
                end
                break
            end
        end
    end,
    AddTask = function (params)
        local Task = CreateTask(params)
        if Task == nil then return end
        OrderCount = OrderCount + 1
        Order[#Order + 1] = Task
        return Task.Num
    end,
    InsertTask = function (params)
        local Task = CreateTask(params)
        if Task == nil then return end
        if OrderCount == 0 or not Order[1].Launched then
            table.insert(Order, 1, Task)
        else
            table.insert(Order, 2, Task)
        end
        OrderCount = OrderCount + 1
        return Task.Num
    end,
    RunTask = function (params)
        if InsideF then
            local Task = CreateTask(params)
            if Task == nil then return end
            Task.OnLaunch()
            if Task.Type == "StringDownload" then
                if not NetInited then
                    Network.init()
                end
                Network.requestStringAsync(Task.Link)
                while System.getAsyncState() == 0 do
                    coroutine.yield(false)
                end
            elseif Task.Type == "FileDownload" then
                if System.doesFileExist(Task.Path) then
                    System.deleteFile(Task.Path)
                end
                if not NetInited then
                    Network.init()
                end
                Network.downloadFileAsync(Task.Link, Task.Path)
                while System.getAsyncState() == 0 do
                    coroutine.yield(false)
                end
            elseif Task.Type == "ImageLoad" then
                if System.doesFileExist(Task.Path) then
                    Graphics.loadImageAsync(Task.Path)
                    while System.getAsyncState() == 0 do
                        coroutine.yield(false)
                    end
                else
                    Console.writeLine(string.format('File for ImageLoad not Found [0x05X] "%s"',Task.Num,Task.Type),Color.new(255,0,0))
                    Task.Type = "Skip"
                end
            end
            if (Task.Type == "StringDownload" or Task.Type == "FileDownload") and not NetInited then
                Network.term()
            end
            if Task.Type == "StringDownload" or Task.Type == "ImageLoad" then
                Task.Save(System.getAsyncResult())
            elseif Task.Type == "Coroutine" then
                while true do
                    if coroutine.status(Task.F) ~= "dead" then
                        Task.Result = {coroutine.resume(Task.F)}
                        coroutine.yield(Task.Result[2])
                    else
                        if Task.Save and Task.Result and Task.Result[1] then
                            Task.Save(select(2, unpack(Task.Result)))
                        end
                        if Task.Result and not Task.Result[1] then
                            Console.writeLine("Coroutine error: "..Task.Result[2])
                        end
                        break
                    end
                end
            end
            if Task.Unique then
                Uniques[Task.Unique] = nil
            end
            coroutine.yield(true)
            Task.OnComplete()
        else
            Console.writeLine("Trying to access to RunTask not from Task's F")
        end
    end,
    GetMemDownloaded = function ()
        return bytes
    end,
    CheckUnique = function (UniqueKey)
        return Uniques[UniqueKey] ~= nil
    end,
    CheckById = function (ID)
        for i=1, #Order do
            if Order.Num == ID then
                return true
            end
        end
        return false
    end
}