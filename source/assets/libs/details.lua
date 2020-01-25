local Point_t = Point_t

DETAILS_START       = 0
DETAILS_WAIT        = 1
DETAILS_END         = 2
local DETAILS_MODE  = DETAILS_END

local TOUCH = TOUCH()
local Slider = Slider()

local Manga     = nil
local Fade      = 0
local Point     = Point_t(0, 0)
local Center    = Point_t(0, 0)

local OldFade   = 1
local ms        = 0
local dif       = 0

local AnimationTimer    = Timer.new()
local NameTimer         = Timer.new()

local NOTIFICATION_SHOW = false

local Chapters = {}

local scrollUpdate = function ()
    Slider.Y = Slider.Y + Slider.V
    Slider.V = Slider.V / 1.12
    if math.abs(Slider.V) < 0.1 then
        Slider.V = 0
    end
    if Slider.Y < -20 then
        Slider.Y = -20
        Slider.V = 0
    elseif Slider.Y > (#Chapters * 70 - 464) then
        Slider.Y = math.max(-20, #Chapters * 70 - 464)
        Slider.V = 0
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
        if manga and x and y then
            Panel.hide()
            Manga = manga
            ms = 50 * string.len(manga.Name)
            dif = math.max(Font.getTextWidth(FONT30, manga.Name) - 920, 0)
            Chapters = {}
            DETAILS_MODE = DETAILS_START
            Point = Point_t(x, y)
            OldFade = 1
            local Parser = GetParserByID(manga.ParserID)
            if Parser then
                ParserManager.getChaptersAsync(manga, Chapters)
            end
            NOTIFICATION_SHOW = false
            Center = Point_t(MANGA_WIDTH * 1.25 / 2 + 40, MANGA_HEIGHT * 1.5 / 2 + 80)
            Timer.reset(AnimationTimer)
            Timer.reset(NameTimer)
        end
    end,
    Input = function(OldPad, Pad, OldTouch, Touch)
        if DETAILS_MODE == DETAILS_START then
            if TOUCH.MODE == TOUCH.NONE and OldTouch.x and Touch.x and Touch.x > 240 then
                TOUCH.MODE = TOUCH.READ
                Slider.TouchY = Touch.y
            elseif TOUCH.MODE ~= TOUCH.NONE and not Touch.x then
                if TOUCH.MODE == TOUCH.READ and OldTouch.x > 320 and OldTouch.x < 900 and OldTouch.y > 90 then
                    local id = math.floor((Slider.Y + OldTouch.y - 20) / 70)
                    if id > 0 and id <= #Chapters then
                        Catalogs.Shrink()
                        Reader.load(Chapters, id)
                        AppMode = READER
                    end
                end
                TOUCH.MODE = TOUCH.NONE
            end
            if OldTouch.x and OldTouch.x < 240 and not Touch.x then
                if OldTouch.x > 35 and OldTouch.x < 245 and OldTouch.y > 420 and OldTouch.y < 472 then
                    if Manga then
                        if Database.check(Manga) then
                            Database.remove(Manga)
                            Notifications.Push("Manga removed from library")
                        else
                            Database.add(Manga)
                            Notifications.Push("Manga added to library")
                        end
                        Database.save()
                    end
                end
            end
            local new_itemID = 0
            if TOUCH.MODE == TOUCH.READ then
                if math.abs(Slider.V) > 0.1 or math.abs(Touch.y - Slider.TouchY)>10 then
                    TOUCH.MODE = TOUCH.SLIDE
                else
                    if OldTouch.x > 320 and OldTouch.x < 900 then
                        local id = math.floor((Slider.Y - 20 + OldTouch.y) / 70)
                        if id > 0 and id <= #Chapters then
                            new_itemID = id
                        end
                    end
                end
            elseif TOUCH.MODE == TOUCH.SLIDE then
                if Touch.x and OldTouch.x then
                    Slider.V = OldTouch.y - Touch.y
                end
            end
            if Slider.ItemID > 0 and new_itemID > 0 and Slider.ItemID ~= new_itemID then
                TOUCH.MODE = TOUCH.SLIDE
            else
                Slider.ItemID = new_itemID
            end
            if Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
                DETAILS_MODE = DETAILS_WAIT
                Loading.set_mode(LOADING_NONE)
                ParserManager.Remove(Chapters)
                Timer.reset(AnimationTimer)
                Panel.show()
                OldFade = Fade
            end
        end
    end,
    Update = function(delta)
        if DETAILS_MODE ~= DETAILS_END then
            animationUpdate()
            if ParserManager.Check(Chapters) then
                Loading.set_mode(LOADING_WHITE, 580, 250)
            else
                Loading.set_mode(LOADING_NONE)
            end
            scrollUpdate()
        end
    end,
    Draw = function()
        if DETAILS_MODE ~= DETAILS_END then
            local M = OldFade * Fade
            local Alpha = 255 * M

            Graphics.fillRect(0, 900, 90, 544, Color.new(0, 0, 0, Alpha))

            local WHITE = Color.new(255, 255, 255, Alpha)
            local GRAY = Color.new(128, 128, 128, Alpha)
            local BLUE = Color.new(42, 47, 78, Alpha)
            local RED = Color.new(137, 30, 43, Alpha)

            local start = math.max(1, math.floor(Slider.Y / 70)+1)
            local shift = (1 - M) * 544
            local y = shift - Slider.Y + start * 70

            for i = start, math.min(#Chapters, start + 8) do
                if y < 544 then
                    Graphics.fillRect(280, 920, y, y + 69, BLUE)
                    Font.print(FONT16, 290, y + 24, Chapters[i].Name, WHITE)
                    Graphics.drawScaleImage(850, y, LUA_GRADIENTH, 1, 69, BLUE)
                    if i == Slider.ItemID then
                        Graphics.fillRect(280, 920, y, y + 69, Color.new(0, 0, 0, 32))
                    end
                else
                    break
                end
                y = y + 70
            end

            if Manga then
                if Database.check(Manga) then
                    Graphics.fillRect(35, 245, shift + 420, shift + 472, RED)
                    local text = "Remove from library"
                    Font.print(FONT20, 140-Font.getTextWidth(FONT20, text)/2, 444 + shift-Font.getTextHeight(FONT20, text)/2, text, WHITE)
                else
                    Graphics.fillRect(35, 245, shift + 420, shift + 472, BLUE)
                    local text = "Add to library"
                    Font.print(FONT20, 140-Font.getTextWidth(FONT20, text)/2, 444 + shift-Font.getTextHeight(FONT20, text)/2, text, WHITE)
                end
            end
            Graphics.fillRect(35, 245, shift + 482, shift + 534, Color.new(19, 76, 76, Alpha))

            if DETAILS_MODE == DETAILS_START and #Chapters == 0 and not ParserManager.Check(Chapters) and not NOTIFICATION_SHOW then
                NOTIFICATION_SHOW = true
                Notifications.Push(Language[LANG].WARNINGS.NO_CHAPTERS)
            end

            Graphics.fillRect(900, 960, 90, 544, Color.new(0, 0, 0, Alpha))
            Graphics.fillRect(  0, 960,  0,  90, Color.new(0, 0, 0, Alpha))

            DrawManga(Point.x + (Center.x - Point.x) * M, Point.y + (Center.y - Point.y) * M, Manga, 1 + (M * 0.25))

            local t = math.min(math.max(0, Timer.getTime(NameTimer) - 1500), ms)
            Font.print(FONT30, 20 - dif * t / ms, 70 * M - 45, Manga.Name, WHITE)
            Font.print(FONT16, 40, 70 * M - 5, Manga.RawLink, GRAY)

            if DETAILS_MODE == DETAILS_START and #Chapters > 5 then
                local h = #Chapters * 70 / 454
                Graphics.fillRect(930, 932, 90, 544, Color.new(92, 92, 92))
                Graphics.fillRect(926, 936, 90 + (Slider.Y + 20) / h, 90 + (Slider.Y + 464) / h, BLUE)
            end
        end
    end
}

Details.GetMode  = function() return DETAILS_MODE  end
Details.GetFade  = function() return Fade          end
Details.GetManga = function() return Manga         end