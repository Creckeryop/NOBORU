local LUA_GREEN_L = Color.new(51, 152, 75)
local LUA_GRADIENT = Graphics.loadImage(LUA_APPIMG_DIR .. "gradient.png")
local slider_x, slider_vel = 0, 0
local current_page = 1
local Mangas = {manga = {}}

local touchTemp = {x = 0, y = 0}
local offset = {x = 0, y = 0}

local TOUCH_NONE = 0
local TOUCH_READ = 1
local TOUCH_PRESS = 2
local TOUCH_SLIDE = 3
local touchMode = TOUCH_NONE

local LIBRARY = 0
local BROWSER = 1
local BRO_MODE = BROWSER
TouchTimer = Timer.new()
local drawManga = function(x, y, manga)
    if manga.image and manga.image.e then
        local width, height = Graphics.getImageWidth(manga.image.e), Graphics.getImageHeight(manga.image.e)
        local draw = false
        if width < height then
            local scale = MANGA_WIDTH / width
            local h = MANGA_HEIGHT / scale
            local s_y = (height - h) / 2
            if s_y >= 0 then
                Graphics.drawImageExtended(x, y, manga.image.e, 0, s_y, width, h, 0, scale, scale)
                draw = true
            end
        end
        if not draw then
            local scale = MANGA_HEIGHT / height
            local w = MANGA_WIDTH / scale
            local s_x = (width - w) / 2
            Graphics.drawImageExtended(x, y, manga.image.e, s_x, 0, w, height, 0, scale, scale)
        end
    else
        Graphics.fillRect(x - MANGA_WIDTH / 2, x + MANGA_WIDTH / 2, y - MANGA_HEIGHT / 2, y + MANGA_HEIGHT / 2, Color.new(128, 128, 128))
    end
    Graphics.drawScaleImage(x - MANGA_WIDTH / 2, y + MANGA_HEIGHT / 2 - 120, LUA_GRADIENT, MANGA_WIDTH, 1)
    if manga.name ~= nil then
        local width = Font.getTextWidth(LUA_FONT,manga.name) --(MANGA_WIDTH - 20) / 10 - 1
        local count = (MANGA_WIDTH - 20) / 10 - 1
        if width < MANGA_WIDTH - 20 then
            Font.print(LUA_FONT, x - MANGA_WIDTH / 2 + 10, y + MANGA_HEIGHT / 2 - 25, manga.name, Color.new(255, 255, 255))
        else
            local n, f, s = 0, "", ""
            for c in it_utf8(manga.name) do
                if n == count + 1 and c ~= " " then
                    s = f:match(".+%s(.-)$") .. c
                    f = f:match("^(.+)%s.-$")
                elseif n <= count then
                    f = f .. c
                else
                    s = s .. c
                end
                n = n + 1
            end
            s = s:gsub("^(%s+)", "")
            if s:len() > count then
                s = s:sub(1, count - 2) .. "..."
            end
            Font.print(LUA_FONT, x - MANGA_WIDTH / 2 + 10, y + MANGA_HEIGHT / 2 - 45, f, Color.new(255, 255, 255))
            Font.print(LUA_FONT, x - MANGA_WIDTH / 2 + 10, y + MANGA_HEIGHT / 2 - 25, s, Color.new(255, 255, 255))
        end
    end
end
local manga
Browser = {
    draw = function()
        local parser = ParserManager.getActiveParser()
        if parser ~= nil then
            Graphics.fillRect(0, 960, 80, 125, LUA_GREEN_L)
            Font.print(LUA_FONT32, 960 / 2 - Font.getTextWidth(LUA_FONT32, parser.name) / 2, 80, parser.name, LUA_COLOR_WHITE)
        end
        if Mangas.manga ~= nil then
            local start_i = math.max(1, math.floor(slider_x / (MANGA_WIDTH + 10)))
            for i = start_i, math.min(start_i + 7, #Mangas.manga) do
                drawManga((i - 1) * (MANGA_WIDTH + 10) + MANGA_WIDTH / 2 + 10 - slider_x - offset.x, 282 + 5, Mangas.manga[i])
            end
            Font.print(LUA_FONT32, 10, 34, "LIBRARY", LUA_COLOR_WHITE)
            Font.print(LUA_FONT32, 10 + Font.getTextWidth(LUA_FONT32, "LIBRARY") + 20, 34, "BROWSER", LUA_COLOR_WHITE)
            Font.print(LUA_FONT32, 950 - Font.getTextWidth(LUA_FONT32, "SETTINGS"), 34, "SETTINGS", LUA_COLOR_WHITE)
            local w = (#Mangas.manga * (MANGA_WIDTH + 10) - 10) / 940
            if w > 1 then
                Graphics.fillRect(10, 950, 282 + MANGA_HEIGHT / 2 + 19, 282 + MANGA_HEIGHT / 2 + 16, Color.new(55, 57, 76))
                Graphics.fillRect(10 + slider_x / w, 10 + (slider_x + 940) / w, 282 + MANGA_HEIGHT / 2 + 15, 282 + MANGA_HEIGHT / 2 + 20, Color.new(146, 161, 184))
            end
        end
    end,
    update = function()
        if touchMode == TOUCH_NONE and Touch.x == nil and OldTouch.x ~=nil then
            if BRO_MODE~= LIBRARY and OldTouch.x < 10 + Font.getTextWidth(LUA_FONT32, "LIBRARY") + 20 and OldTouch.x > 10 then
                BRO_MODE = LIBRARY
                Mangas.manga = GetLibrary() 
            elseif BRO_MODE~=BROWSER and OldTouch.x > 10 + Font.getTextWidth(LUA_FONT32, "LIBRARY") + 20  and OldTouch.x < 10 + Font.getTextWidth(LUA_FONT32, "LIBRARY") + 20 + Font.getTextWidth(LUA_FONT32, "BROWSER") then
                BRO_MODE = BROWSER
                Managas = {}
                ParserManager.getMangaListAsync(current_page, Mangas, "manga")
                slider_x = 0
            end
        end
        if Mangas.manga ~= nil then
            if slider_vel == 0 and Timer.getTime(TouchTimer) > 500 then
                local start_i = math.max(1, math.floor(slider_x / (MANGA_WIDTH + 10)))
                for i = 1, #Mangas.manga do
                    if i >= start_i and i <= math.min(start_i + 7, #Mangas.manga) then
                        if Mangas.manga[i] and not Mangas.manga[i].image_download then
                            Net.downloadImageAsync(Mangas.manga[i].img_link, Mangas.manga[i], "image")
                            Mangas.manga[i].image_download = 0
                        end
                    else
                        Net.remove(Mangas.manga[i],'image')
                        if Mangas.manga[i].image then
                            if Mangas.manga[i].image.e then
                                Graphics.freeImage(Mangas.manga[i].image.e)
                                Mangas.manga[i].image.e = nil
                            end
                        end
                        Mangas.manga[i].image_download = nil
                    end
                end
            end
            if touchMode == TOUCH_NONE and Touch.x ~= nil and OldTouch.x ~= nil and Touch.y > 282 - MANGA_HEIGHT / 2 and Touch.y < 282 + MANGA_HEIGHT / 2 then
                touchTemp = {x = Touch.x, y = Touch.y}
                touchMode = TOUCH_READ
            elseif Touch.x == nil then
                if touchMode == TOUCH_READ then
                    touchMode = TOUCH_PRESS
                    local start_i = math.max(1, math.floor(slider_x / (MANGA_WIDTH + 10)))
                    for i = start_i, math.min(start_i + 7, #Mangas.manga) do
                        if touchTemp.x > (i - 1) * (MANGA_WIDTH + 10) + 10 - slider_x - offset.x and touchTemp.x < (i - 1) * (MANGA_WIDTH + 10) + MANGA_WIDTH + 10 - slider_x - offset.x then
                            manga = Mangas.manga[i]
                            break
                        end
                    end
                else
                    touchMode = TOUCH_NONE
                end
            end
            if touchMode == TOUCH_READ then
                local len = math.sqrt((touchTemp.x - Touch.x) * (touchTemp.x - Touch.x) + (touchTemp.y - Touch.y) * (touchTemp.y - Touch.y))
                if len > 10 or math.abs(slider_vel) > 1 then
                    touchMode = TOUCH_SLIDE
                end
            end
            if touchMode == TOUCH_SLIDE then
                slider_vel = OldTouch.x - Touch.x
                Timer.reset(TouchTimer)
            else
                slider_vel = slider_vel / 1.12
                offset.x = offset.x / 1.12
                if math.abs(slider_vel) < 1 then
                    slider_vel = 0
                end
                if math.abs(offset.x) < 1 then
                    offset.x = 0
                end
            end
            slider_x = slider_x + slider_vel
            if slider_x <= 0 then
                slider_x = 0
                if touchMode == TOUCH_SLIDE then
                    offset.x = offset.x + slider_vel / 4
                end
                slider_vel = 0
            elseif slider_x >= #Mangas.manga * (MANGA_WIDTH + 10) - 950 then
                slider_x = math.max(0, #Mangas.manga * (MANGA_WIDTH + 10) - 950)
                if touchMode == TOUCH_SLIDE then
                    offset.x = offset.x + slider_vel / 4
                end
                slider_vel = 0
            end
        end
    end,
    input = function(pad, oldpad)
        if Controls.check(pad, SCE_CTRL_LTRIGGER) then
            if manga then
                ParserManager.getChaptersAsync(manga)
                while not manga.chapters.done do
                    ParserManager.update()
                    Net.update()
                end
                if (#manga.chapters > 1) then
                    for i = 1, #Mangas.manga do
                        Mangas.manga[i].image = nil
                        Mangas.manga[i].image_download = nil
                    end
                    Reader.load(manga.chapters)
                    MODE = READING_MODE
                else
                    Console.addLine("No pages", LUA_COLOR_RED)
                end
                AddManga(manga)
            end
        end
        if Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) then
            Browser.setPage(current_page + 1)
        end
        if Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) then
            if current_page > 1 then
                Browser.setPage(current_page - 1)
            end
        end
    end,
    Terminate = function()
        Mangas = nil
    end,
    setPage = function(page)
        Managas = {}
        ParserManager.getMangaListAsync(page, Mangas, "manga")
        current_page = page
        slider_x = 0
    end
}
