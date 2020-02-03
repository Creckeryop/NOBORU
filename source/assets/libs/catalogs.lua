Catalogs = {}
local Slider = Slider()
local TOUCH = TOUCH()

local Parser = nil
local TouchTimer = Timer.new()

local mode = "CATALOGS"

local getMangaMode = "POPULAR"
local searchData = ""

local DownloadedImage = {}
local page = 1
local Results = {}
local Parsers = {}

local abs, ceil, floor, max, min = math.abs, math.ceil, math.floor, math.max, math.min

StartSearch = false

local function freeMangaImage(manga)
    if manga and manga.ImageDownload then
        Threads.remove(manga)
        if manga.Image then
            manga.Image:free()
        end
        manga.ImageDownload = nil
    end
end

local function loadMangaImage(manga)
    if manga.Path and System.doesFileExist("ux0:data/noboru/" .. manga.Path) then
        Threads.addTask(manga, {
            Type = "Image",
            Path = manga.Path,
            Table = manga,
            Index = "Image"
        })
    else
        Threads.addTask(manga, {
            Type = "ImageDownload",
            Link = manga.ImageLink,
            Table = manga,
            Index = "Image",
            Path = Cache.isCached(manga) and manga.Path or nil
        })
    end
end

local function UpdateMangas()
    if Slider.V == 0 and Timer.getTime(TouchTimer) > 300 then
        local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 12)) * 4 + 1)
        if #DownloadedImage > 12 then
            local new_table = {}
            for _, i in ipairs(DownloadedImage) do
                if i < start or i > min(#Results, start + 11) then
                    freeMangaImage(Results[i])
                else
                    new_table[#new_table + 1] = i
                end
            end
            DownloadedImage = new_table
        end
        for i = start, min(#Results, start + 11) do
            local manga = Results[i]
            if not manga.ImageDownload then
                loadMangaImage(manga)
                manga.ImageDownload = true
                DownloadedImage[#DownloadedImage + 1] = i
            end
        end
    else
        local new_table = {}
        for _, i in ipairs(DownloadedImage) do
            local manga = Results[i]
            if Threads.check(manga) and (Details.getFade() == 0 or manga ~= Details.getManga()) then
                Threads.remove(manga)
                manga.ImageDownload = nil
            else
                new_table[#new_table + 1] = i
            end
        end
        DownloadedImage = new_table
    end
end

local function selectManga(index)
    local manga = Results[index]
    if manga then
        Details.setManga(manga)
    end
end

local function selectParser(index)
    local parser = GetParserList()[index]
    if parser then
        Parser = parser
        Catalogs.setMode("MANGA")
    end
end

local chapters_space
local cache_space
local sure_clear_library
local sure_clear_chapters
local sure_clear_all_cache
local sure_clear_cache
local function selectSetting(index)
    local item = Settings:list()[index]
    if item then
        if item == "Language" then
            Settings:nextLanguage()
        elseif item == "ClearChapters" then
            sure_clear_chapters = sure_clear_chapters + 1
            if sure_clear_chapters == 2 then
                Settings:clearChapters()
                chapters_space = nil
                sure_clear_chapters = 0
            end
        elseif item == "ShowNSFW" then
            Settings:changeNSFW()
        elseif item == "ClearLibrary" then
            sure_clear_library = sure_clear_library + 1
            if sure_clear_library == 2 then
                Settings:clearLibrary()
                sure_clear_library = 0
            end
        elseif item == "ReaderOrientation" then
            Settings:changeOrientation()
        elseif item == "ZoomReader" then
            Settings:changeZoom()
        elseif item == "ClearAllCache" then
            sure_clear_all_cache = sure_clear_all_cache + 1
            if sure_clear_all_cache == 2 then
                cache_space = nil
                Settings:clearAllCache()
                sure_clear_all_cache = 0
            end
        elseif item == "ClearCache" then
            sure_clear_cache = sure_clear_cache + 1
            if sure_clear_cache == 2 then
                cache_space = nil
                Settings:clearCache()
                sure_clear_cache = 0
            end
        elseif item == "ShowAuthor" then
            Notifications.push(Language[Settings.Language].NOTIFICATIONS.DEVELOPER_THING.."\nhttps://github.com/Creckeryop/NOBORU")
        end
        if item ~= "ClearChapters" then
            sure_clear_chapters = 0
        end
        if item ~= "ClearCache" then
            sure_clear_cache = 0
        end
        if item ~= "ClearAllCache" then
            sure_clear_all_cache = 0
        end
        if item ~= "ClearLibrary" then
            sure_clear_library = 0
        end
    end
end

local MangaSelector = Selector:new(-4, 4, -1, 1, function() return max(1, floor((Slider.Y - 20) / (MANGA_HEIGHT + 12)) * 4 + 1) end)
local ParserSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)
local DownloadSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)
local SettingSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)
MangaSelector:xaction(selectManga)
ParserSelector:xaction(selectParser)
DownloadSelector:xaction(function(item)
    ChapterSaver.stopByListItem(ChapterSaver.getDownloadingList()[item])
end)
SettingSelector:xaction(selectSetting)

function Catalogs.input(oldpad, pad, oldtouch, touch)
    if mode == "MANGA" then
        if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            mode = "CATALOGS"
            Catalogs.terminate()
        elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            local new_mode = getMangaMode == "POPULAR" and Parser.getLatestManga and "LATEST" or "POPULAR"
            if getMangaMode ~= new_mode then
                Catalogs.terminate()
                getMangaMode = new_mode
                Notifications.push(getMangaMode == "POPULAR" and Language[Settings.Language].PANEL.MODE_POPULAR or getMangaMode == "LATEST" and Language[Settings.Language].PANEL.MODE_LATEST)
            end
        elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            if Parser.searchManga then
                Keyboard.show(Language[Settings.Language].APP.SEARCH, searchData, 128, TYPE_DEFAULT, MODE_TEXT, OPT_NO_AUTOCAP)
                StartSearch = true
            end
        end
    elseif mode == "CATALOGS" then
        if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            ParserManager.updateParserList(Parsers)
        end
    elseif mode == "HISTORY" then
        if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            local item = Results[MangaSelector:getSelected()]
            if item then
                Cache.removeHistory(item)
            end
        end
    end
    if touch.x or pad ~= 0 then
        Timer.reset(TouchTimer)
    end
    if mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
        MangaSelector:input(#Results, oldpad, pad, touch.x)
    elseif mode == "CATALOGS" then
        ParserSelector:input(#Parsers, oldpad, pad, touch.x)
    elseif mode == "DOWNLOAD" then
        DownloadSelector:input(#ChapterSaver.getDownloadingList(), oldpad, pad, touch.x)
    elseif mode == "SETTINGS" then
        SettingSelector:input(#Settings:list(), oldpad, pad, touch.x)
    end
    if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
        TOUCH.MODE = TOUCH.READ
        Slider.TouchY = touch.y
    elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
        if oldtouch.x then
            if TOUCH.MODE == TOUCH.READ then
                if mode == "CATALOGS" then
                    if oldtouch.x > 265 and oldtouch.x < 945 then
                        selectParser(floor((Slider.Y - 10 + oldtouch.y) / 75) + 1)
                    end
                elseif mode == "DOWNLOAD" then
                    if oldtouch.x > 265 and oldtouch.x < 945 then
                        local list = ChapterSaver.getDownloadingList()
                        local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
                        if list[id] then
                            ChapterSaver.stopByListItem(list[id])
                        end
                    end
                elseif mode == "SETTINGS" then
                    if oldtouch.x > 265 and oldtouch.x < 945 then
                        local list = Settings:list()
                        local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
                        if list[id] then
                            selectSetting(id)
                        end
                    end
                elseif mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
                    local start = max(1, floor((Slider.Y - 20) / (MANGA_HEIGHT + 12)) * 4 + 1)
                    for i = start, min(#Results, start + 11) do
                        local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 10) + 610
                        local uy = floor((i - 1) / 4) * (MANGA_HEIGHT + 12) - Slider.Y + 12
                        if oldtouch.x > lx and oldtouch.x < lx + MANGA_WIDTH and oldtouch.y > uy and oldtouch.y < uy + MANGA_HEIGHT then
                            selectManga(i)
                            break
                        end
                    end
                end
            end
        end
        TOUCH.MODE = TOUCH.NONE
    end
    local new_itemID = 0
    if TOUCH.MODE == TOUCH.READ then
        if abs(Slider.V) > 0.1 or abs(Slider.TouchY - touch.y) > 10 then
            TOUCH.MODE = TOUCH.SLIDE
        elseif mode == "CATALOGS" and oldtouch.x > 265 and oldtouch.x < 945 then
            local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
            if GetParserList()[id] then
                new_itemID = id
            end
        elseif mode == "DOWNLOAD" then
            local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
            if ChapterSaver.getDownloadingList()[id] then
                new_itemID = id
            end
        elseif mode == "SETTINGS" then
            local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
            if Settings:list()[id] then
                new_itemID = id
            end
        end
    end
    if Slider.ItemID > 0 and new_itemID > 0 and Slider.ItemID ~= new_itemID then
        TOUCH.MODE = TOUCH.SLIDE
    else
        Slider.ItemID = new_itemID
    end
    if TOUCH.MODE == TOUCH.SLIDE and oldtouch.x and touch.x and touch.x > 240 then
        Slider.V = oldtouch.y - touch.y
    end
end

function Catalogs.update()
    if abs(Slider.V) < 1 then
        Slider.V = 0
    else
        Slider.Y = Slider.Y + Slider.V
        Slider.V = Slider.V / 1.12
    end
    if mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
        UpdateMangas()
        if ParserManager.check(Results) then
            Loading.setMode("BLACK", 600, 272)
        elseif Details.getMode() == "END" then
            Loading.setMode("NONE")
        end
        if mode == "MANGA" then
            Panel.set{
                "L\\R", "Square", "Triangle", "DPad", "Cross", "Circle",
                ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
                Square = getMangaMode == "POPULAR" and Language[Settings.Language].PANEL.MODE_POPULAR or getMangaMode == "LATEST" and Language[Settings.Language].PANEL.MODE_LATEST or getMangaMode == "SEARCH" and string.format(Language[Settings.Language].PANEL.MODE_SEARCHING, searchData),
                Triangle = Parser.searchManga and Language[Settings.Language].PANEL.SEARCH or nil,
                Circle = Language[Settings.Language].PANEL.BACK,
                DPad = Language[Settings.Language].PANEL.CHOOSE,
                Cross = Language[Settings.Language].PANEL.SELECT
            }
        elseif mode == "LIBRARY" then
            Panel.set{
                "L\\R", "DPad", "Cross",
                ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
                DPad = Language[Settings.Language].PANEL.CHOOSE,
                Cross = Language[Settings.Language].PANEL.SELECT
            }
        elseif mode == "HISTORY" then
            Panel.set{
                "L\\R", "DPad", "Cross", "Square",
                ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
                DPad = Language[Settings.Language].PANEL.CHOOSE,
                Cross = Language[Settings.Language].PANEL.SELECT,
                Square = Language[Settings.Language].PANEL.DELETE
            }
        end
        local item = MangaSelector:getSelected()
        if item ~= 0 then
            Slider.Y = Slider.Y + (math.floor((item - 1) / 4) * (MANGA_HEIGHT + 10) + MANGA_HEIGHT / 2 - 232 - Slider.Y) / 8
        end
        if Slider.Y < 0 then
            Slider.Y = 0
            Slider.V = 0
        elseif Slider.Y > ceil(#Results / 4) * (MANGA_HEIGHT + 12) - 512 then
            Slider.Y = max(0, ceil(#Results / 4) * (MANGA_HEIGHT + 12) - 512)
            Slider.V = 0
            if mode == "MANGA" then
                if not Results.NoPages and Parser then
                    if not ParserManager.check(Results) then
                        ParserManager.getMangaListAsync(getMangaMode, Parser, page, Results, searchData)
                        page = page + 1
                    end
                end
            end
        end
        if mode == "LIBRARY" and #Results ~= #Database.getMangaList() then
            Results = Database.getMangaList()
        elseif mode == "HISTORY" then
            Results = Cache.getHistory()
        end
    elseif mode == "CATALOGS" then
        Parsers = GetParserList()
        Panel.set{
            "L\\R", "Triangle", "DPad", "Cross",
            ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
            Triangle = Language[Settings.Language].PANEL.UPDATE,
            DPad = Language[Settings.Language].PANEL.CHOOSE,
            Cross = Language[Settings.Language].PANEL.SELECT
        }
        local item = ParserSelector:getSelected()
        if item ~= 0 then
            Slider.Y = Slider.Y + (item * 75 - 272 - Slider.Y) / 8
        end
        if Slider.Y < -10 then
            Slider.Y = -10
            Slider.V = 0
        elseif Slider.Y > ceil(#Parsers) * 75 - 514 then
            Slider.Y = max(-10, ceil(#Parsers) * 75 - 514)
            Slider.V = 0
        end
    elseif mode == "DOWNLOAD" then
        local list = ChapterSaver.getDownloadingList()
        Panel.set{
            "L\\R", "DPad", "Cross",
            ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
            DPad = Language[Settings.Language].PANEL.CHOOSE,
            Cross = Language[Settings.Language].PANEL.CANCEL
        }
        local item = DownloadSelector:getSelected()
        if item ~= 0 then
            Slider.Y = Slider.Y + (item * 75 - 272 - Slider.Y) / 8
        end
        if Slider.Y < -10 then
            Slider.Y = -10
            Slider.V = 0
        elseif Slider.Y > ceil(#list) * 75 - 514 then
            Slider.Y = max(-10, ceil(#list) * 75 - 514)
            Slider.V = 0
        end
    elseif mode == "SETTINGS" then
        local list = Settings:list()
        Panel.set{
            "L\\R", "DPad", "Cross",
            ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
            DPad = Language[Settings.Language].PANEL.CHOOSE,
            Cross = Language[Settings.Language].PANEL.SELECT
        }
        local item = SettingSelector:getSelected()
        if item ~= 0 then
            Slider.Y = Slider.Y + (item * 75 - 272 - Slider.Y) / 8
        end
        if Slider.Y < -10 then
            Slider.Y = -10
            Slider.V = 0
        elseif Slider.Y > ceil(#list) * 75 - 514 then
            Slider.Y = max(-10, ceil(#list) * 75 - 514)
            Slider.V = 0
        end
    end
    if StartSearch then
        if Keyboard.getState() ~= RUNNING then
            if Keyboard.getState() == FINISHED then
                local data = Keyboard.getInput()
                Console.write('Searching for "' .. data .. '"')
                if data:gsub("%s", "") ~= "" then
                    Catalogs.terminate()
                    searchData = data
                    getMangaMode = "SEARCH"
                    Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.SEARCHING, data))
                end
            end
            StartSearch = false
            Keyboard.clear()
        end
    end
end
local download_bar = 0
function Catalogs.draw()
    Graphics.fillRect(955, 960, 0, 544, Color.new(160, 160, 160))
    local scroll_height
    if mode == "CATALOGS" then
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#Parsers, start + 9) do
            local parser = Parsers[i]
            Graphics.fillRect(264, 946, y - 75, y, Color.new(0, 0, 0, 32))
            Graphics.fillRect(265, 945, y - 74, y, COLOR_WHITE)
            Font.print(FONT26, 275, y - 70, parser.Name, COLOR_BLACK)
            local lang_text = Language[Settings.Language].PARSERS[parser.Lang] or parser.Lang or ""
            Font.print(FONT16, 935 - Font.getTextWidth(FONT16, lang_text), y - 10 - Font.getTextHeight(FONT16, lang_text), lang_text, Color.new(101, 101, 101))
            if parser.NSFW then
                Font.print(FONT16, 280 + Font.getTextWidth(FONT26, parser.Name), y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "NSFW"), "NSFW", COLOR_ROYAL_BLUE)
            end
            local link_text = parser.Link .. "/"
            Font.print(FONT16, 275, y - 23 - Font.getTextHeight(FONT16, link_text), link_text, Color.new(128, 128, 128))
            if Slider.ItemID == i then
                Graphics.fillRect(265, 945, y - 74, y, Color.new(0, 0, 0, 32))
            end
            y = y + 75
        end
        local elements_count = #Parsers
        if elements_count > 0 then
            Graphics.fillRect(264, 946, y - 75, y - 74, Color.new(0, 0, 0, 32))
            scroll_height = elements_count > 7 and #Parsers * 75 / 524 or nil
        end
        local item = ParserSelector:getSelected()
        if item ~= 0 then
            y = item * 75 - Slider.Y
            local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks + 1 do
                Graphics.fillEmptyRect(268 + i, 942 - i + 1, y - i - 3, y - 71 + i + 1, COLOR_ROYAL_BLUE)
                Graphics.fillEmptyRect(268 + i, 942 - i + 1, y - i - 3, y - 71 + i + 1, wh)
            end
        end
    elseif mode == "DOWNLOAD" then
        local list = ChapterSaver.getDownloadingList()
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#list, start + 9) do
            local task = list[i]
            Graphics.fillRect(264, 946, y - 75, y, 0x20000000)
            Graphics.fillRect(265, 945, y - 74, y, COLOR_WHITE)
            Font.print(FONT20, 275, y - 70, task.Manga, COLOR_BLACK)
            Font.print(FONT16, 275, y - 44, task.Chapter, COLOR_BLACK)
            if task.page_count > 0 then
                local text_counter = task.page .. "/" .. task.page_count
                local w = Font.getTextWidth(FONT16, text_counter)
                download_bar = download_bar + (task.page / task.page_count - download_bar) / 32
                Graphics.fillRect(270 + 10 + w, 270 + 10 + w + (940 - 270 - 10 - w) * download_bar, y - 20, y - 8, COLOR_ROYAL_BLUE)
                Graphics.fillEmptyRect(270 + 10 + w, 940, y - 20, y - 8, COLOR_BLACK)
                Font.print(FONT16, 275, y - 24, text_counter, COLOR_BLACK)
            elseif i == 1 then
                download_bar = 0
            end
            if Slider.ItemID == i then
                Graphics.fillRect(265, 945, y - 74, y, 0x20000000)
            end
            y = y + 75
        end
        local elements_count = #list
        if elements_count > 0 then
            Graphics.fillRect(264, 946, y - 75, y - 74, Color.new(0, 0, 0, 32))
            scroll_height = elements_count > 7 and #list * 75 / 524 or nil
        end
        local item = DownloadSelector:getSelected()
        if item ~= 0 then
            y = item * 75 - Slider.Y
            local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks + 1 do
                Graphics.fillEmptyRect(268 + i, 942 - i + 1, y - i - 3, y - 71 + i + 1, COLOR_ROYAL_BLUE)
                Graphics.fillEmptyRect(268 + i, 942 - i + 1, y - i - 3, y - 71 + i + 1, wh)
            end
        end
    elseif mode == "SETTINGS" then
        local list = Settings:list()
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#list, start + 9) do
            local task = list[i]
            Graphics.fillRect(264, 946, y - 75, y, 0x20000000)
            Graphics.fillRect(265, 945, y - 74, y, COLOR_WHITE)
            Font.print(FONT20, 275, y - 70, Language[Settings.Language].SETTINGS[task], COLOR_BLACK)
            if task == "Language" then
                Font.print(FONT16, 275, y - 44, LanguageNames[Settings.Language][Settings.Language], COLOR_BLACK)
            elseif task == "ClearChapters" then
                if chapters_space == nil then
                    chapters_space = 0
                    local function get_space_dir(dir)
                        local d = System.listDirectory(dir)
                        for _, v in ipairs(d) do
                            if v.directory then
                                get_space_dir(dir .. "/" .. v.name)
                            else
                                local fh = System.openFile(dir .. "/" .. v.name, FREAD)
                                chapters_space = chapters_space + System.sizeFile(fh)
                                System.closeFile(fh)
                            end
                        end
                    end
                    get_space_dir("ux0:data/noboru/chapters")
                end
                Font.print(FONT16, 275, y - 44, MemToStr(chapters_space, Language[Settings.Language].SETTINGS.Space), COLOR_GRAY)
                if sure_clear_chapters > 0 then
                    Font.print(FONT16, 275, y - 24, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                end
            elseif task == "ReaderOrientation" then
                Font.print(FONT16, 275, y - 44, Language[Settings.Language].READER[Settings.Orientation], COLOR_GRAY)
            elseif task == "ShowNSFW" then
                Font.print(FONT16, 275, y - 44, Language[Settings.Language].NSFW[Settings.NSFW], Settings.NSFW and COLOR_CRIMSON or COLOR_ROYAL_BLUE)
            elseif task == "ZoomReader" then
                Font.print(FONT16, 275, y - 44, Language[Settings.Language].READER[Settings.ZoomReader], COLOR_GRAY)
            elseif task == "ClearLibrary" then
                if sure_clear_library > 0 then
                    Font.print(FONT16, 275, y - 44, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                end
            elseif task == "ClearCache" then
                if sure_clear_cache > 0 then
                    Font.print(FONT16, 275, y - 44, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                end
            elseif task == "ClearAllCache" then
                if cache_space == nil then
                    cache_space = 0
                    local function get_space_dir(dir)
                        local d = System.listDirectory(dir)
                        for _, v in ipairs(d) do
                            if v.directory then
                                get_space_dir(dir .. "/" .. v.name)
                            else
                                local fh = System.openFile(dir .. "/" .. v.name, FREAD)
                                cache_space = cache_space + System.sizeFile(fh)
                                System.closeFile(fh)
                            end
                        end
                    end
                    get_space_dir("ux0:data/noboru/cache")
                end
                Font.print(FONT16, 275, y - 44, MemToStr(cache_space, Language[Settings.Language].SETTINGS.Space), COLOR_GRAY)
                if sure_clear_all_cache > 0 then
                    Font.print(FONT16, 275, y - 24, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                end
            elseif task == "ShowAuthor" then
                Font.print(FONT16, 275, y - 44, "@creckeryop", COLOR_ROYAL_BLUE)
            elseif task == "ShowVersion" then
                Font.print(FONT16, 275, y - 44, Settings.Version, COLOR_GRAY)
            end
            if Slider.ItemID == i then
                Graphics.fillRect(265, 945, y - 74, y, 0x20000000)
            end
            y = y + 75
        end
        local elements_count = #list
        if elements_count > 0 then
            Graphics.fillRect(264, 946, y - 75, y - 74, Color.new(0, 0, 0, 32))
            scroll_height = elements_count > 7 and #list * 75 / 524 or nil
        end
        local item = SettingSelector:getSelected()
        if item ~= 0 then
            y = item * 75 - Slider.Y
            local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks + 1 do
                Graphics.fillEmptyRect(268 + i, 942 - i + 1, y - i - 3, y - 71 + i + 1, COLOR_ROYAL_BLUE)
                Graphics.fillEmptyRect(268 + i, 942 - i + 1, y - i - 3, y - 71 + i + 1, wh)
            end
        end
    elseif mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
        local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 12)) * 4 + 1)
        for i = start, min(#Results, start + 15) do
            DrawManga(610 + (((i - 1) % 4) - 2) * (MANGA_WIDTH + 10) + MANGA_WIDTH / 2, MANGA_HEIGHT / 2 - Slider.Y + floor((i - 1) / 4) * (MANGA_HEIGHT + 12) + 12, Results[i])
        end
        local item = MangaSelector:getSelected()
        if item ~= 0 then
            local x = 610 + (((item - 1) % 4) - 2) * (MANGA_WIDTH + 10) + MANGA_WIDTH / 2
            local y = MANGA_HEIGHT / 2 - Slider.Y + floor((item - 1) / 4) * (MANGA_HEIGHT + 12) + 12
            local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks + 3 do
                Graphics.fillEmptyRect(x - MANGA_WIDTH / 2 + i, x + MANGA_WIDTH / 2 - i + 1, y - MANGA_HEIGHT / 2 + i, y + MANGA_HEIGHT / 2 - i + 1, COLOR_ROYAL_BLUE)
                Graphics.fillEmptyRect(x - MANGA_WIDTH / 2 + i, x + MANGA_WIDTH / 2 - i + 1, y - MANGA_HEIGHT / 2 + i, y + MANGA_HEIGHT / 2 - i + 1, wh)
            end
        end
        if #Results > 4 then
            scroll_height = ceil(#Results / 4) * (MANGA_HEIGHT + 12) / 524
        end
    end
    if scroll_height then
        Graphics.fillRect(955, 960, Slider.Y / scroll_height, (Slider.Y + 524) / scroll_height, COLOR_BLACK)
    end
end

---Frees all images loaded in catalog
function Catalogs.shrink()
    for _, i in ipairs(DownloadedImage) do
        freeMangaImage(Results[i])
    end
    ParserManager.remove(Results)
    Loading.setMode("NONE")
end

function Catalogs.terminate()
    Catalogs.shrink()
    DownloadedImage = {}
    Results = {}
    page = 1
    Slider.Y = -100
    searchData = ""
    getMangaMode = "POPULAR"
end

---@param new_mode string | '"CATALOGS"' | '"MANGA"' | '"LIBRARY"' | '"DOWNLOAD"'
function Catalogs.setMode(new_mode)
    mode = new_mode
    chapters_space = nil
    cache_space = nil
    sure_clear_library = 0
    sure_clear_chapters = 0
    sure_clear_cache = 0
    sure_clear_all_cache = 0
    MangaSelector:resetSelected()
    ParserSelector:resetSelected()
    DownloadSelector:resetSelected()
    SettingSelector:resetSelected()
    Catalogs.terminate()
end
