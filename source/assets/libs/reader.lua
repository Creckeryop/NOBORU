Reader = {}

local Point_t = Point_t

local Pages = {
    Page = 0
}

local velX, velY = 0, 0

local TOUCH_IDLE = 0
local TOUCH_MULTI = 1
local TOUCH_MOVE = 2
local TOUCH_READ = 3
local TOUCH_SWIPE = 4
local TOUCH_LOCK = 5
local touchMode = TOUCH_IDLE

local PAGE_NONE = 0
local PAGE_LEFT = 1
local PAGE_RIGHT = 2
local pageMode = PAGE_NONE

local STATE_LOADING = 0
local STATE_READING = 1
local STATE = STATE_LOADING

local max_Zoom = 3

local offset = Point_t(0, 0)
local touchTemp = Point_t(0, 0)

local StartPage

local orientation
local is_down
local autozoom

local hideCounterTimer = Timer.new()

local doubleClickTimer = Timer.new()
local last_click = {x = -100, y = -100}
local gesture_zoom = false

local ContextMenu = false
local MenuFade = 0
local OpenCloseContextMenu = false
local OpenCloseContextMenuTimer = Timer.new()
local OnTouchMenu = false
local CursorIndex = -1
local CursorFade = 0
local CursorPoint = Point_t(0, 0)
local CursorDestination = Point_t(0, 0)
local CursorPlaces = {Point_t(32 + 12, 40), Point_t(960 - 88 - 88 + 32 + 12, 40), Point_t(960 - 32 - 12, 40), Point_t(32 + 12, 544 - 40), Point_t(0, 0), Point_t(960 - 32 - 12, 544 - 40)}


local name_timer = Timer.new()
local chapter_timer = Timer.new()

local left_arrow_icon = Image:new(Graphics.loadImage("app0:assets/icons/left.png"))
local right_arrow_icon = Image:new(Graphics.loadImage("app0:assets/icons/right.png"))

local readDirection = Settings.ReaderDirection

local function gesture_touch_input(touch, oldtouch, page)
    if Settings.DoubleTapReader then
        if gesture_zoom then
            touchMode = TOUCH_IDLE
        end
        if not page or not page.Zoom then
            return
        end
        if touch.x == nil and oldtouch.x ~= nil and (not ContextMenu or (oldtouch.y >= 80 and oldtouch.y <= 544 - 80)) and not gesture_zoom and touchMode == TOUCH_READ then
            gesture_zoom = false
            local update_last = true
            if Timer.getTime(doubleClickTimer) < 300 then
                local len = math.sqrt((last_click.x - oldtouch.x) * (last_click.x - oldtouch.x) + (last_click.y - oldtouch.y) * (last_click.y - oldtouch.y))
                if len < 80 then
                    OpenCloseContextMenu = false
                    if page.Zoom >= max_Zoom - (max_Zoom - page.min_Zoom) / 2 then
                        gesture_zoom = {
                            Zoom = page.start_Zoom,
                            x = 480,
                            y = 272
                        }
                    else
                        gesture_zoom = {
                            Zoom = math.min(max_Zoom, max_Zoom - (max_Zoom - page.min_Zoom) / 2),
                            x = oldtouch.x,
                            y = oldtouch.y
                        }
                    end
                    touchMode = TOUCH_LOCK
                    Console.write(gesture_zoom.Zoom)
                    Console.write(Pages[Pages.Page].Zoom)
                    update_last = false
                    last_click = {x = -100, y = -100}
                end
            end
            Timer.reset(doubleClickTimer)
            if update_last then
                last_click = {x = oldtouch.x, y = oldtouch.y}
            end
        end
    end
end

local function gesture_touch_update()
    if Settings.DoubleTapReader then
        if gesture_zoom and Pages[Pages.Page] and STATE == STATE_READING then
            local stop = false
            local old_Zoom = Pages[Pages.Page].Zoom
            if math.abs((Pages[Pages.Page].Zoom - gesture_zoom.Zoom) / 4) < 0.01 then
                Pages[Pages.Page].Zoom = gesture_zoom.Zoom
                stop = true
            else
                Pages[Pages.Page].Zoom = (Pages[Pages.Page].Zoom + (gesture_zoom.Zoom - Pages[Pages.Page].Zoom) / 4)
            end
            Pages[Pages.Page].y = 272 + ((Pages[Pages.Page].y - 272) / old_Zoom) * Pages[Pages.Page].Zoom
            Pages[Pages.Page].x = 480 + ((Pages[Pages.Page].x - 480) / old_Zoom) * Pages[Pages.Page].Zoom
            local n = Pages[Pages.Page].Zoom / old_Zoom
            Pages[Pages.Page].y = Pages[Pages.Page].y - (gesture_zoom.y - 272) * (n - 1)
            Pages[Pages.Page].x = Pages[Pages.Page].x - (gesture_zoom.x - 480) * (n - 1)
            if stop then
                gesture_zoom = false
            end
        end
        if Timer.getTime(doubleClickTimer) > 300 then
            last_click = {x = -100, y = -100}
        end
    end
end

local Chapters = {}
local current_chapter = 1

local function updateMeasurements()
    for i = 1, #Pages do
        Pages[i].Zoom = nil
    end
end

local function scale(dZoom, Page)
    if math.abs(1 - dZoom) < 0.005 or not Page.Zoom then return end
    local old_Zoom = Page.Zoom
    Page.Zoom = Page.Zoom * dZoom
    if Page.Zoom < Page.min_Zoom then
        Page.Zoom = Page.min_Zoom
    elseif Page.Zoom > max_Zoom then
        Page.Zoom = max_Zoom
    end
    Page.y = 272 + ((Page.y - 272) / old_Zoom) * Page.Zoom
    Page.x = 480 + ((Page.x - 480) / old_Zoom) * Page.Zoom
end

local function deletePageImage(page)
    if Pages[page].Image then
        if type(Pages[page].Image.e or Pages[page].Image) == "table" then
            Threads.remove(Pages[page])
            ParserManager.remove(Pages[page])
            for i = 1, Pages[page].Image.Parts do
                if Pages[page].Image[i] and Pages[page].Image[i].e then
                    Pages[page].Image[i]:free()
                end
            end
        else
            if Pages[page].Image.e then
                Pages[page].Image:free()
            end
        end
        Pages[page].Image = nil
        Console.write("Removed " .. tostring(page))
    else
        ParserManager.remove(Pages[page])
        Threads.remove(Pages[page])
    end
end

local function loadPageImage(page)
    local PageTable = Pages[page]
    if not PageTable.Image and not (PageTable.Link == "LoadPrev" or PageTable.Link == "LoadNext") then
        if PageTable.Extract then
            Threads.insertTask(PageTable, {
                Type = "UnZipFile",
                Path = PageTable.Path,
                Extract = PageTable.Extract,
                DestPath = "ux0:data/noboru/temp/cache.image",
                OnComplete = function()
                    Threads.insertTask(PageTable, {
                        Type = "Image",
                        Table = PageTable,
                        Path = "temp/cache.image",
                        Index = "Image"
                    })
                end
            })
        elseif PageTable.Path then
            Threads.insertTask(PageTable, {
                Type = "Image",
                Path = PageTable.Path,
                Table = PageTable,
                Index = "Image"
            })
        elseif PageTable.Link then
            Threads.insertTask(PageTable, {
                Type = "ImageDownload",
                Link = PageTable.Link,
                Table = PageTable,
                Index = "Image"
            })
        else
            ParserManager.loadPageImage(Chapters[current_chapter].Manga.ParserID, PageTable[1], PageTable, true)
        end
    end
end
---@param page integer
local function changePage(page)
    if page < 0 and current_chapter > 1 or page > #Pages then
        return false
    end
    Pages.PrevPage = Pages.Page
    Pages.Page = page
    if Pages[Pages.Page].Link == "LoadNext" or Pages[Pages.Page].Link == "LoadPrev" then
        return true
    end
    local o = {0}
    for k = 1, #o do
        local p = page + o[k]
        if Pages[p] then
            loadPageImage(p)
        end
    end
    for i = page - 2, page + 2, 4 do
        if i > 0 and i <= #Pages then
            deletePageImage(i)
            local OldOne = Pages[i][1]
            local OldLink = Pages[i].Link
            local OldPath = Pages[i].Path
            local OldExtr = Pages[i].Extract
            for k, v in pairs(Pages[i]) do
                Pages[i][k] = nil
            end
            Pages[i][1] = OldOne
            Pages[i].Link = OldLink
            Pages[i].Path = OldPath
            Pages[i].Extract = OldExtr
            Pages[i].x = 0
            Pages[i].y = 0
        end
    end
    return true
end

local function changeOrientation()
    orientation = table.next(orientation, {"Horizontal", "Vertical"})
    updateMeasurements()
end

local buttonTimer = Timer.new()
local buttonTimeSpace = 800

---@param direction string | '"LEFT"' | '"RIGHT"'
---Turns the page according to the `direction`
local function swipe(direction)
    if orientation == "Horizontal" then
        if direction == "LEFT" then
            if is_down then
                if Pages.Page ~= #Pages and changePage(Pages.Page + 1) then
                    offset.y = 544 + offset.y
                    local page = Pages[Pages.Page - 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Height >= 544 then
                            page.y = -page.Height * page.Zoom / 2
                        else
                            page.y = -272
                        end
                    end
                end
            else
                if Pages.Page ~= #Pages and changePage(Pages.Page + 1) then
                    offset.x = 960 + offset.x
                    local page = Pages[Pages.Page - 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Width >= 960 then
                            page.x = -page.Width * page.Zoom / 2
                        else
                            page.x = -480
                        end
                    end
                end
            end
        elseif direction == "RIGHT" then
            if is_down then
                if Pages[Pages.Page - 1] and changePage(Pages.Page - 1) then
                    offset.y = -544 + offset.y
                    local page = Pages[Pages.Page + 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Height >= 544 then
                            page.y = 544 + page.Height * page.Zoom / 2
                        else
                            page.y = 544 + 272
                        end
                    end
                end
            else
                if Pages[Pages.Page - 1] and changePage(Pages.Page - 1) then
                    offset.x = -960 + offset.x
                    local page = Pages[Pages.Page + 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Width >= 960 then
                            page.x = 960 + page.Width * page.Zoom / 2
                        else
                            page.x = 960 + 480
                        end
                    end
                end
            end
        end
    elseif orientation == "Vertical" then
        if direction == "LEFT" then
            if is_down then
                if Pages.Page ~= #Pages and changePage(Pages.Page + 1) then
                    offset.x = -960 + offset.x
                    local page = Pages[Pages.Page - 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Height >= 960 then
                            page.x = 960 + page.Height * page.Zoom / 2
                        else
                            page.x = 960 + 480
                        end
                    end
                end
            else
                if Pages.Page ~= #Pages and changePage(Pages.Page + 1) then
                    offset.y = 544 + offset.y
                    local page = Pages[Pages.Page - 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Width >= 544 then
                            page.y = -page.Width * page.Zoom / 2
                        else
                            page.y = -272
                        end
                    end
                end
            end
        elseif direction == "RIGHT" then
            if is_down then
                if Pages[Pages.Page - 1] and changePage(Pages.Page - 1) then
                    offset.x = 960 + offset.x
                    local page = Pages[Pages.Page + 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Height >= 960 then
                            page.x = -page.Height * page.Zoom / 2
                        else
                            page.x = -480
                        end
                    end
                end
            else
                if Pages[Pages.Page - 1] and changePage(Pages.Page - 1) then
                    offset.y = -544 + offset.y
                    local page = Pages[Pages.Page + 1]
                    if page and page.Zoom then
                        if page.Zoom * page.Width >= 544 then
                            page.y = 544 + page.Width * page.Zoom / 2
                        else
                            page.y = 544 + 272
                        end
                    end
                end
            end
        end
    end
end


local function exit()
    for i = 1, #Pages do
        deletePageImage(i)
    end
    Pages = {
        Page = 0
    }
    ParserManager.remove((((Chapters or {})[current_chapter or 0] or {}).Pages) or 0)
    collectgarbage("collect")
    AppMode = MENU
    ContextMenu = false
    MenuFade = 0
    OpenCloseContextMenu = false
end

function Reader.input(oldpad, pad, oldtouch, touch, OldTouch2, Touch2)
    if Controls.check(pad, SCE_CTRL_CIRCLE) or ContextMenu and touch.x and touch.x < 88 and touch.y < 80 * MenuFade and not oldtouch.x then
        if Pages.Page > 0 then
            local bookmark
            if readDirection == "LEFT" then
                bookmark = Pages.Count - Pages.Page + 1
            else
                bookmark = Pages.Page
            end
            if bookmark == 1 then
                bookmark = nil
            elseif bookmark == Pages.Count then
                bookmark = true
            end
            if Cache.isCached(Chapters[current_chapter].Manga) then
                Cache.setBookmark(Chapters[current_chapter], bookmark)
            end
        end
        exit()
    end
    if STATE == STATE_READING and Pages[Pages.Page] then
        if ContextMenu then
            if touch.x and touch.y < 80 * MenuFade and not oldtouch.x then
                if touch.x > 960 - 88 then
                    if Pages[Pages.Page or -1] and (Pages[Pages.Page or -1].Link or Pages[Pages.Page or -1].Path) then
                        Extra.setChapters(Chapters[current_chapter].Manga, Chapters[current_chapter], Pages[Pages.Page])
                    end
                elseif touch.x > 960 - 88 - 88 then
                    if Pages[Pages.Page or -1] then
                        deletePageImage(Pages.Page)
                        loadPageImage(Pages.Page)
                    end
                end
            end
        end
        if touch.x ~= nil or pad ~= 0 then
            Timer.reset(hideCounterTimer)
        end
        local page = Pages[Pages.Page]
        gesture_touch_input(touch, oldtouch, Pages[Pages.Page])
        if page.Zoom then
            local x, y = Controls.readLeftAnalog()
            x = x - 127
            y = y - 127
            if math.abs(x) > SCE_LEFT_STICK_DEADZONE then
                page.x = page.x - SCE_LEFT_STICK_SENSITIVITY * 25 * (x - SCE_LEFT_STICK_DEADZONE * math.sign(x)) / (128 - SCE_LEFT_STICK_DEADZONE)
            end
            if math.abs(y) > SCE_LEFT_STICK_DEADZONE then
                page.y = page.y - SCE_LEFT_STICK_SENSITIVITY * 25 * (y - SCE_LEFT_STICK_DEADZONE * math.sign(y)) / (128 - SCE_LEFT_STICK_DEADZONE)
            end
            if not ContextMenu then
                if Settings.ChangingPageButtons == "LR" then
                    if Controls.check(pad, SCE_CTRL_UP) then
                        page.y = page.y + 20
                    elseif Controls.check(pad, SCE_CTRL_DOWN) then
                        page.y = page.y - 20
                    end
                    if Controls.check(pad, SCE_CTRL_LEFT) then
                        page.x = page.x + 20
                    elseif Controls.check(pad, SCE_CTRL_RIGHT) then
                        page.x = page.x - 20
                    end
                end
            end
        end
        if math.abs(offset.x) < 80 and math.abs(offset.y) < 80 then
            if not ContextMenu then
                if not (Controls.check(pad, SCE_CTRL_RIGHTPAGE) or Controls.check(pad, SCE_CTRL_LEFTPAGE) or (Settings.ChangingPageButtons == "DPAD" and (Controls.check(pad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP)))) then
                    buttonTimeSpace = 800
                end
                local right_page_button = Settings.ChangingPageButtons == "DPAD" and (orientation == "Horizontal" and (is_down and SCE_CTRL_DOWN or SCE_CTRL_RIGHT) or (orientation == "Vertical" and (is_down and SCE_CTRL_LEFT or SCE_CTRL_DOWN))) or SCE_CTRL_RIGHTPAGE
                local left_page_button = Settings.ChangingPageButtons == "DPAD" and (orientation == "Horizontal" and (is_down and SCE_CTRL_UP or SCE_CTRL_LEFT) or (orientation == "Vertical" and (is_down and SCE_CTRL_RIGHT or SCE_CTRL_UP))) or SCE_CTRL_LEFTPAGE
                if Controls.check(pad, right_page_button) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldpad, right_page_button)) then
                    swipe("LEFT")
                    buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
                    Timer.reset(buttonTimer)
                elseif Controls.check(pad, left_page_button) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldpad, left_page_button)) then
                    swipe("RIGHT")
                    buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
                    Timer.reset(buttonTimer)
                elseif Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT) then
                    changeOrientation()
                elseif Controls.check(pad, SCE_CTRL_SQUARE) then
                    scale(0.95, page)
                elseif Controls.check(pad, SCE_CTRL_TRIANGLE) then
                    scale(1.05, page)
                end
            end
            local x, y = Controls.readRightAnalog()
            if orientation == "Horizontal" then
                y = y - 127
                if math.abs(y) > SCE_RIGHT_STICK_DEADZONE then
                    y = (y - SCE_RIGHT_STICK_DEADZONE * math.sign(y)) / (128 - SCE_RIGHT_STICK_DEADZONE)
                    scale(1 - SCE_LEFT_STICK_SENSITIVITY * y * 0.05, page)
                end
            elseif orientation == "Vertical" then
                x = x - 127
                if math.abs(x) > SCE_RIGHT_STICK_DEADZONE then
                    x = (x - SCE_RIGHT_STICK_DEADZONE * math.sign(x)) / (128 - SCE_RIGHT_STICK_DEADZONE)
                    scale(1 + SCE_LEFT_STICK_SENSITIVITY * x * 0.05, page)
                end
            end
        end
        if touch.y and oldtouch.y and (not ContextMenu or touch.y < 544 - 80 and touch.y > 80 and oldtouch.y < 544 - 80 and oldtouch.y > 80) then
            if touchMode ~= TOUCH_MULTI then
                if touchMode == TOUCH_IDLE then
                    touchTemp.x = touch.x
                    touchTemp.y = touch.y
                    touchMode = TOUCH_READ
                end
                velX = touch.x - oldtouch.x
                velY = touch.y - oldtouch.y
            end
            if Touch2.x and OldTouch2.x and page.Zoom then
                touchMode = TOUCH_MULTI
                local old_Zoom = page.Zoom
                local center = {
                    x = (touch.x + Touch2.x) / 2,
                    y = (touch.y + Touch2.y) / 2
                }
                local n = (math.sqrt((touch.x - Touch2.x) * (touch.x - Touch2.x) + (touch.y - Touch2.y) * (touch.y - Touch2.y)) / math.sqrt((oldtouch.x - OldTouch2.x) * (oldtouch.x - OldTouch2.x) + (oldtouch.y - OldTouch2.y) * (oldtouch.y - OldTouch2.y)))
                scale(n, page)
                n = page.Zoom / old_Zoom
                page.y = page.y - (center.y - 272) * (n - 1)
                page.x = page.x - (center.x - 480) * (n - 1)
            end
        elseif ContextMenu and ((touch.y and (touch.y >= 544 - 80 or touch.y <= 80)) or (oldtouch.y and (oldtouch.y >= 544 - 80 or oldtouch.y <= 80))) then
            do end
        else
            if touchMode == TOUCH_SWIPE then
                if offset.x > 90 or offset.y > 90 then
                    if orientation == "Vertical" and is_down then
                        swipe("LEFT")
                    else
                        swipe("RIGHT")
                    end
                elseif offset.x < -90 or offset.y < -90 then
                    if orientation == "Vertical" and is_down then
                        swipe("RIGHT")
                    else
                        swipe("LEFT")
                    end
                end
                velX = 0
                velY = 0
                pageMode = PAGE_NONE
            end
            if touchMode ~= TOUCH_LOCK then
                if touchMode == TOUCH_READ then
                    OpenCloseContextMenu = true
                    Timer.reset(OpenCloseContextMenuTimer)
                end
                touchMode = TOUCH_IDLE
            end
        end
        if touchMode == TOUCH_READ and touchTemp.x and touch.x then
            local len = math.sqrt((touchTemp.x - touch.x) * (touchTemp.x - touch.x) + (touchTemp.y - touch.y) * (touchTemp.y - touch.y))
            if len > 10 then
                if orientation == "Horizontal" then
                    if is_down then
                        if not page.Zoom or (page.Width * page.Zoom < 961 or math.abs(touch.y - touchTemp.y) > math.abs(touch.x - touchTemp.x) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.y > touch.y) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.y < touch.y)) then
                            touchMode = TOUCH_SWIPE
                        else
                            touchMode = TOUCH_MOVE
                        end
                    else
                        if not page.Zoom or (page.Height * page.Zoom < 545 or math.abs(touch.x - touchTemp.x) > math.abs(touch.y - touchTemp.y) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.x > touch.x) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.x < touch.x)) then
                            touchMode = TOUCH_SWIPE
                        else
                            touchMode = TOUCH_MOVE
                        end
                    end
                elseif orientation == "Vertical" then
                    if is_down then
                        if not page.Zoom or (page.Width * page.Zoom < 545 or math.abs(touch.x - touchTemp.x) > math.abs(touch.y - touchTemp.y) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.x > touch.x) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.x < touch.x)) then
                            touchMode = TOUCH_SWIPE
                        else
                            touchMode = TOUCH_MOVE
                        end
                    else
                        if not page.Zoom or (page.Height * page.Zoom < 961 or math.abs(touch.y - touchTemp.y) > math.abs(touch.x - touchTemp.x) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.y > touch.y) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.y < touch.y)) then
                            touchMode = TOUCH_SWIPE
                        else
                            touchMode = TOUCH_MOVE
                        end
                    end
                end
            end
        end
    elseif STATE == STATE_LOADING then
        if touch.x == nil and oldtouch.x ~= nil and (not ContextMenu or (oldtouch.y <= 544 - 80 and oldtouch.y >= 80)) then
            OpenCloseContextMenu = true
            Timer.reset(OpenCloseContextMenuTimer)
        end
    end
    if ContextMenu and ((touch.y and (touch.y >= 544 - 80 or touch.y <= 80)) or (oldtouch.y and (oldtouch.y >= 544 - 80 or oldtouch.y <= 80))) then
        if (touch.y and touch.y >= 544 - 80 or oldtouch.y and oldtouch.y >= 544 - 80) and (touchMode == TOUCH_IDLE or touchMode == TOUCH_READ) then
            if touch.x and touch.x > 180 and touch.x < 780 and Pages.Count and Pages.Count > 1 then
                local new_page = math.min(math.max(1, math.floor((touch.x - 200) / (560 / (Pages.Count - 1)) + 1)), Pages.Count)
                if is_down and orientation == "Vertical" then
                    new_page = Pages.Count - new_page + 1
                end
                if new_page < Pages.Page then
                    repeat
                        swipe("RIGHT")
                    until new_page == Pages.Page
                    if readDirection == "LEFT" then
                        Pages.PrevPage = Pages.Page + 1
                    else
                        Pages.PrevPage = Pages.Page - 1
                    end
                elseif new_page > Pages.Page then
                    repeat
                        swipe("LEFT")
                    until new_page == Pages.Page
                    if readDirection == "LEFT" then
                        Pages.PrevPage = Pages.Page + 1
                    else
                        Pages.PrevPage = Pages.Page - 1
                    end
                end
            elseif not oldtouch.x and touch.x then
                if readDirection == "LEFT" or is_down and orientation == "Vertical" then
                    if touch.x < 88 and current_chapter < #Chapters then
                        if Cache.isCached(Chapters[current_chapter].Manga) then
                            Cache.setBookmark(Chapters[current_chapter], true)
                        end
                        Reader.loadChapter(current_chapter + 1)
                    elseif touch.x > 960 - 88 and current_chapter > 1 then
                        Reader.loadChapter(current_chapter - 1)
                        StartPage = false
                    end
                else
                    if touch.x < 88 and current_chapter > 1 then
                        Reader.loadChapter(current_chapter - 1)
                        StartPage = false
                    elseif touch.x > 960 - 88 and current_chapter < #Chapters then
                        if Cache.isCached(Chapters[current_chapter].Manga) then
                            Cache.setBookmark(Chapters[current_chapter], true)
                        end
                        Reader.loadChapter(current_chapter + 1)
                    end
                end
            end
        end
        OnTouchMenu = true
    else
        OnTouchMenu = false
    end
    if ContextMenu then
        if CursorIndex == -1 and (Controls.check(pad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_DOWN)) then
            CursorIndex = 0
            CursorPoint = Point_t(32 + 12, 35)
            CursorDestination = Point_t(32 + 12, 35)
        elseif CursorIndex >= 0 and CursorIndex < #CursorPlaces then
            if not Controls.check(pad, SCE_CTRL_CROSS) then
                if STATE == STATE_READING then
                    if CursorIndex > 2 then
                        if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
                            CursorIndex = CursorIndex - 3
                        elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) and CursorIndex > 3 then
                            CursorIndex = CursorIndex - 1
                        elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) and CursorIndex < 5 then
                            CursorIndex = CursorIndex + 1
                        end
                    else
                        if Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
                            CursorIndex = CursorIndex + 3
                            if CursorIndex == 4 then
                                CursorIndex = 5
                            end
                        elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) and CursorIndex > 0 then
                            CursorIndex = CursorIndex - 1
                        elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) and CursorIndex < 2 then
                            CursorIndex = CursorIndex + 1
                        end
                    end
                elseif STATE == STATE_LOADING then
                    if CursorIndex > 2 then
                        if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
                            CursorIndex = 0
                        end
                    else
                        if Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
                            CursorIndex = 3
                        elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) then
                            CursorIndex = 3
                        elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) then
                            CursorIndex = 5
                        end
                    end
                end
            end
            if CursorIndex >= 0 then
                if Controls.check(pad, SCE_CTRL_CROSS) then
                    if CursorIndex == 4 then
                        if not (Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_LEFT)) then
                            buttonTimeSpace = 400
                        end
                        local left = is_down and orientation == "Vertical" and SCE_CTRL_RIGHT or SCE_CTRL_LEFT
                        local right = is_down and orientation == "Vertical" and SCE_CTRL_LEFT or SCE_CTRL_RIGHT
                        if Pages.Page < Pages.Count and Controls.check(pad, right) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldpad, right)) then
                            swipe("LEFT")
                            buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
                            Timer.reset(buttonTimer)
                        elseif Pages.Page > 1 and Controls.check(pad, left) and (buttonTimeSpace < Timer.getTime(buttonTimer) or not Controls.check(oldpad, left)) then
                            swipe("RIGHT")
                            buttonTimeSpace = math.max(buttonTimeSpace / 2, 10)
                            Timer.reset(buttonTimer)
                        end
                    elseif not Controls.check(oldpad, SCE_CTRL_CROSS) then
                        if CursorIndex == 0 then
                            if Pages.Page > 0 then
                                local bookmark
                                if readDirection == "LEFT" then
                                    bookmark = Pages.Count - Pages.Page + 1
                                else
                                    bookmark = Pages.Page
                                end
                                if bookmark == 1 then
                                    bookmark = nil
                                elseif bookmark == Pages.Count then
                                    bookmark = true
                                end
                                if Cache.isCached(Chapters[current_chapter].Manga) then
                                    Cache.setBookmark(Chapters[current_chapter], bookmark)
                                end
                            end
                            exit()
                        elseif CursorIndex == 1 and STATE == STATE_READING then
                            if Pages[Pages.Page or -1] then
                                deletePageImage(Pages.Page)
                                loadPageImage(Pages.Page)
                            end
                        elseif CursorIndex == 2 and STATE == STATE_READING then
                            if Pages[Pages.Page or -1] and (Pages[Pages.Page or -1].Link or Pages[Pages.Page or -1].Path) then
                                Extra.setChapters(Chapters[current_chapter].Manga, Chapters[current_chapter], Pages[Pages.Page])
                            end
                        else
                            if readDirection == "LEFT" or is_down and orientation == "Vertical" then
                                if CursorIndex == 3 and current_chapter < #Chapters then
                                    if Cache.isCached(Chapters[current_chapter].Manga) then
                                        Cache.setBookmark(Chapters[current_chapter], true)
                                    end
                                    Reader.loadChapter(current_chapter + 1)
                                elseif CursorIndex == 5 and current_chapter > 1 then
                                    Reader.loadChapter(current_chapter - 1)
                                    StartPage = false
                                end
                            else
                                if CursorIndex == 3 and current_chapter > 1 then
                                    Reader.loadChapter(current_chapter - 1)
                                    StartPage = false
                                elseif CursorIndex == 5 and current_chapter < #Chapters then
                                    if Cache.isCached(Chapters[current_chapter].Manga) then
                                        Cache.setBookmark(Chapters[current_chapter], true)
                                    end
                                    Reader.loadChapter(current_chapter + 1)
                                end
                            end
                        end
                    end
                end
                if CursorIndex == 4 and STATE == STATE_READING then
                    local current_page = Pages.Page
                    current_page = math.max(1, math.min(current_page, Pages.Count))
                    local point = 0
                    if Pages.Count == 1 then
                        point = 560
                    else
                        point = ((current_page - 1) * 560 / (Pages.Count - 1))
                    end
                    if readDirection == "LEFT" then
                        CursorDestination = Point_t(200 + point, 544 - 40)
                    elseif orientation == "Vertical" and is_down then
                        if Pages.Count == 1 then
                            point = 560
                        else
                            point = (((Pages.Count - Pages.Page + 1) - 1) * 560 / (Pages.Count - 1))
                        end
                        CursorDestination = Point_t(200 + point, 544 - 40)
                    else
                        CursorDestination = Point_t(200 + point, 544 - 40)
                    end
                else
                    CursorDestination = CursorPlaces[CursorIndex + 1]
                end
                CursorPoint.x = CursorPoint.x + (CursorDestination.x - CursorPoint.x) / 4
                CursorPoint.y = CursorPoint.y + (CursorDestination.y - CursorPoint.y) / 4
            end
        end
    end
    if touch.x or not ContextMenu then
        CursorIndex = -1
    end
    if Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START) then
        ContextMenu = not ContextMenu
    end
end

local counterShift = 0


function Reader.update()
    if OpenCloseContextMenu and Timer.getTime(OpenCloseContextMenuTimer) > 300 then
        Timer.reset(chapter_timer)
        Timer.reset(name_timer)
        ContextMenu = not ContextMenu
        OpenCloseContextMenu = false
    end
    if STATE == STATE_LOADING then
        if Chapters[current_chapter].Pages.Done then
            if #Chapters[current_chapter].Pages == 0 then
                Console.error("Error loading chapter")
                ParserManager.remove((((Chapters or {})[current_chapter or 0] or {}).Pages) or 0)
                collectgarbage("collect")
                if Threads.netActionUnSafe(Network.isWifiEnabled) then
                    Notifications.push("Unknown error (Parser's)")
                else
                    Notifications.push("Unknown error (No Connection?)")
                end
                AppMode = MENU
                return
            end
            STATE = STATE_READING
            local chapter = Chapters[current_chapter]
            Pages.Count = #chapter.Pages
            if readDirection == "RIGHT" or is_down then
                for i = 1, #chapter.Pages do
                    Pages[#Pages + 1] = {
                        chapter.Pages[i],
                        Path = chapter.Pages[i].Path,
                        Extract = chapter.Pages[i].Extract,
                        x = 0,
                        y = 0
                    }
                end
            elseif readDirection == "LEFT" then
                for i = #chapter.Pages, 1, -1 do
                    Pages[#Pages + 1] = {
                        chapter.Pages[i],
                        Path = chapter.Pages[i].Path,
                        Extract = chapter.Pages[i].Extract,
                        x = 0,
                        y = 0
                    }
                end
            end
            if readDirection == "RIGHT" or is_down then
                StartPage = StartPage and StartPage > 0 and StartPage <= Pages.Count and StartPage or StartPage == false and -1 or nil
                if StartPage == -1 then
                    StartPage = false
                end
                if current_chapter ~= 1 then
                    Pages[0] = {
                        Link = "LoadPrev",
                        x = 0,
                        y = 0
                    }
                end
                if current_chapter < #Chapters then
                    Pages[#Pages + 1] = {
                        Link = "LoadNext",
                        x = 0,
                        y = 0
                    }
                end
                if StartPage then
                    Pages.Page = StartPage - 1
                    changePage(StartPage)
                elseif StartPage == false then
                    Pages.Page = Pages.Count + 1
                    changePage(Pages.Count)
                else
                    Pages.Page = 0
                    changePage(1)
                end
                StartPage = nil
            elseif readDirection == "LEFT" then
                StartPage = StartPage and StartPage > 0 and StartPage <= Pages.Count and StartPage or StartPage == false and -1 or nil
                if StartPage == -1 then
                    StartPage = false
                end
                if current_chapter < #Chapters then
                    Pages[0] = {
                        Link = "LoadNext",
                        x = 0,
                        y = 0
                    }
                end
                if current_chapter ~= 1 then
                    Pages[#Pages + 1] = {
                        Link = "LoadPrev",
                        x = 0,
                        y = 0
                    }
                end
                if StartPage then
                    Pages.Page = Pages.Count - StartPage + 2
                    changePage(Pages.Count + 1 - StartPage)
                elseif StartPage == false then
                    Pages.Page = 0
                    changePage(1)
                else
                    Pages.Page = Pages.Count + 1
                    changePage(Pages.Count)
                end
                StartPage = nil
            end
            Timer.reset(hideCounterTimer)
        end
    elseif STATE == STATE_READING then
        if not Pages[Pages.Page] then
            return
        end
        gesture_touch_update()
        if Pages.PrevPage and Pages.PrevPage ~= Pages.Page and (((is_down and offset.y or offset.x) >= 0 and Pages.PrevPage > Pages.Page or (is_down and offset.y or offset.x) <= 0 and Pages.PrevPage < Pages.Page) and orientation == "Horizontal" or ((is_down and -offset.x or offset.y) >= 0 and Pages.PrevPage > Pages.Page or (is_down and -offset.x or offset.y) <= 0 and Pages.PrevPage < Pages.Page) and orientation == "Vertical") then
            if Pages.PrevPage > 0 and Pages.PrevPage <= #Pages then
                deletePageImage(Pages.PrevPage)
            end
            local p = Pages.Page + math.sign(Pages.Page - Pages.PrevPage)
            if p > 0 and p <= #Pages then
                if not Pages[p].Image and not (Pages[p].Link == "LoadPrev" or Pages[p].Link == "LoadNext") then
                    if Pages[p].Extract then
                        local new_page = Pages[p]
                        Threads.addTask(new_page, {
                            Type = "UnZipFile",
                            Path = new_page.Path,
                            Extract = new_page.Extract,
                            DestPath = "ux0:data/noboru/temp/cache.image",
                            OnComplete = function()
                                Threads.insertTask(new_page, {
                                    Type = "Image",
                                    Table = new_page,
                                    Path = "temp/cache.image",
                                    Index = "Image"
                                })
                            end
                        })
                    elseif Pages[p].Path then
                        Threads.addTask(Pages[p], {
                            Type = "Image",
                            Path = Pages[p].Path,
                            Table = Pages[p],
                            Index = "Image"
                        })
                    elseif Pages[p].Link then
                        Threads.addTask(Pages[p], {
                            Type = "ImageDownload",
                            Link = Pages[p].Link,
                            Table = Pages[p],
                            Index = "Image"
                        })
                    else
                        ParserManager.loadPageImage(Chapters[current_chapter].Manga.ParserID, Pages[p][1], Pages[p], p, false)
                    end
                end
            end
        end
        local o = readDirection == "LEFT" and {1, -1, 0} or {-1, 1, 0}
        for _, i in ipairs(o) do
            local page = Pages[Pages.Page + i]
            if page and not page.Zoom and page.Image then
                local Image = page.Image
                if orientation == "Horizontal" then
                    if is_down then
                        page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480, 272 + i * 544
                        Console.write("Added " .. Pages.Page + i)
                        if autozoom == "Smart" then
                            if page.Width < page.Height then
                                page.Zoom = 960 / page.Width
                            else
                                page.Zoom = 544 / page.Height
                            end
                        elseif autozoom == "Width" then
                            page.Zoom = 960 / page.Width
                        elseif autozoom == "Height" then
                            page.Zoom = 544 / page.Height
                        else
                            page.Zoom = 960 / page.Width
                        end
                        if page.Height * page.Zoom >= 544 then
                            if i == 0 then
                                if Pages.PrevPage > Pages.Page then
                                    page.y = page.y + (544 - page.Height * page.Zoom) / 2
                                elseif Pages.PrevPage < Pages.Page then
                                    page.y = page.y - (544 - page.Height * page.Zoom) / 2
                                end
                            else
                                page.y = page.y - i * (544 - page.Height * page.Zoom) / 2
                            end
                        end
                        page.min_Zoom = math.min(544 / page.Height, 960 / page.Width)
                        if page.Zoom * page.Width > 960 then
                            page.x = 960 - (page.Width * page.Zoom) / 2
                        end
                        page.start_Zoom = page.Zoom
                    else
                        page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 + i * 960, 272
                        Console.write("Added " .. Pages.Page + i)
                        if autozoom == "Smart" then
                            if page.Width > page.Height then
                                page.Zoom = 544 / page.Height
                            else
                                page.Zoom = 960 / page.Width
                            end
                        elseif autozoom == "Width" then
                            page.Zoom = 960 / page.Width
                        elseif autozoom == "Height" then
                            page.Zoom = 544 / page.Height
                        end
                        if page.Width * page.Zoom >= 960 then
                            if i == 0 then
                                if Pages.PrevPage > Pages.Page then
                                    page.x = page.x + (960 - page.Width * page.Zoom) / 2
                                elseif Pages.PrevPage < Pages.Page then
                                    page.x = page.x - (960 - page.Width * page.Zoom) / 2
                                end
                            else
                                page.x = page.x - i * (960 - page.Width * page.Zoom) / 2
                            end
                        end
                        page.min_Zoom = math.min(544 / page.Height, 960 / page.Width)
                        if page.Zoom * page.Height > 544 then
                            page.y = page.Zoom * page.Height / 2
                        end
                        page.start_Zoom = page.Zoom
                    end
                elseif orientation == "Vertical" then
                    if is_down then
                        page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 - i * 960, 272
                        Console.write("Added " .. Pages.Page + i)
                        if autozoom == "Smart" then
                            if page.Width > page.Height then
                                page.Zoom = 960 / page.Height
                            else
                                page.Zoom = 544 / page.Width
                            end
                        elseif autozoom == "Width" then
                            page.Zoom = 544 / page.Width
                        elseif autozoom == "Height" then
                            page.Zoom = 960 / page.Height
                        else
                            page.Zoom = 544 / page.Width
                        end
                        if page.Height * page.Zoom >= 960 then
                            if i == 0 then
                                if Pages.PrevPage > Pages.Page then
                                    page.x = page.x - (960 - page.Height * page.Zoom) / 2
                                elseif Pages.PrevPage < Pages.Page then
                                    page.x = page.x + (960 - page.Height * page.Zoom) / 2
                                end
                            else
                                page.x = page.x + i * (960 - page.Height * page.Zoom) / 2
                            end
                        end
                        page.min_Zoom = math.min(960 / page.Height, 544 / page.Width)
                        if page.Zoom * page.Width > 544 then
                            page.y = 544 - (page.Zoom * page.Width) / 2
                        end
                        page.start_Zoom = page.Zoom
                    else
                        page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480, 272 + i * 544
                        Console.write("Added " .. Pages.Page + i)
                        if autozoom == "Smart" then
                            if page.Width > page.Height then
                                page.Zoom = 960 / page.Height
                            else
                                page.Zoom = 544 / page.Width
                            end
                        elseif autozoom == "Width" then
                            page.Zoom = 544 / page.Width
                        elseif autozoom == "Height" then
                            page.Zoom = 960 / page.Height
                        end
                        if page.Width * page.Zoom >= 544 then
                            if i == 0 then
                                if Pages.PrevPage > Pages.Page then
                                    page.y = page.y + (544 - page.Width * page.Zoom) / 2
                                elseif Pages.PrevPage < Pages.Page then
                                    page.y = page.y - (544 - page.Width * page.Zoom) / 2
                                end
                            else
                                page.y = page.y - i * (544 - page.Width * page.Zoom) / 2
                            end
                        end
                        page.min_Zoom = math.min(960 / page.Height, 544 / page.Width)
                        if page.Zoom * page.Height > 960 then
                            page.x = 960 - (page.Zoom * page.Height) / 2
                        end
                        page.start_Zoom = page.Zoom
                    end
                end
            end
        end
        if touchMode == TOUCH_IDLE or touchMode == TOUCH_MOVE then
            local page = Pages[Pages.Page]
            if page and page.Zoom then
                page.x = page.x + velX
                page.y = page.y + velY
            end
            if touchMode == TOUCH_IDLE or OnTouchMenu then
                velY = velY * 0.9
                velX = velX * 0.9
            end
        elseif touchMode == TOUCH_SWIPE then
            if (orientation == "Horizontal" and not is_down) or (orientation == "Vertical" and is_down) then
                if orientation == "Vertical" then
                    offset.x = offset.x + velX
                    if offset.x < 0 and not Pages[Pages.Page - 1] then
                        offset.x = 0
                    elseif offset.x > 0 and Pages.Page == #Pages then
                        offset.x = 0
                    end
                else
                    offset.x = offset.x + velX
                    if offset.x > 0 and not Pages[Pages.Page - 1] then
                        offset.x = 0
                    elseif offset.x < 0 and Pages.Page == #Pages then
                        offset.x = 0
                    end
                end
            else
                offset.y = offset.y + velY
                if offset.y > 0 and not Pages[Pages.Page - 1] then
                    offset.y = 0
                elseif offset.y < 0 and Pages.Page == #Pages then
                    offset.y = 0
                end
            end
        end
        if touchMode ~= TOUCH_SWIPE then
            local dir = 'x'
            if orientation == "Vertical" and not is_down or orientation == "Horizontal" and is_down then
                dir = 'y'
            end
            offset[dir] = offset[dir] / 1.3
            if math.abs(offset[dir]) < 1 then
                offset[dir] = 0
                if Pages[Pages.Page] and Pages[Pages.Page].Link == "LoadNext" then
                    Cache.setBookmark(Chapters[current_chapter], true)
                    Reader.loadChapter(current_chapter + 1)
                    return
                end
                if Pages[Pages.Page] and Pages[Pages.Page].Link == "LoadPrev" then
                    Cache.setBookmark(Chapters[current_chapter], nil)
                    StartPage = false
                    Reader.loadChapter(current_chapter - 1)
                    return
                end
            end
        end
        local page = Pages[Pages.Page]
        if orientation == "Horizontal" then
            if is_down then
                if page.Zoom then
                    if page.Width * page.Zoom < 960 then
                        page.x = 480
                    elseif page.x - page.Width / 2 * page.Zoom > 0 then
                        page.x = page.Width / 2 * page.Zoom
                    elseif page.x + page.Width / 2 * page.Zoom < 960 then
                        page.x = 960 - page.Width / 2 * page.Zoom
                    end
                    if page.Zoom * page.Height > 545 then
                        if page.y - page.Height / 2 * page.Zoom >= 0 then
                            page.y = page.Height / 2 * page.Zoom
                            if Pages[Pages.Page - 1] then
                                pageMode = PAGE_LEFT
                            else
                                pageMode = PAGE_NONE
                            end
                        elseif page.y + page.Height / 2 * page.Zoom <= 544 then
                            page.y = 544 - page.Height / 2 * page.Zoom
                            if Pages.Page ~= #Pages then
                                pageMode = PAGE_RIGHT
                            else
                                pageMode = PAGE_NONE
                            end
                        else
                            pageMode = PAGE_NONE
                        end
                    else
                        page.y = 272
                        pageMode = PAGE_LEFT + PAGE_RIGHT
                    end
                else
                    pageMode = PAGE_LEFT + PAGE_RIGHT
                end
            else
                if page.Zoom then
                    if page.Height * page.Zoom < 544 then
                        page.y = 272
                    elseif page.y - page.Height / 2 * page.Zoom > 0 then
                        page.y = page.Height / 2 * page.Zoom
                    elseif page.y + page.Height / 2 * page.Zoom < 544 then
                        page.y = 544 - page.Height / 2 * page.Zoom
                    end
                    if page.Zoom * page.Width > 961 then
                        if page.x - page.Width / 2 * page.Zoom >= 0 then
                            page.x = page.Width / 2 * page.Zoom
                            if Pages[Pages.Page - 1] then
                                pageMode = PAGE_LEFT
                            else
                                pageMode = PAGE_NONE
                            end
                        elseif page.x + page.Width / 2 * page.Zoom <= 960 then
                            page.x = 960 - page.Width / 2 * page.Zoom
                            if Pages.Page ~= #Pages then
                                pageMode = PAGE_RIGHT
                            else
                                pageMode = PAGE_NONE
                            end
                        else
                            pageMode = PAGE_NONE
                        end
                    else
                        page.x = 480
                        pageMode = PAGE_LEFT + PAGE_RIGHT
                    end
                else
                    pageMode = PAGE_LEFT + PAGE_RIGHT
                end
            end
        elseif orientation == "Vertical" then
            if is_down then
                if page.Zoom then
                    if page.Width * page.Zoom < 544 then
                        page.y = 272
                    elseif page.y - page.Width / 2 * page.Zoom > 0 then
                        page.y = page.Width / 2 * page.Zoom
                    elseif page.y + page.Width / 2 * page.Zoom < 544 then
                        page.y = 544 - page.Width / 2 * page.Zoom
                    end
                    if page.Zoom * page.Height > 961 then
                        if page.x - page.Height / 2 * page.Zoom >= 0 then
                            page.x = page.Height / 2 * page.Zoom
                            if Pages.Page ~= #Pages then
                                pageMode = PAGE_LEFT
                            else
                                pageMode = PAGE_NONE
                            end
                        elseif page.x + page.Height / 2 * page.Zoom <= 960 then
                            page.x = 960 - page.Height / 2 * page.Zoom
                            if Pages[Pages.Page - 1] then
                                pageMode = PAGE_RIGHT
                            else
                                pageMode = PAGE_NONE
                            end
                        else
                            pageMode = PAGE_NONE
                        end
                    else
                        page.x = 480
                        pageMode = PAGE_LEFT + PAGE_RIGHT
                    end
                else
                    pageMode = PAGE_LEFT + PAGE_RIGHT
                end
            else
                if page.Zoom then
                    if page.Height * page.Zoom < 960 then
                        page.x = 480
                    elseif page.x - page.Height / 2 * page.Zoom > 0 then
                        page.x = page.Height / 2 * page.Zoom
                    elseif page.x + page.Height / 2 * page.Zoom < 960 then
                        page.x = 960 - page.Height / 2 * page.Zoom
                    end
                    if page.Zoom * page.Width > 545 then
                        if page.y - page.Width / 2 * page.Zoom >= 0 then
                            page.y = page.Width / 2 * page.Zoom
                            if Pages[Pages.Page - 1] then
                                pageMode = PAGE_LEFT
                            else
                                pageMode = PAGE_NONE
                            end
                        elseif page.y + page.Width / 2 * page.Zoom <= 544 then
                            page.y = 544 - page.Width / 2 * page.Zoom
                            if Pages.Page ~= #Pages then
                                pageMode = PAGE_RIGHT
                            else
                                pageMode = PAGE_NONE
                            end
                        else
                            pageMode = PAGE_NONE
                        end
                    else
                        page.y = 272
                        pageMode = PAGE_LEFT + PAGE_RIGHT
                    end
                else
                    pageMode = PAGE_LEFT + PAGE_RIGHT
                end
            end
        end
        if Timer.getTime(hideCounterTimer) > 1500 or MenuFade > 0 then
            counterShift = math.max(counterShift - 1.5, -30)
        else
            counterShift = math.min(counterShift + 1.5, 0)
        end
    end
    if ContextMenu then
        MenuFade = math.min(MenuFade + 0.1, 1)
    else
        MenuFade = math.max(MenuFade - 0.1, 0)
    end
    if CursorIndex >= 0 then
        CursorFade = math.min(CursorFade + 0.1, 1)
    else
        CursorFade = math.max(CursorFade - 0.1, 0)
    end
end

function Reader.draw()
    Screen.clear(COLOR_BACK)
    if STATE == STATE_LOADING then
        local manga_name = Chapters[current_chapter].Manga.Name
        local prepare_message = Language[Settings.Language].READER.PREPARING_PAGES .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
        local chapter_name = Chapters[current_chapter].Name
        if Font.getTextWidth(BONT30, manga_name) > 960 then
            Font.print(FONT16, 480 - Font.getTextWidth(FONT16, manga_name) / 2, 242, manga_name, COLOR_FONT)
        else
            Font.print(BONT30, 480 - Font.getTextWidth(BONT30, manga_name) / 2, 232, manga_name, COLOR_FONT)
        end
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, chapter_name) / 2, 264, chapter_name, COLOR_FONT)
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, prepare_message) / 2, 284, prepare_message, COLOR_FONT)
    elseif STATE == STATE_READING then
        local o = readDirection == "LEFT" and {1, -1, 0} or {-1, 1, 0}
        for _, i in ipairs(o) do
            local page = Pages[Pages.Page + i]
            if page and page.Image then
                if type(page.Image.e or page.Image) == "table" then
                    for k = 1, page.Image.Parts do
                        if page.Image[k] and page.Image[k].e then
                            local Height = Graphics.getImageHeight(page.Image[k].e)
                            if orientation == "Horizontal" then
                                local x, y = math.ceil((offset.x + page.x) * 4) / 4, offset.y + page.y + (k - 1) * page.Image.SliceHeight * page.Zoom - page.Height / 2 * page.Zoom + page.Image.SliceHeight / 2 * page.Zoom
                                Graphics.fillRect(x - page.Width / 2 * page.Zoom, x + page.Width / 2 * page.Zoom, y - Height / 2 * page.Zoom, y + Height / 2 * page.Zoom, COLOR_BLACK)
                                Graphics.drawImageExtended(x, y, page.Image[k].e, 0, 0, page.Width, Height, 0, page.Zoom, page.Zoom)
                            elseif orientation == "Vertical" then
                                local x, y = math.ceil((offset.x + page.x) * 4) / 4 - (k - 1) * page.Image.SliceHeight * page.Zoom + page.Height / 2 * page.Zoom - page.Image.SliceHeight / 2 * page.Zoom, offset.y + page.y
                                Graphics.fillRect(x - Height / 2 * page.Zoom, x + Height / 2 * page.Zoom, y - page.Width / 2 * page.Zoom, y + page.Width / 2 * page.Zoom, COLOR_BLACK)
                                Graphics.drawImageExtended(x, y, page.Image[k].e, 0, 0, page.Width, Height, math.pi / 2, page.Zoom, page.Zoom)
                            end
                        else
                            if orientation == "Horizontal" then
                                local loading = Language[Settings.Language].READER.LOADING_SEGMENT .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                                local Width = Font.getTextWidth(FONT16, loading)
                                Font.print(FONT16, offset.x + 960 * i + 480 - Width / 2, offset.y + page.y + (k - 1) * page.Image.SliceHeight * page.Zoom - page.Height / 2 * page.Zoom + 10 * page.Zoom, loading, COLOR_FONT)
                            elseif orientation == "Vertical" then
                                local loading = Language[Settings.Language].READER.LOADING_SEGMENT .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                                local Width = Font.getTextWidth(FONT16, loading)
                                Font.print(FONT16, offset.x - Width + page.x - ((k - 1) * page.Image.SliceHeight * page.Zoom - page.Height / 2 * page.Zoom + 10 * page.Zoom), offset.y + 272 + 544 * i, loading, COLOR_FONT)
                            end
                        end
                    end
                else
                    local x, y = math.ceil((offset.x + page.x) * 4) / 4, math.ceil((offset.y + page.y) * 4) / 4
                    if orientation == "Horizontal" then
                        Graphics.fillRect(x - page.Width / 2 * page.Zoom, x + page.Width / 2 * page.Zoom, y - page.Height / 2 * page.Zoom, y + page.Height / 2 * page.Zoom, COLOR_BLACK)
                        Graphics.drawImageExtended(x, y, page.Image.e, 0, 0, page.Width, page.Height, 0, page.Zoom, page.Zoom)
                    elseif orientation == "Vertical" then
                        Graphics.fillRect(x - page.Height / 2 * page.Zoom, x + page.Height / 2 * page.Zoom, y - page.Width / 2 * page.Zoom, y + page.Width / 2 * page.Zoom, COLOR_BLACK)
                        Graphics.drawImageExtended(x, y, page.Image.e, 0, 0, page.Width, page.Height, math.pi / 2, page.Zoom, page.Zoom)
                    end
                end
            elseif page then
                local precentage = Threads.getProgress(page)
                local loading = Language[Settings.Language].READER.LOADING_PAGE .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                local Width = Font.getTextWidth(FONT16, loading)
                if orientation == "Horizontal" then
                    Font.print(FONT16, offset.x + 960 * (is_down and 0 or i) + 480 - Width / 2, 272 + offset.y + 544 * (is_down and i or 0) - 10, loading, COLOR_FONT)
                    Graphics.fillEmptyRect(offset.x + 960 * (is_down and 0 or i) + 480 - 52, offset.x + 960 * (is_down and 0 or i) + 480 + 53, 272 + offset.y + 544 * (is_down and i or 0) + 20, 272 + offset.y + 544 * (is_down and i or 0) + 32, COLOR_FONT)
                    Graphics.fillRect(offset.x + 960 * (is_down and 0 or i) + 480 - 50, offset.x + 960 * (is_down and 0 or i) + 480 - 50 + 100 * precentage, 272 + offset.y + 544 * (is_down and i or 0) + 22, 272 + offset.y + 544 * (is_down and i or 0) + 29, COLOR_FONT)
                elseif orientation == "Vertical" then
                    Font.print(FONT16, 960 / 2 - Width / 2 + offset.x + 960 * (is_down and i or 0), 272 + offset.y + 544 * (is_down and 0 or i) - 10, loading, COLOR_FONT)
                    Graphics.fillEmptyRect(offset.x + 960 * (is_down and i or 0) + 480 - 52, offset.x + 960 * (is_down and i or 0) + 480 + 53, 272 + offset.y + 544 * (is_down and 0 or i) + 20, 272 + offset.y + 544 * (is_down and 0 or i) + 32, COLOR_FONT)
                    Graphics.fillRect(offset.x + 960 * (is_down and i or 0) + 480 - 50, offset.x + 960 * (is_down and i or 0) + 480 - 50 + 100 * precentage, 272 + offset.y + 544 * (is_down and 0 or i) + 22, 272 + offset.y + 544 * (is_down and 0 or i) + 29, COLOR_FONT)
                end
            end
        end
        if Pages.Page <= (Pages.Count or 0) and Pages.Page > 0 then
            local Counter = Pages.Page .. "/" .. Pages.Count
            if readDirection == "LEFT" then
                Counter = (Pages.Count - Pages.Page + 1) .. "/" .. Pages.Count
            end
            local Width = Font.getTextWidth(FONT16, Counter) + 20
            Graphics.fillRect(960 - Width, 960, counterShift, counterShift + Font.getTextHeight(FONT16, Counter) + 4, Color.new(0, 0, 0, 128))
            Font.print(FONT16, 970 - Width, counterShift, Counter, COLOR_WHITE)
        end
    end
    if MenuFade > 0 then
        local BACK_COLOR = Color.new(0, 0, 0, 255 * MenuFade)
        local GRAY_COLOR = Color.new(128, 128, 128, 255 * MenuFade)
        local BLUE_COLOR = ChangeAlpha(COLOR_ROYAL_BLUE, 255 * MenuFade)
        Graphics.fillRect(88, 960 - 88 - 32 - 24 - 32, 0, 80 * MenuFade, BACK_COLOR)
        Graphics.fillRect(0, 960, 544 - 80 * MenuFade, 544, BACK_COLOR)
        if STATE == STATE_READING then
            local current_page = Pages.Page
            current_page = math.max(1, math.min(current_page, Pages.Count))
            local point = 0
            if Pages.Count == 1 then
                point = 560
            else
                point = ((current_page - 1) * 560 / (Pages.Count - 1))
            end
            if readDirection == "LEFT" then
                Graphics.fillRect(200, 760, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, BLUE_COLOR)
                Graphics.fillRect(200, 200 + point, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, GRAY_COLOR)
                Graphics.drawImage(200 + point - 6, 544 - 80 * MenuFade + 40 - 6, Circle_icon.e, BLUE_COLOR)
                current_page = (Pages.Count - Pages.Page + 1)
                current_page = math.max(1, math.min(current_page, Pages.Count))
                Font.print(FONT26, 180 - Font.getTextWidth(FONT26, Pages.Count), 544 - 80 * MenuFade + 23, Pages.Count, COLOR_WHITE)
                Font.print(FONT26, 780, 544 - 80 * MenuFade + 23, current_page, COLOR_WHITE)
            elseif orientation == "Vertical" and is_down then
                if Pages.Count == 1 then
                    point = 560
                else
                    point = (((Pages.Count - Pages.Page + 1) - 1) * 560 / (Pages.Count - 1))
                end
                Graphics.fillRect(200, 760, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, BLUE_COLOR)
                Graphics.fillRect(200, 200 + point, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, GRAY_COLOR)
                Graphics.drawImage(200 + point - 6, 544 - 80 * MenuFade + 40 - 6, Circle_icon.e, BLUE_COLOR)
                Font.print(FONT26, 180 - Font.getTextWidth(FONT26, Pages.Count), 544 - 80 * MenuFade + 23, Pages.Count, COLOR_WHITE)
                Font.print(FONT26, 780, 544 - 80 * MenuFade + 23, current_page, COLOR_WHITE)
            else
                Graphics.fillRect(200, 760, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, GRAY_COLOR)
                Graphics.fillRect(200, 200 + point, 544 - 80 * MenuFade + 39, 544 - 80 * MenuFade + 41, BLUE_COLOR)
                Graphics.drawImage(200 + point - 6, 544 - 80 * MenuFade + 40 - 6, Circle_icon.e, BLUE_COLOR)
                Font.print(FONT26, 180 - Font.getTextWidth(FONT26, current_page), 544 - 80 * MenuFade + 23, current_page, COLOR_WHITE)
                Font.print(FONT26, 780, 544 - 80 * MenuFade + 23, Pages.Count, COLOR_WHITE)
            end
        end
        if current_chapter > 1 and not (orientation == "Vertical" and is_down or readDirection == "LEFT") or current_chapter < #Chapters and (orientation == "Vertical" and is_down or readDirection == "LEFT") then
            Graphics.drawImage(32, 544 - 80 * MenuFade + 40 - 12, left_arrow_icon.e, COLOR_WHITE)
        else
            Graphics.drawImage(32, 544 - 80 * MenuFade + 40 - 12, left_arrow_icon.e, COLOR_GRAY)
        end
        if current_chapter < #Chapters and not (orientation == "Vertical" and is_down or readDirection == "LEFT") or current_chapter > 1 and (orientation == "Vertical" and is_down or readDirection == "LEFT") then
            Graphics.drawImage(960 - 32 - 24, 544 - 80 * MenuFade + 40 - 12, right_arrow_icon.e, COLOR_WHITE)
        else
            Graphics.drawImage(960 - 32 - 24, 544 - 80 * MenuFade + 40 - 12, right_arrow_icon.e, COLOR_GRAY)
        end
        if Chapters[current_chapter] then
            local manga_name = Chapters[current_chapter].Manga.Name
            local chapter_name = Chapters[current_chapter].Name
            local dif = math.max(Font.getTextWidth(BONT30, manga_name) - 960 + 88 + 32 + 24 + 32 + 24 + 32 + 32, 0)
            local dif_ch = math.max(Font.getTextWidth(FONT16, chapter_name) - 960 + 88 + 32 + 24 + 32 + 24 + 32 + 32, 0)
            local ms = 50 * string.len(manga_name)
            local ms_ch = 50 * string.len(chapter_name)
            local t = math.min(math.max(0, Timer.getTime(name_timer) - 1500), ms)
            local t_ch = math.min(math.max(0, Timer.getTime(chapter_timer) - 1500), ms_ch)
            Font.print(BONT30, 88 - dif * t / ms, 80 * MenuFade - 73, manga_name, COLOR_WHITE)
            Font.print(FONT16, 88 - dif_ch * t_ch / ms_ch, 80 * MenuFade - 32, chapter_name, COLOR_WHITE)
            Graphics.fillRect(0, 88, 0, 80 * MenuFade, BACK_COLOR)
            Graphics.drawImage(32, 80 * MenuFade - 40 - 12, Back_icon.e, COLOR_WHITE)
            Graphics.fillRect(960 - 88 - 32 - 24 - 32, 960, 0, 80 * MenuFade, BACK_COLOR)
            if STATE == STATE_READING then
                Graphics.drawImage(960 - 32 - 24 - 32 - 32 - 24, 80 * MenuFade - 40 - 12, Refresh_icon.e, COLOR_WHITE)
                if Pages[Pages.Page] and (Pages[Pages.Page].Link or Chapters[current_chapter].Manga.ParserID == "IMPORTED" or Pages[Pages.Page].Path) then
                    Graphics.drawImage(960 - 32 - 24, 80 * MenuFade - 40 - 12, Options_icon.e, COLOR_WHITE)
                else
                    Graphics.drawImage(960 - 32 - 24, 80 * MenuFade - 40 - 12, Options_icon.e, COLOR_GRAY)
                end
            end
            if Timer.getTime(name_timer) > 3500 + ms then
                Timer.reset(name_timer)
            end
            if Timer.getTime(chapter_timer) > 3500 + ms_ch then
                Timer.reset(chapter_timer)
            end
        else
            Graphics.fillRect(0, 88, 0, 80 * MenuFade, BACK_COLOR)
            Graphics.fillRect(960 - 88 - 32 - 24 - 32, 960, 0, 80 * MenuFade, BACK_COLOR)
        end
        if CursorFade >= 0 then
            local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
            local shift = 80 * (1 - MenuFade)
            for i = ks, ks + 1 do
                if CursorPoint.y > 272 then
                    Graphics.fillEmptyRect(CursorPoint.x - 20 - i, CursorPoint.x + 20 + i + 2, CursorPoint.y - 20 - i + shift, CursorPoint.y + 20 + i + 2 + shift, Color.new(255, 0, 51, 255 * CursorFade))
                else
                    Graphics.fillEmptyRect(CursorPoint.x - 20 - i, CursorPoint.x + 20 + i + 2, CursorPoint.y - 20 - i - shift, CursorPoint.y + 20 + i + 2 - shift, Color.new(255, 0, 51, 255 * CursorFade))
                end
            end
        end
    end
end

function Reader.loadChapter(chapter)
    STATE = STATE_LOADING
    if not Chapters[chapter] then
        Console.error("Error loading chapter")
        exit()
        return
    end
    if Chapters and Chapters[current_chapter] then
        ParserManager.remove(Chapters[current_chapter].Pages)
    end
    current_chapter = chapter
    Chapters[chapter].Pages = {}
    Pages = {
        Page = 0
    }
    collectgarbage("collect")
    if ChapterSaver.check(Chapters[chapter]) then
        Chapters[chapter].Pages = ChapterSaver.getChapter(Chapters[chapter])
    else
        ParserManager.prepareChapter(Chapters[chapter], Chapters[chapter].Pages)
    end
    Timer.reset(chapter_timer)
    Timer.reset(name_timer)
end

function Reader.updateSettings()
    local settings = CuSettings.load(Chapters[1].Manga)
    local old_read_dir = readDirection
    if settings then
        readDirection = settings.ReaderDirection == "Default" and Settings.ReaderDirection or settings.ReaderDirection
        is_down = readDirection == "DOWN"
        orientation = settings.Orientation == "Default" and Settings.Orientation or settings.Orientation
        autozoom = settings.ZoomReader == "Default" and Settings.ZoomReader or settings.ZoomReader
    end
    if old_read_dir == "LEFT" and readDirection ~= old_read_dir or (old_read_dir == "RIGHT" or old_read_dir == "DOWN") and readDirection == "LEFT" then
        if Pages and Pages.Count and Pages.Page and Pages.PrevPage then
            local i, j = 1, Pages.Count
            while i < j do
                Pages[i], Pages[j] = Pages[j], Pages[i]
                i = i + 1
                j = j - 1
            end
            local zpage = Pages[0]
            if Pages[#Pages].Link == "LoadNext" or Pages[#Pages].Link == "LoadPrev" then
                Pages[0] = Pages[#Pages]
                Pages[#Pages] = nil
            end
            if zpage then
                Pages[#Pages + 1] = zpage
                if Pages[0] == zpage then
                    Pages[0] = nil
                end
            end
            Pages.Page = Pages.Count - Pages.Page + 1
            Pages.PrevPage = Pages.Count - Pages.PrevPage + 1
        end
    end
    updateMeasurements()
end

function Reader.load(chapters, num)
    if not chapters[1] then
        Console.error("Error loading chapter")
        AppMode = MENU
        return
    end
    local settings = CuSettings.load(chapters[1].Manga)
    if settings then
        readDirection = settings.ReaderDirection == "Default" and Settings.ReaderDirection or settings.ReaderDirection
        is_down = readDirection == "DOWN"
        orientation = settings.Orientation == "Default" and Settings.Orientation or settings.Orientation
        autozoom = settings.ZoomReader == "Default" and Settings.ZoomReader or settings.ZoomReader
    end
    Chapters = chapters
    StartPage = Cache.getBookmark(chapters[num])
    if StartPage == true or StartPage == nil then
        StartPage = 1
    end
    Reader.loadChapter(num)
end
