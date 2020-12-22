---@class Image
Image = {
	__gc = function(self)
		self:free()
	end
}

local function setmt__gc(t, mt)
	local prox = newproxy(true)
	getmetatable(prox).__gc = function()
		mt.__gc(t)
	end
	t[prox] = true
	return setmetatable(t, mt)
end

---Variable to count used memory by textures
local textureMemUsed = 0

---@param image integer
---@return Image|nil
---Creates Image Object
function Image:new(image, filter)
	if not image then
		return nil
	end
	local p = {
		e = image,
		Width = Graphics.getImageWidth(image),
		Height = Graphics.getImageHeight(image)
	}
	if filter then
		Graphics.setImageFilters(image, filter, filter)
	end
	p.Memory = bit32.band(p.Width + 7, bit32.bnot(7)) * p.Height * 4 + 1024
	textureMemUsed = textureMemUsed + p.Memory
	setmt__gc(p, self)
	self.__index = self
	return p
end

---Free image
function Image:free()
	if not self.e then
		return
	end
	Graphics.freeImage(self.e)
	Console.write("Freed!")
	self.e = nil
	textureMemUsed = textureMemUsed - self.Memory
end

---Get used memory by textures
function GetTextureMemoryUsed()
	return textureMemUsed
end
