DETAILS_START       = 0
DETAILS_WAIT        = 1
DETAILS_END         = 2
local DETAILS_MODE  = DETAILS_END

local TOUCH_MODE_NONE     = 0
local TOUCH_MODE_READ     = 1
local TOUCH_MODE_SLIDE    = 2
local TOUCH_MODE    = TOUCH_MODE_NONE

local Manga     = nil
local Fade      = 0
local Point     = {x = 0, y = 0}
local Center    = {x = 0, y = 0}

local TouchY    = 0
local OldFade   = 1
local ScrollY   = 0
local VelY      = 0
local ms        = 0
local dif       = 0

local AnimationTimer    = Timer.new()
local NameTimer         = Timer.new()

local Chapters = {}

local scrollUpdate = function ()
    ScrollY = ScrollY + VelY
    VelY = VelY / 1.12
    if math.abs(VelY) < 0.1 then
        VelY = 0
    end
    if ScrollY < 0 then
        ScrollY = 0
        VelY = 0
    elseif ScrollY > (#Chapters * 100 - 444) then
        ScrollY = math.max(0, #Chapters * 100 - 444)
        VelY = 0
    end
end

local easeQubicOut = function(t)
    t = t - 1
    return 1 + t * t * t
end

local animationUpdate = function ()
    if DETAILS_MODE == DETAILS_START then
        Fade = easeQubicOut(math.min((Timer.getTime(AnimationTimer) / 500), 1))
    elseif DETAILS_MODE == DETAILS_WAIT then
        if Fade == 0 then
            DETAILS_MODE = DETAILS_END
        end
        Fade = 1 - easeQubicOut(math.min((Timer.getTime(AnimationTimer) / 500), 1))
    end
    local Time = Timer.getTime(NameTimer)
    if Time > 3500 + ms then
        Timer.reset(NameTimer)
    end
end

Details = {
    SetManga = function(manga, x, y)
        if manga ~= nil and x ~= nil and y ~= nil then
            Manga = manga
            ms = 50 * string.len(manga.Name)
            dif = math.max(Font.getTextWidth(FONT32, manga.Name) - 880, 0)
            Chapters = {}
            DETAILS_MODE = DETAILS_START
            Point.x, Point.y = x, y
            OldFade = 1
            local Parser = GetParserByID(manga.ParserID)
            if Parser then
                ParserManager.getChaptersAsync(manga, Chapters)
            end
            Center.x, Center.y = (MANGA_WIDTH * 1.5) / 2 + 40, MANGA_HEIGHT * 1.5 / 2 + 80
            Timer.reset(AnimationTimer)
            Timer.reset(NameTimer)
        end
    end,
    Input = function(OldPad, Pad, OldTouch, Touch)
        if DETAILS_MODE == DETAILS_START then
            if TOUCH_MODE == TOUCH_MODE_NONE and OldTouch.x ~= nil and Touch.x ~= nil and Touch.x > 240 then
                TOUCH_MODE = TOUCH_MODE_READ
                TouchY = Touch.y
            elseif TOUCH_MODE ~= TOUCH_MODE_NONE and Touch.x == nil then
                if TOUCH_MODE == TOUCH_MODE_READ and OldTouch.x > 320 and OldTouch.x < 900 and OldTouch.y > 90 then
                    local id = math.floor((ScrollY + OldTouch.y) / 100)
                    if id > 0 and id <= #Chapters then
                        Reader.load(Chapters, id)
                        APP_MODE = READER
                    end
                end
                TOUCH_MODE = TOUCH_MODE_NONE
            end
            if TOUCH_MODE == TOUCH_MODE_READ then
                if math.abs(VelY) > 0.1 or math.abs(Touch.y - TouchY)>10 then
                    TOUCH_MODE = TOUCH_MODE_SLIDE
                end
            elseif TOUCH_MODE == TOUCH_MODE_SLIDE then
                if Touch.x ~= nil and OldTouch.x ~= nil then
                    VelY = OldTouch.y - Touch.y
                end
            end
            if Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
                DETAILS_MODE = DETAILS_WAIT
                Loading.SetMode(LOADING_NONE)
                ParserManager.Remove(Chapters)
                Timer.reset(AnimationTimer)
                OldFade = Fade
            end
        end
    end,
    Update = function(delta)
        if DETAILS_MODE ~= DETAILS_END then
            animationUpdate()
            if ParserManager.Check(Chapters) then
                Loading.SetMode(LOADING_WHITE, 580, 250)
            else
                Loading.SetMode(LOADING_NONE)
            end
            scrollUpdate()
        end
    end,
    Draw = function()
        if DETAILS_MODE ~= DETAILS_END then
            local M = OldFade * Fade
            local Alpha = 255 * M

            Graphics.fillRect(0, 900, 90, 544, Color.new(9, 12, 22, Alpha))

            local WHITE     = Color.new(255, 255, 255, Alpha)
            local GRAY      = Color.new(128, 128, 128, Alpha)
            local DARK_GRAY = Color.new( 65,  65,  65, Alpha)

            local start = math.max(1, math.floor(ScrollY / 100) + 1)
            local y = (1 - M) * 544 - ScrollY + start * 100

            for i = start, math.min(#Chapters, start + 5) do
                Graphics.fillRect(320, 900, y, y + 90, DARK_GRAY)
                Font.print(FONT, 330, y + 34, Chapters[i].Name, WHITE)
                Graphics.drawImage(830, y, LUA_GRADIENTH, DARK_GRAY)
                y = y + 100
            end

            if DETAILS_MODE == DETAILS_START and #Chapters == 0 and not ParserManager.Check(Chapters) then
                local msg = Language[LANG].WARNINGS.NO_CHAPTERS
                Font.print(FONT24, 632 - Font.getTextWidth(FONT24, msg) / 2, y + 240, msg, WHITE)
            end

            Graphics.fillRect(900, 960, 90, 544, Color.new(9, 12, 22, Alpha))
            Graphics.fillRect(  0, 960,  0,  90, Color.new(9, 12, 22, Alpha))

            DrawManga(Point.x + (Center.x - Point.x) * M, Point.y + (Center.y - Point.y) * M, Manga, 1 + (M * 0.25))

            local t = math.min(math.max(0, Timer.getTime(NameTimer) - 1500), ms)
            Font.print(FONT32, 40 - dif * t / ms, 70 * M - 45, Manga.Name, WHITE)
            Font.print(FONT, 60, 70 * M - 5, Manga.RawLink, GRAY)

            if #Chapters > 5 then
                
            end
        end
    end
}

Details.GetMode  = function() return DETAILS_MODE  end
Details.GetFade  = function() return Fade          end
Details.GetManga = function() return Manga         end