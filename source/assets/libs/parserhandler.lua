local Order = {}
local OrderCount = 0

local Task = nil
local Trash = {}

ParserManager = {
    Update = function()
        if OrderCount == 0 and Task == nil then
            return
        end
        if Task == nil then
            Task = Order[1]
            table.remove(Order, 1)
            OrderCount = OrderCount - 1
            if Task.Type == "Skip" then
                Task = nil
            else
                Task.Update = coroutine.create(Task.F)
            end
        else
            if coroutine.status(Task.Update) == "dead" then
                if Task.Type ~= "Update" then
                    Task.Table.Done = true
                end
                Task = nil
            else
                local _, isSafeToleave = coroutine.resume(Task.Update)
                if Task.Stop and isSafeToleave then
                    Task = nil
                end
            end
        end
    end,
    getMangaListAsync = function(parser, i, Table)
        if parser == nil or ParserManager.Check(Table) then return end
        Console.writeLine("Task created", Color.new(255,255,255))
        local T = {
            Type = "MangaList",
            F = function()
                parser:getManga(i, Table)
            end,
            Table = Table
        }
        OrderCount = OrderCount + 1
        Order[OrderCount] = T
    end,
    getChaptersAsync = function(manga, Table, Insert)
        local parser = GetParserByID(manga.ParserID)
        if parser == nil or ParserManager.Check(Table) then return end
        local T = {
            Type = "Chapters",
            F = function()
                parser:getChapters(manga, Table)
            end,
            Table = Table
        }
        OrderCount = OrderCount + 1
        if Insert then
            table.insert(Order, 1, T)
        else
            Order[#Order + 1] = T
        end
    end,
    prepareChapter = function (chapter, Table, Insert)
        local parser = GetParserByID(chapter.Manga.ParserID)
        if parser == nil or ParserManager.Check(Table) then return end
        local T = {
            Type = "PrepareChapter",
            F = function()
                parser:prepareChapter(chapter, Table)
            end,
            Table = Table
        }
        OrderCount = OrderCount + 1
        if Insert then
            table.insert(Order, 1, T)
        else
            Order[#Order + 1] = T
        end
    end,
    getPageImage = function (parserID, Link, Table, Insert)
        local parser = GetParserByID(parserID)
        if parser == nil or ParserManager.Check(Table) then return end
        local T = {
            Type = "getPageImage",
            F = function()
                parser:loadChapterPage(Link, Table)
                coroutine.yield(true)
                if Table.Link ~= nil then
                    threads.DownloadImageAsync(Table.Link, Table, "Image")
                end
            end,
            Table = Table
        }
        OrderCount = OrderCount + 1
        if Insert then
            table.insert(Order, 1, T)
        else
            Order[#Order + 1] = T
        end
    end,
    Check = function(Table)
        if Task ~= nil and Task.Table == Table then
            return Task.Type ~= "Skip"
        end
        for _, v in pairs(Order) do
            if v.Table == Table then
                return v.Type ~= "Skip"
            end
        end
        return false
    end,
    Remove = function (Table)
        if Task ~= nil and Task.Table == Table then
            Task.Table = Trash
            Task.Stop = true
            return
        end
        for _, v in pairs(Order) do
            if v.Table == Table then
                v.Type = "Skip"
                return
            end
        end
    end,
    UpdateParserList = nil,
    Clear = function ()
        Order = {}
        OrderCount = 0
        if Task ~= nil then
            Task.Stop = true
        end
    end
}
