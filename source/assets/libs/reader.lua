local Pages = {Page = 0}
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
local CurrentChapter = 1

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
    else
        ParserManager.Remove(Pages[page])
        threads.Remove(Pages[page])
    end
end

local orderPageLoad = {-1, 1, 0}

local ChangePage = function(page)
    if page < 0 and CurrentChapter > 1 or page > #Pages then
        return false
    end
    Pages.Page = page
    if Pages[Pages.Page].Link == "LoadNext" or Pages[Pages.Page].Link == "LoadPrev" then
        return true
    end
    for k = 1, 3 do
        local o = orderPageLoad
        local i = o[k]
        if page + i > 0 and page + i <= #Pages then
            if Pages[page + i].Image == nil and not (Pages[page + i].Link == "LoadPrev" or Pages[page + i].Link == "LoadNext") then
                if Pages[page + i].Link then
                    threads.DownloadImageAsync(Pages[page + i].Link, Pages[page + i], "Image", true)
                else
                    ParserManager.getPageImage(Chapters[CurrentChapter].Manga.ParserID, Pages[page + i][1], Pages[page + i], true)
                end
            end
        end
    end
    if page - 2 > 0 then
        deletePageImage(page - 2)
        Pages[page - 2] = {Pages[page - 2][1], Link = Pages[page - 2].Link, x = 0, y = 0}
    end
    if page + 2 < #Pages then
        deletePageImage(page + 2)
        Pages[page + 2] = {Pages[page + 2][1], Link = Pages[page + 2].Link, x = 0, y = 0}
    end
    return true
end

Reader = {
    Input = function(OldPad, Pad, OldTouch, Touch, OldTouch2, Touch2)
        if STATE == STATE_READING and Pages[Pages.Page] and Pages[Pages.Page].Zoom then
            if Controls.check(Pad, SCE_CTRL_RTRIGGER) then
                Scale(1.2, Pages[Pages.Page])
            elseif Controls.check(Pad, SCE_CTRL_LTRIGGER) then
                Scale(5 / 6, Pages[Pages.Page])
            end
        end
        if Controls.check(Pad, SCE_CTRL_CIRCLE) then
            for i = 1, #Pages do
                if Pages[i] then
                    Pages[i].Image = nil
                else
                    threads.Remove(Pages[i])
                end
            end
            Pages = {Page = 0}
            ParserManager.Clear()
            collectgarbage()
            APP_MODE = MENU
        end
        if Touch.y and OldTouch.y then
            if touchMode ~= TOUCH_MULTI then
                if touchMode == TOUCH_IDLE then
                    touchTemp.x = Touch.x
                    touchTemp.y = Touch.y
                    touchMode = TOUCH_READ
                end
                velX = Touch.x - OldTouch.x
                velY = Touch.y - OldTouch.y
            end
            local page = Pages[Pages.Page]
            if Touch2.x and OldTouch2.x and page.Zoom then
                touchMode = TOUCH_MULTI
                local old_Zoom = page.Zoom
                local center = {x = (Touch.x + Touch2.x) / 2, y = (Touch.y + Touch2.y) / 2}
                local n = (math.sqrt((Touch.x - Touch2.x) * (Touch.x - Touch2.x) + (Touch.y - Touch2.y) * (Touch.y - Touch2.y)) / math.sqrt((OldTouch.x - OldTouch2.x) * (OldTouch.x - OldTouch2.x) + (OldTouch.y - OldTouch2.y) * (OldTouch.y - OldTouch2.y)))
                Scale(n, page)
                n = page.Zoom / old_Zoom
                page.y = page.y - (center.y - 272) * (n - 1)
                page.x = page.x - (center.x - 480) * (n - 1)
            end
        else
            if touchMode == TOUCH_SWIPE then
                local old_page = Pages.Page
                if offset.x > 90 and ChangePage(Pages.Page - 1) then
                    offset.x = -960 + offset.x
                    local page = Pages[Pages.Page + 1]
                    if page and page.Zoom then
                        if (page.Mode ~= "Horizontal" and page.Zoom >= 960 / page.Width) or page.Zoom * page.Width >= 960 then
                            page.x = 960 + page.Width * page.Zoom / 2
                        else
                            page.x = 960 + 480
                        end
                    end
                    PageChanged = old_page
                elseif offset.x < -90 and ChangePage(Pages.Page + 1) then
                    offset.x = 960 + offset.x
                    local page = Pages[Pages.Page - 1]
                    if page and page.Zoom then
                        if (page.Mode ~= "Horizontal" and page.Zoom >= 960 / page.Width) or page.Zoom * page.Width >= 960 then
                            page.x = -page.Width * page.Zoom / 2
                        else
                            page.x = -480
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
            Pages[Pages.Page].y = Pages[Pages.Page].y + 5 * Pages[Pages.Page].Zoom
        elseif Controls.check(Pad, SCE_CTRL_DOWN) then
            Pages[Pages.Page].y = Pages[Pages.Page].y - 5 * Pages[Pages.Page].Zoom
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
            if Chapters[CurrentChapter].Pages.Done then
                STATE = STATE_READING
                local chapter = Chapters[CurrentChapter]
                Pages.Count = #chapter.Pages
                for i = 1, #chapter.Pages do
                    Pages[i] = {chapter.Pages[i], x = 0, y = 0}
                end
                Pages[0] = {Link = "LoadPrev", x = 0, y = 0}
                if CurrentChapter < #Chapters then
                    Pages[#Pages + 1] = {Link = "LoadNext", x = 0, y = 0}
                end
                ChangePage(1)
            else
            end
        elseif STATE == STATE_READING then
            if Pages[Pages.Page] == nil then
                return
            end
            for i = -1, 1 do
                local page = Pages[Pages.Page + i]
                if page and page.Zoom == nil and page.Image then
                    local Image = page.Image
                    if type(Image.e or Image) == "table" then
                        page.Width, page.Height, page.x, page.y = Image.Width, Image.Height, 480 + i * 960, 272
                    else
                        page.Width, page.Height, page.x, page.y = Graphics.getImageWidth(Image.e), Graphics.getImageHeight(Image.e), 480 + i * 960, 272
                    end
                    Console.writeLine("Added " .. Pages.Page + i)
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
                offset.x = offset.x + velX
                if offset.x > 0 and Pages.Page == 1 and CurrentChapter == 1 then
                    offset.x = 0
                end
                if offset.x < 0 and Pages.Page == #Pages then
                    offset.x = 0
                end
            end
            if touchMode ~= TOUCH_SWIPE then
                offset.x = offset.x / 1.3
                if math.abs(offset.x) < 1 then
                    offset.x = 0
                    if Pages[Pages.Page] and Pages[Pages.Page].Link == "LoadNext" then
                        Reader.loadChapter(CurrentChapter + 1)
                        return
                    end
                    if Pages[Pages.Page] and Pages[Pages.Page].Link == "LoadPrev" then
                        Reader.loadChapter(CurrentChapter - 1)
                        return
                    end
                    if PageChanged then
                        if PageChanged ~= Pages.Page and Pages[PageChanged] and Pages[PageChanged].Image and type(Pages[PageChanged].Image.e or Pages[PageChanged].Image) =="table" then
                            deletePageImage(PageChanged)
                            if math.abs(PageChanged-Pages.Page) == 1 and Pages[PageChanged].Link ~= "LoadNext" and Pages[PageChanged].Link ~= "LoadPrev" then
                                if Pages[PageChanged].Link then
                                    threads.DownloadImageAsync(Pages[PageChanged].Link, Pages[PageChanged], "Image")
                                else
                                    ParserManager.getPageImage(Chapters[CurrentChapter].Manga.ParserID, Pages[PageChanged][1], Pages[PageChanged])
                                end
                            end
                        end
                        PageChanged = nil
                    end
                end
            end
            local page = Pages[Pages.Page]
            if page.Zoom then
                if page.y - page.Height / 2 * page.Zoom > 0 then
                    page.y = page.Height / 2 * page.Zoom
                elseif page.y + page.Height / 2 * page.Zoom < 544 then
                    page.y = 544 - page.Height / 2 * page.Zoom
                end
                if (page.Mode ~= "Horizontal" and page.Zoom >= 960 / page.Width) or page.Zoom * page.Width > 960 then
                    if page.Zoom * page.Width <= 960 or page.Zoom == page.min_Zoom and page.Mode ~= "Horizontal" then
                        pageMode = bit32.bor(PAGE_LEFT, PAGE_RIGHT)
                    end
                    if page.x - page.Width / 2 * page.Zoom >= 0 then
                        page.x = page.Width / 2 * page.Zoom
                        pageMode = bit32.bor(pageMode, PAGE_LEFT)
                    elseif page.x + page.Width / 2 * page.Zoom <= 960 then
                        page.x = 960 - page.Width / 2 * page.Zoom
                        pageMode = bit32.bor(pageMode, PAGE_RIGHT)
                    else
                        pageMode = PAGE_NONE
                    end
                else
                    page.x = 480
                    pageMode = bit32.bor(PAGE_LEFT, PAGE_RIGHT)
                end
            else
                pageMode = bit32.bor(PAGE_LEFT, PAGE_RIGHT)
            end
        end
    end,
    Draw = function()
        Screen.clear(COLOR_WHITE)
        if STATE == STATE_LOADING then
            local MangaName = Chapters[CurrentChapter].Manga.Name
            local PrepareMessage = Language[LANG].READER.PREPARING_PAGES.. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
            local ChapterName = Chapters[CurrentChapter].Name
            if Font.getTextWidth(FONT26, MangaName) > 960 then
                if Font.getTextWidth(FONT, MangaName) > 960 then
                    Font.print(FONT12, 480 - Font.getTextWidth(FONT12, MangaName) / 2, 247, MangaName, COLOR_BLACK)
                else
                    Font.print(FONT, 480 - Font.getTextWidth(FONT, MangaName) / 2, 242, MangaName, COLOR_BLACK)
                end
            else
                Font.print(FONT26, 480 - Font.getTextWidth(FONT26, MangaName) / 2, 232, MangaName, COLOR_BLACK)
            end
            Font.print(FONT, 480 - Font.getTextWidth(FONT, ChapterName) / 2, 264, ChapterName, COLOR_BLACK)
            Font.print(FONT, 480 - Font.getTextWidth(FONT, PrepareMessage) / 2, 284, PrepareMessage, COLOR_BLACK)
        elseif STATE == STATE_READING then
            for i = -1, 1 do
                local page = Pages[Pages.Page + i]
                if page and page.Image then
                    if type(page.Image.e or page.Image) == "table" then
                        for k = 1, page.Image.Parts do
                            if page.Image[k] and page.Image[k].e then
                                local Height = Graphics.getImageHeight(page.Image[k].e)
                                local x, y = math.ceil((offset.x + page.x) * 4) / 4, offset.y + page.y + (k - 1) * page.Image.part_h * page.Zoom - page.Height / 2 * page.Zoom + page.Image.part_h / 2 * page.Zoom
                                Graphics.fillRect(x-page.Width/2*page.Zoom,x+page.Width/2*page.Zoom,y-Height/2*page.Zoom,y+Height/2*page.Zoom,COLOR_BLACK)
                                Graphics.drawImageExtended(x, y, page.Image[k].e, 0, 0, page.Width, Height, 0, page.Zoom, page.Zoom)
                            else
                                local loading = Language[LANG].READER.LOADING_SEGMENT .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                                local Width = Font.getTextWidth(FONT, loading)
                                Font.print(FONT, offset.x + 960 * i + 480 - Width / 2, offset.y + page.y + (k - 1) * page.Image.part_h * page.Zoom - page.Height / 2 * page.Zoom + 10 * page.Zoom, loading, COLOR_BLACK)
                            end
                        end
                    else
                        local x, y = math.ceil((offset.x + page.x) * 4) / 4, math.ceil((offset.y + page.y) * 4) / 4
                        Graphics.fillRect(x - page.Width / 2 * page.Zoom, x + page.Width / 2 * page.Zoom, y - page.Height / 2 * page.Zoom,y + page.Height / 2 * page.Zoom, COLOR_BLACK)
                        Graphics.drawImageExtended(x, y, page.Image.e, 0, 0, page.Width, page.Height, 0, page.Zoom, page.Zoom)
                    end
                elseif page then
                    local loading = Language[LANG].READER.LOADING_PAGE .. string.sub("...", 1, math.ceil(Timer.getTime(GlobalTimer) / 250) % 4)
                    local Width = Font.getTextWidth(FONT, loading)
                    Font.print(FONT, offset.x + 960 * i + 480 - Width / 2, 272 - 10, loading, COLOR_BLACK)
                end
            end
            if Pages.Page <= (Pages.Count or 0) and Pages.Page > 0 then
                local Counter = Pages.Page .. "/" .. Pages.Count
                local Width = Font.getTextWidth(FONT, Counter) + 20
                Graphics.fillRect(960 - Width, 960, 0, Font.getTextHeight(FONT, Counter) + 5, Color.new(0, 0, 0, 128))
                Font.print(FONT, 970 - Width, 0, Counter, COLOR_WHITE)
            end
        end
    end,
    loadChapter = function(chapter)
        STATE = STATE_LOADING
        CurrentChapter = chapter
        for i = 1, #Pages do
            if Pages[i] then
                Pages[i].Image = nil
            else
                threads.Remove(Pages[i])
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
