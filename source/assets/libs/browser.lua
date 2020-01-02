local LUA_GREEN_L = Color.new(51,152,75)
local LUA_GRADIENT = Graphics.loadImage(LUA_APPIMG_DIR..'gradient.png')
local downloaded = 0
local freed = 0
local slider_x, slider_vel = 0, 0

local drawManga = function (x, y, manga)
    if manga.image then
        local width, height = Graphics.getImageWidth(manga.image), Graphics.getImageHeight(manga.image)
        local draw = false
        if width < height then
            local scale = MANGA_WIDTH / width
            local h = MANGA_HEIGHT / scale
            local s_y = (height - h) / 2
            if  s_y >= 0 then
                Graphics.drawImageExtended(x, y, manga.image, 0, s_y, width, h, 0, scale, scale)
                draw = true
            end
        end
        if not draw then
            local scale = MANGA_HEIGHT / height
            local w = MANGA_WIDTH / scale
            local s_x = (width - w) / 2
            Graphics.drawImageExtended(x, y, manga.image, s_x, 0, w, height, 0, scale, scale)
        end
    else
        Graphics.fillRect(x-MANGA_WIDTH/2, x+MANGA_WIDTH/2, y-MANGA_HEIGHT/2, y+MANGA_HEIGHT/2, Color.new(128,128,128))
    end
    Graphics.drawScaleImage(x-MANGA_WIDTH/2,y+MANGA_HEIGHT/2-120,LUA_GRADIENT,MANGA_WIDTH,1)
    if manga.name ~= nil then
        local count = (MANGA_WIDTH-20)/10 - 1
        if manga.name:len() <= count then
            Font.print(LUA_FONT, x - MANGA_WIDTH/2+10,y + MANGA_HEIGHT/2-25,manga.name,Color.new(255,255,255))
        else
            local n, f, s = 0, "", ""
            for c in it_utf8(manga.name) do
                if n==count+1 and c~=" " then
                    s = f:match(".+%s(.-)$")..c
                    f = f:match("^(.+)%s.-$")
                elseif n<=count then
                    f = f..c
                else
                    s = s..c
                end
                n = n + 1 
            end
            s = s:gsub("^(%s+)","")
            if s:len() > count then
                s = s:sub(1,count-2).."..."
            end
            Font.print(LUA_FONT, x - MANGA_WIDTH/2+10,y + MANGA_HEIGHT/2-45,f,Color.new(255,255,255))
            Font.print(LUA_FONT, x - MANGA_WIDTH/2+10,y + MANGA_HEIGHT/2-25,s,Color.new(255,255,255))
        end
    end
end

local Mangas = {}

Browser = {
    draw = function ()
        local parser = ParserManager.getActiveParser()
        if parser ~= nil then
            Graphics.fillRect(0, 960, 80, 120, LUA_GREEN_L)
            Font.print(LUA_FONT32,960/2 - Font.getTextWidth(LUA_FONT32, parser.name) / 2,80, parser.name, LUA_COLOR_WHITE)
        end
        if Mangas.manga~= nil then
            local start_i = math.max(1,math.floor(slider_x/(MANGA_WIDTH + 10)))
            for i = start_i, math.min(start_i + 7,#Mangas.manga) do
                drawManga((i - 1)*(MANGA_WIDTH + 10) + MANGA_WIDTH/2 + 10 -slider_x, 282, Mangas.manga[i])
            end
            Font.print(LUA_FONT32,10,34,"БИБЛИОТЕКА",LUA_COLOR_WHITE)
            Font.print(LUA_FONT32,10+Font.getTextWidth(LUA_FONT32,"БИБЛИОТЕКА") + 20,34,"КАТАЛОГИ",LUA_COLOR_WHITE)
            Font.print(LUA_FONT32,950-Font.getTextWidth(LUA_FONT32,"НАСТРОЙКИ"),34,"НАСТРОЙКИ",LUA_COLOR_WHITE)
        end
        Font.print(LUA_FONT32,0,0,freed..'/'..downloaded,LUA_COLOR_WHITE)
    end,
    update = function ()
        if math.abs(slider_vel) < 0.05 then
			local start_i = math.max(1,math.floor(slider_x/(MANGA_WIDTH+10)))
			for i = 1, #Mangas.manga do
				if i >= start_i and i <= math.min(start_i + 7,#Mangas.manga)  then
                    if Mangas.manga[i] and not Mangas.manga[i].image then
                        if Net.downloadImageAsync(Mangas.manga[i].img_link, Mangas.manga[i], 'image') then
                            downloaded = downloaded + 1
                        end
					end
                else
                    if Mangas.manga[i].image then
                        local success, err = pcall(Graphics.freeImage,Mangas.manga[i].image)
						if success then
                            Mangas.manga[i].image = nil
                            freed = freed + 1
                        else
                            Console.addLine(err)
                        end
                    else
                        if Net.check(Mangas.manga[i],'image') then
                            Net.remove(Mangas.manga[i],'image')
                            freed = freed + 1
                        end
					end
				end
			end
        end
        if Mangas.manga~=nil then
            if Touch.x ~= nil and OldTouch.x~=nil and Touch.y>282-MANGA_HEIGHT/2 and Touch.y<282+MANGA_HEIGHT/2  then
                Touch_Event = "SLIDE"
            elseif Touch.x == nil then
                Touch_Event = nil
            end
            if Touch_Event == "SLIDE" then
                slider_vel = OldTouch.x - Touch.x
            else
                slider_vel = slider_vel * 0.95
                if math.abs(slider_vel) < 0.05 then
                    slider_vel = 0
                end
            end
            if slider_x + slider_vel < 0 then
                slider_x = 0
                slider_vel = 0
            elseif slider_x + slider_vel > #Mangas.manga*(MANGA_WIDTH+10) - 950 then
                slider_x = math.max(0,#Mangas.manga*(MANGA_WIDTH+10)-950) - slider_vel
            end
            slider_x = slider_x + slider_vel
        end
    end,
    input = function ()
        
    end,
    setPage = function (page)
        ParserManager.getMangaListAsync(1, Mangas, 'manga')
        slider_x = 0
    end
}
