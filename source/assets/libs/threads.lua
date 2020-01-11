Thread = {
    new = function (self)
        local p = {}
        setmetatable (p, self)
        self.__index = self
        return p
    end
}
