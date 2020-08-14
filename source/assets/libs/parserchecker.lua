ParserChecker = {}

local ParserCoroutine = nil

function ParserChecker.update()
    if ParserCoroutine then
        if coroutine.status(ParserCoroutine) ~= "dead" then
            local a, b = coroutine.resume(ParserCoroutine)
            if a then
                
                else
                Console.error(b, 2)
            end
        else
            ParserCoroutine = nil
        end
    end
end

local function F(Parser)
    local name = Parser.Name
    Console.write("Start checking /" .. name .. "/", Color.new(0, 0, 255), 2)
    coroutine.yield()
    local foos = {"getPopularManga", "getLatestManga", "getAZManga", "getLetterManga", "getTagManga", "searchManga", "searchManga", "searchManga"}
    local image_test_chapter = {}
    local Filters = Parser.Filters or {}
    local Checked = {}
    for k, v in ipairs(Filters) do
        v.visible = false
        local default = v.Default
        if v.Type == "check" or v.Type == "checkcross" then
            Checked[k] = {}
            for i, _ in ipairs(v.Tags) do
                Checked[k][i] = false
            end
            if default then
                if v.Type == "checkcross" then
                    for i = 1, #default.include do
                        for e, t in ipairs(v.Tags) do
                            if t == default.include[i] then
                                Checked[k][e] = true
                            end
                        end
                    end
                    for i = 1, #default.exclude do
                        for e, t in ipairs(v.Tags) do
                            if t == default.exclude[i] then
                                Checked[k][e] = "cross"
                            end
                        end
                    end
                elseif v.Type == "check" then
                    for i = 1, #default do
                        for e, t in ipairs(v.Tags) do
                            if t == default[i] then
                                Checked[k][e] = true
                            end
                        end
                    end
                end
            end
        elseif v.Type == "radio" then
            Checked[k] = 1
            if default then
                for e, t in ipairs(v.Tags) do
                    if t == default then
                        Checked[k] = e
                    end
                end
            end
        end
    end
    local filter = {}
    for i, fil in ipairs(Filters) do
        if fil.Type == "check" then
            local list = {}
            for i, v in ipairs(Checked[i]) do
                if v then
                    list[#list + 1] = fil.Tags[i]
                end
            end
            filter[#filter + 1] = list
            filter[fil.Name] = list
        elseif fil.Type == "checkcross" then
            local include = {}
            for j, c in ipairs(Checked[i]) do
                if c == true then
                    include[#include + 1] = fil.Tags[j]
                end
            end
            local exclude = {}
            for j, c in ipairs(Checked[i]) do
                if c == "cross" then
                    exclude[#exclude + 1] = fil.Tags[j]
                end
            end
            filter[#filter + 1] = {
                include = include,
                exclude = exclude
            }
            filter[fil.Name] = filter[#filter]
        elseif fil.Type == "radio" then
            filter[#filter + 1] = fil.Tags[Checked[i]] or ""
            filter[fil.Name] = fil.Tags[Checked[i]] or ""
        end
    end
    local search_i = 1
    local search_words = {"a", "Naruto", "one piece"}
    for k, v in ipairs(foos) do
        local f = Parser[v]
        if f then
            local Manga = {}
            local add_text = ""
            if v == "getLetterManga" then
                local letter = (Parser.Letters or {})[1]
                if letter then
                    add_text = letter
                    f(Parser, 1, Manga, letter)
                end
            elseif v == "getTagManga" then
                local tag = (Parser.Tags or {})[1]
                if tag then
                    add_text = tag
                    f(Parser, 1, Manga, tag)
                end
            elseif v == "searchManga" then
                local search_word = search_words[search_i] or ""
                search_i = search_i + 1
                add_text = search_word
                f(Parser, search_word, 1, Manga, filter)
            else
                f(Parser, 1, Manga)
            end
            Console.write("Checking /" .. name .. ":" .. v .. "(\"" .. add_text .. "\")/", Color.new(0, 255, 0), 2)
            while ParserManager.check(Manga) do
                coroutine.yield()
            end
            local count = #(Manga or {})
            Console.write("Got '" .. count .. "' manga", nil, 2)
            if count == 0 then
                Console.error("function: " .. name .. ":" .. v .. "(\"" .. add_text .. "\") probably have an error", 2)
            else
                local mangas_to_check = math.min(3, count)
                local ch_s = {}
                local manga = nil
                Console.write("Checking " .. mangas_to_check .. " first mangas for having chapters", Color.new(0, 255, 0), 2)
                local log = {}
                for i = 1, mangas_to_check do
                    local Chapters = {}
                    Parser:getChapters(Manga[i], Chapters)
                    while ParserManager.check(Chapters) do
                        coroutine.yield()
                    end
                    if #ch_s < #Chapters then
                        ch_s = Chapters
                        manga = Manga[i]
                    end
                    log[#log + 1] = #(Chapters or {})
                end
                Console.write("Done got '" .. table.concat(log, ", ") .. "'!", nil, 2)
                if manga then
                    local chapters_to_check = math.min(3, #ch_s)
                    Console.write("Checking " .. chapters_to_check .. " first chapters of " .. manga.Name .. " for having pages", Color.new(0, 255, 0), 2)
                    log = {}
                    for i = 1, chapters_to_check do
                        local Images = {}
                        Parser:prepareChapter(ch_s[i], Images)
                        while ParserManager.check(Images) do
                            coroutine.yield()
                        end
                        if #Images > #image_test_chapter then
                            image_test_chapter = Images
                        end
                        log[#log + 1] = #(Images or {})
                    end
                    Console.write("Done got '" .. table.concat(log, ", ") .. "' images!", nil, 2)
                else
                    Console.error("No chapters found for first mangas", 2)
                end
            end
        end
    end
    if #image_test_chapter > 0 then
        Console.write("Checking 1 image to download " .. tostring(image_test_chapter[1]), nil, 2)
        local Table = {}
        Parser:loadChapterPage(image_test_chapter[1], Table)
        while ParserManager.check(Table) do
            coroutine.yield()
        end
        Threads.insertTask(Table, {
            Type = "ImageDownload",
            Link = Table.Link,
            Table = Table,
            Index = "Image"
        })
        while Threads.check(Table) do
            coroutine.yield()
        end
        if Table.Image == nil then
            Console.error("Error getting image", 2)
        else
            Table.Image:free()
            Console.write("All OK!", nil, 2)
        end
    end
    Console.write("Checking " .. name .. " done!", COLOR_ROYAL_BLUE, 2)
end

function ParserChecker.addCheck(Parser)
    if ParserCoroutine then
        Console.error("Can't start other check, while one is active, try again later", 2)
    else
        ParserCoroutine = coroutine.create(function()F(Parser) end)
    end
end
