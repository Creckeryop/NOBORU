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
local brger = Image:new(Graphics.loadImage("app0:assets/images/burger.png"))

local ms = 0
local dif = 0
local ms_ch = 0
local dif_ch = 0

local animation_timer = Timer.new()
local name_timer = Timer.new()
local chapter_timer = Timer.new()

local is_notification_showed = false

local Chapters = {}

---Updates scrolling movement
local function scrollUpdate()
    Slider.Y = Slider.Y + Slider.V
    Slider.V = Slider.V / 1.12
    if math.abs(Slider.V) < 0.1 then
        Slider.V = 0
    end
    if Slider.Y < -20 then
        Slider.Y = -20
        Slider.V = 0
    elseif Slider.Y > (#Chapters * 80 - 464) then
        Slider.Y = math.max(-20, #Chapters * 80 - 464)
        Slider.V = 0
    end
end

local easing = EaseInOutCubic

---Updates animation of fade in or out
local function animationUpdate()
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
    if Timer.getTime(chapter_timer) > 3500 + ms_ch then
        Timer.reset(chapter_timer)
    end
end

local DetailsSelector = Selector:new(-1, 1, -3, 3, function() return math.floor((Slider.Y - 20 + 90) / 80) end)

local is_chapter_loaded_offline = false

local ContinueChapter

---@param Manga table
---Sets Continue button to latest read chapter in given `Manga`
local function updateContinueManga(Manga)
    ContinueChapter = 0
    if #Chapters > 0 then
        Chapters[1].Manga.Counter = #Chapters
        local Latest = Cache.getLatestBookmark(Manga)
        for i = 1, #Chapters do
            local key = Chapters[i].Link:gsub("%p", "")
            if Latest == key then
                local bookmark = Cache.getBookmark(Chapters[i])
                if bookmark == true then
                    ContinueChapter = i + 1
                    if not Chapters[ContinueChapter] then
                        ContinueChapter = i
                    end
                    Chapters[1].Manga.Counter = #Chapters - i
                else
                    ContinueChapter = i
                    Chapters[1].Manga.Counter = #Chapters - i + 1
                end
                break
            end
        end
        if ContinueChapter > 0 then
            local ch_name = Chapters[ContinueChapter].Name or ("Chapter " .. ContinueChapter)
            ms_ch = 25 * string.len(ch_name)
            dif_ch = math.max(Font.getTextWidth(FONT12, ch_name) - 220, 0)
            Timer.reset(chapter_timer)
        end
    end
end

local chapters_loaded = false

---@param manga table
---Sets `manga` to details
function Details.setManga(manga)
    if manga then
        Manga = manga
        ms = 50 * string.len(manga.Name)
        dif = math.max(Font.getTextWidth(BONT30, manga.Name) - 830, 0)
        Chapters = {}
        Slider.Y = -50
        DetailsSelector:resetSelected()
        mode = "START"
        old_fade = 1
        ContinueChapter = nil
        if Cache.isCached(Manga) then
            if not Cache.BookmarksLoaded(Manga) then
                Cache.loadBookmarks(Manga)
            end
        elseif Database.check(Manga) then
            Cache.addManga(Manga, Chapters)
        end
        if Threads.netActionUnSafe(Network.isWifiEnabled) and GetParserByID(manga.ParserID) then
            ParserManager.getChaptersAsync(manga, Chapters)
            is_chapter_loaded_offline = false
        else
            Chapters = Cache.loadChapters(manga)
            is_chapter_loaded_offline = true
        end
        chapters_loaded = false
        is_notification_showed = false
        Timer.reset(animation_timer)
        Timer.reset(name_timer)
    end
end

local function press_add_to_library()
    if Manga then
        if Database.check(Manga) then
            Database.remove(Manga)
            Notifications.push(Language[Settings.Language].NOTIFICATIONS.REMOVED_FROM_LIBRARY)
        else
            Database.add(Manga)
            Cache.addManga(Manga)
            Notifications.push(Language[Settings.Language].NOTIFICATIONS.ADDED_TO_LIBRARY)
        end
    end
end

local function press_download(item)
    local connection = Threads.netActionUnSafe(Network.isWifiEnabled)
    item = Chapters[item]
    if item then
        Cache.addManga(Manga, Chapters)
        Cache.makeHistory(Manga)
        if not ChapterSaver.check(item) then
            if ChapterSaver.is_downloading(item) then
                ChapterSaver.stop(item)
            elseif connection then
                ChapterSaver.downloadChapter(item)
            elseif not connection then
                Notifications.pushUnique(Language[Settings.Language].SETTINGS.NoConnection)
            end
        else
            ChapterSaver.delete(item)
        end
    end
end

local function press_manga(item)
    if Chapters[item] then
        Catalogs.shrink()
        Cache.addManga(Manga, Chapters)
        Cache.makeHistory(Manga)
        Reader.load(Chapters, item)
        AppMode = READER
        ContinueChapter = nil
    end
end

function Details.input(oldpad, pad, oldtouch, touch)
    if mode == "START" then
        local oldtouch_mode = TOUCH.MODE
        if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
            TOUCH.MODE = TOUCH.READ
            Slider.TouchY = touch.y
        elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
            if TOUCH.MODE == TOUCH.READ and oldtouch.x then
                if oldtouch.x > 320 and oldtouch.x < 920 and oldtouch.y > 90 then
                    local id = math.floor((Slider.Y + oldtouch.y - 20) / 80)
                    if Settings.ChapterSorting == "N->1" then
                        id = #Chapters - id + 1
                    end
                    if oldtouch.x < 850 or Manga.ParserID == "IMPORTED" then
                        press_manga(id)
                    else
                        press_download(id)
                    end
                end
            end
            TOUCH.MODE = TOUCH.NONE
        end
        DetailsSelector:input(#Chapters, oldpad, pad, touch.x)
        if oldtouch.x and not touch.x then
            if oldtouch.x > 20 and oldtouch.x < 260 and oldtouch.y > 416 and oldtouch.y < 475 then
                press_add_to_library()
            elseif oldtouch.x > 20 and oldtouch.x < 260 and oldtouch.y > 480 then
                if ContinueChapter then
                    if ContinueChapter > 0 then
                        press_manga(ContinueChapter)
                    else
                        press_manga(1)
                    end
                end
            elseif oldtouch.x > 960 - 90 and oldtouch.y < 90 and chapters_loaded and oldtouch_mode == TOUCH.READ then
                Extra.setChapters(Manga, Chapters)
            end
        elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
            press_add_to_library()
        elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
            local id = DetailsSelector.getSelected()
            if Settings.ChapterSorting == "N->1" then
                id = #Chapters - id + 1
            end
            press_manga(id)
        elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            mode = "WAIT"
            Loading.setMode("NONE")
            ParserManager.remove(Chapters)
            Timer.reset(animation_timer)
            old_fade = fade
        elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) and Manga.ParserID ~= "IMPORTED" then
            local id = DetailsSelector.getSelected()
            if Settings.ChapterSorting == "N->1" then
                id = #Chapters - id + 1
            end
            press_download(id)
        elseif Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT) then
            if ContinueChapter then
                if ContinueChapter > 0 then
                    press_manga(ContinueChapter)
                else
                    press_manga(1)
                end
            end
        elseif Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START) and chapters_loaded then
            Extra.setChapters(Manga, Chapters)
        end
        local new_itemID = 0
        if TOUCH.MODE == TOUCH.READ then
            if math.abs(Slider.V) > 0.1 or math.abs(touch.y - Slider.TouchY) > 10 then
                TOUCH.MODE = TOUCH.SLIDE
            else
                if oldtouch.x > 320 and oldtouch.x < 900 then
                    local id = math.floor((Slider.Y - 20 + oldtouch.y) / 80)
                    if Settings.ChapterSorting == "N->1" then
                        id = #Chapters - id + 1
                    end
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
            Slider.Y = Slider.Y + (item_selected * 80 - 272 - Slider.Y) / 8
        end
        scrollUpdate()
        if not is_chapter_loaded_offline and not ParserManager.check(Chapters) then
            if #Chapters > 0 then
                if Cache.isCached(Chapters[1].Manga) then
                    is_chapter_loaded_offline = true
                    Cache.saveChapters(Chapters[1].Manga, Chapters)
                end
            end
        end
        if not chapters_loaded and not ParserManager.check(Chapters) then
            chapters_loaded = true
        end
        if AppMode == MENU and not ContinueChapter and not ParserManager.check(Chapters) then
            updateContinueManga(Manga)
        end
        if Extra.doesBookmarksUpdate() then
            ContinueChapter = nil
        end
    end
end

function Details.draw()
    if mode ~= "END" then
        local M = old_fade * fade
        local Alpha = 255 * M
        local BACK_COLOR = ChangeAlpha(Themes[Settings.Theme].COLOR_DETAILS_BACK, Alpha)
        Graphics.fillRect(20, 260, 90, 544, BACK_COLOR)
        local WHITE = Color.new(255, 255, 255, Alpha)
        local GRAY = Color.new(128, 128, 128, Alpha)
        local BLUE = Color.new(42, 47, 78, Alpha)
        local RED = Color.new(137, 30, 43, Alpha)
        local start = math.max(1, math.floor(Slider.Y / 80) + 1)
        local shift = (1 - M) * 544
        local y = shift - Slider.Y + start * 80
        Graphics.fillRect(920, 960, 90, 544, BACK_COLOR)
        local text, color = Language[Settings.Language].DETAILS.ADD_TO_LIBRARY, BLUE
        if Database.check(Manga) then
            color = RED
            text = Language[Settings.Language].DETAILS.REMOVE_FROM_LIBRARY
        end
        Graphics.fillRect(20, 260, shift + 416, shift + 475, color)
        Font.print(FONT20, 140 - Font.getTextWidth(FONT20, text) / 2, 444 + shift - Font.getTextHeight(FONT20, text) / 2, text, WHITE)
        if ContinueChapter then
            if #Chapters > 0 then
                Graphics.fillRect(30, 250, shift + 480, shift + 539, Color.new(19, 76, 76, Alpha))
                local continue_txt = Language[Settings.Language].DETAILS.START
                local ch_name
                local dy = 0
                if ContinueChapter > 0 and Chapters[ContinueChapter] and (ContinueChapter == 1 and Cache.getBookmark(Chapters[ContinueChapter]) or ContinueChapter ~= 1) then
                    continue_txt = Language[Settings.Language].DETAILS.CONTINUE
                    dy = -10
                    ch_name = Chapters[ContinueChapter].Name or ("Chapter " .. ContinueChapter)
                end
                local width = Font.getTextWidth(FONT20, continue_txt)
                local height = Font.getTextHeight(FONT20, continue_txt)
                Font.print(FONT20, 140 - width / 2, shift + 505 - height / 2 + dy, continue_txt, WHITE)
                if ch_name then
                    width = math.min(Font.getTextWidth(FONT12, ch_name), 220)
                    local t = math.min(math.max(0, Timer.getTime(chapter_timer) - 1500), ms_ch)
                    Font.print(FONT12, 140 - width / 2 - dif_ch * t / ms_ch, shift + 505 - height / 2 + 18, ch_name, WHITE)
                end
                Graphics.fillRect(20, 30, shift + 480, shift + 539, Color.new(19, 76, 76, Alpha))
                Graphics.fillRect(250, 260, shift + 480, shift + 539, Color.new(19, 76, 76, Alpha))
            end
        end
        Graphics.fillRect(0, 20, 90, 544, BACK_COLOR)
        if ContinueChapter then
            if #Chapters > 0 then
                if textures_16x16.Select and textures_16x16.Select.e then
                    Graphics.drawImage(0, shift + 472, textures_16x16.Select.e)
                end
            end
        end
        if textures_16x16.Triangle and textures_16x16.Triangle.e then
            Graphics.drawImageExtended(20, shift + 420, textures_16x16.Triangle.e, 0, 0, 16, 16, 0, 2, 2)
        end
        DrawManga(point.x, point.y + 544 * (1 - M), Manga, 1 + M / 4)
        Graphics.fillRect(260, 920, 90, 544, BACK_COLOR)
        local ListCount = #Chapters
        for n = start, math.min(ListCount, start + 8) do
            local i = n
            if Settings.ChapterSorting == "N->1" then
                i = ListCount - n + 1
            end
            if y < 544 then
                local bookmark = Cache.getBookmark(Chapters[i])
                if bookmark ~= nil and bookmark ~= true then
                    Font.print(FONT16, 290, y + 44, Language[Settings.Language].DETAILS.PAGE .. bookmark, WHITE)
                    Font.print(BONT16, 290, y + 14, Chapters[i].Name or ("Chapter " .. i), WHITE)
                else
                    Font.print(BONT16, 290, y + 28, Chapters[i].Name or ("Chapter " .. i), WHITE)
                end
                Graphics.drawScaleImage(850, y, LUA_GRADIENTH.e, 1, 79, BACK_COLOR)
                if n < ListCount then
                    Graphics.drawLine(270, 920, y + 79, y + 79, WHITE)
                end
                if i == Slider.ItemID then
                    Graphics.fillRect(270, 920, y, y + 79, Color.new(255, 255, 255, 24 * M))
                end
                if Manga.ParserID ~= "IMPORTED" then
                    if ChapterSaver.check(Chapters[i]) then
                        Graphics.drawRotateImage(920 - 32, y + 37, cross.e, 0)
                    else
                        local t = ChapterSaver.is_downloading(Chapters[i])
                        if t then
                            local text = "0%"
                            if t.page_count and t.page_count > 0 then
                                text = math.ceil(100 * t.page / t.page_count) .. "%"
                            end
                            local width = Font.getTextWidth(FONT20, text)
                            Font.print(FONT20, 920 - 32 - width / 2, y + 26, text, COLOR_WHITE)
                        else
                            Graphics.drawRotateImage(920 - 32, y + 37, dwnld.e, 0)
                        end
                    end
                end
            else
                break
            end
            y = y + 80
        end
        
        if mode == "START" and #Chapters == 0 and not ParserManager.check(Chapters) and not is_notification_showed then
            is_notification_showed = true
            Notifications.push(Language[Settings.Language].WARNINGS.NO_CHAPTERS)
        end
        local item = DetailsSelector.getSelected()
        if item ~= 0 then
            y = shift - Slider.Y + item * 80
            local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks + 1 do
                Graphics.fillEmptyRect(272 + i, 920 - i, y + i + 2, y + 75 - i + 1, Themes[Settings.Theme].COLOR_SELECTOR_DETAILS)
                Graphics.fillEmptyRect(272 + i, 920 - i, y + i + 2, y + 75 - i + 1, SELECTED_RED)
            end
            if Manga.ParserID ~= "IMPORTED" then
                Graphics.drawImage(899 - ks, y + 5 + ks, textures_16x16.Square.e)
            end
        end
        Graphics.fillRect(0, 870, 0, 90, BACK_COLOR)
        local t = math.min(math.max(0, Timer.getTime(name_timer) - 1500), ms)
        Font.print(BONT30, 20 - dif * t / ms, 70 * M - 45, Manga.Name, WHITE)
        Font.print(FONT16, 40, 70 * M - 5, Manga.RawLink, GRAY)
        Graphics.fillRect(870, 960, 0, 90, BACK_COLOR)
        if chapters_loaded then
            Graphics.drawImage(870, 0, brger.e, Color.new(255, 255, 255, Alpha))
            if textures_16x16.Start and textures_16x16.Start.e then
                Graphics.drawImage(883, 5 - (1 - M) * 32, textures_16x16.Start.e)
            end
        end
        if mode == "START" and #Chapters > 5 then
            local h = #Chapters * 80 / 454
            Graphics.fillRect(930, 932, 90, 544, Color.new(92, 92, 92, Alpha))
            Graphics.fillRect(926, 936, 90 + (Slider.Y + 20) / h, 90 + (Slider.Y + 464) / h, COLOR_GRAY)
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
