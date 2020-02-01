local Point_t = Point_t

local mode = "END"

Details = {}

local TOUCH = TOUCH()
local Slider = Slider()

local Manga = nil

local fade = 0
local old_fade = 1

local point = Point_t(MANGA_WIDTH * 1.25 / 2 + 40, MANGA_HEIGHT * 1.5 / 2 + 80)

local cross = Image:new(Graphics.loadImage("app0:assets/images/cross.png"))
local dwnld = Image:new(Graphics.loadImage("app0:assets/images/download.png"))

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

local DetailsSelector = Selector:new(-1, 1, -3, 3)

local is_chapter_loaded = false

function Details.setManga(manga)
    if manga then
        Panel.hide()
        Manga = manga
        ms = 50 * string.len(manga.Name)
        dif = math.max(Font.getTextWidth(FONT30, manga.Name) - 920, 0)
        Chapters = {}
        Slider.Y = -50
        DetailsSelector:resetSelected()
        mode = "START"
        old_fade = 1
        if Threads.netActionUnSafe(Network.isWifiEnabled) then
            ParserManager.getChaptersAsync(manga, Chapters)
            is_chapter_loaded = false
        else
            Chapters = Database.getChapters(manga)
            is_chapter_loaded = true
        end
        is_notification_showed = false
        Timer.reset(animation_timer)
        Timer.reset(name_timer)
    end
end

local function press_add_to_library()
    if Manga then
        if Database.check(Manga) then
            Database.remove(Manga)
            Notifications.push(Language[LANG].NOTIFICATIONS.REMOVED_FROM_LIBRARY)
        else
            Database.add(Manga, Chapters)
            Notifications.push(Language[LANG].NOTIFICATIONS.ADDED_TO_LIBRARY)
        end
        Database.save()
    end
end

local function press_download(item)
    local connection = Threads.netActionUnSafe(Network.isWifiEnabled)
    item = Chapters[item]
    if item then
        if not Cache.check(item) then
            if Cache.is_downloading(item) then
                Cache.stop(item)
            elseif connection then
                Cache.download(item)
            end
        else
            Cache.delete(item)
        end
    end
end

local function press_manga(item)
    if Chapters[item] then
        Catalogs.shrink()
        Reader.load(Chapters, item)
        AppMode = READER
    end
end

function Details.input(oldpad, pad, oldtouch, touch)
    if mode == "START" then
        if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
            TOUCH.MODE = TOUCH.READ
            Slider.TouchY = touch.y
        elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
            if TOUCH.MODE == TOUCH.READ and oldtouch.x > 320 and oldtouch.x < 900 and oldtouch.y > 90 then
                local id = math.floor((Slider.Y + oldtouch.y - 20) / 70)
                if oldtouch.x < 850 then
                    press_manga(id)
                else
                    press_download(id)
                end
            end
            TOUCH.MODE = TOUCH.NONE
        end
        DetailsSelector:input(#Chapters, math.floor((Slider.Y - 20 + 90) / 70), oldpad, pad, touch.x)
        if oldtouch.x and not touch.x and oldtouch.x > 20 and oldtouch.x < 260 and oldtouch.y > 420 and oldtouch.y < 475 then
            press_add_to_library()
        elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            press_add_to_library()
        elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
            press_manga(DetailsSelector.getSelected())
        elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            mode = "WAIT"
            Loading.setMode("NONE")
            ParserManager.remove(Chapters)
            Timer.reset(animation_timer)
            Panel.show()
            old_fade = fade
        elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            press_download(DetailsSelector.getSelected())
        end
        local new_itemID = 0
        if TOUCH.MODE == TOUCH.READ then
            if math.abs(Slider.V) > 0.1 or math.abs(touch.y - Slider.TouchY) > 10 then
                TOUCH.MODE = TOUCH.SLIDE
            else
                if oldtouch.x > 320 and oldtouch.x < 900 then
                    local id = math.floor((Slider.Y - 20 + oldtouch.y) / 70)
                    if Chapters[id] then
                        new_itemID = id
                    end
                end
            end
        elseif TOUCH.MODE == TOUCH.SLIDE then
            if touch.x and oldtouch.x then
                Slider.V = oldtouch.y - touch.y
            end
        end
        if Slider.ItemID > 0 and new_itemID > 0 and Slider.ItemID ~= new_itemID then
            TOUCH.MODE = TOUCH.SLIDE
        else
            Slider.ItemID = new_itemID
        end
    end
end

function Details.update()
    if mode ~= "END" then
        animationUpdate()
        if ParserManager.check(Chapters) then
            Loading.setMode("WHITE", 580, 250)
        else
            Loading.setMode("NONE")
        end
        local item_selected = DetailsSelector.getSelected()
        if item_selected ~= 0 then
            Slider.Y = Slider.Y + (item_selected * 70 - 272 - Slider.Y) / 8
        end
        scrollUpdate()
        if not is_chapter_loaded and not ParserManager.check(Chapters) then
            is_chapter_loaded = true
            if #Chapters > 0 then
                Database.updateChapters(Chapters[1].Manga, Chapters)
            end
        end
    end
end

function Details.draw()
    if mode ~= "END" then
        local M = old_fade * fade
        local Alpha = 255 * M
        Graphics.fillRect(0, 920, 90, 544, Color.new(0, 0, 0, Alpha))
        local WHITE = Color.new(255, 255, 255, Alpha)
        local GRAY = Color.new(128, 128, 128, Alpha)
        local BLUE = Color.new(42, 47, 78, Alpha)
        local RED = Color.new(137, 30, 43, Alpha)
        local start = math.max(1, math.floor(Slider.Y / 70) + 1)
        local shift = (1 - M) * 544
        local y = shift - Slider.Y + start * 70
        local connection = Threads.netActionUnSafe(Network.isWifiEnabled)
        for i = start, math.min(#Chapters, start + 8) do
            if y < 544 then
                Graphics.fillRect(280, 920, y, y + 69, BLUE)
                Font.print(FONT16, 290, y + 24, Chapters[i].Name, WHITE)
                Graphics.drawScaleImage(850, y, LUA_GRADIENTH, 1, 69, BLUE)
                if i == Slider.ItemID then
                    Graphics.fillRect(280, 920, y, y + 69, Color.new(0, 0, 0, 32))
                end
                if Cache.check(Chapters[i]) then
                    Graphics.drawRotateImage(920-32, y+34, cross.e, 0)
                else
                    local t = Cache.is_downloading(Chapters[i])
                    if t then
                        local text = "0%"
                        if t.page_count and t.page_count > 0 then
                            text = math.ceil(100 * t.page / t.page_count).."%"
                        end
                        local width = Font.getTextWidth(FONT20,text)
                        Font.print(FONT20, 920-32-width/2, y + 21, text, COLOR_WHITE)
                    else
                        Graphics.drawRotateImage(920-32, y+34, dwnld.e, 0)
                    end
                end
            else
                break
            end
            y = y + 70
        end
        Graphics.fillRect(920, 960, 90, 544, Color.new(0, 0, 0, Alpha))
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
        if mode == "START" and #Chapters == 0 and not ParserManager.check(Chapters) and not is_notification_showed then
            is_notification_showed = true
            Notifications.push(Language[LANG].WARNINGS.NO_CHAPTERS)
        end
        local item = DetailsSelector.getSelected()
        if item ~= 0 then
            y = shift - Slider.Y + item * 70
            local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks+1 do
                Graphics.fillEmptyRect(284 + i, 916 - i + 1, y + i+4, y + 65 - i + 1, Color.new(255, 0, 51))
                Graphics.fillEmptyRect(284 + i, 916 - i + 1, y + i+4, y + 65 - i + 1, SELECTED_RED)
            end
            Graphics.drawImage(899-ks, y+5+ks, textures_16x16.Square.e)
        end
        Graphics.fillRect(0, 960, 0, 90, Color.new(0, 0, 0, Alpha))
        DrawManga(point.x, point.y + 544 * (1 - M), Manga, 1 + M / 4)
        local t = math.min(math.max(0, Timer.getTime(name_timer) - 1500), ms)
        Font.print(FONT30, 20 - dif * t / ms, 70 * M - 45, Manga.Name, WHITE)
        Font.print(FONT16, 40, 70 * M - 5, Manga.RawLink, GRAY)
        if mode == "START" and #Chapters > 5 then
            local h = #Chapters * 70 / 454
            Graphics.fillRect(930, 932, 90, 544, Color.new(92, 92, 92, Alpha))
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
