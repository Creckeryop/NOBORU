Parsers = {}
Parser = {
    downloadCover = nil,
    getManga = nil,
    getChapters = nil,
    getPages = nil,
    new = function (self, name, link, lang)
        local p = {name = name, link = link, lang = lang}
        setmetatable (p, self)
        self.__index = self
        for k, v in ipairs (Parsers) do
            if p.name == v.name then
                Console.addLine('Parser \"'..name..'\" updated', LUA_COLOR_BLUE)
                Parsers[k] = p
                return p
            end
        end
        Console.addLine('Parser \"'..name..'\" added', LUA_COLOR_GREEN)
        Parsers[#Parsers + 1] = p
        return p
    end
}