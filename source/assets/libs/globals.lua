LUA_GRADIENT = Graphics.loadImage("app0:assets/images/gradient.png")

FONT    = Font.load("app0:roboto.ttf")
FONT32  = Font.load("app0:roboto.ttf")
Font.setPixelSizes(FONT32, 32)

MANGA_WIDTH     = 160
MANGA_HEIGHT    = math.floor(MANGA_WIDTH * 1.5)

GlobalTimer = Timer.new()

PI = 3.14159265359

if not System.doesDirExist("ux0:data/Moondayo/") then
    System.createDirectory("ux0:data/Moondayo")
end

function CreateManga(Name, Link, ImageLink, ParserID)
    return {Name = Name or "", Link = Link, ImageLink = ImageLink, ParserID = ParserID}
end

function DrawManga(x, y, Manga)
    if Manga.image then
        local width, height = Graphics.getImageWidth(Manga.image), Graphics.getImageHeight(Manga.image)
        local draw = false
        if width < height then
            local scale = MANGA_WIDTH / width
            local h = MANGA_HEIGHT / scale
            local s_y = (height - h) / 2
            if s_y >= 0 then
                Graphics.drawImageExtended(x, y, Manga.image, 0, s_y, width, h, 0, scale, scale)
                draw = true
            end
        end
        if not draw then
            local scale = MANGA_HEIGHT / height
            local w = MANGA_WIDTH / scale
            local s_x = (width - w) / 2
            Graphics.drawImageExtended(x, y, Manga.image, s_x, 0, w, height, 0, scale, scale)
        end
    else
        --Graphics.fillRect(x - MANGA_WIDTH / 2-3, x + MANGA_WIDTH / 2-3, y - MANGA_HEIGHT / 2+3, y + MANGA_HEIGHT / 2+3, Color.new(0, 0, 0, 64))
        Graphics.fillRect(x - MANGA_WIDTH / 2, x + MANGA_WIDTH / 2, y - MANGA_HEIGHT / 2, y + MANGA_HEIGHT / 2, Color.new(128, 128, 128))
    end
    Graphics.drawScaleImage(x - MANGA_WIDTH / 2, y + MANGA_HEIGHT / 2 - 120, LUA_GRADIENT, MANGA_WIDTH, 1)
    if Manga.Name then
        local DrawMangaName = function ()
            local width = Font.getTextWidth(FONT, Manga.Name)
            local count = (MANGA_WIDTH - 20) / 10 - 1
            if width < MANGA_WIDTH - 20 then
                Font.print(FONT, x - MANGA_WIDTH / 2 + 10, y + MANGA_HEIGHT / 2 - 25, Manga.Name, Color.new(255, 255, 255))
            else
                local n, f, s = 0, "", ""
                for c in it_utf8(Manga.Name) do
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
                Font.print(FONT, x - MANGA_WIDTH / 2 + 10, y + MANGA_HEIGHT / 2 - 45, f, Color.new(255, 255, 255))
                Font.print(FONT, x - MANGA_WIDTH / 2 + 10, y + MANGA_HEIGHT / 2 - 25, s, Color.new(255, 255, 255))
            end
        end
        pcall(DrawMangaName)
    end
end

local function setmt__gc(t, mt)
    local prox = newproxy(true)
    getmetatable(prox).__gc = function()
        mt.__gc(t)
    end
    t[prox] = true
    return setmetatable(t, mt)
end

Image = {
    __gc = function(self)
        if self.e ~= nil then
            Graphics.freeImage(self.e)
            Console.addLine("Freed!")
        end
    end,
    new = function(self, image)
        if image == nil then
            return nil
        end
        local p = {e = image}
        setmt__gc(p, self)
        self.__index = self
        return p
    end
}
