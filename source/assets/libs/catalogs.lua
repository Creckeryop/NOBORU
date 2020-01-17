local SliderY       = 0
local SliderVel     = 0
local TouchY        = 0

local COLOR_WHITE   = Color.new(255, 255, 255)
local COLOR_BLACK   = Color.new(  0,   0,   0)

local Parser        = nil

TOUCH_MODE_NONE     = 0
TOUCH_MODE_READ     = 1
TOUCH_MODE_SLIDE    = 2
local TOUCH_MODE    = TOUCH_MODE_NONE

local PARSERS_MODE  = 0
local MANGAS_MODE   = 1
local CATALOGS_MODE = PARSERS_MODE

local DownloadedImage   = {}
local page              = 1
local PagesDownloadDone = false
local Results           = {}

local UpdateMangas  = function()
    if SliderVel == 0 then
        local start = math.max(1, math.floor(SliderY / (MANGA_HEIGHT + 24))*4 + 1)
        if #DownloadedImage > 12 then
            local new_table = {}
            for _, i in ipairs(DownloadedImage) do
                if i < start or i > math.min(#Results, start + 11) then
                    local manga = Results[i]
                    if manga.ImageDownload then
                        threads.Remove(manga,'Image')
                        if manga.Image then
                            if manga.Image.e then
                                Graphics.freeImage(manga.Image.e)
                                manga.Image.e = nil
                            end
                        end
                        manga.ImageDownload = nil
                    end
                else
                    new_table[#new_table + 1] = i
                end
            end
            DownloadedImage = new_table
        end
        for i = start, math.min(#Results,start + 11) do
            local manga = Results[i]
            if not manga.ImageDownload then
                threads.DownloadImageAsync(manga.ImageLink, manga, "Image")
                manga.ImageDownload = true
                DownloadedImage[#DownloadedImage + 1] = i
            end
        end
    end
end

Catalogs = {
    Input = function(OldPad, Pad, OldTouch, Touch)
        if CATALOGS_MODE == MANGAS_MODE then
            if Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
                CATALOGS_MODE = PARSERS_MODE
                Catalogs.Term()
            end
        end
        if TOUCH_MODE == TOUCH_MODE_NONE and OldTouch.x ~= nil and Touch.x ~= nil and Touch.x > 240 then
            TOUCH_MODE = TOUCH_MODE_READ
            TouchY = Touch.y
        elseif TOUCH_MODE ~= TOUCH_MODE_NONE and Touch.x == nil then
            if TOUCH_MODE == TOUCH_MODE_READ then
                if CATALOGS_MODE == PARSERS_MODE then
                    if OldTouch.x > 265 and OldTouch.x < 945 then
                        local id = math.floor((SliderY - 10 + OldTouch.y) / 70) + 1
                        if Parsers[id] ~= nil then
                            CATALOGS_MODE = MANGAS_MODE
                            Parser = Parsers[id]
                        end
                    end
                elseif CATALOGS_MODE == MANGAS_MODE then
                    local start = math.max(1,math.floor((SliderY - 20) / (MANGA_HEIGHT+24))*4 + 1)
                    for i = start, math.min(#Results,start + 11) do
                        local lx = ((i - 1) % 4 - 2) * (MANGA_WIDTH + 10) + 610
                        local uy = math.floor((i - 1) / 4) * (MANGA_HEIGHT + 24) - SliderY + 24
                        if OldTouch.x > lx and OldTouch.x < lx + MANGA_WIDTH and OldTouch.y > uy and OldTouch.y < uy + MANGA_HEIGHT  then
                            local manga = Results[i]
                            local id = i
                            Details.SetManga(manga, lx + MANGA_WIDTH / 2, uy + MANGA_HEIGHT / 2)
                            if manga.Image == nil then
                                threads.Remove(manga, 'Image')
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
            TOUCH_MODE = TOUCH_MODE_NONE
        end
        if TOUCH_MODE == TOUCH_MODE_READ then
            if SliderVel ~= 0 or math.abs(TouchY-Touch.y) > 10 then
                TOUCH_MODE = TOUCH_MODE_SLIDE
            end
        end
        if TOUCH_MODE == TOUCH_MODE_SLIDE and OldTouch.x ~= nil and Touch.x ~= nil and Touch.x > 240  then
            SliderVel = OldTouch.y - Touch.y
        end
    end,
    Update = function(delta)
        if CATALOGS_MODE == MANGAS_MODE then
            UpdateMangas()
        end
        SliderY = SliderY + SliderVel
        SliderVel = SliderVel / 1.12
        if math.abs(SliderVel) < 1 then
            SliderVel = 0
        end
        if SliderY < 0 then
            SliderY = 0
            SliderVel = 0
        elseif CATALOGS_MODE == PARSERS_MODE and SliderY > math.ceil(#Parsers) * 70 - 534 then
            SliderY = math.max(0, math.ceil(#Parsers) * 70 - 534)
            SliderVel = 0
        elseif CATALOGS_MODE == MANGAS_MODE and SliderY > math.ceil(#Results/4) * (MANGA_HEIGHT + 24) - 520 then
            SliderY = math.max(0, math.ceil(#Results/4) * (MANGA_HEIGHT + 24) - 520)
            SliderVel = 0
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
            local start = math.max(1, math.floor((SliderY - 10) / 70))
            local y = start * 70 - SliderY
            for i = start, math.min(#Parsers,start + 9) do
                local parser = Parsers[i]
                Graphics.fillRect(265, 945, y - 60, y, COLOR_WHITE)
                Font.print(FONT, 275, y - 50, parser.Name, COLOR_BLACK)

                local lang_text = Language[LANG].PARSERS[parser.Lang] or parser.Lang or ""
                Font.print(FONT, 935 - Font.getTextWidth(FONT, lang_text), y - 10 - Font.getTextHeight(FONT,lang_text), lang_text, Color.new(101,101,101))
                
                local link_text = (parser.Link.."/")
                Font.print(FONT, 275, y - 10 - Font.getTextHeight(FONT, link_text), link_text, Color.new(128,128,128))
                y = y + 70
            end
            if #Parsers > 7 then
                local h = #Parsers * 70 / 544
                Graphics.fillRect(955, 960, SliderY / h, (SliderY + 544) / h, COLOR_BLACK)
            end
        elseif CATALOGS_MODE == MANGAS_MODE then
            local start = math.max(1, math.floor(SliderY / (MANGA_HEIGHT + 24)) * 4 + 1)
            for i = start, math.min(#Results, start + 11) do
                if (Details.GetMode() == DETAILS_START or Details.GetMode() == DETAILS_WAIT) and Details.GetManga() == Results[i] then
                else
                    DrawManga(610 + (((i - 1) % 4) - 2)*(MANGA_WIDTH + 10) + MANGA_WIDTH/2, MANGA_HEIGHT / 2 - SliderY + math.floor((i - 1)/4) * (MANGA_HEIGHT + 24) + 24, Results[i])
                end
            end
            if #Results > 4 then
                local h = math.ceil(#Results / 4) * (MANGA_HEIGHT + 24) / 544
                Graphics.fillRect(955, 960, SliderY / h, (SliderY + 544) / h, Color.new(0, 0, 0))
            end
        end
    end,
    Shrink = function()
        for _, i in ipairs(DownloadedImage) do
            local manga = Results[i]
            if manga.ImageDownload then
                threads.Remove(manga,'Image')
                if manga.Image then
                    if manga.Image.e then
                        Graphics.freeImage(manga.Image.e)
                        manga.Image.e = nil
                    end
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