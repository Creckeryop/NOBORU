Manga = {
    new = function (self, name, link, img_link, parser)
        local p = {name = name, link = link, parser = parser, img_link = img_link}
        setmetatable (p, self)
        self.__index = self
        return p
    end
}