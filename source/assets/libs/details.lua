DETAILS_START = 0
DETAILS_WAIT  = 1
DETAILS_END   = 2
local DETAILS_MODE = DETAILS_END

local Manga     = nil
local Fade      = 0
local Point     = {x = 0, y = 0}
local Center    = {x = 0, y = 0}
local alpha     = 255
local M         = 0.5
local Y         = 0
local VelY      = 0
local AnimationTimer     = Timer.new()
local NameTimer          = Timer.new()
local Chapters = {}

local easeInOutQuint = function(t)
    t = t - 1
    return 1 + t * t * t
end
local a544 = 960
Details = {
    SetManga = function (manga, x, y)
        if manga ~= nil and x ~= nil and y ~= nil then
            Chapters = {}
            Manga = manga
            DETAILS_MODE = DETAILS_START
            Point.x, Point.y = x, y
            alpha = 255
            M = 0.25
            a544 = 544
            if Parsers[manga.ParserID] then
                Threads.InsertTask{
                    Type = "Coroutine",
                    Unique = "ChaptersLoading",
                    F = function ()
                        return Parsers[manga.ParserID]:getChapters(manga)
                    end,
                    Save = function(chapters)
                        Chapters = chapters
                        Loading.SetMode(LOADING_NONE)
                    end,
                    OnLaunch = function ()
                        Loading.SetMode(LOADING_WHITE)
                    end
                }
            end
            if manga.image == nil then
                Threads.InsertTask{
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
                            Unique = "ImageLoading"
                        }
                    end,
                    Unique = "ImageLoading"
                }
            end
            Center.x, Center.y = (MANGA_WIDTH*1.5)/2 + 40, MANGA_HEIGHT*1.5/2+80
            Timer.reset(AnimationTimer)
            Timer.reset(NameTimer)
        end
    end,
    Input = function (OldPad, Pad, OldTouch, Touch)
        if DETAILS_MODE == DETAILS_START and Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
            DETAILS_MODE = DETAILS_WAIT
            Timer.reset(AnimationTimer)
            alpha = 255*Fade
            M = 0.25*Fade
            a544 = 544*Fade
            Center.x = Point.x+(Center.x-Point.x)*Fade
            Center.y = Point.y+(Center.y-Point.y)*Fade
            Threads.DeleteUnique("ChaptersLoading")
            Loading.SetMode(LOADING_NONE)
        end
        if DETAILS_MODE == DETAILS_START then
            if Touch.x ~=nil and OldTouch.x ~= nil then
                VelY = OldTouch.y - Touch.y
            end
        end
    end,
    Update = function (delta)
        if DETAILS_MODE == DETAILS_START then
            Fade = easeInOutQuint(math.min((Timer.getTime(AnimationTimer)/500),1))
        elseif DETAILS_MODE == DETAILS_WAIT then
            if Fade == 0 then
                DETAILS_MODE = DETAILS_END
            end
            Fade = 1 - easeInOutQuint(math.min((Timer.getTime(AnimationTimer)/500),1))
        end
        if Manga then
            local ms = 50*string.len(Manga.Name)
            local t = math.min(math.max(0,Timer.getTime(NameTimer)-1500),ms)
            if t == ms then
                if Timer.getTime(NameTimer) > ms+2000 then
                    Timer.reset(NameTimer)
                end
            end
        end
        Y = Y + VelY
        VelY = VelY / 1.12
        if math.abs(VelY) < 0.1 then
            VelY = 0
        end
        if Y < 0 then
            Y = 0
            VelY = 0
        elseif Y > (#Chapters*100+10-544+90) then
            Y = math.max(0,#Chapters*100+10-544+90)
            VelY = 0
        end
    end,
    Draw = function ()
        if DETAILS_MODE~=DETAILS_END then
            local Alpha = alpha * Fade
            Graphics.fillRect(0, 945, 90, 544, Color.new(9, 12, 22, Alpha))
            local start = math.max(1,math.floor(Y/100)+1)
            local WHITE = Color.new(255,255,255,Alpha)
            local GRAY = Color.new(128,128,128,Alpha)
            local x = 544-a544*Fade
            for i=start, math.min(#Chapters,start+5) do
                Graphics.fillRect(320,945,x+90+10+(i-1)*(90+10)-Y,x+90+i*(90+10)-Y,Color.new(65,65,65,Alpha))
                Font.print(FONT,320+10,x+90+10+(i-1)*(90+10)+34-Y,Chapters[i].Name, WHITE)
                Graphics.drawImage(945-70,x+90+10+(i-1)*(90+10)-Y,LUA_GRADIENTH, Color.new(65,65,65,Alpha))
            end
            if #Chapters == 0 and not Threads.CheckUnique("ChaptersLoading") then
                local msg = Language[LANG].WARNINGS.NO_CHAPTERS
                Font.print(FONT24,632-Font.getTextWidth(FONT24,msg)/2,x+240,msg,WHITE)
            end
            Graphics.fillRect(945, 960, 90, 544, Color.new(9, 12, 22, Alpha))
            Graphics.fillRect(0, 960,  0,  90, Color.new(9, 12, 22, Alpha))
            if Manga then
                local ms = 50*string.len(Manga.Name)
                local dif = math.max(Font.getTextWidth(FONT32, Manga.Name)-880,0)
                local t = math.min(math.max(0,Timer.getTime(NameTimer)-1500),ms)
                DrawManga(Point.x+(Center.x-Point.x)*Fade, Point.y+(Center.y - Point.y)*Fade, Manga, 1 + (Fade * M))
                Font.print(FONT32, 40 - dif*t/ms,-40 + 70 * alpha / 255*Fade-5,Manga.Name, WHITE)
                Font.print(FONT, 20+40,-40 + 70 * alpha / 255*Fade+30+5,Manga.RawLink, GRAY)
            end
        end
    end,
    GetMode = function ()
        return DETAILS_MODE
    end,
    GetFade = function ()
        return Fade
    end
}