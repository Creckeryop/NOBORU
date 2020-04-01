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

local hideCounterTimer = Timer.new()

local doubleClickTimer = Timer.new()
local last_click = {x = -100, y = -100}
local gesture_zoom = false

local function gesture_touch_input(touch, oldtouch, page)
    if Settings.DoubleTapReader then
        if gesture_zoom then
            touchMode = TOUCH_IDLE
        end
        if not page or not page.Zoom then
            return
        end
        if touch.x == nil and oldtouch.x ~= nil and not gesture_zoom and touchMode == TOUCH_READ then
            gesture_zoom = false
            local update_last = true
            if Timer.getTime(doubleClickTimer) < 300 then
                local len = math.sqrt((last_click.x - oldtouch.x) * (last_click.x - oldtouch.x) + (last_click.y - oldtouch.y) * (last_click.y - oldtouch.y))
                if len < 80 then
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
    else
        ParserManager.remove(Pages[page])
        Threads.remove(Pages[page])
    end
end

---@param page integer
local function changePage(page)
    if page < 0 and current_chapter > 1 or page > #Pages then
        return false
    end
    local prev_page = Pages.Page
    Pages.Page = page
    Pages.PrevPage = prev_page
    if Pages[Pages.Page].Link == "LoadNext" or Pages[Pages.Page].Link == "LoadPrev" then
        return true
    end
    local o = {0}
    for k = 1, #o do
        local p = page + o[k]
        if p > 0 and p <= #Pages then
            if not Pages[p].Image and not (Pages[p].Link == "LoadPrev" or Pages[p].Link == "LoadNext") then
                if Pages[p].Extract then
                    local new_page = Pages[p]
                    Threads.insertTask(new_page, {
                        Type = "UnZipFile",
                        Path = new_page.Path,
                        Extract = new_page.Extract,
                        DestPath = "ux0:data/noboru/cache.image",
                        OnComplete = function()
                            Threads.insertTask(new_page, {
                                Type = "Image",
                                Table = new_page,
                                Path = "cache.image",
                                Index = "Image"
                            })
                        end
                    })
                elseif Pages[p].Path then
                    Threads.insertTask(Pages[p], {
                        Type = "Image",
                        Path = Pages[p].Path,
                        Table = Pages[p],
                        Index = "Image"
                    })
                elseif Pages[p].Link then
                    Threads.insertTask(Pages[p], {
                        Type = "ImageDownload",
                        Link = Pages[p].Link,
                        Table = Pages[p],
                        Index = "Image"
                    })
                else
                    ParserManager.loadPageImage(Chapters[current_chapter].Manga.ParserID, Pages[p][1], Pages[p], p, true)
                end
            end
        end
    end
    for i = page - 2, page + 2, 4 do
        if i > 0 and i <= #Pages then
            deletePageImage(i)
            Pages[i] = {
                Pages[i][1],
                Link = Pages[i].Link,
                Path = Pages[i].Path,
                Extract = Pages[i].Extract,
                x = 0,
                y = 0
            }
        end
    end
    return true
end

local function changeOrientation()
    if orientation == "Vertical" then
        orientation = "Horizontal"
    else
        orientation = "Vertical"
    end
    for i = 1, #Pages do
        Pages[i].Zoom = nil
    end
end

local buttonTimer = Timer.new()
local buttonTimeSpace = 800

---@param direction string | '"LEFT"' | '"RIGHT"'
---Turns the page according to the `direction`
local function swipe(direction)
    if orientation == "Horizontal" then
        if direction == "LEFT" then
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
        elseif direction == "RIGHT" then
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
    elseif orientation == "Vertical" then
        if direction == "LEFT" then
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
        elseif direction == "RIGHT" then
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

function Reader.input(oldpad, pad, oldtouch, touch, OldTouch2, Touch2)
    if Controls.check(pad, SCE_CTRL_CIRCLE) then
        if Pages.Page > 0 then
            local bookmark
            if Settings.ReaderDirection == "LEFT" then
                bookmark = Pages.Count - Pages.Page + 1
            elseif Settings.ReaderDirection == "RIGHT" then
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
        for i = 1, #Pages do
            Threads.remove(Pages[i])
        end
        Pages = {
            Page = 0
        }
        ParserManager.clear()
        collectgarbage("collect")
        AppMode = MENU
    end
    if STATE == STATE_READING and Pages[Pages.Page] then
        if touch.x ~= nil or pad ~= 0 then
            Timer.reset(hideCounterTimer)
        end
        gesture_touch_input(touch, oldtouch, Pages[Pages.Page])
        local page = Pages[Pages.Page]
        if page.Zoom then
            local x, y = Controls.readLeftAnalog()
            x = x - 127
            y = y - 127
            if math.abs(x) > SCE_LEFT_STICK_DEADZONE then
                page.x = page.x - SCE_LEFT_STICK_SENSITIVITY * 25 * (x - SCE_LEFT_STICK_DEADZONE * math.sign(x)) / (128-SCE_LEFT_STICK_DEADZONE)
            end
            if math.abs(y) > SCE_LEFT_STICK_DEADZONE then
                page.y = page.y - SCE_LEFT_STICK_SENSITIVITY * 25 * (y - SCE_LEFT_STICK_DEADZONE * math.sign(y)) / (128-SCE_LEFT_STICK_DEADZONE)
            end
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
        if math.abs(offset.x) < 80 and math.abs(offset.y) < 80 then
            if not (Controls.check(pad, SCE_CTRL_RIGHTPAGE) or Controls.check(pad, SCE_CTRL_LEFTPAGE) or (Settings.ChangingPageButtons == "DPAD" and (Controls.check(pad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP)))) then
                buttonTimeSpace = 800
            end
            local right_page_button = Settings.ChangingPageButtons == "DPAD" and orientation == "Vertical" and SCE_CTRL_DOWN or SCE_CTRL_RIGHTPAGE
            local left_page_button = Settings.ChangingPageButtons == "DPAD" and orientation == "Vertical" and SCE_CTRL_UP or SCE_CTRL_LEFTPAGE
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
            local x, y = Controls.readRightAnalog()
            if orientation == "Horizontal" then
                y = y - 127
                if math.abs(y) > SCE_RIGHT_STICK_DEADZONE then
                    y = (y - SCE_RIGHT_STICK_DEADZONE * math.sign(y)) / (128-SCE_RIGHT_STICK_DEADZONE)
                    scale(1 - SCE_LEFT_STICK_SENSITIVITY * y * 0.05, page)
                end
            elseif orientation == "Vertical" then
                x = x - 127
                if math.abs(x) > SCE_RIGHT_STICK_DEADZONE then
                    x = (x - SCE_RIGHT_STICK_DEADZONE * math.sign(x)) / (128-SCE_RIGHT_STICK_DEADZONE)
                    scale(1 + SCE_LEFT_STICK_SENSITIVITY * x * 0.05, page)
                end
            end
        end
        if touch.y and oldtouch.y then
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
        else
            if touchMode == TOUCH_SWIPE then
                if offset.x > 90 or offset.y > 90 then
                    swipe("RIGHT")
                elseif offset.x < -90 or offset.y < -90 then
                    swipe("LEFT")
                end
                velX = 0
                velY = 0
                pageMode = PAGE_NONE
            end
            if touchMode ~= TOUCH_LOCK then
                touchMode = TOUCH_IDLE
            end
        end
        if touchMode == TOUCH_READ then
            local len = math.sqrt((touchTemp.x - touch.x) * (touchTemp.x - touch.x) + (touchTemp.y - touch.y) * (touchTemp.y - touch.y))
            if len > 10 then
                if orientation == "Horizontal" then
                    if not page.Zoom or (page.Height * page.Zoom < 545 or math.abs(touch.x - touchTemp.x) > math.abs(touch.y - touchTemp.y) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.x > touch.x) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.x < touch.x)) then
                        touchMode = TOUCH_SWIPE
                    else
                        touchMode = TOUCH_MOVE
                    end
                elseif orientation == "Vertical" then
                    if not page.Zoom or (page.Height * page.Zoom < 961 or math.abs(touch.y - touchTemp.y) > math.abs(touch.x - touchTemp.x) * 1.5) and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.y > touch.y) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.y < touch.y)) then
                        touchMode = TOUCH_SWIPE
                    else
                        touchMode = TOUCH_MOVE
                    end
                end
            end
        end
    end
end

local counterShift = 0

function Reader.update()
    if STATE == STATE_LOADING then
        if Chapters[current_chapter].Pages.Done then
            if #Chapters[current_chapter].Pages == 0 then
                Console.error("Error loading chapter")
                ParserManager.clear()
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
            if Settings.ReaderDirection == "RIGHT" then
                for i = 1, #chapter.Pages do
                    Pages[#Pages + 1] = {
                        chapter.Pages[i],
                        Path = chapter.Pages[i].Path,
                        Extract = chapter.Pages[i].Extract,
                        x = 0,
                        y = 0
                    }
                end
            elseif Settings.ReaderDirection == "LEFT" then
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
            if Settings.ReaderDirection == "RIGHT" then
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
            elseif Settings.ReaderDirection == "LEFT" then
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
        if Pages.PrevPage and Pages.PrevPage ~= Pages.Page and ((offset.x >= 0 and Pages.PrevPage > Pages.Page or offset.x <= 0 and Pages.PrevPage < Pages.Page) and orientation == "Horizontal" or (offset.y >= 0 and Pages.PrevPage > Pages.Page or offset.y <= 0 and Pages.PrevPage < Pages.Page) and orientation == "Vertical") then
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
                            DestPath = "ux0:data/noboru/cache.image",
                            OnComplete = function()
                                Threads.insertTask(new_page, {
                                    Type = "Image",
                                    Table = new_page,
                                    Path = "cache.image",
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
        local o = Settings.ReaderDirection == "LEFT" and {1, -1, 0} or {-1, 1, 0}
        for _, i in ipairs(o) do
            local page = Pages[Pages.Page + i]
            if page and not page.Zoom and page.Image then
                local Image = page.Image
                if orientation == "Horizontal" then
                    page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 + i * 960, 272
                    Console.write("Added " .. Pages.Page + i)
                    if Settings.ZoomReader == "Smart" then
                        if page.Width > page.Height then
                            page.Zoom = 544 / page.Height
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
                        else
                            page.Zoom = 960 / page.Width
                        end
                    elseif Settings.ZoomReader == "Width" then
                        page.Zoom = 960 / page.Width
                    elseif Settings.ZoomReader == "Height" then
                        page.Zoom = 544 / page.Height
                    end
                    page.min_Zoom = math.min(544 / page.Height, 960 / page.Width)
                    if page.Zoom * page.Height > 544 then
                        page.y = page.Zoom * page.Height / 2
                    end
                    page.start_Zoom = page.Zoom
                elseif orientation == "Vertical" then
                    page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480, 272 + i * 544
                    Console.write("Added " .. Pages.Page + i)
                    if Settings.ZoomReader == "Smart" then
                        if page.Width > page.Height then
                            page.Zoom = 960 / page.Height
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
                        else
                            page.Zoom = 544 / page.Width
                        end
                    elseif Settings.ZoomReader == "Width" then
                        page.Zoom = 544 / page.Width
                    elseif Settings.ZoomReader == "Height" then
                        page.Zoom = 960 / page.Height
                    end
                    page.min_Zoom = math.min(960 / page.Height, 544 / page.Width)
                    if page.Zoom * page.Height > 960 then
                        page.x = 960 - (page.Zoom * page.Height) / 2
                    end
                    page.start_Zoom = page.Zoom
                end
            end
        end
        if touchMode == TOUCH_IDLE or touchMode == TOUCH_MOVE then
            local page = Pages[Pages.Page]
            if page and page.Zoom then
                page.x = page.x + velX
                page.y = page.y + velY
            end
            if touchMode == TOUCH_IDLE then
                velY = velY * 0.9
                velX = velX * 0.9
            end
        elseif touchMode == TOUCH_SWIPE then
            if orientation == "Horizontal" then
                offset.x = offset.x + velX
                if offset.x > 0 and not Pages[Pages.Page - 1] then
                    offset.x = 0
                elseif offset.x < 0 and Pages.Page == #Pages then
                    offset.x = 0
                end
            elseif orientation == "Vertical" then
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
            if orientation == "Vertical" then
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
        elseif orientation == "Vertical" then
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
        if Timer.getTime(hideCounterTimer) > 1500 then
            counterShift = math.max(counterShift - 1.5, -30)
        else
            counterShift = math.min(counterShift + 1.5, 0)
        end
    end
end

function Reader.draw()
    Screen.clear(COLOR_BACK)
    if STATE == STATE_LOADING then
        local manga_name = Chapters[current_chapter].Manga.Name
        local prepare_message = Language[Settings.Language].READER.PREPARING_PAGES .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
        local chapter_name = Chapters[current_chapter].Name
        if Font.getTextWidth(BONT30, manga_name) > 960 then
            if Font.getTextWidth(FONT16, manga_name) > 960 then
                Font.print(FONT12, 480 - Font.getTextWidth(FONT12, manga_name) / 2, 247, manga_name, COLOR_FONT)
            else
                Font.print(FONT16, 480 - Font.getTextWidth(FONT16, manga_name) / 2, 242, manga_name, COLOR_FONT)
            end
        else
            Font.print(BONT30, 480 - Font.getTextWidth(BONT30, manga_name) / 2, 232, manga_name, COLOR_FONT)
        end
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, chapter_name) / 2, 264, chapter_name, COLOR_FONT)
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, prepare_message) / 2, 284, prepare_message, COLOR_FONT)
    elseif STATE == STATE_READING then
        local o = Settings.ReaderDirection == "LEFT" and {1, -1, 0} or {-1, 1, 0}
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
                if orientation == "Horizontal" then
                    local loading = Language[Settings.Language].READER.LOADING_PAGE .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                    local Width = Font.getTextWidth(FONT16, loading)
                    Font.print(FONT16, offset.x + 960 * i + 480 - Width / 2, 272 - 10, loading, COLOR_FONT)
                elseif orientation == "Vertical" then
                    local loading = Language[Settings.Language].READER.LOADING_PAGE .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                    local Width = Font.getTextWidth(FONT16, loading)
                    Font.print(FONT16, 960 / 2 - Width / 2, 272 + offset.y + 544 * i - 10, loading, COLOR_FONT)
                end
            end
        end
        if Pages.Page <= (Pages.Count or 0) and Pages.Page > 0 then
            local Counter = Pages.Page .. "/" .. Pages.Count
            if Settings.ReaderDirection == "LEFT" then
                Counter = (Pages.Count - Pages.Page + 1) .. "/" .. Pages.Count
            end
            local Width = Font.getTextWidth(FONT16, Counter) + 20
            Graphics.fillRect(960 - Width, 960, counterShift, counterShift + Font.getTextHeight(FONT16, Counter) + 4, Color.new(0, 0, 0, 128))
            Font.print(FONT16, 970 - Width, counterShift, Counter, COLOR_WHITE)
        end
    end
end

function Reader.loadChapter(chapter)
    STATE = STATE_LOADING
    current_chapter = chapter
    for i = 1, #Pages do
        Threads.remove(Pages[i])
    end
    if not Chapters[chapter] then
        Console.error("Error loading chapter")
        ParserManager.clear()
        collectgarbage("collect")
        AppMode = MENU
        return
    end
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
end

function Reader.load(chapters, num)
    orientation = Settings.Orientation
    Chapters = chapters
    StartPage = Cache.getBookmark(chapters[num])
    if StartPage == true or StartPage == nil then
        StartPage = 1
    end
    Reader.loadChapter(num)
end
