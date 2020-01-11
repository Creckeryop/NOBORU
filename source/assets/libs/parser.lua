Parsers = {}

Parser = {
    getManga        = nil,
    getChapters     = nil,
    prepareChapter  = nil,
    loadChapterPage = nil
}

function Parser:new(Name, Link, Lang, ID)
    local p = {Name = Name, Link = Link, Lang = Lang, ID = ID}
    setmetatable (p, self)
    self.__index = self
    Parsers[ID] = p
    return p
end

MangaReader = Parser:new("MangaReader", "https://www.mangareader.net", "ENG", 1)

function MangaReader:getManga(i)
    Network.requestStringAsync(self.Link.."/popular/"..((i - 1) * 30))
    while System.getAsyncState() == 0 do
        coroutine.yield(false)
    end
    local content = System.getAsyncResult()
    if content then
        local table = {}
        for img_link, link, name in content:gmatch('image:url%(\'(%S-)\'.-<div class="manga_name">.-<a href="(%S-)">(.-)</a>') do
            table[#table + 1] = CreateManga(name, link, img_link, self)
        end
        return table
    else
        return {}
    end
end
--[[

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

function MangaReader:getChapters(manga, index)
	local file = {}
	Net.downloadStringAsync("https://www.mangareader.net" .. manga.link, file, "string")
	while file.string == nil do
		coroutine.yield(false)
	end
	file.string = file.string:match('id="chapterlist"(.+)$') or ""
	for link, name, subName in file.string:gmatch('<td>.-<a href%="/.-(/%S-)">(.-)</a>(.-)</td>') do
		local chapter = {name = name .. subName, link = link, pages = {}, manga = manga}
		manga[index][#manga[index] + 1] = chapter
		--Console.addLine ("Parser: Got chapter \""..chapter.name.."\" ("..chapter.link..")", LUA_COLOR_GREEN)
	end
end

function MangaReader:getChapterInfo(chapter, index)
	local file = {}
	Net.downloadStringAsync("https://www.mangareader.net" .. chapter.manga.link .. chapter.link .. "#", file, "string")
	while file.string == nil do
		coroutine.yield(false)
	end
	local count = file.string:match(" of (.-)<")
	for i = 1, count do
		file = {}
		Net.downloadStringAsync("https://www.mangareader.net" .. chapter.manga.link .. chapter.link .. "/" .. i, file, "string")
		while file.string == nil do
			coroutine.yield(false)
		end
		chapter[index][i] = file.string:match('id="img".-src="(.-)"')
		coroutine.yield(true)
	end
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