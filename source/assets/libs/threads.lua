dofile "app0:assets/libs/net.lua"
local Order = {}
local OrderCount = 0

Threads = {
    Update = function ()
        if OrderCount > 0 then
            local Task = Order[1]
            if coroutine.status(Task.Coroutine) ~= "dead" then
                coroutine.resume(Task.Coroutine)
            else
                table.remove(Order, 1)
                OrderCount = OrderCount - 1
            end
        end
        Net.Update()
    end,
    getManga = function(parser, page)

    end,
    getMangaImage = function (manga)
        
    end
}
