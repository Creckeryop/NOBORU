function CreatePoint(x, y)
	return {
		x = x or 0,
		y = y or 0
	}
end

function CreateSlider()
	return {
		Y = 0,
		V = 0,
		TouchY = 0,
		ItemID = 0
	}
end

TOUCH_MODES = {
	NONE = 0,
	READ = 1,
	SLIDE = 2,
	MODE = 0
}

LUA_GRADIENT = Image:new(Graphics.loadImage("app0:assets/images/gradient.png"))

DEFAULT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"

COLOR_WHITE = Color.new(255, 255, 255)
COLOR_BLACK = Color.new(0, 0, 0)
COLOR_GRAY = Color.new(128, 128, 128)
COLOR_DARK_GRAY = Color.new(64, 64, 64)
COLOR_LIGHT_GRAY = Color.new(192, 192, 192)
COLOR_ROYAL_BLUE = Color.new(65, 105, 226)
COLOR_CRIMSON = Color.new(137, 30, 43)

COLOR_COVER = Color.new(101, 115, 146)
COLOR_FONT = COLOR_WHITE
COLOR_SUB_FONT = COLOR_GRAY
COLOR_BACK = COLOR_WHITE
COLOR_SELECTED = COLOR_WHITE
COLOR_ICON_EXTRACT = COLOR_WHITE
COLOR_PANEL = COLOR_WHITE

function COLOR_GRADIENT(colorA, colorB, a)
	if a <= 0 then
		return colorA
	elseif a >= 1 then
		return colorB
	end
	local r1, g1, b1, a1 = Color.getR(colorA), Color.getG(colorA), Color.getB(colorA), Color.getA(colorA)
	local r2, g2, b2, a2 = Color.getR(colorB), Color.getG(colorB), Color.getB(colorB), Color.getA(colorB)
	return Color.new(r1 + (r2 - r1) * a, g1 + (g2 - g1) * a, b1 + (b2 - b1) * a, a1 + (a2 - a1) * a)
end

SCE_CTRL_RIGHTPAGE = SCE_CTRL_RTRIGGER
SCE_CTRL_LEFTPAGE = SCE_CTRL_LTRIGGER

SCE_LEFT_STICK_DEADZONE = 20
SCE_LEFT_STICK_SENSITIVITY = 1
SCE_RIGHT_STICK_DEADZONE = 20
SCE_RIGHT_STICK_SENSITIVITY = 1

SCE_CTRL_REAL_CROSS = SCE_CTRL_CROSS
SCE_CTRL_REAL_CIRCLE = SCE_CTRL_CIRCLE

FONT16 = Font.load("app0:assets/fonts/roboto_regular.ttf")
FONT20 = Font.load("app0:assets/fonts/roboto_regular.ttf")
FONT26 = Font.load("app0:assets/fonts/roboto_regular.ttf")
BOLD_FONT16 = Font.load("app0:assets/fonts/roboto_bold.ttf")
BOLD_FONT30 = Font.load("app0:assets/fonts/roboto_bold.ttf")

Font.setPixelSizes(FONT20, 20)
Font.setPixelSizes(FONT26, 26)
Font.setPixelSizes(BOLD_FONT30, 30)

local doesDirExist = System.doesDirExist
local createDirectory = System.createDirectory
local deleteFile = System.deleteFile
local doesFileExist = System.doesFileExist

MANGA_WIDTH = 180
MANGA_HEIGHT = math.floor(MANGA_WIDTH * 1.5)

GlobalTimer = Timer.new()

if not doesDirExist("ux0:data/noboru") then
	createDirectory("ux0:data/noboru")
end

if not doesDirExist("ux0:data/noboru/chapters") then
	createDirectory("ux0:data/noboru/chapters")
end

if not doesDirExist("ux0:data/noboru/ext") then
	createDirectory("ux0:data/noboru/ext")
end

if not doesDirExist("ux0:data/noboru/pictures") then
	createDirectory("ux0:data/noboru/pictures")
end

if not doesDirExist("ux0:data/noboru/cache") then
	createDirectory("ux0:data/noboru/cache")
end

if not doesDirExist("ux0:data/noboru/import") then
	createDirectory("ux0:data/noboru/import")
end

if not doesDirExist("ux0:data/noboru/temp") then
	createDirectory("ux0:data/noboru/temp")
end

if not doesDirExist("ux0:data/noboru/cusettings") then
	createDirectory("ux0:data/noboru/cusettings")
end

if doesFileExist("ux0:data/noboru/temp/auth.html") then
	deleteFile("ux0:data/noboru/temp/auth.html")
end

if doesFileExist("ux0:data/noboru/temp/logo.png") then
	deleteFile("ux0:data/noboru/temp/logo.png")
end

if doesDirExist("uma0:") then
	if not doesDirExist("uma0:data") then
		createDirectory("uma0:data")
	end

	if not doesDirExist("uma0:data/noboru") then
		createDirectory("uma0:data/noboru")
	end

	if not doesDirExist("uma0:data/noboru/chapters") then
		createDirectory("uma0:data/noboru/chapters")
	end

	if not doesDirExist("uma0:data/noboru/import") then
		createDirectory("uma0:data/noboru/import")
	end

	if not doesDirExist("uma0:data/noboru/pictures") then
		createDirectory("uma0:data/noboru/pictures")
	end
end

local openFile, closeFile, readFile, sizeFile, writeFile = System.openFile, System.closeFile, System.readFile, System.sizeFile, System.writeFile

---@param sourcePath string
---@param destPath string
---Copies file source_path to destPath (creates file)
---Example:
---`copyFile("ux0:data/noboru/cache.image","ux0:cover.jpeg") -> cover.jpeg appeared in ux0:`
local function copyFile(sourcePath, destPath)
	local fileSrc = openFile(sourcePath, FREAD)
	local fileDest = openFile(destPath, FCREATE)
	local srcContent = readFile(fileSrc, sizeFile(fileSrc))
	writeFile(fileDest, srcContent, #srcContent)
	closeFile(fileSrc)
	closeFile(fileDest)
end

CopyFile = copyFile

copyFile("app0:assets/auth.html", "ux0:data/noboru/temp/auth.html")
copyFile("app0:assets/images/logo.png", "ux0:data/noboru/temp/logo.png")

function BytesToStr(bytes)
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
function CreateManga(Name, Link, ImageLink, ParserID, RawLink, BrowserLink)
	if Name and Link and ImageLink and ParserID then
		return {
			Name = Name,
			Link = Link,
			ImageLink = ImageLink,
			ParserID = ParserID,
			RawLink = RawLink or "",
			BrowserLink = BrowserLink,
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

---Checks if letter is chinese, japanese or korean
function IsCJK(letter)
	for i = 1, #CJK do
		if letter >= CJK[i][1] and letter <= CJK[i][2] then
			return true
		end
	end
	return false
end

local isCJK = IsCJK

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
					local cut = f:match(".+%s(.-)$") or f:match(".+-(.-)$") or f
					for k in it_utf8(cut) do
						s[#s + 1] = k
					end
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

function DrawManga(x, y, Manga)
	if Manga.Image and Manga.Image.e then
		Graphics.fillRect(x - MANGA_WIDTH / 2, x + MANGA_WIDTH / 2, y - MANGA_HEIGHT / 2, y + MANGA_HEIGHT / 2, Color.new(0, 0, 0))
		local width, height = Manga.Image.Width, Manga.Image.Height
		local isDrawn = false
		if width < height then
			local scale = MANGA_WIDTH / width
			local h = MANGA_HEIGHT / scale
			local s_y = (height - h) / 2
			if s_y >= 0 then
				Graphics.drawImageExtended(x, y, Manga.Image.e, 0, s_y, width, h, 0, scale, scale)
				isDrawn = true
			end
		end
		if not isDrawn then
			local scale = MANGA_HEIGHT / height
			local w = MANGA_WIDTH / scale
			local s_x = (width - w) / 2
			Graphics.drawImageExtended(x, y, Manga.Image.e, s_x, 0, w, height, 0, scale, scale)
		end
	else
		Graphics.fillRect(x - MANGA_WIDTH / 2, x + MANGA_WIDTH / 2, y - MANGA_HEIGHT / 2, y + MANGA_HEIGHT / 2, COLOR_COVER)
	end
	Graphics.drawScaleImage(x - MANGA_WIDTH / 2, y + MANGA_HEIGHT / 2 - 120, LUA_GRADIENT.e, MANGA_WIDTH, 1)
	if Manga.Name then
		if not Manga.PrintName then
			pcall(drawMangaName, Manga)
		else
			if Manga.PrintName.f then
				if y + MANGA_HEIGHT / 2 - 47 < 544 and y + MANGA_HEIGHT / 2 - 47 > -16 then
					Font.print(BOLD_FONT16, x - MANGA_WIDTH / 2 + 8, y + MANGA_HEIGHT / 2 - 47, Manga.PrintName.f, COLOR_WHITE)
				end
			end
			if y + MANGA_HEIGHT / 2 - 27 < 544 and y + MANGA_HEIGHT / 2 - 27 > -16 then
				Font.print(BOLD_FONT16, x - MANGA_WIDTH / 2 + 8, y + MANGA_HEIGHT / 2 - 27, Manga.PrintName.s, COLOR_WHITE)
			end
		end
	end
end

function DrawDetailsManga(x, y, Manga, M)
	M = M or 1
	if Manga.Image and Manga.Image.e then
		Graphics.fillRect(x - MANGA_WIDTH * M / 2, x + MANGA_WIDTH * M / 2, y - MANGA_HEIGHT * M / 2, y + MANGA_HEIGHT * M / 2, Color.new(0, 0, 0))
		local width, height = Manga.Image.Width, Manga.Image.Height
		local isDrawn = false
		if width < height then
			local scale = MANGA_WIDTH / width
			local h = MANGA_HEIGHT / scale
			local s_y = (height - h) / 2
			if s_y >= 0 then
				Graphics.drawImageExtended(x, y, Manga.Image.e, 0, s_y, width, h, 0, scale * M, scale * M)
				isDrawn = true
			end
		end
		if not isDrawn then
			local scale = MANGA_HEIGHT / height
			local w = MANGA_WIDTH / scale
			local s_x = (width - w) / 2
			Graphics.drawImageExtended(x, y, Manga.Image.e, s_x, 0, w, height, 0, scale * M, scale * M)
		end
	else
		Graphics.fillRect(x - MANGA_WIDTH * M / 2, x + MANGA_WIDTH * M / 2, y - MANGA_HEIGHT * M / 2, y + MANGA_HEIGHT * M / 2, COLOR_COVER)
	end
end
