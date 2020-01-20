local ffi = require 'ffi'
local Slider = ffi.new("Slider")
local TOUCH  = ffi.new("TOUCH")

local Parser        = nil
local TouchTimer    = Timer.new()

local PARSERS_MODE  = 0
local MANGAS_MODE   = 1
local CATALOGS_MODE = PARSERS_MODE

local DownloadedImage   = {}
local page              = 1
local PagesDownloadDone = false
local Results           = {}

local abs, ceil, floor, max, min = math.abs, math.ceil, math.floor, math.max, math.min

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
                            threads.Remove(manga)
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
                threads.DownloadImageAsync(manga.ImageLink, manga, "Image")
                manga.ImageDownload = true
                DownloadedImage[#DownloadedImage + 1] = i
            end
        end
    else
        local new_table = {}
        for _, i in ipairs(DownloadedImage) do
            local manga = Results[i]
            if threads.Check(manga) and (Details.GetFade() == 0 or manga ~= Details.GetManga()) then
                threads.Remove(manga)
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
        if CATALOGS_MODE == MANGAS_MODE and Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
            CATALOGS_MODE = PARSERS_MODE
            Catalogs.Term()
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
                        local id = floor((Slider.Y - 10 + OldTouch.y) / 70) + 1
                        if Parsers[id]then
                            CATALOGS_MODE = MANGAS_MODE
                            Parser = Parsers[id]
                        end
                    end
                elseif CATALOGS_MODE == MANGAS_MODE then
                    local start = max(1,floor((Slider.Y - 20) / (MANGA_HEIGHT+24))*4 + 1)
                    for i = start, min(#Results,start + 11) do
                        local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 10) + 610
                        local uy = floor((i - 1) / 4) * (MANGA_HEIGHT + 24) - Slider.Y + 24
                        if OldTouch.x > lx and OldTouch.x < lx + MANGA_WIDTH and OldTouch.y > uy and OldTouch.y < uy + MANGA_HEIGHT  then
                            local manga = Results[i]
                            local id = i
                            Details.SetManga(manga, lx + MANGA_WIDTH / 2, uy + MANGA_HEIGHT / 2)
                            if manga.Image == nil then
                                threads.Remove(manga)
                                threads.DownloadImageAsync(manga.ImageLink, manga, 'Image', true)
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
        if TOUCH.MODE == TOUCH.READ and (abs(Slider.V) > 0.1 or abs(Slider.TouchY - Touch.y) > 10) then
            TOUCH.MODE = TOUCH.SLIDE
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
        end
        Slider.Y = Slider.Y + Slider.V
        Slider.V = Slider.V / 1.12
        if abs(Slider.V) < 1 then
            Slider.V = 0
        end
        if Slider.Y < 0 then
            Slider.Y = 0
            Slider.V = 0
        elseif CATALOGS_MODE == PARSERS_MODE and Slider.Y > ceil(#Parsers) * 70 - 534 then
            Slider.Y = max(0, ceil(#Parsers) * 70 - 534)
            Slider.V = 0
        elseif CATALOGS_MODE == MANGAS_MODE and Slider.Y > ceil(#Results/4) * (MANGA_HEIGHT + 24) - 520 then
            Slider.Y = max(0, ceil(#Results/4) * (MANGA_HEIGHT + 24) - 520)
            Slider.V = 0
            if not PagesDownloadDone then
                if Parser then
                    if not ParserManager.Check(Results) then
                        ParserManager.getMangaListAsync(Parser, page, Results)
                        page = page + 1
                    end
                end
            end
        end
    end,
    Draw = function()
        Graphics.fillRect(955, 960, 0, 544, Color.new(160, 160, 160))
        if CATALOGS_MODE == PARSERS_MODE then
            local start = max(1, floor((Slider.Y - 10) / 70))
            local y = start * 70 - Slider.Y
            for i = start, min(#Parsers,start + 9) do
                local parser = Parsers[i]
                Graphics.fillRect(265, 945, y - 60, y, COLOR_WHITE)
                Font.print(FONT, 275, y - 50, parser.Name, COLOR_BLACK)

                local lang_text = Language[LANG].PARSERS[parser.Lang] or parser.Lang or ""
                Font.print(FONT, 935 - Font.getTextWidth(FONT, lang_text), y - 10 - Font.getTextHeight(FONT,lang_text), lang_text, Color.new(101, 101, 101))

                local link_text = (parser.Link.."/")
                Font.print(FONT, 275, y - 10 - Font.getTextHeight(FONT, link_text), link_text, Color.new(128, 128, 128))
                y = y + 70
            end
            if #Parsers > 7 then
                local h = #Parsers * 70 / 544
                Graphics.fillRect(955, 960, Slider.Y / h, (Slider.Y + 544) / h, COLOR_BLACK)
            end
        elseif CATALOGS_MODE == MANGAS_MODE then
            local start = max(1, floor(Slider.Y / (MANGA_HEIGHT + 24)) * 4 + 1)
            for i = start, min(#Results, start + 11) do
                if Details.GetFade() == 0 or Details.GetManga() ~= Results[i] then
                    DrawManga(610 + (((i - 1) % 4) - 2)*(MANGA_WIDTH + 10) + MANGA_WIDTH/2, MANGA_HEIGHT / 2 - Slider.Y + floor((i - 1)/4) * (MANGA_HEIGHT + 24) + 24, Results[i])
                end
            end
            if #Results > 4 then
                local h = ceil(#Results / 4) * (MANGA_HEIGHT + 24) / 544
                Graphics.fillRect(955, 960, Slider.Y / h, (Slider.Y + 544) / h, COLOR_BLACK)
            end
        end
    end,
    Shrink = function()
        for _, i in ipairs(DownloadedImage) do
            local manga = Results[i]
            if manga.ImageDownload then
                threads.Remove(manga)
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
    end
}