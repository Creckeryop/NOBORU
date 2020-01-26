local Point_t = Point_t

DETAILS_START = 0
DETAILS_WAIT = 1
DETAILS_END = 2
local DETAILS_MODE = DETAILS_END

local TOUCH = TOUCH()
local Slider = Slider()

local Manga = nil
local Fade = 0
local Point = Point_t(0, 0)
local Center = Point_t(0, 0)

local OldFade = 1
local ms = 0
local dif = 0

local AnimationTimer = Timer.new()
local NameTimer = Timer.new()

local NOTIFICATION_SHOW = false

local Chapters = {}

local scrollUpdate = function()
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

local animationUpdate = function()
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

local ControlsTimer = Timer.new()
local TimerSpace = 400
local TOUCH_MODE = 0
local KEYS_MODE = 1
local CONTROL_MODE = TOUCH_MODE
local ItemSelected = 0

Details = {
    SetManga = function(manga, x, y)
        if manga and x and y then
            Panel.hide()
            Manga = manga
            ms = 50 * string.len(manga.Name)
            dif = math.max(Font.getTextWidth(FONT30, manga.Name) - 920, 0)
            Chapters = {}
            ItemSelected = 0
            TimerSpace = 400
            CONTROL_MODE = TOUCH_MODE
            DETAILS_MODE = DETAILS_START
            Point = Point_t(x, y)
            OldFade = 1
            if GetParserByID(manga.ParserID) then
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
                ItemSelected = 0
                TimerSpace = 400
                TOUCH.MODE = TOUCH.READ
                Slider.TouchY = Touch.y
                CONTROL_MODE = TOUCH_MODE
            elseif TOUCH.MODE ~= TOUCH.NONE and not Touch.x then
                if TOUCH.MODE == TOUCH.READ and OldTouch.x > 320 and OldTouch.x < 900 and OldTouch.y > 90 then
                    local id = math.floor((Slider.Y + OldTouch.y - 20) / 70)
                    if Chapters[id] then
                        Catalogs.Shrink()
                        Reader.load(Chapters, id)
                        AppMode = READER
                    end
                end
                TOUCH.MODE = TOUCH.NONE
            end
            local AddToLibrary = false
            if OldTouch.x and OldTouch.x < 260 and not Touch.x then
                if OldTouch.x > 20 and OldTouch.x < 260 and OldTouch.y > 420 and OldTouch.y < 475 then
                    AddToLibrary = true
                end
            end
            if Controls.check(Pad, SCE_CTRL_TRIANGLE) and not Controls.check(OldPad, SCE_CTRL_TRIANGLE) then
                AddToLibrary = true
            end
            if Manga and AddToLibrary then
                if Database.check(Manga) then
                    Database.remove(Manga)
                    Notifications.Push(Language[LANG].NOTIFICATIONS.REMOVED_FROM_LIBRARY)
                else
                    Database.add(Manga)
                    Notifications.Push(Language[LANG].NOTIFICATIONS.ADDED_TO_LIBRARY)
                end
                Database.save()
            end
            if Timer.getTime(ControlsTimer) > TimerSpace or (Controls.check(Pad, SCE_CTRL_DOWN) and not Controls.check(OldPad, SCE_CTRL_DOWN) or Controls.check(Pad, SCE_CTRL_UP) and not Controls.check(OldPad, SCE_CTRL_UP) or Controls.check(Pad, SCE_CTRL_LEFT) and not Controls.check(OldPad, SCE_CTRL_LEFT) or Controls.check(Pad, SCE_CTRL_RIGHT) and not Controls.check(OldPad, SCE_CTRL_RIGHT)) then
                if (Controls.check(Pad, SCE_CTRL_DOWN) or Controls.check(Pad, SCE_CTRL_UP) or Controls.check(Pad, SCE_CTRL_RIGHT) or Controls.check(Pad, SCE_CTRL_LEFT)) then
                    if CONTROL_MODE == TOUCH_MODE then
                        ItemSelected = math.floor((Slider.Y - 20 + 90) / 70)
                        CONTROL_MODE = KEYS_MODE
                    elseif CONTROL_MODE == KEYS_MODE then
                        if Controls.check(Pad, SCE_CTRL_DOWN) then
                            ItemSelected = ItemSelected + 1
                        elseif Controls.check(Pad, SCE_CTRL_UP) then
                            ItemSelected = ItemSelected - 1
                        elseif Controls.check(Pad, SCE_CTRL_RIGHT) then
                            ItemSelected = ItemSelected + 3
                        elseif Controls.check(Pad, SCE_CTRL_LEFT) then
                            ItemSelected = ItemSelected - 3
                        end
                    end
                    if #Chapters > 0 then
                        if ItemSelected <= 0 then
                            ItemSelected = 1
                        elseif ItemSelected > #Chapters then
                            ItemSelected = #Chapters
                        end
                    else
                        ItemSelected = 0
                    end
                    if TimerSpace > 50 then
                        TimerSpace = math.max(50, TimerSpace / 2)
                    end
                    Slider.V = 0
                    Timer.reset(ControlsTimer)
                else
                    TimerSpace = 400
                end
            end
            if Controls.check(Pad, SCE_CTRL_CROSS) and not Controls.check(OldPad, SCE_CTRL_CROSS) then
                if ItemSelected ~= 0 then
                    if Chapters[ItemSelected] then
                        Catalogs.Shrink()
                        Reader.load(Chapters, ItemSelected)
                        AppMode = READER
                    end
                end
            end
            local new_itemID = 0
            if TOUCH.MODE == TOUCH.READ then
                if math.abs(Slider.V) > 0.1 or math.abs(Touch.y - Slider.TouchY) > 10 then
                    TOUCH.MODE = TOUCH.SLIDE
                else
                    if OldTouch.x > 320 and OldTouch.x < 900 then
                        local id = math.floor((Slider.Y - 20 + OldTouch.y) / 70)
                        if Chapters[id] then
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
            if ItemSelected ~= 0 then
                Slider.Y = Slider.Y + (ItemSelected * 70 - 272 - Slider.Y) / 8
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

            local start = math.max(1, math.floor(Slider.Y / 70) + 1)
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
            Graphics.fillRect(900, 960, 90, 544, Color.new(0, 0, 0, Alpha))
            if Manga then
                local text, color = Language[LANG].DETAILS.ADD_TO_LIBRARY, BLUE
                if Database.check(Manga) then
                    color = RED
                    text = Language[LANG].DETAILS.REMOVE_FROM_LIBRARY
                end
                Graphics.fillRect(20, 260, shift + 420, shift + 479, color)
                if textures_16x16.Triangle and textures_16x16.Triangle.e then
                    Graphics.drawImageExtended(20, shift + 420, textures_16x16.Triangle.e, 0, 0, 16, 16, 0, 2, 2)
                end
                Font.print(FONT20, 140 - Font.getTextWidth(FONT20, text) / 2, 448 + shift - Font.getTextHeight(FONT20, text) / 2, text, WHITE)
            end
            Graphics.fillRect(20, 260, shift + 480, shift + 539, Color.new(19, 76, 76, Alpha))

            if DETAILS_MODE == DETAILS_START and #Chapters == 0 and not ParserManager.Check(Chapters) and not NOTIFICATION_SHOW then
                NOTIFICATION_SHOW = true
                Notifications.Push(Language[LANG].WARNINGS.NO_CHAPTERS)
            end
            if ItemSelected ~= 0 then
                y = shift - Slider.Y + ItemSelected * 70
                local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 1000)))
                Graphics.fillEmptyRect(281, 900, y + 1, y + 69, RED)
                Graphics.fillEmptyRect(282, 899, y + 2, y + 68, RED)
                Graphics.fillEmptyRect(281, 900, y + 1, y + 69, SELECTED_RED)
                Graphics.fillEmptyRect(282, 899, y + 2, y + 68, SELECTED_RED)
            end
            Graphics.fillRect(0, 960, 0, 90, Color.new(0, 0, 0, Alpha))
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

Details.GetMode = function()
    return DETAILS_MODE
end
Details.GetFade = function()
    return Fade
end
Details.GetManga = function()
    return Manga
end
