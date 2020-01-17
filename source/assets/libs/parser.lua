local i = {}
Parsers = {}
GetParserByID = function (ID)
	return Parsers[i[ID]]
end

Parser = {
    getManga        = nil,
    getChapters     = nil,
    prepareChapter  = nil,
	loadChapterPage = nil,
	getMangaUrl		= nil
}

function Parser:new(Name, Link, Lang, ID)
    local p = {Name = Name, Link = Link, Lang = Lang, ID = ID}
    setmetatable (p, self)
	self.__index = self
	if i[ID] then
		Parsers[i[ID]] = p
	else
		Parsers[#Parsers + 1] = p
		i[ID] = #Parsers
	end
    return p
end

--[[
MangaReader = Parser:new("MangaReader", "https://www.mangareader.net", "ENG", 1)

function MangaReader:getManga(i)
	local manga = {}
	Threads.RunTask{
		Type = "StringDownload",
		Link = self.Link.."/popular/"..((i - 1) * 30),
		Save = function (str)
			coroutine.yield(true)
			Threads.RunTask{
				Type = "Coroutine",
				F = function()
					for img_link, link, name in str:gmatch('image:url%(\'(%S-)\'.-<div class="manga_name">.-<a href="(%S-)">(.-)</a>') do
						manga[#manga + 1] = CreateManga(name, link, img_link, self.ID, self.Link..link)
					end
				end
			}
		end
	}
	return manga
end

function MangaReader:getChapters(manga)
	local chapters = {}
	Threads.RunTask{
		Type = "StringDownload",
		Link = self.Link .. manga.Link,
		Save = function (str)
			coroutine.yield(true)
			local num = 0
			str = str:match('id="chapterlist"(.+)$') or ""
			for link, name, subName in str:gmatch('chico_manga.-<a href%="/.-(/%S-)">(.-)</a>(.-)</td>') do
				local chapter = {Name = name .. subName, Link = link, Pages = {}, Manga = manga, RawLink = self.Link..manga.Link..link}
				chapters[#chapters + 1] = chapter
				num = num + 1
				if num == 50 then
					num = num - 50
					coroutine.yield(true)
				end
			end
		end
	}
	return chapters
end

function MangaReader:prepareChapter(chapter)
	local pages = {}
	Threads.RunTask{
		Type = "StringDownload",
		Link = self.Link..chapter.. chapter.manga.link .. chapter.link .. "#",
		Save = function (str)
			local count = str:match(" of (.-)<") or 0
			for i = 1, count do
				pages[#pages + 1] = {Link = self.Link .. chapter.manga.link .. chapter.link .. "/" .. i}
			end
		end
	}
	return pages
end

function MangaReader:loadChapterPage(page)
	local PageImage = nil
	Threads.RunTask{
		Type = "StringDownload",
		Link = page.Link,
		Unique = page,
		Save = function (str)
			local link = str:match('id="img".-src="(.-)"')
			if link ~= nil then
				Threads.RunTask{
					Type = "FileDownload",
					Link = link,
					Path = "cache.img",
					Unique = page,
					OnComplete = function ()
						Threads.RunTask{
							Type = "PageLoad",
							Path = "cache.img",
							Unique = page,
							Save = function (a)
								PageImage = a
							end
						}
					end
				}
			end
		end
	}
	return PageImage
end

ReadManga = Parser:new("ReadManga", "http://readmanga.me", "RUS", 2)

function ReadManga:getManga(i)
	local manga = {}
	Threads.RunTask{
		Type = "StringDownload",
		Link = self.Link.."/list?sortType=rate&offset=" .. ((i - 1) * 70),
		Save = function (str)
			coroutine.yield(true)
			Threads.RunTask{
				Type = "Coroutine",
				F = function()
					for link, img_link, name in str:gmatch('<a href="(/%S-)" class="non%-hover".-original=\'(%S-)\' title=\'(.-)\' alt') do
						if link:match("^/") then
							manga[#manga+ 1] = CreateManga(name, link, img_link, self.ID, self.Link..link)
						end
					end
				end
			}
		end
	}
	return manga
end

function ReadManga:getChapters(manga)
	local chapters = {}
	Threads.RunTask{
		Type = "StringDownload",
		Link = self.Link .. manga.Link,
		Save = function (str)
			coroutine.yield(true)
			local num = 0
			for link, name in str:gmatch('<td class%=.-<a href%="/.-(/vol%S-)".->%s*(.-)</a>') do
				local chapter = {Name = name:gsub("%s+", " "):gsub("<sup>.-</sup>",""):gsub("&quot;","\""):gsub("&amp;","&"):gsub("&#92;","\\"):gsub("&#39;","'"), Link = link, Pages = {}, Manga = manga, RawLink = self.Link..manga.Link..link}
				chapters[#chapters+ 1] = chapter
				num = num + 1
				if num == 50 then
					num = num - 50
					coroutine.yield(true)
				end
			end
		end
	}
	table.reverse(chapters)
	return chapters
end

function MangaReader:getManga(i, table, index)
	local file = {}
	Net.downloadStringAsync("https://www.mangareader.net/popular/" .. ((i - 1) * 30), file, "string")
	while file.string == nil do
		coroutine.yield(false)
	end
	for img_link, link, name in file.string:gmatch('image:url%(\'(%S-)\'.-<div class="manga_name">.-<a href="(%S-)">(.-)</a>') do
		table[index][#table[index] + 1] = CreateManga(name, link, img_link, self)
		coroutine.yield(true)
	end
end

local file = {}
	Net.downloadStringAsync("https://www.mangareader.net" .. chapter.manga.link .. chapter.link .. "#", file, "string")
	while file.string == nil do
		coroutine.yield(false)
	end
	local count = file.string:match(" of (.-)<")
	for i = 1, count do
		file = {}
		Net.downloadStringAsync(, file, "string")
		while file.string == nil do
			coroutine.yield(false)
		end
		
		coroutine.yield(true)
	end



function MangaReader:getMangaFromUrl(url)
	local file = {}
	Net.downloadStringAsync("https://www.mangareader.net" .. url, file, "string")
	while file.string == nil do
		coroutine.yield(false)
	end
	local name = file.string:match('aname">(.-)<')
	local img_link = file.string:match('mangaimg">.-src%="(.-)"')
	return CreateManga(name, url, img_link, self)
end--]]