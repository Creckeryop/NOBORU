ParserManager = {}

local Order = {}

local Task = nil
local Trash = {}

local uniques = {}

function ParserManager.update()
    if #Order == 0 and not Task then return end
    if not Task then
        Task = table.remove(Order, 1)
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
            uniques[Task.Table] = nil
            Task = nil
        else
            local _, isSafeToleave = coroutine.resume(Task.Update)
            if Task.Stop and isSafeToleave then
                uniques[Task.Table] = nil
                Task = nil
            end
            if not _ then
                Console.error(isSafeToleave)
            end
        end
    end
end

function ParserManager.getMangaListAsync(mode, parser, i, Table, data)
    if not parser or uniques[Table] then return end
    Console.write("Task created")
    if mode == "SEARCH" then
        data = data:gsub("%%", "%%%%25"):gsub("!", "%%%%21"):gsub("#", "%%%%23"):gsub("%$", "%%%%24"):gsub("&", "%%%%26"):gsub("'", "%%%%27"):gsub("%(", "%%%%28"):gsub("%)", "%%%%29"):gsub("%*", "%%%%2A"):gsub("%+", "%%%%2B"):gsub(",", "%%%%2C"):gsub("%.", "%%%%2E"):gsub("/", "%%%%2F"):gsub(" ", "%+")
    end
    local T = {
        Type = "MangaList",
        F = function()
            if mode == "POPULAR" then
                if parser.getPopularManga then
                    parser:getPopularManga(i, Table)
                else
                    Console.write(parser.Name .. " doesn't support getPopularManga function", COLOR_GRAY)
                end
            elseif mode == "LATEST" then
                if parser.getLatestManga then
                    parser:getLatestManga(i, Table)
                else
                    Console.write(parser.Name .. " doesn't support getLatestManga function", COLOR_GRAY)
                end
            elseif mode == "SEARCH" then
                if parser.searchManga then
                    parser:searchManga(data, i, Table)
                else
                    Console.write(parser.Name .. " doesn't support searchManga function", COLOR_GRAY)
                end
            end
        end,
        Table = Table
    }
    Order[#Order + 1] = T
    uniques[Table] = T
end

function ParserManager.getChaptersAsync(manga, Table, Insert)
    local parser = GetParserByID(manga.ParserID)
    if not parser or uniques[Table] then
        return
    end
    local T = {
        Type = "Chapters",
        F = function()
            parser:getChapters(manga, Table)
        end,
        Table = Table
    }
    if Insert then
        table.insert(Order, 1, T)
    else
        Order[#Order + 1] = T
    end
    uniques[Table] = T
end

function ParserManager.prepareChapter(chapter, Table, Insert)
    local parser = GetParserByID(chapter.Manga.ParserID)
    if not parser or uniques[Table] then
        return
    end
    local T = {
        Type = "PrepareChapter",
        F = function()
            parser:prepareChapter(chapter, Table)
        end,
        Table = Table
    }
    if Insert then
        table.insert(Order, 1, T)
    else
        Order[#Order + 1] = T
    end
    uniques[Table] = T
end

function ParserManager.getPageImage(parserID, Link, Table, Insert)
    local parser = GetParserByID(parserID)
    if not parser or uniques[Table] then return end
    local T = {
        Type = "getPageImage",
        F = function()
            parser:loadChapterPage(Link, Table)
            coroutine.yield(true)
            if Table.Link then
                Threads.insertTask(Table, {
                    Type = "ImageDownload",
                    Link = Table.Link,
                    Table = Table,
                    Index = "Image"
                })
            end
        end,
        Table = Table
    }
    if Insert then
        table.insert(Order, 1, T)
    else
        Order[#Order + 1] = T
    end
    uniques[Table] = T
end

function ParserManager.check(Table)
    return uniques[Table] ~= nil
end

function ParserManager.remove(Table)
    if uniques[Table] then
        if uniques[Table] == Task then
            Task.Table = Trash
            Task.Stop = true
        else
            uniques[Table].Type = "Skip"
        end
        uniques[Table] = nil
    end
end

function ParserManager.updateParserList(Table, Insert)
    if uniques[Table] then
        return
    end
    local T = {
        Type = "Update",
        F = function()
            ClearParsers()
            local file = {}
            Threads.insertTask(file, {
                Type = "StringRequest",
                Link = "https://github.com/Creckeryop/vsKoob-parsers/tree/master/parsers",
                Table = file,
                Index = "string"
            })
            while not file.string do
                coroutine.yield(false)
            end
            for link, name in file.string:gmatch('href="([^"]-.lua)">(.-)<') do
                local link2row = "https://raw.githubusercontent.com" .. link:gsub("/blob", ""):gsub("%%", "%%%%")
                local path2row = "ux0:data/noboru/parsers/" .. name
                Threads.addTask(link2row, {
                    Type = "FileDownload",
                    Link = link2row,
                    Path = "parsers/" .. name
                })
                while Threads.check(link2row) do
                    coroutine.yield(false)
                end
                if System.doesFileExist(path2row) then
                    local suc, err = pcall(function()
                        dofile(path2row)
                    end)
                    if not suc then
                        Console.error(string.format("Cant load %s:%s", path2row, err))
                    end
                end
            end
        end,
        Table = Table
    }
    if Insert then
        table.insert(Order, 1, T)
    else
        Order[#Order + 1] = T
    end
    uniques["Update"] = T
end

function ParserManager.clear()
    Order = {}
    uniques = {}
    if Task then
        Task.Stop = true
    end
end
