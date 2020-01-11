local Order = {}
local OrderCount = 0
local NetInited = false

Net = {
    Update = function ()
        if OrderCount == 0 and NetInited then
            Network.term()
            NetInited = false
        elseif OrderCount > 0 and not NetInited then
            Network.init()
            NetInited = true
        end
        if OrderCount == 0 or System.getAsyncState() == 0 then
            return
        end
        local Task = Order[1]
        if not Task.Launched then
            if Task.Type == "String" then
                Network.requestStringAsync(Task.Link)
            elseif Task.Type == "File" then
                if System.doesFileExist(Task.Path) then
                    System.deleteFile(Task.Path)
                end
                Network.downloadFileAsync(Task.Link, Task.Path)
            end
            Task.Launched = true
        else
            if Task.Type == "String" then
                Task.OnComplete(System.getAsyncResult())
            end
            table.remove(Order, 1)
            OrderCount = OrderCount - 1
        end
    end,
    Clear = function ()
        if OrderCount == 0 then return end
        local Task = Order[1]
        if Task.Launched then
            if Task.Type == "String" then
                Task.OnComplete = function(a) end
            end
            OrderCount = 1
        else
            OrderCount = 0
        end
        for i = 2, #Order do
            Order[i] = nil
        end
    end,
    AddTask = function (params)
        local Task = {Type = params.Type or "Skip", Path = params.Path, OnComplete = params.OnComplete}
        if Task.Type == "File" then
            if Task.Path == nil then
                Task.Type = "Skip"
                Console.addLine("Task Creation Error: No Path found", Color.new(255, 0, 0))
                return
            end
        elseif Task.Type == "String" then
            if Task.OnComplete == nil then
                Task.Type = "Skip"
                Console.addLine("Task Creation Error: No OnComplete function found", Color.new(255, 0, 0))
                return
            end
        elseif Task.Type == "Skip" then
            return
        end
        OrderCount = OrderCount + 1
        Order[#Order + 1] = Task
    end
}