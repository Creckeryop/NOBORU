local Point_t = Point_t

local mode = "END"

local TOUCH = TOUCH()
local Slider = Slider()

local Manga = nil

local fade = 0
local old_fade = 1

local point = Point_t(0, 0)
local center = Point_t(0, 0)

local ms = 0
local dif = 0

local animation_timer = Timer.new()
local name_timer = Timer.new()

local is_notification_showed = false

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

local easing = EaseInOutCubic

local animationUpdate = function()
    if mode == "START" then
        fade = easing(math.min((Timer.getTime(animation_timer) / 500), 1))
    elseif mode == "WAIT" then
        if fade == 0 then
            mode = "END"
        end
        fade = 1 - easing(math.min((Timer.getTime(animation_timer) / 500), 1))
    end
    if Timer.getTime(name_timer) > 3500 + ms then
        Timer.reset(name_timer)
    end
end


local control_timer = Timer.new()
local time_space = 400
local item_selected = 0

Details = {}

function Details.setManga(manga, x, y)
    if manga and x and y then
        Panel.hide()
        Manga = manga
        ms = 50 * string.len(manga.Name)
        dif = math.max(Font.getTextWidth(FONT30, manga.Name) - 920, 0)
        Chapters = {}
        item_selected = 0
        mode = "START"
        point = Point_t(x, y)
        old_fade = 1
        if GetParserByID(manga.ParserID) then
            ParserManager.getChaptersAsync(manga, Chapters)
        end
        is_notification_showed = false
        center = Point_t(MANGA_WIDTH * 1.25 / 2 + 40, MANGA_HEIGHT * 1.5 / 2 + 80)
        Timer.reset(animation_timer)
        Timer.reset(name_timer)
    end
end

function Details.input(OldPad, Pad, OldTouch, Touch)
    if mode == "START" then
        if TOUCH.MODE == TOUCH.NONE and OldTouch.x and Touch.x and Touch.x > 240 then
            item_selected = 0
            time_space = 400
            TOUCH.MODE = TOUCH.READ
            Slider.TouchY = Touch.y
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
                Notifications.push(Language[LANG].NOTIFICATIONS.REMOVED_FROM_LIBRARY)
            else
                Database.add(Manga)
                Notifications.push(Language[LANG].NOTIFICATIONS.ADDED_TO_LIBRARY)
            end
            Database.save()
        end
        if Timer.getTime(control_timer) > time_space or (Controls.check(Pad, SCE_CTRL_DOWN) and not Controls.check(OldPad, SCE_CTRL_DOWN) or Controls.check(Pad, SCE_CTRL_UP) and not Controls.check(OldPad, SCE_CTRL_UP) or Controls.check(Pad, SCE_CTRL_LEFT) and not Controls.check(OldPad, SCE_CTRL_LEFT) or Controls.check(Pad, SCE_CTRL_RIGHT) and not Controls.check(OldPad, SCE_CTRL_RIGHT)) then
            if (Controls.check(Pad, SCE_CTRL_DOWN) or Controls.check(Pad, SCE_CTRL_UP) or Controls.check(Pad, SCE_CTRL_RIGHT) or Controls.check(Pad, SCE_CTRL_LEFT)) then
                if item_selected == 0 then
                    item_selected = math.floor((Slider.Y - 20 + 90) / 70)
                elseif item_selected ~= 0 then
                    if Controls.check(Pad, SCE_CTRL_DOWN) then
                        item_selected = item_selected + 1
                    elseif Controls.check(Pad, SCE_CTRL_UP) then
                        item_selected = item_selected - 1
                    elseif Controls.check(Pad, SCE_CTRL_RIGHT) then
                        item_selected = item_selected + 3
                    elseif Controls.check(Pad, SCE_CTRL_LEFT) then
                        item_selected = item_selected - 3
                    end
                end
                if #Chapters > 0 then
                    if item_selected <= 0 then
                        item_selected = 1
                    elseif item_selected > #Chapters then
                        item_selected = #Chapters
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
        if Controls.check(Pad, SCE_CTRL_CROSS) and not Controls.check(OldPad, SCE_CTRL_CROSS) then
            if item_selected ~= 0 then
                if Chapters[item_selected] then
                    Catalogs.Shrink()
                    Reader.load(Chapters, item_selected)
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
            mode = "WAIT"
            Loading.setMode("NONE")
            ParserManager.Remove(Chapters)
            Timer.reset(animation_timer)
            Panel.show()
            old_fade = fade
        end
    end
end

function Details.update(dt)
    if mode ~= "END" then
        animationUpdate()
        if ParserManager.Check(Chapters) then
            Loading.setMode("WHITE", 580, 250)
        else
            Loading.setMode("NONE")
        end
        if item_selected ~= 0 then
            Slider.Y = Slider.Y + (item_selected * 70 - 272 - Slider.Y) / 8
        end
        scrollUpdate()
    end
end

function Details.draw()
    if mode ~= "END" then
        local M = old_fade * fade
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

        Graphics.fillRect(20, 260, shift + 480, shift + 539, Color.new(19, 76, 76, Alpha))

        if mode == "START" and #Chapters == 0 and not ParserManager.Check(Chapters) and not is_notification_showed then
            is_notification_showed = true
            Notifications.push(Language[LANG].WARNINGS.NO_CHAPTERS)
        end

        if item_selected ~= 0 then
            y = shift - Slider.Y + item_selected * 70
            local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 1000)))
            Graphics.fillEmptyRect(281, 900, y + 1, y + 69, RED)
            Graphics.fillEmptyRect(282, 899, y + 2, y + 68, RED)
            Graphics.fillEmptyRect(281, 900, y + 1, y + 69, SELECTED_RED)
            Graphics.fillEmptyRect(282, 899, y + 2, y + 68, SELECTED_RED)
        end

        Graphics.fillRect(0, 960, 0, 90, Color.new(0, 0, 0, Alpha))
        DrawManga(point.x + (center.x - point.x) * M, point.y + (center.y - point.y) * M, Manga, 1 + M / 4)

        local t = math.min(math.max(0, Timer.getTime(name_timer) - 1500), ms)
        Font.print(FONT30, 20 - dif * t / ms, 70 * M - 45, Manga.Name, WHITE)
        Font.print(FONT16, 40, 70 * M - 5, Manga.RawLink, GRAY)

        if mode == "START" and #Chapters > 5 then
            local h = #Chapters * 70 / 454
            Graphics.fillRect(930, 932, 90, 544, Color.new(92, 92, 92))
            Graphics.fillRect(926, 936, 90 + (Slider.Y + 20) / h, 90 + (Slider.Y + 464) / h, BLUE)
        end
    end
end

function Details.getMode()
    return mode
end

function Details.getFade()
    return fade * old_fade
end

function Details.getManga()
    return Manga
end
