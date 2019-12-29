ReadManga = Parser:new("ReadManga", "https://readmanga.me/", "RUS")

function ReadManga:getManga (i)
	local file = Net.downloadString("http://readmanga.me/list?sortType=rate&offset="..((i - 1) * 70))
	local list = {}
	for link, img_link, name in file:gmatch("<a href=\"(/%S-)\" class=\"non%-hover\".-original='(%S-)' title='(.-)'") do
		if link:match("^/") then
			list[#list + 1] = Manga:new(name, link, img_link, self)
		end
	end
	return list
end

function ReadManga:getChapters (manga)
	local file = Net.downloadString("http://readmanga.me"..manga.link)
	local list = {}
	for link, name in file:gmatch("<td class%=.-<a href%=\""..manga.link.."(/vol%S-)\".->(.-)</a>") do
		local chapter = {name = name:gsub("%s+"," "), link = link, pages = {}, manga = manga}
		list[#list + 1] = chapter
		Console.addLine("Parser: Got chapter \""..chapter.name.."\" ("..chapter.link..")", LUA_COLOR_GREEN)
	end
	return list
end