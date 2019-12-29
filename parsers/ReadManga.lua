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