Catalogs = {}
local Slider = Slider()
local TOUCH = TOUCH()

local doesFileExist = System.doesFileExist
local listDirectory = System.listDirectory

local Parser = nil
local TouchTimer = Timer.new()

local mode = "CATALOGS"

local DownloadedImage = {}
local page = 1
local Results = {}
local Parsers = {}

local abs, ceil, floor, max, min = math.abs, math.ceil, math.floor, math.max, math.min

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
    if manga.Path and doesFileExist("ux0:data/noboru/" .. manga.Path) and System.getPictureResolution("ux0:data/noboru/" .. manga.Path) or -1 > 0 then
        Threads.addTask(manga, {
            Type = "Image",
            Path = manga.Path,
            Table = manga,
            MaxHeight = MANGA_HEIGHT * 2,
            Index = "Image"
        })
    else
        if Database.check(manga) and not Cache.isCached(manga) then
            Cache.addManga(manga)
        end
        Threads.addTask(manga, {
            Type = "ImageDownload",
            Link = manga.ImageLink,
            Table = manga,
            Index = "Image",
            MaxHeight = MANGA_HEIGHT * 2,
            Path = Cache.isCached(manga) and manga.Path or nil
        })
    end
end

local function UpdateMangas()
    if Slider.V == 0 and Timer.getTime(TouchTimer) > 200 then
        local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 6)) * 4 + 1)
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
        CatalogModes.load(parser)
    end
end

local chapters_space
local cache_space
local sure_clear_library
local sure_clear_chapters
local sure_clear_all_cache
local sure_clear_cache

local MangaSelector = Selector:new(-4, 4, -1, 1, function() return max(1, floor((Slider.Y - 20) / (MANGA_HEIGHT + 12)) * 4 + 1) end)
local ParserSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)
local DownloadSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)
local SettingSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)
local ImportSelector = Selector:new(-1, 1, -3, 3, function() return max(1, floor((Slider.Y - 10) / 75)) end)

local function selectSetting(index)
    local item = Settings.list()[index]
    if Settings.isTab(item) then
        if Settings.getTab() ~= "AdvancedChaptersDeletion" then
            SettingSelector:resetSelected()
        end
        Settings.setTab(item)
    elseif item then
        if SettingsFunctions[item] then
            if item == "ClearChapters" then
                sure_clear_chapters = sure_clear_chapters + 1
                if sure_clear_chapters == 2 then
                    SettingsFunctions[item]()
                    chapters_space = nil
                    sure_clear_chapters = 0
                end
            elseif item == "ClearLibrary" then
                sure_clear_library = sure_clear_library + 1
                if sure_clear_library == 2 then
                    SettingsFunctions[item]()
                    sure_clear_library = 0
                end
            elseif item == "ClearAllCache" then
                sure_clear_all_cache = sure_clear_all_cache + 1
                if sure_clear_all_cache == 2 then
                    cache_space = nil
                    SettingsFunctions[item]()
                    sure_clear_all_cache = 0
                end
            elseif item == "ClearCache" then
                sure_clear_cache = sure_clear_cache + 1
                if sure_clear_cache == 2 then
                    cache_space = nil
                    SettingsFunctions[item]()
                    sure_clear_cache = 0
                end
            else
                SettingsFunctions[item]()
                Settings.save()
            end
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

local function selectImport(index)
    local list = Import.listDir()
    if index > 0 and index <= #list then
        Import.go(list[index])
    end
end

MangaSelector:xaction(selectManga)
ParserSelector:xaction(selectParser)
DownloadSelector:xaction(function(item)
    ChapterSaver.stopByListItem(ChapterSaver.getDownloadingList()[item])
end)
SettingSelector:xaction(selectSetting)
ImportSelector:xaction(selectImport)
local keyboard_mode = "NONE"
function Catalogs.input(oldpad, pad, oldtouch, touch)
    if mode == "MANGA" then
        if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            mode = "CATALOGS"
            Catalogs.terminate()
        elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            CatalogModes.show()
        elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            Keyboard.show(Language[Settings.Language].SETTINGS.InputValue, 1, 128, TYPE_NUMBER, MODE_TEXT, OPT_NO_AUTOCAP)
            keyboard_mode = "JUMP_PAGE"
        end
    elseif mode == "CATALOGS" then
        if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            ParserManager.updateParserList(Parsers)
        end
        if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            local item = Parsers[ParserSelector:getSelected()]
            if item then
                Settings.toggleFavouriteParser(item)
            end
        end
        if (Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT)) and Debug.getMode() == 2 then
            local item = Parsers[ParserSelector:getSelected()]
            if item then
                ParserChecker.addCheck(item)
            end
        end
    elseif mode == "HISTORY" then
        if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            local item = Results[MangaSelector:getSelected()]
            if item then
                Cache.removeHistory(item)
            end
        end
    elseif mode == "SETTINGS" then
        if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            Settings.back()
            SettingSelector:resetSelected()
        end
        
        if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) and Settings.getTab() == "AdvancedChaptersDeletion" then
            local id = SettingSelector:getSelected()
            local item = Settings.list()[id]
            if item then
                Settings.delTab(item)
            end
        end
    elseif mode == "IMPORT" then
        if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            Import.back()
            ImportSelector:resetSelected()
        end
        if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            local item = Import.listDir()[ImportSelector:getSelected()]
            if item and item.active and item.name ~= "..." then
                ChapterSaver.importManga(Import.getPath(item))
                ImportSelector:resetSelected()
            end
        end
    elseif mode == "LIBRARY" then
        if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            ParserManager.updateCounters()
        end
    end
    if Slider.V ~= 0 or Controls.check(pad, SCE_CTRL_RTRIGGER) or Controls.check(pad, SCE_CTRL_LTRIGGER) or touch.x then
        Timer.reset(TouchTimer)
    end
    if mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
        MangaSelector:input(#Results, oldpad, pad, touch.x)
    elseif mode == "CATALOGS" then
        ParserSelector:input(#Parsers, oldpad, pad, touch.x)
    elseif mode == "DOWNLOAD" then
        DownloadSelector:input(#ChapterSaver.getDownloadingList(), oldpad, pad, touch.x)
    elseif mode == "SETTINGS" then
        SettingSelector:input(#Settings.list(), oldpad, pad, touch.x)
    elseif mode == "IMPORT" then
        ImportSelector:input(#Import.listDir(), oldpad, pad, touch.x)
    end
    if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
        TOUCH.MODE = TOUCH.READ
        Slider.TouchY = touch.y
    elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
        if oldtouch.x then
            if TOUCH.MODE == TOUCH.READ then
                if mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
                    local start = max(1, floor((Slider.Y - 20) / (MANGA_HEIGHT + 6)) * 4 + 1)
                    for i = start, min(#Results, start + 11) do
                        local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 6) + 610
                        local uy = floor((i - 1) / 4) * (MANGA_HEIGHT + 6) - Slider.Y + 6
                        if oldtouch.x > lx and oldtouch.x < lx + MANGA_WIDTH and oldtouch.y > uy and oldtouch.y < uy + MANGA_HEIGHT then
                            selectManga(i)
                            break
                        end
                    end
                elseif oldtouch.x > 205 and oldtouch.x < 955 then
                    local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
                    if mode == "CATALOGS" then
                        selectParser(id)
                    elseif mode == "DOWNLOAD" then
                        local list = ChapterSaver.getDownloadingList()
                        if list[id] then
                            ChapterSaver.stopByListItem(list[id])
                        end
                    elseif mode == "SETTINGS" then
                        local list = Settings.list()
                        if list[id] then
                            selectSetting(id)
                        end
                    elseif mode == "IMPORT" then
                        if oldtouch.x < 850 then
                            local list = Import.listDir()
                            if list[id] then
                                selectImport(id)
                            end
                        else
                            local item = Import.listDir()[id]
                            if item and item.active and item.name ~= "..." then
                                ChapterSaver.importManga(Import.getPath(item))
                                ImportSelector:resetSelected()
                            end
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
        elseif oldtouch.x > 205 and oldtouch.x < 945 then
            local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
            if mode == "CATALOGS" and GetParserList()[id] then
                new_itemID = id
            elseif mode == "DOWNLOAD" and ChapterSaver.getDownloadingList()[id] then
                new_itemID = id
            elseif mode == "SETTINGS" and Settings.list()[id] then
                new_itemID = id
            elseif mode == "IMPORT" and Import.listDir()[id] then
                new_itemID = id
            end
        end
    end
    if Slider.ItemID > 0 and new_itemID > 0 and Slider.ItemID ~= new_itemID then
        TOUCH.MODE = TOUCH.SLIDE
    else
        Slider.ItemID = new_itemID
    end
    if TOUCH.MODE == TOUCH.SLIDE and oldtouch.x and touch.x and touch.x > 205 then
        Slider.V = oldtouch.y - touch.y
    end
end

Panels = {}

function GenPanels()
    Panels["MANGA"] = {
        "L\\R", "Square", "DPad", "Cross", "Circle", "Triangle",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        Square = Language[Settings.Language].PANEL.MODE,
        Triangle = Language[Settings.Language].PANEL.JUMPTOPAGE,
        Circle = Language[Settings.Language].PANEL.BACK,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.SELECT
    }
    Panels["IMPORT"] = {
        "L\\R", "DPad", "Circle", "Cross", "Square",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.SELECT
    }
    Panels["HISTORY"] = {
        "L\\R", "DPad", "Cross", "Square",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.SELECT,
        Square = Language[Settings.Language].PANEL.DELETE
    }
    Panels["LIBRARY"] = {
        "L\\R", "DPad", "Triangle", "Cross",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.SELECT,
        Triangle = Language[Settings.Language].PANEL.UPDATE
    }
    Panels["CATALOGS"] = {
        "L\\R", "DPad", "Square", "Cross", "Triangle",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        Triangle = Language[Settings.Language].PANEL.UPDATE,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.SELECT
    }
    Panels["DOWNLOAD"] = {
        "L\\R", "DPad", "Cross",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.CANCEL
    }
    Panels["SETTINGS"] = {
        "L\\R", "DPad", "Circle", "Cross", "Square",
        ["L\\R"] = Language[Settings.Language].PANEL.CHANGE_SECTION,
        DPad = Language[Settings.Language].PANEL.CHOOSE,
        Cross = Language[Settings.Language].PANEL.SELECT
    }
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
            Loading.setMode(COLOR_FONT == COLOR_BLACK and "BLACK" or "WHITE", 580, 272)
        elseif Details.getMode() == "END" then
            Loading.setMode("NONE")
        end
        local item = MangaSelector:getSelected()
        if item ~= 0 then
            Slider.Y = Slider.Y + (math.floor((item - 1) / 4) * (MANGA_HEIGHT + 6) + MANGA_HEIGHT / 2 - 232 - Slider.Y) / 8
            if mode == "MANGA" and not Results.NoPages and Parser and item > #Results - 4 then
                if not ParserManager.check(Results) then
                    ParserManager.getMangaListAsync(CatalogModes.getMangaMode(), Parser, page, Results, CatalogModes.getSearchData(), CatalogModes.getTagsData())
                    page = page + 1
                end
            end
        end
        if Slider.Y < 0 then
            Slider.Y = 0
            Slider.V = 0
        elseif Slider.Y > ceil(#Results / 4) * (MANGA_HEIGHT + 6) - 512 - 6 then
            Slider.Y = max(0, ceil(#Results / 4) * (MANGA_HEIGHT + 6) - 512 - 6)
            Slider.V = 0
            if mode == "MANGA" then
                if not Results.NoPages and Parser then
                    if not ParserManager.check(Results) then
                        ParserManager.getMangaListAsync(CatalogModes.getMangaMode(), Parser, page, Results, CatalogModes.getSearchData(), CatalogModes.getTagsData())
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
    else
        local list = {}
        local item = 0
        if mode == "CATALOGS" then
            Parsers = GetParserList()
            list = Parsers
            item = ParserSelector:getSelected()
            Panels["CATALOGS"].Square = Parsers[item] and (Settings.FavouriteParsers[Parsers[item].ID] and Language[Settings.Language].PANEL.UNFOLLOW or Language[Settings.Language].PANEL.FOLLOW)
        elseif mode == "DOWNLOAD" then
            list = ChapterSaver.getDownloadingList()
            item = DownloadSelector:getSelected()
        elseif mode == "SETTINGS" then
            list = Settings.list()
            Panels["SETTINGS"].Cirlce = Settings.inTab() and Language[Settings.Language].PANEL.BACK
            Panels["SETTINGS"].Cross = Settings.getTab() == "AdvancedChaptersDeletion" and Language[Settings.Language].PANEL.READ or Language[Settings.Language].PANEL.SELECT
            Panels["SETTINGS"].Square = Settings.getTab() == "AdvancedChaptersDeletion" and Language[Settings.Language].PANEL.DELETE
            item = SettingSelector:getSelected()
        elseif mode == "IMPORT" then
            list = Import.listDir()
            item = ImportSelector:getSelected()
            Panels["IMPORT"].Square = list[item] and Import.canImport(list[item]) and Language[Settings.Language].PANEL.IMPORT
            Panels["IMPORT"].Circle = Import.canBack() and Language[Settings.Language].PANEL.BACK
        end
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
    Panel.set(Panels[mode] or {})
    if keyboard_mode ~= "NONE" and Keyboard.getState() ~= RUNNING then
        if keyboard_mode == "JUMP_PAGE" and Keyboard.getState() == FINISHED then
            local new_page = tonumber(Keyboard.getInput())
            if new_page and new_page > 0 then
                Catalogs.terminate()
                page = new_page
            end
        end
        keyboard_mode = "NONE"
        Keyboard.clear()
    end
end

local download_bar = 0
function Catalogs.draw()
    local scroll_height, item
    local item_h = 0
    if mode == "CATALOGS" then
        local first = max(1, floor((Slider.Y - 10) / 75))
        local y = first * 75 - Slider.Y
        local last = min(#Parsers, first + 9)
        for i = first, last do
            local parser = Parsers[i]
            if Slider.ItemID == i then
                Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
            end
            Font.print(FONT26, 225, y - 70, parser.Name, COLOR_FONT)
            local lang_text = Language[Settings.Language].PARSERS[parser.Lang] or parser.Lang or ""
            Font.print(FONT16, 935 - Font.getTextWidth(FONT16, lang_text), y - 15 - Font.getTextHeight(FONT16, lang_text), lang_text, Color.new(101, 101, 101))
            local width = Font.getTextWidth(FONT26, parser.Name)
            if Settings.FavouriteParsers[parser.ID] then
                Graphics.drawImage(230 + width, y - 70 + 8, Mini_star_icon.e, COLOR_ROYAL_BLUE)
                width = width + 16 + 5
            end
            if parser.NSFW then
                Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "NSFW"), "NSFW", COLOR_ROYAL_BLUE)
                width = width + Font.getTextWidth(FONT16, "NSFW") + 5
            end
            if parser.isNew then
                Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "New"), "New", COLOR_CRIMSON)
            elseif parser.isUpdated then
                Font.print(FONT16, 230 + width, y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "Updated"), "Updated", COLOR_CRIMSON)
            end
            Font.print(FONT16, 935 - Font.getTextWidth(FONT16, "v" .. parser.Version), y - 65, "v" .. parser.Version, Color.new(101, 101, 101))
            local link_text = parser.Link .. "/"
            Font.print(FONT16, 225, y - 23 - Font.getTextHeight(FONT16, link_text), link_text, COLOR_GRAY)
            y = y + 75
        end
        local elements_count = #Parsers
        if elements_count > 7 then
            scroll_height = elements_count * 75 / 524
        end
        item = ParserSelector:getSelected()
    elseif mode == "IMPORT" then
        local list = Import.listDir()
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#list, start + 9) do
            local object = list[i]
            if Slider.ItemID == i then
                Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
            end
            if object.active then
                Font.print(FONT26, 225, y - 70, object.name, COLOR_FONT)
            elseif object.directory then
                Font.print(FONT26, 225, y - 70, "*" .. Language[Settings.Language].IMPORT.EXTERNAL_MEMORY .. "*", COLOR_ROYAL_BLUE)
            else
                Font.print(FONT26, 225, y - 70, object.name, COLOR_GRAY)
            end
            Graphics.fillRect(945, 955, y - 75, y - 1, COLOR_BACK)
            if object.active and object.name ~= "..." then
                if Slider.ItemID == i then
                    Graphics.fillRect(925 - 16 - 12 - 34 + 10, 945, y - 75, y - 1, COLOR_SELECTED)
                else
                    Graphics.fillRect(925 - 16 - 12 - 34 + 10, 945, y - 75, y - 1, COLOR_BACK)
                end
            end
            local text_dis = object.name == "..." and Language[Settings.Language].IMPORT.GOBACK or object.directory and (object.active and Language[Settings.Language].IMPORT.FOLDER or Language[Settings.Language].IMPORT.DRIVE .. " \"" .. object.name .. "\"") or object.active and Language[Settings.Language].IMPORT.FILE or Language[Settings.Language].IMPORT.UNSUPFILE
            Font.print(FONT16, 225, y - 23 - Font.getTextHeight(FONT16, text_dis), text_dis, Color.new(128, 128, 128))
            if object.active and object.name ~= "..." then
                Graphics.drawImage(925 - 16 - 12, y - 38 - 14, Import_icon.e, COLOR_ICON_EXTRACT)
            end
            y = y + 75
        end
        local elements_count = #list
        if elements_count > 7 then
            scroll_height = elements_count * 75 / 524
        end
        item = ImportSelector:getSelected()
    elseif mode == "DOWNLOAD" then
        local list = ChapterSaver.getDownloadingList()
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#list, start + 9) do
            local task = list[i]
            local page_count = task.page_count or 0
            local page = task.page or 0
            if Slider.ItemID == i then
                Graphics.fillRect(215, 945, y - 75, y - 1, COLOR_SELECTED)
            end
            Font.print(FONT20, 225, y - 70, task.MangaName, COLOR_FONT)
            Font.print(FONT16, 225, y - 44, task.ChapterName, COLOR_FONT)
            if page_count > 0 then
                local text_counter = math.ceil(page) .. "/" .. page_count
                local w = Font.getTextWidth(FONT16, text_counter)
                download_bar = page / page_count
                Graphics.fillRect(220 + 10 + w, 220 + 10 + w + (940 - 220 - 10 - w) * download_bar, y - 20, y - 8, COLOR_ROYAL_BLUE)
                Graphics.fillEmptyRect(220 + 10 + w, 940, y - 20, y - 8, COLOR_FONT)
                Font.print(FONT16, 225, y - 24, text_counter, COLOR_FONT)
            elseif i == 1 then
                download_bar = 0
            end
            y = y + 75
        end
        local elements_count = #list
        if elements_count > 7 then
            scroll_height = elements_count * 75 / 524
        end
        item = DownloadSelector:getSelected()
    elseif mode == "SETTINGS" then
        local list = Settings.list()
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#list, start + 9) do
            local task = list[i]
            if Slider.ItemID == i then
                local dy_for_translators = list[i] == "Translators" and 90 or 0
                Graphics.fillRect(215, 945, y - 75, y - 1 + dy_for_translators, COLOR_SELECTED)
            end
            if type(task) == "table" then
                Font.print(FONT20, 225, y - 70, task.name, COLOR_FONT)
                if task.type == "savedChapter" then
                    Font.print(FONT16, 225, y - 44, task.info, COLOR_GRAY)
                end
            else
                Font.print(FONT20, 225, y - 70, Language[Settings.Language].SETTINGS[task] or task, COLOR_FONT)
                if task == "Language" then
                    Font.print(FONT16, 225, y - 44, LanguageNames[Settings.Language][Settings.Language], COLOR_FONT)
                elseif task == "ClearChapters" then
                    if chapters_space == nil then
                        chapters_space = 0
                        local function get_space_dir(dir)
                            local d = listDirectory(dir) or {}
                            for _, v in ipairs(d) do
                                if v.directory then
                                    get_space_dir(dir .. "/" .. v.name)
                                else
                                    chapters_space = chapters_space + v.size
                                end
                            end
                        end
                        get_space_dir("ux0:data/noboru/chapters")
                    end
                    Font.print(FONT16, 225, y - 44, MemToStr(chapters_space), COLOR_GRAY)
                    if sure_clear_chapters > 0 then
                        Font.print(FONT16, 225, y - 24, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                    end
                elseif task == "ReaderOrientation" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].READER[Settings.Orientation], COLOR_GRAY)
                elseif task == "PreferredCatalogLanguage" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].PARSERS[Settings.ParserLanguage] or Settings.ParserLanguage or "error_type", COLOR_GRAY)
                elseif task == "ShowNSFW" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].NSFW[Settings.NSFW], Settings.NSFW and COLOR_CRIMSON or COLOR_ROYAL_BLUE)
                elseif task == "HideInOffline" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.HideInOffline], COLOR_ROYAL_BLUE)
                elseif task == "SkipFontLoading" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.SkipFontLoad], COLOR_ROYAL_BLUE)
                elseif task == "ZoomReader" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].READER[Settings.ZoomReader], COLOR_GRAY)
                elseif task == "DoubleTapReader" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.DoubleTapReader], COLOR_ROYAL_BLUE)
                elseif task == "RefreshLibAtStart" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.RefreshLibAtStart], COLOR_ROYAL_BLUE)
                elseif task == "SilentDownloads" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.SilentDownloads], COLOR_ROYAL_BLUE)
                elseif task == "ChangeUI" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].THEME[Settings.Theme] or Settings.Theme, COLOR_GRAY)
                elseif task == "LibrarySorting" then
                    Font.print(FONT16, 225, y - 44, Settings.LibrarySorting, COLOR_GRAY)
                elseif task == "ChapterSorting" then
                    Font.print(FONT16, 225, y - 44, Settings.ChapterSorting, COLOR_GRAY)
                elseif task == "ConnectionTime" then
                    Font.print(FONT16, 225, y - 44, Settings.ConnectionTime, COLOR_ROYAL_BLUE)
                elseif task == "UseProxy" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.UseProxy], COLOR_ROYAL_BLUE)
                elseif task == "ProxyIP" then
                    Font.print(FONT16, 225, y - 44, Settings.ProxyIP, COLOR_GRAY)
                elseif task == "ProxyPort" then
                    Font.print(FONT16, 225, y - 44, Settings.ProxyPort, COLOR_GRAY)
                elseif task == "UseProxyAuth" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.UseProxyAuth], COLOR_ROYAL_BLUE)
                elseif task == "SkipCacheChapterChecking" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].YORN[Settings.SkipCacheChapterChecking], COLOR_ROYAL_BLUE)
                elseif task == "ProxyAuth" then
                    Font.print(FONT16, 225, y - 44, Settings.ProxyAuth, COLOR_GRAY)
                elseif task == "ChapterSorting" then
                    Font.print(FONT16, 225, y - 44, Settings.ChapterSorting, COLOR_GRAY)
                elseif task == "LeftStickDeadZone" then
                    local x = 0
                    for n = 1, #DeadZoneValues do
                        Font.print(FONT16, 225 + x, y - 44, DeadZoneValues[n], DeadZoneValues[n] == Settings.LeftStickDeadZone and COLOR_CRIMSON or COLOR_GRAY)
                        x = x + Font.getTextWidth(FONT16, DeadZoneValues[n]) + 5
                    end
                elseif task == "LeftStickSensitivity" then
                    local x = 0
                    for n = 1, #SensitivityValues do
                        Font.print(FONT16, 225 + x, y - 44, SensitivityValues[n], SensitivityValues[n] == Settings.LeftStickSensitivity and COLOR_CRIMSON or COLOR_GRAY)
                        x = x + Font.getTextWidth(FONT16, SensitivityValues[n]) + 5
                    end
                elseif task == "RightStickDeadZone" then
                    local x = 0
                    for n = 1, #DeadZoneValues do
                        Font.print(FONT16, 225 + x, y - 44, DeadZoneValues[n], DeadZoneValues[n] == Settings.RightStickDeadZone and COLOR_CRIMSON or COLOR_GRAY)
                        x = x + Font.getTextWidth(FONT16, DeadZoneValues[n]) + 5
                    end
                elseif task == "RightStickSensitivity" then
                    local x = 0
                    for n = 1, #SensitivityValues do
                        Font.print(FONT16, 225 + x, y - 44, SensitivityValues[n], SensitivityValues[n] == Settings.RightStickSensitivity and COLOR_CRIMSON or COLOR_GRAY)
                        x = x + Font.getTextWidth(FONT16, SensitivityValues[n]) + 5
                    end
                elseif task == "ChangingPageButtons" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].PAGINGCONTROLS[Settings.ChangingPageButtons], COLOR_GRAY)
                elseif task == "Translators" then
                    Font.print(FONT16, 225, y - 44, ("@SamuEDL :- Spanish \n@nguyenmao2101 :- Vietnamese \n@theheroGAC :- Italian \n@Cimmerian_Iter :- French \n@kemalsanli :- Turkish \n@rutantan :- PortugueseBR \n@Qingyu510 :- SimplifiedChinese &- TraditionalChinese "):gsub("%- (.-) ", function(a) return " " .. (LanguageNames[Settings.Language][a] or a) .. " " end), COLOR_ROYAL_BLUE)
                elseif task == "ClearLibrary" then
                    if sure_clear_library > 0 then
                        Font.print(FONT16, 225, y - 44, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                    end
                elseif task == "ClearCache" then
                    if sure_clear_cache > 0 then
                        Font.print(FONT16, 225, y - 44, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                    end
                elseif task == "ClearAllCache" then
                    if cache_space == nil then
                        cache_space = 0
                        local function get_space_dir(dir)
                            local d = listDirectory(dir) or {}
                            for _, v in ipairs(d) do
                                if v.directory then
                                    get_space_dir(dir .. "/" .. v.name)
                                else
                                    cache_space = cache_space + v.size
                                end
                            end
                        end
                        get_space_dir("ux0:data/noboru/cache")
                    end
                    Font.print(FONT16, 225, y - 44, MemToStr(cache_space), COLOR_GRAY)
                    if sure_clear_all_cache > 0 then
                        Font.print(FONT16, 225, y - 24, Language[Settings.Language].SETTINGS.PressAgainToAccept, COLOR_CRIMSON)
                    end
                elseif task == "ShowAuthor" then
                    Font.print(FONT16, 225, y - 44, "@creckeryop", COLOR_GRAY)
                    Font.print(FONT16, 225 + Font.getTextWidth(FONT16,"@creckeryop") + 20, y - 44, "email: didager@ya.ru", COLOR_ROYAL_BLUE)
                elseif task == "ShowVersion" then
                    Font.print(FONT16, 225, y - 44, Settings.Version, COLOR_GRAY)
                elseif task == "ReaderDirection" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].READER[Settings.ReaderDirection], COLOR_GRAY)
                elseif task == "SwapXO" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].SETTINGS[Settings.KeyType], COLOR_GRAY)
                elseif task == "CheckUpdate" then
                    Font.print(FONT16, 225, y - 44, Language[Settings.Language].SETTINGS.LatestVersion .. Settings.LateVersion, tonumber(Settings.LateVersion) > tonumber(Settings.Version) and COLOR_ROYAL_BLUE or COLOR_GRAY)
                elseif task == "SaveDataPath" then
                    Font.print(FONT16, 225, y - 44, Settings.SaveDataPath, COLOR_GRAY)
                end
            end
            y = y + 75
        end
        local elements_count = #list
        if elements_count > 7 then
            scroll_height = elements_count * 75 / 524
        end
        item = SettingSelector:getSelected()
        item_h = list[item] == "Translators" and 70 or 0
    elseif mode == "MANGA" or mode == "LIBRARY" or mode == "HISTORY" then
        local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 6)) * 4 + 1)
        for i = start, min(#Results, start + 15) do
            local x = 580 + (((i - 1) % 4) - 2) * (MANGA_WIDTH + 6) + 3
            local y = -Slider.Y + floor((i - 1) / 4) * (MANGA_HEIGHT + 6) + 6
            DrawManga(x + MANGA_WIDTH / 2, y + MANGA_HEIGHT / 2, Results[i])
            if mode == "LIBRARY" and Results[i].Counter then
                local c = Results[i].Counter
                if c > 0 then
                    Graphics.fillRect(x, x + Font.getTextWidth(BONT16, c) + 11, y, y + 24, Themes[Settings.Theme].COLOR_LABEL)
                    Font.print(BONT16, x + 5, y + 2, tostring(c), COLOR_WHITE)
                end
            end
        end
        local item = MangaSelector:getSelected()
        if item ~= 0 then
            local x = 580 + (((item - 1) % 4) - 2) * (MANGA_WIDTH + 6) + MANGA_WIDTH / 2 + 3
            local y = MANGA_HEIGHT / 2 - Slider.Y + floor((item - 1) / 4) * (MANGA_HEIGHT + 6) + 6
            local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks + 1, ks + 3 do
                Graphics.fillEmptyRect(x - MANGA_WIDTH / 2 + i, x + MANGA_WIDTH / 2 - i + 1, y - MANGA_HEIGHT / 2 + i, y + MANGA_HEIGHT / 2 - i + 1, Themes[Settings.Theme].COLOR_SELECTOR)
                Graphics.fillEmptyRect(x - MANGA_WIDTH / 2 + i, x + MANGA_WIDTH / 2 - i + 1, y - MANGA_HEIGHT / 2 + i, y + MANGA_HEIGHT / 2 - i + 1, wh)
            end
        end
        if #Results > 4 then
            scroll_height = ceil(#Results / 4) * (MANGA_HEIGHT + 14) / 524
        end
    end
    if item and item ~= 0 then
        local y = item * 75 - Slider.Y
        local wh = Color.new(255, 255, 255, 100 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
        local ks = math.ceil(4 * math.sin(Timer.getTime(GlobalTimer) / 100))
        for i = ks, ks + 1 do
            Graphics.fillEmptyRect(218 + i, 942 - i + 1, y - i - 5 + item_h, y - 71 + i + 1, Themes[Settings.Theme].COLOR_SELECTOR)
            Graphics.fillEmptyRect(218 + i, 942 - i + 1, y - i - 5 + item_h, y - 71 + i + 1, wh)
        end
    end
    Graphics.fillRect(955, 960, 0, 544, COLOR_BACK)
    if scroll_height then
        Graphics.fillRect(955, 960, Slider.Y / scroll_height, (Slider.Y + 524) / scroll_height, COLOR_FONT)
    else
        Graphics.fillRect(955, 960, 0, 524, COLOR_FONT)
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
    MangaSelector:resetSelected()
    ParserSelector:resetSelected()
    DownloadSelector:resetSelected()
    SettingSelector:resetSelected()
    ImportSelector:resetSelected()
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
    Catalogs.terminate()
end
