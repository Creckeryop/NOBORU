Parser = {}

function Parser:new (name, link, lang)
    local p = {name = name, link = link, lang = lang}
    setmetatable (p, self)
    self.__index = self
    return p
end

function Parser:downloadCover (manga)
end

function Parser:getManga (i)
    local file = Net.downloadString("https://www.mangareader.net/popular/"..(i - 1) * 30)
	local list = {}
	for img_link, link, name in file:gmatch("image:url%('(%S-)'.-<div class=\"manga_name\">.-<a href=\"(%S-)\">(.-)</a>") do
		list[#list + 1] = Manga:new(name, link, img_link, self)
	end
	return list
end