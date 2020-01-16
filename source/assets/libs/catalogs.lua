local SliderY       = 0
local SliderVel     = 0
local TouchY        = 0

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

local Results = {}
local UpdateMangas  = function()
    if SliderVel == 0 then
        local start = math.max(1,math.floor(SliderY / (MANGA_HEIGHT+24))*4 + 1)
        if #DownloadedImage > 12 then
            local new_table = {}
            for k = 1, #DownloadedImage do
                local i = DownloadedImage[k]
                if i<start or i>math.min(#Results,start+11) then
                    if Results[i].ImageDownload then
                        Threads.DeleteUnique("ImgLoad"..i)
                        if Results[i].image ~= nil then
                            Graphics.freeImage(Results[i].image)
                            Results[i].image = nil
                        end
                        Results[i].ImageDownload = nil
                    end
                else
                    new_table[#new_table+1] = i
                end
            end
            DownloadedImage = new_table
        end
        for i = start, math.min(#Results,start + 11) do
            if not Results[i].ImageDownload then
                local manga = Results[i]
                local id = i
                Threads.AddTask{
                    Type = "FileDownload",
                    Path = "cache.img",
                    Link = manga.ImageLink,
                    OnComplete = function()
                        Threads.InsertTask{
                            Type = "ImageLoad",
                            Path = "cache.img",
                            Save = function(a)
                                if a ~= nil then
                                    Graphics.setImageFilters(a, FILTER_LINEAR, FILTER_LINEAR)
                                    manga.image = a
                                end
                            end,
                            Unique = "ImgLoad"..id
                        }
                    end,
                    Unique = "ImgLoad"..id
                }
                Results[i].ImageDownload = true
                DownloadedImage[#DownloadedImage+1] = i
            end
        end
    end
end
Catalogs = {
    Input = function(OldPad, Pad, OldTouch, Touch)
        if TOUCH_MODE == TOUCH_MODE_NONE and OldTouch.x ~= nil and Touch.x ~= nil and Touch.x > 240 then
            TOUCH_MODE = TOUCH_MODE_READ
            TouchY = Touch.y
        elseif TOUCH_MODE ~= TOUCH_MODE_NONE and Touch.x == nil then
            if TOUCH_MODE == TOUCH_MODE_READ then
                if CATALOGS_MODE == PARSERS_MODE then
                    local start = math.max(1,math.floor((SliderY-10) / (60+10)))
                    for i = start, math.min(#Parsers,start+8) do
                        if OldTouch.x > 265 and OldTouch.x < 945 and OldTouch.y > 10+(i-1)*(60+10) - SliderY and OldTouch.y < 10+(i-1)*(60+10) - SliderY+60 then
                            CATALOGS_MODE = MANGAS_MODE
                            Parser = Parsers[i]
                            break
                        end
                    end
                elseif CATALOGS_MODE == MANGAS_MODE then
                    local start = math.max(1,math.floor((SliderY - 20) / (MANGA_HEIGHT+24))*4 + 1)
                    for i = start, math.min(#Results,start + 11) do
                        if OldTouch.x > 235 + 750 / 2 - (10 + MANGA_WIDTH) * 2 + ((i - 1) % 4)*(MANGA_WIDTH + 10) and
                            OldTouch.x < 235 + 750 / 2 - (10 + MANGA_WIDTH) * 2 + ((i - 1) % 4)*(MANGA_WIDTH + 10)+MANGA_WIDTH and
                            OldTouch.y > 24 - SliderY + math.floor((i-1)/4)*(MANGA_HEIGHT + 24) and
                            OldTouch.y < 24 + MANGA_HEIGHT - SliderY + math.floor((i-1)/4)*(MANGA_HEIGHT + 24) then
                            local manga = Results[i]
                            local x = 235 + 750 / 2 - (10 + MANGA_WIDTH) * 2 + ((i - 1) % 4)*(MANGA_WIDTH + 10) + MANGA_WIDTH/2
                            local y = 24 + MANGA_HEIGHT / 2 - SliderY + math.floor((i-1)/4)*(MANGA_HEIGHT + 24)
                            if manga.image == nil then
                                Threads.DeleteUnique("ImgLoad"..i)
                            end
                            Details.SetManga(manga, x, y)
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
        if CATALOGS_MODE == MANGAS_MODE then
            if Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
                CATALOGS_MODE = PARSERS_MODE
                Catalogs.Term()
            end
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
        elseif CATALOGS_MODE == PARSERS_MODE and SliderY > math.ceil(#Parsers) * (60+10) - 534 then
            SliderY = math.max(0, math.ceil(#Parsers) * (60+10) - 534)
            SliderVel = 0
        elseif CATALOGS_MODE == MANGAS_MODE and SliderY > math.ceil(#Results/4) * (MANGA_HEIGHT + 24) - 520 then
            SliderY = math.max(0, math.ceil(#Results/4) * (MANGA_HEIGHT + 24) - 520)
            SliderVel = 0
            if not PagesDownloadDone then
                local parser = Parser
                if parser then
                    if not Threads.CheckUnique("PageLoading") then
                        Threads.InsertTask{
                            Type = "Coroutine",
                            Unique = "PageLoading",
                            F = function() return parser:getManga(page) end,
                            Save = function(a)
                                for i = 1, #a do
                                    Results[#Results+1] = a[i]
                                end
                                Loading.SetMode(LOADING_NONE)
                                page = page + 1
                                if #a == 0 then
                                    PagesDownloadDone = true
                                end
                            end,
                            OnLaunch = function()
                                Loading.SetMode(LOADING_BLACK, 599, 272)
                            end
                        }
                    end
                end
            end
        end
    end,
    Draw = function()
        Graphics.fillRect(955, 960, 0, 544, Color.new(160, 160, 160))
        if CATALOGS_MODE == PARSERS_MODE then
            local start = math.max(1,math.floor((SliderY-10) / (60+10)))
            for i = start, math.min(#Parsers,start+8) do
                Graphics.fillRect(265, 945, 10+(i-1)*(60+10) - SliderY,10+(i-1)*(60+10) - SliderY+60,Color.new(255,255,255))
                Font.print(FONT,275, 10+(i-1)*(60+10) - SliderY+10,Parsers[i].Name, Color.new(0,0,0))
                local lang_text = Language[LANG].PARSERS[Parsers[i].Lang] or ""
                Font.print(FONT,945-10-Font.getTextWidth(FONT,lang_text),10+(i-1)*(60+10) - SliderY+60-10-Font.getTextHeight(FONT,lang_text),lang_text,Color.new(101,101,101))
                local link_text = (Parsers[i].Link.."/")
                Font.print(FONT,275,10+(i-1)*(60+10) - SliderY+60-10-Font.getTextHeight(FONT,link_text),link_text,Color.new(128,128,128))
            end
            if #Parsers > 7 then
                local h = #Parsers * (60 + 10) / 544
                Graphics.fillRect(955, 960, SliderY / h, (SliderY + 544) / h, Color.new(0, 0, 0))
            end
        elseif CATALOGS_MODE == MANGAS_MODE then
            local start = math.max(1,math.floor(SliderY / (MANGA_HEIGHT+24))*4 + 1)
            for i = start, math.min(#Results,start + 11) do
                DrawManga(235 + 750 / 2 - (10 + MANGA_WIDTH) * 2 + ((i - 1) % 4)*(MANGA_WIDTH + 10) + MANGA_WIDTH/2, MANGA_HEIGHT / 2 - SliderY + math.floor((i-1)/4)*(MANGA_HEIGHT + 24) + 24, Results[i])
            end
            if #Results > 4 then
                local h = math.ceil(#Results/4) * (MANGA_HEIGHT + 24) / 544
                Graphics.fillRect(955, 960, SliderY / h, (SliderY + 544) / h, Color.new(0, 0, 0))
            end
        end
    end,
    Shrink = function()
        for k = 1, #DownloadedImage do
            local i = DownloadedImage[k]
            if Results[i].ImageDownload then
                Threads.DeleteUnique("ImgLoad"..i)
                if Results[i].image ~= nil then
                    Graphics.freeImage(Results[i].image)
                    Results[i].image = nil
                end
                Results[i].ImageDownload = nil
            end
        end
        Threads.DeleteUnique("PageLoading")
        Loading.SetMode(LOADING_NONE)
    end,
    Term = function()
        Catalogs.Shrink()
        DownloadedImage = {}
        PagesDownloadDone = false
        page = 1
        SliderY = 0
        SliderVel = 0
        TOUCH_MODE = TOUCH_MODE_NONE
        Results = {}
    end
}