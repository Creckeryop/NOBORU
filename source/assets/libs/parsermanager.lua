local order = {}
local order_count = 0

local task = nil

local parser

local PARSERS_UPDATE = 1
local PARSERS_DOWNLOADING_MANGA = 2
local PARSERS_GETTING_CHAPTER_INFO = 3

local status

ParserManager = {
    update = function()
        if task == nil then
            if order[1] ~= nil then
                task = order[1]
                table.remove(order, 1)
                order_count = order_count - 1
                task.update = coroutine.create(task.f)
            end
        else
            if coroutine.status(task.update) == "dead" then
                if task.type ~= "Update" then
                    task.table[task.index].done = true
                end
                task = nil
            else
                local _, isSafeToleave = coroutine.resume(task.update)
                if task.stop and isSafeToleave then
                    task = nil
                end
            end
        end
    end,
    setParser = function(new_parser)
        parser = new_parser
    end,
    getParserList = function()
        local list = {}
        for i = 1, #Parsers do
            list[i] = Parsers[i]
        end
        return list
    end,
    getMangaListAsync = function(i, table, index)
        if parser == nil or (task ~= nil and task.table == table and task.index == index) then
            return
        end
        for _, v in ipairs(order) do
            if v.table == table and v.index == index then
                return
            end
        end
        table[index] = {}
        local new_task = {
            type = "MangaList",
            f = function()
                parser:getManga(i, table, index)
            end,
            table = table,
            index = index
        }
        order_count = order_count + 1
        order[order_count] = new_task
    end,
    getChaptersAsync = function(manga)
        if manga.parser == nil or (task ~= nil and task.table == manga and task.index == "chapters") then
            return
        end
        for _, v in ipairs(order) do
            if v.table == manga and v.index == "chapters" then
                return
            end
        end
        manga.chapters = {}
        local new_task = {
            type = "Chapters",
            f = function()
                manga.parser:getChapters(manga, "chapters")
            end,
            table = manga,
            index = "chapters"
        }
        order_count = order_count + 1
        order[order_count] = new_task
    end,
    getChapterInfoAsync = function(chapter)
        if chapter.manga == nil or chapter.manga.parser == nil or (task ~= nil and task.table == chapter and task.index == "pages") then
            return
        end
        for _, v in ipairs(order) do
            if v.table == chapter and v.index == "pages" then
                return
            end
        end
        chapter.pages = {}
        local new_task = {
            type = "Info",
            f = function()
                chapter.manga.parser:getChapterInfo(chapter, "pages")
            end,
            table = chapter,
            index = "pages"
        }
        order_count = order_count + 1
        order[order_count] = new_task
    end,
    updateParserList = function()
        local new_task = {
            type = "Update",
            f = function()
                if System.doesFileExist(LUA_APPDATA_DIR .. "parsers.lua") then
                    System.deleteFile(LUA_APPDATA_DIR .. "parsers.lua")
                end
                Net.downloadFileAsync("https://raw.githubusercontent.com/Creckeryop/vsKoob-parsers/master/parsers.lua", LUA_APPDATA_DIR .. "parsers.lua")
                while Net.check("https://raw.githubusercontent.com/Creckeryop/vsKoob-parsers/master/parsers.lua", LUA_APPDATA_DIR .. "parsers.lua") do
                    coroutine.yield()
                end
                dofile(LUA_APPDATA_DIR .. "parsers.lua")
            end
        }
        order_count = order_count + 1
        order[order_count] = new_task
    end,
    getActiveParser = function()
        return parser
    end,
    clear = function ()
        order = {}
        order_count = 0
        if task~=nil then
            task.stop = true
        end
    end
}
