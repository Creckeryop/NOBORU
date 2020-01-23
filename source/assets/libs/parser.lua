local i = {}
Parsers = {}
GetParserByID = function (ID)
	return Parsers[i[ID]]
end
Parser = {
    getLatestManga  = nil,
    getPopularManga = nil,
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
		Console.writeLine('Parser "'..Name..'" Updated!')
	else
		Parsers[#Parsers + 1] = p
		i[ID] = #Parsers
		Console.writeLine('Parser "'..Name..'" Loaded!')
	end
    return p
end