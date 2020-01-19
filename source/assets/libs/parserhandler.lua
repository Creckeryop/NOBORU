local ffi = require 'ffi'
local Order = {}
local OrderCount = 0

local Task = nil
local Trash = {}

local Uniques = {}

ParserManager = {
    Update = function()
        if OrderCount == 0 and Task == nil then return end
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
                Uniques[Task.Table] = nil
                Task = nil
            else
                local _, isSafeToleave = coroutine.resume(Task.Update)
                if Task.Stop and isSafeToleave then
                    Uniques[Task.Table] = nil
                    Task = nil
                end
            end
        end
    end,
    getMangaListAsync = function(parser, i, Table)
        if parser == nil or Uniques[Table] then return end
        Console.writeLine("Task created")
        local T = {
            Type = "MangaList",
            F = function()
                parser:getManga(i, Table)
            end,
            Table = Table
        }
        OrderCount = OrderCount + 1
        Order[OrderCount] = T
        Uniques[Table] = T
    end,
    getChaptersAsync = function(manga, Table, Insert)
        local parser = GetParserByID(manga.ParserID)
        if parser == nil or Uniques[Table] then return end
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
        Uniques[Table] = T
    end,
    prepareChapter = function (chapter, Table, Insert)
        local parser = GetParserByID(chapter.Manga.ParserID)
        if parser == nil or Uniques[Table] then return end
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
        Uniques[Table] = T
    end,
    getPageImage = function (parserID, Link, Table, Insert)
        local parser = GetParserByID(parserID)
        if parser == nil or Uniques[Table] then return end
        local T = {
            Type = "getPageImage",
            F = function()
                parser:loadChapterPage(Link, Table)
                coroutine.yield(true)
                if Table.Link then
                    threads.DownloadImageAsync(Table.Link, Table, "Image", true)
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
        Uniques[Table] = T
    end,
    Check = function(Table)
        return Uniques[Table] ~= nil
    end,
    Remove = function (Table)
        if Uniques[Table] then
            if Uniques[Table] == Task then
                Task.Table = Trash
                Task.Stop = true
            else
                Uniques[Table].Type = "Skip"
            end
            Uniques[Table] = nil
        end
    end,
    UpdateParserList = nil,
    Clear = function ()
        Order = {}
        Uniques = {}
        OrderCount = 0
        if Task then
            Task.Stop = true
        end
    end
}
