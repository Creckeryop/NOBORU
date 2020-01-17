local Pages = {page = 0}
local velX, velY = 0, 0

local TOUCH_IDLE = 0
local TOUCH_MULTI = 1
local TOUCH_MOVE = 2
local TOUCH_READ = 3
local TOUCH_SWIPE = 4
local touchMode = TOUCH_IDLE

local PAGE_NONE = 0
local PAGE_LEFT = 1
local PAGE_RIGHT = 2
local pageMode = PAGE_NONE

local STATE_LOADING = 0
local STATE_READING = 1
local STATE = STATE_LOADING

local max_Zoom = 3

local offset = {x = 0, y = 0}
local touchTemp = {x = 0, y = 0}

local Chapters = {}
local current_chapter = 1

local PageChanged = nil

local Scale = function(dZoom, Page)
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
    ParserManager.Remove(Pages[page])
    threads.Remove(Pages[page], "Image")
    if Pages[page].Image then
        if type(Pages[page].Image.e or Pages[page].Image) == "table" then
            for i = 1, Pages[page].Image.Parts do
                if Pages[page].Image[i] and Pages[page].Image[i].e then
                    Graphics.freeImage(Pages[page].Image[i].e)
                    Pages[page].Image[i].e = nil
                end
            end
        else
            if Pages[page].Image.e then
                Graphics.freeImage(Pages[page].Image.e)
                Pages[page].Image.e = nil
            end
        end
        Pages[page].Image = nil
    end
end

local orderPageLoad = {0,1,-1}

local ChangePage = function(page)
    if page < 0 and current_chapter > 1 or page > #Pages then
        return false
    end
    Pages.page = page
    if Pages[Pages.page].Link == "loadnext" or Pages[Pages.page].Link == "loadprev" then
        return true
    end
    for k = 1, 3 do
        local o = orderPageLoad
        local i = o[k]
        if page + i > 0 and page + i <= #Pages then
            if Pages[page + i].Image == nil and not (Pages[page + i].Link == "loadprev" or Pages[page + i].Link == "loadnext") then
                if Pages[page + i].Link then
                    threads.DownloadImageAsync(Pages[page + i].Link, Pages[page + i], "Image")
                else
                    ParserManager.getPageImage(Chapters[current_chapter].Manga.ParserID, Pages[page + i][1], Pages[page + i], true)
                end
            end
        end
    end
    if page - 2 > 0 then
        deletePageImage(page - 2)
        Pages[page - 2] = {Pages[page - 2][1],Link = Pages[page - 2].Link, x = 0, y = 0}
    end
    if page + 2 < #Pages then
        deletePageImage(page + 2)
        Pages[page + 2] = {Pages[page + 2][1],Link = Pages[page + 2].Link, x = 0, y = 0}
    end
    return true
end

Reader = {
    Input = function(OldPad, Pad, OldTouch, Touch, OldTouch2, Touch2)
        if Controls.check(Pad, SCE_CTRL_RTRIGGER) then
            Scale(1.2, Pages[Pages.page])
        elseif Controls.check(Pad, SCE_CTRL_LTRIGGER) then
            Scale(5 / 6, Pages[Pages.page])
        end
        if Controls.check(Pad, SCE_CTRL_CIRCLE) then
            for i = 1, #Pages do
                if Pages[i] ~= nil then
                    threads.Remove(Pages[i], "Image")
                    Pages[i].Image = nil
                end
            end
            Pages = {page = 0}
            ParserManager.Clear()
            collectgarbage()
            APP_MODE = MENU
        end
        if Touch.y ~= nil and OldTouch.y ~= nil then
            if touchMode ~= TOUCH_MULTI then
                if touchMode == TOUCH_IDLE then
                    touchTemp.x = Touch.x
                    touchTemp.y = Touch.y
                    touchMode = TOUCH_READ
                end
                velX = Touch.x - OldTouch.x
                velY = Touch.y - OldTouch.y
            end
            if Touch2.x ~= nil and OldTouch2.x ~= nil and Pages[Pages.page].Zoom ~= nil then
                touchMode = TOUCH_MULTI
                local old_Zoom = Pages[Pages.page].Zoom
                local center = {x = (Touch.x + Touch2.x) / 2, y = (Touch.y + Touch2.y) / 2}
                local n = (math.sqrt((Touch.x - Touch2.x) * (Touch.x - Touch2.x) + (Touch.y - Touch2.y) * (Touch.y - Touch2.y)) / math.sqrt((OldTouch.x - OldTouch2.x) * (OldTouch.x - OldTouch2.x) + (OldTouch.y - OldTouch2.y) * (OldTouch.y - OldTouch2.y)))
                Scale(n, Pages[Pages.page])
                n = Pages[Pages.page].Zoom / old_Zoom
                Pages[Pages.page].y = Pages[Pages.page].y - (center.y - 272) * (n - 1)
                Pages[Pages.page].x = Pages[Pages.page].x - (center.x - 480) * (n - 1)
            end
        else
            if touchMode == TOUCH_SWIPE then
                local old_page = Pages.page
                if offset.x > 90 and ChangePage(Pages.page - 1) then
                    offset.x = -960 + offset.x
                    if Pages[Pages.page + 1] ~= nil and Pages[Pages.page + 1].Zoom ~= nil then
                        if (Pages[Pages.page + 1].Mode ~= "Horizontal" and Pages[Pages.page + 1].Zoom >= 960 / Pages[Pages.page + 1].Width) or Pages[Pages.page + 1].Zoom * Pages[Pages.page + 1].Width >= 960 then
                            Pages[Pages.page + 1].x = 960 + Pages[Pages.page + 1].Width * Pages[Pages.page + 1].Zoom / 2
                        else
                            Pages[Pages.page + 1].x = 960 + 480
                        end
                    end
                    PageChanged = old_page
                elseif offset.x < -90 and ChangePage(Pages.page + 1) then
                    offset.x = 960 + offset.x
                    if Pages[Pages.page - 1] ~= nil and Pages[Pages.page - 1].Zoom ~= nil then
                        if (Pages[Pages.page - 1].Mode ~= "Horizontal" and Pages[Pages.page - 1].Zoom >= 960 / Pages[Pages.page - 1].Width) or Pages[Pages.page - 1].Zoom * Pages[Pages.page - 1].Width >= 960 then
                            Pages[Pages.page - 1].x = -Pages[Pages.page - 1].Width * Pages[Pages.page - 1].Zoom / 2
                        else
                            Pages[Pages.page - 1].x = -480
                        end
                    end
                    PageChanged = old_page
                end
                velX = 0
                velY = 0
                pageMode = PAGE_NONE
            end
            touchMode = TOUCH_IDLE
        end
        if Controls.check(Pad, SCE_CTRL_UP) then
            Pages[Pages.page].y = Pages[Pages.page].y + 5 * Pages[Pages.page].Zoom
        elseif Controls.check(Pad, SCE_CTRL_DOWN) then
            Pages[Pages.page].y = Pages[Pages.page].y - 5 * Pages[Pages.page].Zoom
        end
        if touchMode == TOUCH_READ then
            local len = math.sqrt((touchTemp.x - Touch.x) * (touchTemp.x - Touch.x) + (touchTemp.y - Touch.y) * (touchTemp.y - Touch.y))
            if len > 10 then
                if math.abs(Touch.x - touchTemp.x) > math.abs(Touch.y - touchTemp.y) * 3 and ((bit32.band(pageMode, PAGE_RIGHT) ~= 0 and touchTemp.x > Touch.x) or (bit32.band(pageMode, PAGE_LEFT) ~= 0 and touchTemp.x < Touch.x)) then
                    touchMode = TOUCH_SWIPE
                else
                    touchMode = TOUCH_MOVE
                end
            end
        end
    end,
    Update = function(delta)
        if STATE == STATE_LOADING then
            if Chapters[current_chapter].Pages.Done then
                STATE = STATE_READING
                Pages.Count = #Chapters[current_chapter].Pages
                for i = 1, #Chapters[current_chapter].Pages do
                    Pages[i] = {Chapters[current_chapter].Pages[i], x = 0, y = 0}
                end
                Pages[0] = {Link = "loadprev", x = 0, y = 0}
                if current_chapter < #Chapters then
                    Pages[#Pages + 1] = {Link = "loadnext", x = 0, y = 0}
                end
                ChangePage(1)
            else
            end
        elseif STATE == STATE_READING then
            if Pages[Pages.page] == nil then
                return
            end
            for i = -1, 1 do
                local page = Pages[Pages.page + i]
                if page ~= nil and page.Zoom == nil and page.Image ~= nil then
                    local Image = page.Image
                    if type(Image.e or Image) == "table" then
                        page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 + i * 960, 272
                    else
                        page.Width, page.Height, page.x, page.y = Graphics.getImageWidth(Image.e), Graphics.getImageHeight(Image.e), 480 + i * 960, 272
                    end
                    Console.writeLine("Added " .. Pages.page + i)
                    if page.Width > page.Height then
                        page.Mode = "Horizontal"
                        page.Zoom = 544 / page.Height
                        page.min_Zoom = page.Zoom
                        if page.Width * page.Zoom >= 960 then
                            page.x = 480 + i * (480 + page.Width * page.Zoom / 2)
                        else
                            page.x = 480 + i * 960
                        end
                    else
                        page.Mode = "Vertical"
                        page.Zoom = 960 / page.Width
                        page.min_Zoom = page.Zoom / 2
                        page.x = 480 + i * 960
                    end
                    page.y = page.Zoom * page.Height / 2
                end
            end
            if touchMode == TOUCH_IDLE or touchMode == TOUCH_MOVE then
                local page = Pages[Pages.page]
                if page ~= nil and page.Zoom ~= nil then
                    page.x = page.x + velX
                    page.y = page.y + velY
                end
                if touchMode == TOUCH_IDLE then
                    velY = velY * 0.9
                    velX = velX * 0.9
                end
            elseif touchMode == TOUCH_SWIPE then
                offset.x = offset.x + velX
                if offset.x > 0 and Pages.page == 1 and current_chapter == 1 then
                    offset.x = 0
                end
                if offset.x < 0 and Pages.page == #Pages then
                    offset.x = 0
                end
            end
            if touchMode ~= TOUCH_SWIPE then
                offset.x = offset.x / 1.3
                if math.abs(offset.x) < 1 then
                    offset.x = 0
                    if Pages[Pages.page] and Pages[Pages.page].Link == "loadnext" then
                        Reader.loadChapter(current_chapter + 1)
                        return
                    end
                    if Pages[Pages.page] and Pages[Pages.page].Link == "loadprev" then
                        Reader.loadChapter(current_chapter - 1)
                        return
                    end
                    if PageChanged~=nil then
                        if PageChanged ~= Pages.page and Pages[PageChanged] and Pages[PageChanged].Image and type(Pages[PageChanged].Image.e or Pages[PageChanged].Image) =="table" then
                            deletePageImage(PageChanged)
                            if math.abs(PageChanged-Pages.page)==1 and Pages[PageChanged].Link ~= "loadnext" and Pages[PageChanged].Link ~= "loadprev" then
                                if Pages[PageChanged].Link then
                                    threads.DownloadImageAsync(Pages[PageChanged].Link, Pages[PageChanged], "Image")
                                else
                                    ParserManager.getPageImage(Chapters[current_chapter].Manga.ParserID, Pages[PageChanged][1], Pages[PageChanged])
                                end
                            end
                        end
                        PageChanged = nil
                    end
                end
            end
            if Pages[Pages.page].Zoom ~= nil then
                if Pages[Pages.page].y - Pages[Pages.page].Height / 2 * Pages[Pages.page].Zoom > 0 then
                    Pages[Pages.page].y = Pages[Pages.page].Height / 2 * Pages[Pages.page].Zoom
                elseif Pages[Pages.page].y + Pages[Pages.page].Height / 2 * Pages[Pages.page].Zoom < 544 then
                    Pages[Pages.page].y = 544 - Pages[Pages.page].Height / 2 * Pages[Pages.page].Zoom
                end
                if (Pages[Pages.page].Mode ~= "Horizontal" and Pages[Pages.page].Zoom >= 960 / Pages[Pages.page].Width) or Pages[Pages.page].Zoom * Pages[Pages.page].Width > 960 then
                    if Pages[Pages.page].Zoom * Pages[Pages.page].Width <= 960 or Pages[Pages.page].Zoom == Pages[Pages.page].min_Zoom and Pages[Pages.page].Mode ~= "Horizontal" then
                        pageMode = bit32.bor(PAGE_LEFT, PAGE_RIGHT)
                    end
                    if Pages[Pages.page].x - Pages[Pages.page].Width / 2 * Pages[Pages.page].Zoom >= 0 then
                        Pages[Pages.page].x = Pages[Pages.page].Width / 2 * Pages[Pages.page].Zoom
                        pageMode = bit32.bor(pageMode, PAGE_LEFT)
                    elseif Pages[Pages.page].x + Pages[Pages.page].Width / 2 * Pages[Pages.page].Zoom <= 960 then
                        Pages[Pages.page].x = 960 - Pages[Pages.page].Width / 2 * Pages[Pages.page].Zoom
                        pageMode = bit32.bor(pageMode, PAGE_RIGHT)
                    else
                        pageMode = PAGE_NONE
                    end
                else
                    Pages[Pages.page].x = 480
                    pageMode = bit32.bor(PAGE_LEFT, PAGE_RIGHT)
                end
            else
                pageMode = bit32.bor(PAGE_LEFT, PAGE_RIGHT)
            end
        end
    end,
    Draw = function()
        Screen.clear(Color.new(255,255,255))
        if STATE == STATE_LOADING then
            local loadingManga_Name = "Loading " .. Chapters[current_chapter].Manga.Name
            local loading = 'Loading Chapter ' .. Chapters[current_chapter].Name .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
            local Width = Font.getTextWidth(FONT, loading)
            local Width2 = Font.getTextWidth(FONT, loadingManga_Name)
            Font.print(FONT, 480 - Width / 2, 272 + 10, loading, Color.new(0,0,0))
            Font.print(FONT, 480 - Width2 / 2, 272 - 10, loadingManga_Name, Color.new(0,0,0))
        elseif STATE == STATE_READING then
            for i = -1, 1 do
                local page = Pages[Pages.page + i]
                if page ~= nil and page.Image ~= nil then
                    if (type(page.Image.e or page.Image) == "table") then
                        for k = 1, page.Image.Parts do
                            if page.Image[k] and page.Image[k].e ~= nil then
                                local Height = Graphics.getImageHeight(page.Image[k].e)
                                Graphics.drawImageExtended(math.ceil((offset.x + page.x) * 4) / 4, offset.y + page.y + (k - 1) * page.Image.part_h * page.Zoom - page.Height / 2 * page.Zoom + page.Image.part_h / 2 * page.Zoom, page.Image[k].e, 0, 0, page.Width, Height, 0, page.Zoom, page.Zoom)
                            else
                                local loading = "Loading segment" .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                                local Width = Font.getTextWidth(FONT, loading)
                                Font.print(FONT, offset.x + 960 * i + 480 - Width / 2, offset.y + page.y + (k - 1) * page.Image.part_h * page.Zoom - page.Height / 2 * page.Zoom + 10 * page.Zoom, loading, Color.new(0,0,0))
                            end
                        end
                    else
                        Graphics.drawImageExtended(math.ceil((offset.x + page.x) * 4) / 4, math.ceil((offset.y + page.y) * 4) / 4, page.Image.e, 0, 0, page.Width, page.Height, 0, page.Zoom, page.Zoom)
                    end
                elseif page ~= nil then
                    local loading = "Loading" .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                    local Width = Font.getTextWidth(FONT, loading)
                    Font.print(FONT, offset.x + 960 * i + 480 - Width / 2, 272 - 10, loading, Color.new(0,0,0))
                end
            end
            if Pages.page <= (Pages.Count or 0) and Pages.page > 0 then
                local Width = Font.getTextWidth(FONT, Pages.page .. "/" .. Pages.Count) + 20
                local Height = Font.getTextHeight(FONT, Pages.page .. "/" .. Pages.Count)
                Graphics.fillRect(960 - Width, 960, 0, Height + 5, Color.new(0, 0, 0, 128))
                Font.print(FONT, 960 - Width + 10, 0, Pages.page .. "/" .. Pages.Count, Color.new(255, 255, 255))
            end
        end
    end,
    loadChapter = function(chapter)
        STATE = STATE_LOADING
        current_chapter = chapter
        for i = 1, #Pages do
            threads.Remove(Pages[i], "Image")
            if Pages[i] then
                Pages[i].Image = nil
            end
        end
        Chapters[chapter].Pages = {}
        collectgarbage("collect")
        ParserManager.prepareChapter(Chapters[chapter], Chapters[chapter].Pages)
    end,
    load = function(chapters, num)
        Chapters = chapters
        Reader.loadChapter(num)
    end
}
