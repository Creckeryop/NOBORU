local Slider = Slider()
local TOUCH  = TOUCH()
Slider.Y = -10

local Parser        = nil
local TouchTimer    = Timer.new()

local PARSERS_MODE  = 0
local MANGAS_MODE   = 1
local CATALOGS_MODE = PARSERS_MODE

local GETMANGA_MODE = POPULAR_MODE
local SEARCH_DATA = ""

local DownloadedImage   = {}
local page              = 1
local PagesDownloadDone = false
local Results           = {}

local abs, ceil, floor, max, min = math.abs, math.ceil, math.floor, math.max, math.min

START_SEARCH = false

local UpdateMangas  = function()
    if Slider.V == 0 and Timer.getTime(TouchTimer) > 200 then
        local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 24))*4 + 1)
        if #DownloadedImage > 12 then
            local new_table = {}
            for _, i in ipairs(DownloadedImage) do
                if i < start or i > min(#Results, start + 11) then
                    local manga = Results[i]
                    if manga.ImageDownload then
                        if manga.Image then
                            manga.Image:free()
                        else
                            Threads.Remove(manga)
                        end
                        manga.ImageDownload = nil
                    end
                else
                    new_table[#new_table + 1] = i
                end
            end
            DownloadedImage = new_table
        end
        for i = start, min(#Results,start + 11) do
            local manga = Results[i]
            if not manga.ImageDownload then
                Threads.DownloadImageAsync(manga.ImageLink, manga, "Image")
                manga.ImageDownload = true
                DownloadedImage[#DownloadedImage + 1] = i
            end
        end
    else
        local new_table = {}
        for _, i in ipairs(DownloadedImage) do
            local manga = Results[i]
            if Threads.Check(manga) and (Details.GetFade() == 0 or manga ~= Details.GetManga()) then
                Threads.Remove(manga)
                manga.ImageDownload = nil
            else
                new_table[#new_table + 1] = i
            end
        end
        DownloadedImage = new_table
    end
end

Catalogs = {
    Input = function(OldPad, Pad, OldTouch, Touch)
        if CATALOGS_MODE == MANGAS_MODE then
            if Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
                CATALOGS_MODE = PARSERS_MODE
                Slider.Y = -10
                Catalogs.Term()
            end
            if Controls.check(Pad, SCE_CTRL_SQUARE) and not Controls.check(OldPad, SCE_CTRL_SQUARE) then
                local new_mode = GETMANGA_MODE == POPULAR_MODE and Parser.getLatestManga and LATEST_MODE or POPULAR_MODE
                if GETMANGA_MODE ~= new_mode then
                    Catalogs.Term()
                    GETMANGA_MODE = new_mode
                    Notifications.Push(GETMANGA_MODE == POPULAR_MODE and "Mode: Popular" or GETMANGA_MODE == LATEST_MODE and "Mode: Latest")
                end
            end
            if Controls.check(Pad, SCE_CTRL_TRIANGLE) and not Controls.check(OldPad, SCE_CTRL_TRIANGLE) then
                if Parser.searchManga then
                    Keyboard.show("Search", SEARCH_DATA, 128, TYPE_DEFAULT, MODE_TEXT,OPT_NO_AUTOCAP)
                    START_SEARCH = true
                end
            end
        elseif CATALOGS_MODE == PARSERS_MODE then
            if Controls.check(Pad, SCE_CTRL_TRIANGLE) and not Controls.check(OldPad, SCE_CTRL_TRIANGLE) then
                ParserManager.UpdateParserList(Parsers)
            end
        end
        if Touch.x then
            Timer.reset(TouchTimer)
        end
        if TOUCH.MODE == TOUCH.NONE and OldTouch.x and Touch.x and Touch.x > 240 then
            TOUCH.MODE = TOUCH.READ
            Slider.TouchY = Touch.y
        elseif TOUCH.MODE ~= TOUCH.NONE and Touch.x == nil then
            if TOUCH.MODE == TOUCH.READ then
                if CATALOGS_MODE == PARSERS_MODE then
                    if OldTouch.x > 265 and OldTouch.x < 945 then
                        local id = floor((Slider.Y - 10 + OldTouch.y) / 75) + 1
                        if Parsers[id]then
                            CATALOGS_MODE = MANGAS_MODE
                            Parser = Parsers[id]
                        end
                    end
                elseif CATALOGS_MODE == MANGAS_MODE then
                    local start = max(1,floor((Slider.Y - 20) / (MANGA_HEIGHT+12))*4 + 1)
                    for i = start, min(#Results,start + 11) do
                        local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 10) + 610
                        local uy = floor((i - 1) / 4) * (MANGA_HEIGHT + 12) - Slider.Y + 12
                        if OldTouch.x > lx and OldTouch.x < lx + MANGA_WIDTH and OldTouch.y > uy and OldTouch.y < uy + MANGA_HEIGHT  then
                            local manga = Results[i]
                            local id = i
                            Details.SetManga(manga, lx + MANGA_WIDTH / 2, uy + MANGA_HEIGHT / 2)
                            if manga.Image == nil then
                                Threads.Remove(manga)
                                Threads.DownloadImageAsync(manga.ImageLink, manga, 'Image', true)
                                if not manga.ImageDownload then
                                    DownloadedImage[#DownloadedImage + 1] = id
                                    manga.ImageDownload = true
                                end
                            end
                            break
                        end
                    end
                end
            end
            TOUCH.MODE = TOUCH.NONE
        end
        local new_itemID = 0
        if TOUCH.MODE == TOUCH.READ then
            if abs(Slider.V) > 0.1 or abs(Slider.TouchY - Touch.y) > 10 then
                TOUCH.MODE = TOUCH.SLIDE
            else
                if CATALOGS_MODE == PARSERS_MODE then
                    if OldTouch.x > 265 and OldTouch.x < 945 then
                        local id = floor((Slider.Y - 10 + OldTouch.y) / 75) + 1
                        if Parsers[id] then
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
        if TOUCH.MODE == TOUCH.SLIDE and OldTouch.x and Touch.x and Touch.x > 240  then
            Slider.V = OldTouch.y - Touch.y
        end
    end,
    Update = function(delta)
        if CATALOGS_MODE == MANGAS_MODE then
            UpdateMangas()
            if ParserManager.Check(Results) then
                Loading.SetMode(LOADING_BLACK, 600, 272)
            elseif Details.GetMode() == DETAILS_END then
                Loading.SetMode(LOADING_NONE)
            end
            Panel.Set{
                ["L\\R"] = "Change Section",
                Square = GETMANGA_MODE == POPULAR_MODE and "Mode: Popular" or GETMANGA_MODE == LATEST_MODE and "Mode: Latest" or GETMANGA_MODE == SEARCH_MODE and "Mode: Searching <<"..SEARCH_DATA..">>",
                Triangle = Parser.searchManga and "Search" or nil,
                DPad = "Choose"
            }
        elseif CATALOGS_MODE == PARSERS_MODE then
            Panel.Set{
                ["L\\R"] = "Change Section",
                Triangle = "Update",
                DPad = "Choose"
            }
        end

        Slider.Y = Slider.Y + Slider.V
        Slider.V = Slider.V / 1.12

        if abs(Slider.V) < 1 then
            Slider.V = 0
        end
        if START_SEARCH then
            if Keyboard.getState() == FINISHED then
                local data = Keyboard.getInput()
                Console.writeLine("Searching for "..data)
                if data:gsub("%s","") ~= "" then
                    Catalogs.Term()
                    SEARCH_DATA = data
                    GETMANGA_MODE = SEARCH_MODE
                end
                START_SEARCH = false
                Keyboard.clear()
            elseif Keyboard.getState() == CANCELED then
                START_SEARCH = false
                Keyboard.clear()
            end
        end
        if CATALOGS_MODE == PARSERS_MODE then
            if Slider.Y < -10 then
                Slider.Y = -10
                Slider.V = 0
            elseif Slider.Y > ceil(#Parsers) * 75 - 514 then
                Slider.Y = max(-10, ceil(#Parsers) * 75 - 514)
                Slider.V = 0
            end
        elseif CATALOGS_MODE == MANGAS_MODE then
            if Slider.Y < 0 then
                Slider.Y = 0
                Slider.V = 0
            elseif Slider.Y > ceil(#Results/4) * (MANGA_HEIGHT + 12) - 512 then
                Slider.Y = max(0, ceil(#Results/4) * (MANGA_HEIGHT + 12) - 512)
                Slider.V = 0
                if not PagesDownloadDone then
                    if Parser then
                        if not ParserManager.Check(Results) then
                            ParserManager.getMangaListAsync(GETMANGA_MODE, Parser, page, Results, SEARCH_DATA)
                            page = page + 1
                        end
                    end
                end
            end
        end
    end,
    Draw = function()
        Graphics.fillRect(955, 960, 0, 544, Color.new(160, 160, 160))
        if CATALOGS_MODE == PARSERS_MODE then
            local start = max(1, floor((Slider.Y - 10) / 75))
            local y = start * 75 - Slider.Y
            for i = start, min(#Parsers,start + 9) do
                local parser = Parsers[i]
                Graphics.fillRect(264, 946, y - 75, y, Color.new(0, 0, 0, 32))
                Graphics.fillRect(265, 945, y - 74, y, COLOR_WHITE)
                Font.print(FONT26, 275, y - 70, parser.Name, COLOR_BLACK)

                local lang_text = Language[LANG].PARSERS[parser.Lang] or parser.Lang or ""
                Font.print(FONT, 935 - Font.getTextWidth(FONT, lang_text), y - 10 - Font.getTextHeight(FONT,lang_text), lang_text, Color.new(101, 101, 101))
                if parser.NSFW then
                    Font.print(FONT, 280 + Font.getTextWidth(FONT26, parser.Name), y - 70 +Font.getTextHeight(FONT26, parser.Name)-Font.getTextHeight(FONT, "NSFW"), "NSFW", Color.new(0, 105, 170))
                end
                local link_text = (parser.Link.."/")
                Font.print(FONT, 275, y - 23 - Font.getTextHeight(FONT, link_text), link_text, Color.new(128, 128, 128))
                if Slider.ItemID == i then
                    Graphics.fillRect(265, 945, y - 74, y, Color.new(0, 0, 0, 32))
                end
                y = y + 75
            end
            if #Parsers > 0 then
                Graphics.fillRect(264, 946, y - 75, y-74, Color.new(0, 0, 0, 32))
            end
            if #Parsers > 7 then
                local h = #Parsers * 75 / 524
                Graphics.fillRect(955, 960, Slider.Y / h, (Slider.Y + 524) / h, COLOR_BLACK)
            end
        elseif CATALOGS_MODE == MANGAS_MODE then
            local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 12)) * 4 + 1)
            for i = start, min(#Results, start + 15) do
                if Details.GetFade() == 0 or Details.GetManga() ~= Results[i] then
                    DrawManga(610 + (((i - 1) % 4) - 2)*(MANGA_WIDTH + 10) + MANGA_WIDTH/2, MANGA_HEIGHT / 2 - Slider.Y + floor((i - 1)/4) * (MANGA_HEIGHT + 12) + 12, Results[i])
                end
            end
            if #Results > 4 then
                local h = ceil(#Results / 4) * (MANGA_HEIGHT + 12) / 524
                Graphics.fillRect(955, 960, Slider.Y / h, (Slider.Y + 524) / h, COLOR_BLACK)
            end
        end
    end,
    Shrink = function()
        for _, i in ipairs(DownloadedImage) do
            local manga = Results[i]
            if manga.ImageDownload then
                Threads.Remove(manga)
                if manga.Image then
                    manga.Image:free()
                    manga.Image = nil
                end
                manga.ImageDownload = nil
            end
        end
        ParserManager.Remove(Results)
        Loading.SetMode(LOADING_NONE)
    end,
    Term = function()
        Catalogs.Shrink()
        DownloadedImage     = {}
        Results             = {}
        page                = 1
        PagesDownloadDone   = false
        SEARCH_DATA = ""
        GETMANGA_MODE = POPULAR_MODE
    end
}