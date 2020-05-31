local mode = "END"

Extra = {}

local TOUCH = TOUCH()
local Slider = Slider()

local fade = 0
local old_fade = 1

local animation_timer = Timer.new()

local Chapters = {}
local Manga
ExtraMenu = {}

ExtraMenuNormal = {
    "DownloadAll",
    "RemoveAll",
    "CancelAll",
    "ClearBookmarks"
}

ExtraMenuNormalWithBrowser = {
    "OpenMangaInBrowser",
    "DownloadAll",
    "RemoveAll",
    "CancelAll",
    "ClearBookmarks",
}

ExtraMenuImported = {
    "ClearBookmarks"
}

ExtraMenuReader = {
    "OpenInBrowser",
    "ReaderOrientation",
    "ReaderDirection",
    "ZoomReader"
}

local w_max = 0
local y_srt = 0

local bookmarks_update = false

---Updates scrolling movement
local function scrollUpdate()
    Slider.Y = Slider.Y + Slider.V
    Slider.V = Slider.V / 1.12
    if math.abs(Slider.V) < 0.1 then
        Slider.V = 0
    end
    if Slider.Y < 0 then
        Slider.Y = 0
        Slider.V = 0
    elseif Slider.Y > #ExtraMenu * 80 - 544 then
        Slider.Y = math.max(0, #ExtraMenu * 80 - 544)
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
end

local ExtraSelector = Selector:new(-1, 1, 0, 0, function() return math.floor((Slider.Y + y_srt) / 80) end)
local Page = nil
local CustomSettings = {}
function Extra.setChapters(manga, chapters, page)
    if manga then
        bookmarks_update = false
        Manga = manga
        Chapters = chapters
        Slider.Y = -50
        if page then
            ExtraMenu = ExtraMenuReader
            Page = page
            CustomSettings = CuSettings.load(Manga)
        elseif manga.ParserID == "IMPORTED" then
            ExtraMenu = ExtraMenuImported
        else
            if Manga.BrowserLink then
                ExtraMenu = ExtraMenuNormalWithBrowser
            else
                ExtraMenu = ExtraMenuNormal
            end
        end
        ExtraSelector:resetSelected()
        mode = "START"
        old_fade = 1
        Timer.reset(animation_timer)
        w_max = 512
        y_srt = 272 - #ExtraMenu * 80 / 2
        for i = 1, #ExtraMenu do
            local w = Font.getTextWidth(BONT16, Language[Settings.Language].EXTRA[ExtraMenu[i]] or ExtraMenu[i]) + 40
            if w > w_max then
                w_max = w
            end
        end
    end
end


local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local callUri = System.executeUri
local extractZip = System.extractFromZip
local function press_action(id)
    if ExtraMenu[id] == "DownloadAll" then
        Cache.addManga(Manga)
        Cache.makeHistory(Manga)
        for i = 1, #Chapters do
            local chapter = Chapters[i]
            if not ChapterSaver.is_downloading(chapter) and not ChapterSaver.check(chapter) then
                ChapterSaver.downloadChapter(chapter, true)
            end
        end
    elseif ExtraMenu[id] == "RemoveAll" then
        ChapterSaver.stopList(Chapters, true)
        for i = 1, #Chapters do
            ChapterSaver.delete(Chapters[i], true)
        end
    elseif ExtraMenu[id] == "CancelAll" then
        ChapterSaver.stopList(Chapters, true)
    elseif ExtraMenu[id] == "ClearBookmarks" then
        Cache.clearBookmarks(Manga)
        bookmarks_update = true
    elseif ExtraMenu[id] == "OpenInBrowser" then
        if doesFileExist("ux0:data/noboru/temp/image.html") then
            deleteFile("ux0:data/noboru/temp/image.html")
        end
        local file = openFile("ux0:data/noboru/temp/image.html", FCREATE)
        if type(Page)=="table" then
            if Manga.ParserID == "IMPORTED" then
                extractZip("ux0:data/noboru/"..Page.Path, Page.Extract, "ux0:data/noboru/temp/page.image")
                Page = "file:///ux0:data/noboru/temp/page.image"
            elseif Page.Path then
                Page = "file:///ux0:data/noboru/"..Page.Path
            elseif type(Page.Link)=="string" then
                if Page.Link:find("$http") then
                    Page = Page.Link
                else
                    Page = "http://"..Page.Link
                end
            elseif type(Page.Link)=="table" then
                local img = {}
                Threads.insertTask(img, {
                    Type = "FileDownload",
                    Link = Page.Link,
                    Table = img
                })
                while Threads.check(img) do
                    Threads.update()
                end
                Page = "file:///ux0:data/noboru/temp/cache.image"
            else
                return
            end
        end
        local content = ([[
<html>
    <head>
    <title>%s</title>
    </head>
    <body style="background-color: black;">
        <div style="text-align: center;">
            <img src="%s" width="100%%">
        </div>
    </body>
</html>
        ]]):format("NOBORU: "..Manga.Name.." | "..Chapters.Name, Page)
        writeFile(file, content, #content)
        closeFile(file)
        callUri("webmodal: file:///ux0:data/noboru/temp/image.html")
    elseif ExtraMenu[id] == "ReaderOrientation" then
        CuSettings.changeOrientation(Manga)
        Reader.updateSettings()
        CustomSettings = CuSettings.load(Manga)
    elseif ExtraMenu[id] == "ReaderDirection" then
        CuSettings.changeDirection(Manga)
        Reader.updateSettings()
        CustomSettings = CuSettings.load(Manga)
    elseif ExtraMenu[id] == "ZoomReader" then
        CuSettings.changeZoom(Manga)
        Reader.updateSettings()
        CustomSettings = CuSettings.load(Manga)
    elseif ExtraMenu[id] == "OpenMangaInBrowser" then
        callUri("webmodal: "..Manga.BrowserLink)
    end
end

function Extra.doesBookmarksUpdate()
    local a = bookmarks_update
    bookmarks_update = false
    return a
end

function Extra.input(oldpad, pad, oldtouch, touch)
    if mode == "START" then
        local oldtouch_mode = TOUCH.MODE
        if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
            TOUCH.MODE = TOUCH.READ
            Slider.TouchY = touch.y
        elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
            if TOUCH.MODE == TOUCH.READ and oldtouch.x then
                if oldtouch.x > 480 - w_max / 2 and oldtouch.x < 480 + w_max / 2 and oldtouch.y > y_srt and oldtouch.y < y_srt + #ExtraMenu * 80 then
                    local id = math.floor((Slider.Y + oldtouch.y - y_srt) / 80) + 1
                    press_action(id)
                end
            end
            TOUCH.MODE = TOUCH.NONE
        end
        ExtraSelector:input(#ExtraMenu, oldpad, pad, touch.x)
        if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
            local id = ExtraSelector.getSelected()
            press_action(id)
        elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
            mode = "WAIT"
            Timer.reset(animation_timer)
            old_fade = fade
        elseif Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START) then
            mode = "WAIT"
            Timer.reset(animation_timer)
            old_fade = fade
        elseif touch.x ~= nil and oldtouch.x == nil then
            if touch.x > 480 - w_max / 2 and touch.x < 480 + w_max / 2 and touch.y > y_srt and touch.y < y_srt + 80 * #ExtraMenu then
                else
                mode = "WAIT"
                Timer.reset(animation_timer)
                old_fade = fade
            end
        end
        local new_itemID = 0
        if TOUCH.MODE == TOUCH.READ then
            if math.abs(Slider.V) > 0.1 or math.abs(touch.y - Slider.TouchY) > 10 then
                TOUCH.MODE = TOUCH.SLIDE
            else
                if oldtouch.x > 480 - w_max / 2 and oldtouch.x < 480 + w_max / 2 then
                    local id = math.floor((Slider.Y + oldtouch.y - y_srt) / 80) + 1
                    if ExtraMenu[id] then
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

function Extra.update()
    if mode ~= "END" then
        animationUpdate()
        local item_selected = ExtraSelector.getSelected()
        if item_selected ~= 0 then
            Slider.Y = Slider.Y + (item_selected * 80 - 272 - Slider.Y) / 8
        end
        scrollUpdate()
    end
end

function Extra.draw()
    if mode ~= "END" then
        local M = old_fade * fade
        local Alpha = 255 * M
        local start = math.max(1, math.floor(Slider.Y / 80) + 1)
        local shift = (1 - M) * 544
        local WHITE = Color.new(255, 255, 255, Alpha)
        local BLACK = Color.new(0, 0, 0, Alpha)
        local y = shift - Slider.Y + start * 80 + y_srt
        local ListCount = #ExtraMenu
        Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 150 * M))
        Graphics.fillRect(480 - w_max / 2, 480 + w_max / 2, y_srt + shift, y_srt + 80 * ListCount + shift - 1, WHITE)
        for i = start, math.min(ListCount, start + 8) do
            if ExtraMenu == ExtraMenuReader then
                local text = Language[Settings.Language].SETTINGS[ExtraMenu[i]] or ExtraMenu[i]
                if ExtraMenu[i] == "ReaderOrientation" then
                    text = text..": "..Language[Settings.Language].READER[CustomSettings.Orientation]
                elseif ExtraMenu[i] == "ReaderDirection" then
                    text = text..": "..Language[Settings.Language].READER[CustomSettings.ReaderDirection]
                elseif ExtraMenu[i] == "ZoomReader" then
                    text = text..": "..Language[Settings.Language].READER[CustomSettings.ZoomReader]
                end
                Font.print(BONT16, 480 - Font.getTextWidth(BONT16, text) / 2, y + 28 - 79, text, BLACK)

            else
                Font.print(BONT16, 480 - Font.getTextWidth(BONT16, Language[Settings.Language].EXTRA[ExtraMenu[i]] or ExtraMenu[i]) / 2, y + 28 - 79, Language[Settings.Language].EXTRA[ExtraMenu[i]] or ExtraMenu[i], BLACK)
            end
            if i == Slider.ItemID then
                Graphics.fillRect(480 - w_max / 2, 480 + w_max / 2, y - 79, y, Color.new(0, 0, 0, 24 * M))
            end
            y = y + 80
        end
        local item = ExtraSelector.getSelected()
        if item ~= 0 then
            y = shift - Slider.Y + (item - 1) * 80 + y_srt
            local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for i = ks, ks + 1 do
                Graphics.fillEmptyRect(480 - w_max / 2 + i + 3, 480 + w_max / 2 - i - 2, y + i + 3, y + 75 - i + 2, Themes[Settings.Theme].COLOR_SELECTOR)
                Graphics.fillEmptyRect(480 - w_max / 2 + i + 3, 480 + w_max / 2 - i - 2, y + i + 3, y + 75 - i + 2, SELECTED_RED)
            end
        end
        if mode == "START" and #ExtraMenu > 5 then
            local h = #ExtraMenu * 80 / 454
            Graphics.fillRect(930, 932, 90, 544, Color.new(92, 92, 92, Alpha))
            Graphics.fillRect(926, 936, 90 + (Slider.Y + 20) / h, 90 + (Slider.Y + 464) / h, COLOR_GRAY)
        end
    end
end

function Extra.getMode()
    return mode
end

function Extra.getFade()
    return fade * old_fade
end
