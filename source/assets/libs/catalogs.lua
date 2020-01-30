Catalogs = {}
local Slider = Slider()
local TOUCH = TOUCH()
Slider.Y = -10

local Parser = nil
local TouchTimer = Timer.new()

local mode = "PARSERS"

local getMangaMode = "POPULAR"
local searchData = ""

local DownloadedImage = {}
local page = 1
local Results = {}

local abs, ceil, floor, max, min = math.abs, math.ceil, math.floor, math.max, math.min

StartSearch = false

local control_timer = Timer.new()
local time_space = 400
local item_selected = 0

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
    if manga.Path and System.doesFileExist("ux0:data/noboru/books/"..manga.Path) then
        Threads.addTask(manga, {
            Type = "Image",
            Path = "books/"..manga.Path,
            Table = manga,
            Index = "Image"
        })
    else
        local UniquePath = Database.check(manga) and manga.Path and ("books/"..manga.Path) or nil
        Threads.addTask(manga, {
            Type = "ImageDownload",
            Link = manga.ImageLink,
            Table = manga,
            Index = "Image",
            Path = UniquePath
        })
    end
end

local function UpdateMangas()
    if Slider.V == 0 and Timer.getTime(TouchTimer) > 200 then
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

local Parsers = {}

function Catalogs.input(oldpad, pad, oldtouch, touch)
    if mode == "MANGA" then
        if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            mode = "PARSERS"
            Catalogs.terminate()
        end
        if Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            local new_mode = getMangaMode == "POPULAR" and Parser.getLatestManga and "LATEST" or "POPULAR"
            if getMangaMode ~= new_mode then
                Catalogs.terminate()
                getMangaMode = new_mode
                Notifications.push(getMangaMode == "POPULAR" and Language[LANG].PANEL.MODE_POPULAR or getMangaMode == "LATEST" and Language[LANG].PANEL.MODE_LATEST)
            end
        end
        if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            if Parser.searchManga then
                Keyboard.show(Language[LANG].APP.SEARCH, searchData, 128, TYPE_DEFAULT, MODE_TEXT, OPT_NO_AUTOCAP)
                StartSearch = true
            end
        end
    elseif mode == "PARSERS" then
        if Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            ParserManager.updateParserList(Parsers)
        end
    end
    if touch.x then
        Timer.reset(TouchTimer)
    end
    local parserList = GetParserList()
    if mode == "MANGA" or mode == "LIBRARY" then
        if Timer.getTime(control_timer) > time_space or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT)) then
            if (Controls.check(pad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_LEFT)) then
                Timer.reset(TouchTimer)
                if item_selected == 0 then
                    item_selected = max(1, floor((Slider.Y - 20) / (MANGA_HEIGHT + 12)) * 4 + 1)
                elseif item_selected ~= 0 then
                    if Controls.check(pad, SCE_CTRL_DOWN) then
                        if item_selected + 4 <= #Results then
                            item_selected = item_selected + 4
                        end
                    elseif Controls.check(pad, SCE_CTRL_UP) then
                        if item_selected - 4 > 0 then
                            item_selected = item_selected - 4
                        end
                    elseif Controls.check(pad, SCE_CTRL_RIGHT) then
                        item_selected = item_selected + 1
                    elseif Controls.check(pad, SCE_CTRL_LEFT) then
                        item_selected = item_selected - 1
                    end
                end
                if #Results > 0 then
                    if item_selected <= 0 then
                        item_selected = 1
                    elseif item_selected > #Results then
                        item_selected = #Results
                    end
                else
                    item_selected = 0
                end
                if time_space > 50 then
                    time_space = math.max(50, time_space / 2)
                end
                Slider.V = 0
                Timer.reset(control_timer)
            else
                time_space = 400
            end
        end
        if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
            local manga = Results[item_selected]
            if manga then
                local lx = ((item_selected - 1) % 4 - 2) * (MANGA_WIDTH + 10) + 610
                local uy = floor((item_selected - 1) / 4) * (MANGA_HEIGHT + 12) - Slider.Y + 12
                Details.setManga(manga, lx + MANGA_WIDTH / 2, uy + MANGA_HEIGHT / 2)
                if not manga.Image then
                    Threads.remove(manga)
                    loadMangaImage(manga)
                    if not manga.ImageDownload then
                        DownloadedImage[#DownloadedImage + 1] = item_selected
                        manga.ImageDownload = true
                    end
                end
            end
        end
    elseif mode == "PARSERS" then
        if Timer.getTime(control_timer) > time_space or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT)) then
            if (Controls.check(pad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_LEFT)) then
                if item_selected == 0 then
                    item_selected = max(1, floor((Slider.Y - 10) / 75))
                elseif item_selected ~= 0 then
                    if Controls.check(pad, SCE_CTRL_DOWN) then
                        if item_selected + 1 <= #Parsers then
                            item_selected = item_selected + 1
                        end
                    elseif Controls.check(pad, SCE_CTRL_UP) then
                        if item_selected - 1 > 0 then
                            item_selected = item_selected - 1
                        end
                    elseif Controls.check(pad, SCE_CTRL_RIGHT) then
                        item_selected = item_selected + 3
                    elseif Controls.check(pad, SCE_CTRL_LEFT) then
                        item_selected = item_selected - 3
                    end
                end
                if #Parsers > 0 then
                    if item_selected <= 0 then
                        item_selected = 1
                    elseif item_selected > #Parsers then
                        item_selected = #Parsers
                    end
                else
                    item_selected = 0
                end
                if time_space > 50 then
                    time_space = math.max(50, time_space / 2)
                end
                Slider.V = 0
                Timer.reset(control_timer)
            else
                time_space = 400
            end
        end
        if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
            if parserList[item_selected] then
                Parser = parserList[item_selected]
                Catalogs.setMode("MANGA")
            end
        end
    end
    if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
        TOUCH.MODE = TOUCH.READ
        Slider.TouchY = touch.y
        item_selected = 0
    elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
        if oldtouch.x then
            if TOUCH.MODE == TOUCH.READ then
                if mode == "PARSERS" then
                    if oldtouch.x > 265 and oldtouch.x < 945 then
                        local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
                        if parserList[id] then
                            mode = "MANGA"
                            Parser = parserList[id]
                        end
                    end
                elseif mode == "MANGA" or mode == "LIBRARY" then
                    local start = max(1, floor((Slider.Y - 20) / (MANGA_HEIGHT + 12)) * 4 + 1)
                    for i = start, min(#Results, start + 11) do
                        local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 10) + 610
                        local uy = floor((i - 1) / 4) * (MANGA_HEIGHT + 12) - Slider.Y + 12
                        if oldtouch.x > lx and oldtouch.x < lx + MANGA_WIDTH and oldtouch.y > uy and oldtouch.y < uy + MANGA_HEIGHT then
                            local manga = Results[i]
                            Details.setManga(manga, lx + MANGA_WIDTH / 2, uy + MANGA_HEIGHT / 2)
                            if not manga.Image then
                                Threads.remove(manga)
                                loadMangaImage(manga)
                                if not manga.ImageDownload then
                                    DownloadedImage[#DownloadedImage + 1] = i
                                    manga.ImageDownload = true
                                end
                            end
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
        else
            if mode == "PARSERS" then
                if oldtouch.x > 265 and oldtouch.x < 945 then
                    local id = floor((Slider.Y - 10 + oldtouch.y) / 75) + 1
                    if parserList[id] then
                        new_itemID = id
                    end
                end
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
    Parsers = GetParserList()
    if mode == "MANGA" or mode == "LIBRARY" then
        UpdateMangas()
        if ParserManager.check(Results) then
            Loading.setMode("BLACK", 600, 272)
        elseif Details.getMode() == "END" then
            Loading.setMode("NONE")
        end
        if mode == "MANGA" then
            Panel.set {
                "L\\R", "Square", "Triangle", "DPad", "Cross", "Circle",
                ["L\\R"] = Language[LANG].PANEL.CHANGE_SECTION,
                Square = getMangaMode == "POPULAR" and Language[LANG].PANEL.MODE_POPULAR or getMangaMode == "LATEST" and Language[LANG].PANEL.MODE_LATEST or getMangaMode == "SEARCH" and string.format(Language[LANG].PANEL.MODE_SEARCHING, searchData),
                Triangle = Parser.searchManga and Language[LANG].PANEL.SEARCH or nil,
                Circle = Language[LANG].PANEL.BACK,
                DPad = Language[LANG].PANEL.CHOOSE,
                Cross = Language[LANG].PANEL.SELECT
            }
        elseif mode == "LIBRARY" then
            Panel.set {
                "L\\R", "DPad", "Cross",
                ["L\\R"] = Language[LANG].PANEL.CHANGE_SECTION,
                DPad = Language[LANG].PANEL.CHOOSE,
                Cross = Language[LANG].PANEL.SELECT
            }
        end
    elseif mode == "PARSERS" then
        Panel.set {
            "L\\R", "Triangle", "DPad", "Cross",
            ["L\\R"] = Language[LANG].PANEL.CHANGE_SECTION,
            Triangle = Language[LANG].PANEL.UPDATE,
            DPad = Language[LANG].PANEL.CHOOSE,
            Cross = Language[LANG].PANEL.SELECT
        }
    end

    Slider.Y = Slider.Y + Slider.V
    Slider.V = Slider.V / 1.12

    if abs(Slider.V) < 1 then
        Slider.V = 0
    end
    if item_selected ~= 0 then
        if mode == "LIBRARY" or mode == "MANGA" then
            Slider.Y = Slider.Y + (math.floor((item_selected-1)/4) * (MANGA_HEIGHT+10)+MANGA_HEIGHT/2 - 232 - Slider.Y) / 8
        elseif mode == "PARSERS" then
            Slider.Y = Slider.Y + (item_selected * 75 - 272 - Slider.Y) / 8
        end
    end
    if StartSearch then
        if Keyboard.getState() == FINISHED then
            local data = Keyboard.getInput()
            Console.write('Searching for "' .. data .. '"')
            if data:gsub("%s", "") ~= "" then
                Catalogs.terminate()
                searchData = data
                getMangaMode = "SEARCH"
                Notifications.push(string.format(Language[LANG].NOTIFICATIONS.SEARCHING, data))
            end
            StartSearch = false
            Keyboard.clear()
        elseif Keyboard.getState() == CANCELED then
            StartSearch = false
            Keyboard.clear()
        end
    end
    if mode == "PARSERS" then
        if Slider.Y < -10 then
            Slider.Y = -10
            Slider.V = 0
        elseif Slider.Y > ceil(#Parsers) * 75 - 514 then
            Slider.Y = max(-10, ceil(#Parsers) * 75 - 514)
            Slider.V = 0
        end
    elseif mode == "MANGA" or mode == "LIBRARY" then
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
        end
    end
end

function Catalogs.draw()
    Graphics.fillRect(955, 960, 0, 544, Color.new(160, 160, 160))
    if mode == "PARSERS" then
        local start = max(1, floor((Slider.Y - 10) / 75))
        local y = start * 75 - Slider.Y
        for i = start, min(#Parsers, start + 9) do
            local parser = Parsers[i]
            Graphics.fillRect(264, 946, y - 75, y, Color.new(0, 0, 0, 32))
            Graphics.fillRect(265, 945, y - 74, y, COLOR_WHITE)
            Font.print(FONT26, 275, y - 70, parser.Name, COLOR_BLACK)
            local lang_text = Language[LANG].PARSERS[parser.Lang] or parser.Lang or ""
            Font.print(FONT16, 935 - Font.getTextWidth(FONT16, lang_text), y - 10 - Font.getTextHeight(FONT16, lang_text), lang_text, Color.new(101, 101, 101))
            if parser.NSFW then
                Font.print(FONT16, 280 + Font.getTextWidth(FONT26, parser.Name), y - 70 + Font.getTextHeight(FONT26, parser.Name) - Font.getTextHeight(FONT16, "NSFW"), "NSFW", Color.new(0, 105, 170))
            end
            local link_text = (parser.Link .. "/")
            Font.print(FONT16, 275, y - 23 - Font.getTextHeight(FONT16, link_text), link_text, Color.new(128, 128, 128))
            if Slider.ItemID == i then
                Graphics.fillRect(265, 945, y - 74, y, Color.new(0, 0, 0, 32))
            end
            y = y + 75
        end
        if item_selected ~= 0 then
            y = item_selected * 75 - Slider.Y
            local SELECTED_RED = Color.new(255, 255, 255, 150 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 800)))
            for i=0,2 do
                Graphics.fillEmptyRect(264+i, 946-i, y-i, y-74+i, Color.new(20, 20, 230))
                Graphics.fillEmptyRect(264+i, 946-i, y-i, y-74+i, SELECTED_RED)
            end
        end
        local elements_count = #Parsers
        if elements_count > 0 then
            Graphics.fillRect(264, 946, y - 75, y - 74, Color.new(0, 0, 0, 32))        
            if elements_count > 7 then
                local h = #Parsers * 75 / 524
                Graphics.fillRect(955, 960, Slider.Y / h, (Slider.Y + 524) / h, COLOR_BLACK)
            end
        end
    elseif mode == "MANGA" or mode == "LIBRARY" then
        local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 12)) * 4 + 1)
        for i = start, min(#Results, start + 15) do
            if Details.getFade() == 0 or Details.getManga() ~= Results[i] then
                DrawManga(610 + (((i - 1) % 4) - 2) * (MANGA_WIDTH + 10) + MANGA_WIDTH / 2, MANGA_HEIGHT / 2 - Slider.Y + floor((i - 1) / 4) * (MANGA_HEIGHT + 12) + 12, Results[i])
            end
        end
        if item_selected ~= 0 then
            local x = 610 + (((item_selected - 1) % 4) - 2) * (MANGA_WIDTH + 10) + MANGA_WIDTH / 2
            local y = MANGA_HEIGHT / 2 - Slider.Y + floor((item_selected - 1) / 4) * (MANGA_HEIGHT + 12) + 12
            local SELECTED_RED = Color.new(255, 255, 255, 150 * math.abs(math.sin(Timer.getTime(GlobalTimer) / 800)))
            for i=0,4 do
                Graphics.fillEmptyRect(x-MANGA_WIDTH/2+i, x+MANGA_WIDTH/2-i, y-MANGA_HEIGHT/2+i, y+MANGA_HEIGHT/2-i, Color.new(20, 20, 230))
                Graphics.fillEmptyRect(x-MANGA_WIDTH/2+i, x+MANGA_WIDTH/2-i, y-MANGA_HEIGHT/2+i, y+MANGA_HEIGHT/2-i, SELECTED_RED)
            end
        end
        if #Results > 4 then
            local h = ceil(#Results / 4) * (MANGA_HEIGHT + 12) / 524
            Graphics.fillRect(955, 960, Slider.Y / h, (Slider.Y + 524) / h, COLOR_BLACK)
        end
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

---@param new_mode string | '"PARSERS"' | '"MANGA"' | '"LIBRARY"'
function Catalogs.setMode(new_mode)
    mode = new_mode
    item_selected = 0
    Catalogs.terminate()
end
