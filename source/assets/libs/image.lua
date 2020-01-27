---@class Image
Image = {
    __gc = function(self)
        self:free()
    end
}

---Variable to count used memory by textures
local textureMemUsed = 0

---@param image integer
---@return Image|nil
---Creates Image Object
function Image:new(image)
    if not image then return nil end
    local p = {
        e = image,
        Width = Graphics.getImageWidth(image),
        Height = Graphics.getImageHeight(image)
    }
    p.Memory = bit32.band(bit32.bor(p.Width, 7), bit32.bnot(7)) * p.Height * 4
    textureMemUsed = textureMemUsed + p.Memory
    Setmt__gc(p, self)
    self.__index = self
    return p
end

---Free image
function Image:free()
    if not self.e then return end
    Graphics.freeImage(self.e)
    Console.write("Freed!")
    self.e = nil
    textureMemUsed = textureMemUsed - self.Memory
end

---Get used memory by textures
function GetTextureMemoryUsed()
    return textureMemUsed
end
