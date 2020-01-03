Parsers = {}
Parser = {
    downloadCover = nil,
    getManga = nil,
    getChapters = nil,
    getChapterInfo = nil,
    getPage = nil,
    new = function(self, name, link, lang)
        local p = {name = name, link = link, lang = lang}
        setmetatable(p, self)
        self.__index = self
        for k, v in ipairs(Parsers) do
            if p.name == v.name then
                Parsers[k].name = p.name
                Parsers[k].link = p.link
                Parsers[k].lang = p.lang
                return p
            end
        end
        Parsers[#Parsers + 1] = p
        return p
    end
}
