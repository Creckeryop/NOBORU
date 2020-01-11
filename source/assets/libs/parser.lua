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
