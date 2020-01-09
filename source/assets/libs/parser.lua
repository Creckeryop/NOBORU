Parsers = {}
Parser = {
    downloadCover = nil,
    getManga = nil,
    getChapters = nil,
    getChapterInfo = nil,
    getPage = nil,
    getMangaFromUrl = nil,
    new = function(self, name, link, lang, id)
        local p = {name = name, link = link, lang = lang, id = id}
        setmetatable(p, self)
        self.__index = self
        Parsers[id] = p
        return p
    end
}
