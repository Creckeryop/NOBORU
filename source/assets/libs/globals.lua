Point_t = function(x, y)
    return {
        x = x or 0,
        y = y or 0
    }
end

TOUCH = function()
    return {
        NONE = 0,
        READ = 1,
        SLIDE = 2,
        MODE = 0
    }
end

Slider = function()
    return {
        Y = 0,
        V = 0,
        TouchY = 0,
        ItemID = 0
    }
end

LUA_GRADIENT = Image:new(Graphics.loadImage("app0:assets/images/gradient.png"))
LUA_GRADIENTH = Image:new(Graphics.loadImage("app0:assets/images/gradientH.png"))
LUA_PANEL = Image:new(Graphics.loadImage("app0:assets/images/panel.png"))
DEV_LOGO = Image:new(Graphics.loadImage("app0:assets/images/devlogo.png"))

USERAGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"

COLOR_WHITE = Color.new(255, 255, 255)
COLOR_BLACK = Color.new(0, 0, 0)
COLOR_GRAY = Color.new(128, 128, 128)
COLOR_DARK_GRAY = Color.new(64, 64, 64)
COLOR_LIGHT_GRAY = Color.new(192, 192, 192)
COLOR_ROYAL_BLUE = Color.new(65, 105, 226)
COLOR_CRIMSON = Color.new(137, 30, 43)

COLOR_FONT = COLOR_WHITE
COLOR_BACK = COLOR_WHITE
COLOR_SELECTED = COLOR_WHITE
COLOR_ICON_EXTRACT = COLOR_WHITE
COLOR_PANEL = COLOR_WHITE

SCE_CTRL_RIGHTPAGE = SCE_CTRL_RTRIGGER
SCE_CTRL_LEFTPAGE = SCE_CTRL_LTRIGGER

SCE_LEFT_STICK_DEADZONE = 20
SCE_LEFT_STICK_SENSITIVITY = 1
SCE_RIGHT_STICK_DEADZONE = 20
SCE_RIGHT_STICK_SENSITIVITY = 1

SCE_CTRL_REAL_CROSS = SCE_CTRL_CROSS
SCE_CTRL_REAL_CIRCLE = SCE_CTRL_CIRCLE

FONT16 = Font.load("app0:roboto.ttf")
FONT20 = Font.load("app0:roboto.ttf")
FONT26 = Font.load("app0:roboto.ttf")
FONT30 = Font.load("app0:roboto.ttf")
BONT16 = Font.load("app0:robboto.ttf")
BONT30 = Font.load("app0:robboto.ttf")

Font.setPixelSizes(FONT20, 20)
Font.setPixelSizes(FONT26, 26)
Font.setPixelSizes(FONT30, 30)
Font.setPixelSizes(BONT30, 30)

local doesDirExist = System.doesDirExist
local createDirectory = System.createDirectory

MANGA_WIDTH = 160
MANGA_HEIGHT = math.floor(MANGA_WIDTH * 1.5)

GlobalTimer = Timer.new()

PI = 3.14159265359

if not doesDirExist("ux0:data/noboru") then
    createDirectory("ux0:data/noboru")
end

if not doesDirExist("ux0:data/noboru/chapters") then
    createDirectory("ux0:data/noboru/chapters")
end

if not doesDirExist("ux0:data/noboru/cache") then
    createDirectory("ux0:data/noboru/cache")
end

if not doesDirExist("ux0:data/noboru/import") then
    createDirectory("ux0:data/noboru/import")
end

function MemToStr(bytes)
    local str = "Bytes"
    if bytes > 1024 then
        bytes = bytes / 1024
        str = "KB"
        if bytes > 1024 then
            bytes = bytes / 1024
            str = "MB"
            if bytes > 1024 then
                bytes = bytes / 1024
                str = "GB"
            end
        end
    end
    return string.format("%.2f %s", bytes, str)
end

---@param Name string
---@param Link string
---@param ImageLink string
---@param ParserID integer
---@param RawLink string
---Creates `Manga-Info` table
function CreateManga(Name, Link, ImageLink, ParserID, RawLink)
    if Name and Link and ImageLink and ParserID then
        return {
            Name = Name,
            Link = Link,
            ImageLink = ImageLink,
            ParserID = ParserID,
            RawLink = RawLink or "",
            Data = {}
        }
    else
        return nil
    end
end

local CJK = {
    {"㌀", "㏿"},
    {"︰", "﹏"},
    {"豈", "﫿"},
    {"丽", "𯨟"},
    {"぀", "ゟ"},
    {"゠", "ヿ"},
    {"⺀", "⻿"},
    {"一", "鿿"},
    {"㐀", "䶿"},
    {"𠀀", "𪛟"},
    {"𪜀", "𫜿"},
    {"𫝀", "𫠟"},
    {"𫠠", "𬺯"}
}

local function isCJK(letter)
    for i = 1, #CJK do
        if letter >= CJK[i][1] and letter <= CJK[i][2] then
            return true
        end
    end
    return false
end

local function drawMangaName(Manga)
    Manga.PrintName = {}
    local width = Font.getTextWidth(FONT16, Manga.Name)
    if width < MANGA_WIDTH - 20 then
        Manga.PrintName.s = Manga.Name
    else
        local f, s = {}, {}
        local tf = false
        for c in it_utf8(Manga.Name) do
            if tf and Font.getTextWidth(FONT16, table.concat(s)) > MANGA_WIDTH - 40 then
                s[#s] = "…"
                if Font.getTextWidth(FONT16, table.concat(s)) > MANGA_WIDTH - 40 then
                    s[#s] = nil
                    s[#s] = "…"
                end
                break
            elseif tf then
                s[#s + 1] = c
            elseif not tf and Font.getTextWidth(FONT16, table.concat(f)) > MANGA_WIDTH - 30 then
                if isCJK(f[#f]) then
                    s[#s + 1] = f[#f]
                    f[#f] = nil
                else
                    f = table.concat(f)
                    s[#s + 1] = (f:match(".+%s(.-)$") or f:match(".+-(.-)$") or f)
                    s[#s + 1] = c
                    f = f:match("^(.+)%s.-$") or f:match("(.+-).-$") or ""
                end
                tf = true
            elseif not tf then
                f[#f + 1] = c
            end
        end
        if type(s) == "table" then
            s = table.concat(s)
        end
        if type(f) == "table" then
            f = table.concat(f)
        end
        s = s:gsub("^(%s+)", "")
        if s == "" then
            s, f = f, ""
        end
        Manga.PrintName.f = f or ""
        Manga.PrintName.s = s
    end
end

function DrawManga(x, y, Manga, M)
    local Mflag = M ~= nil
    M = M or 1
    if Manga.Image and Manga.Image.e then
        Graphics.fillRect(x - MANGA_WIDTH * M / 2, x + MANGA_WIDTH * M / 2, y - MANGA_HEIGHT * M / 2, y + MANGA_HEIGHT * M / 2, Color.new(0, 0, 0))
        local width, height = Manga.Image.Width, Manga.Image.Height
        local draw = false
        if width < height then
            local scale = MANGA_WIDTH / width
            local h = MANGA_HEIGHT / scale
            local s_y = (height - h) / 2
            if s_y >= 0 then
                Graphics.drawImageExtended(x, y, Manga.Image.e, 0, s_y, width, h, 0, scale * M, scale * M)
                draw = true
            end
        end
        if not draw then
            local scale = MANGA_HEIGHT / height
            local w = MANGA_WIDTH / scale
            local s_x = (width - w) / 2
            Graphics.drawImageExtended(x, y, Manga.Image.e, s_x, 0, w, height, 0, scale * M, scale * M)
        end
    else
        Graphics.fillRect(x - MANGA_WIDTH * M / 2, x + MANGA_WIDTH * M / 2, y - MANGA_HEIGHT * M / 2, y + MANGA_HEIGHT * M / 2, Color.new(101, 115, 146))
    end
    local alpha = Mflag and 5 - M / 0.25 or M
    Graphics.drawScaleImage(x - MANGA_WIDTH * M / 2, y + MANGA_HEIGHT * M / 2 - 120, LUA_GRADIENT.e, MANGA_WIDTH * M, 1, Color.new(255, 255, 255, 255 * alpha))
    if Manga.Name then
        if not Manga.PrintName then
            pcall(drawMangaName, Manga)
        else
            if Manga.PrintName.f then
                Font.print(BONT16, x - MANGA_WIDTH / 2 + 8, y + MANGA_HEIGHT * M / 2 - 47, Manga.PrintName.f, Color.new(255, 255, 255, 255 * alpha))
            end
            Font.print(BONT16, x - MANGA_WIDTH / 2 + 8, y + MANGA_HEIGHT * M / 2 - 27, Manga.PrintName.s, Color.new(255, 255, 255, 255 * alpha))
        end
    end
end
