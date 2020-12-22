local mode = "HIDE"

---Textures for PS Buttons
textures_16x16 = {
	Cross = Image:new(Graphics.loadImage("app0:assets/images/cross_button.png")),
	Triangle = Image:new(Graphics.loadImage("app0:assets/images/triangle_button.png")),
	Square = Image:new(Graphics.loadImage("app0:assets/images/square_button.png")),
	Circle = Image:new(Graphics.loadImage("app0:assets/images/circle_button.png")),
	DPad = Image:new(Graphics.loadImage("app0:assets/images/dpad.png")),
	Select = Image:new(Graphics.loadImage("app0:assets/images/select_button.png")),
	Start = Image:new(Graphics.loadImage("app0:assets/images/start_button.png"))
}

---Table of actions
local hints = {}

---Table of Panel functions
Panel = {}

---Hides Panel
function Panel.hide()
	if mode ~= "SHOW" then
		return
	end
	mode = "HIDE"
end

---Shows Panel
function Panel.show()
	if mode ~= "HIDE" then
		return
	end
	mode = "SHOW"
end

---@param buttons table
---Sets table of actions
function Panel.set(buttons)
	hints = buttons
end

---Local variable used as vertical offset of panel
local y = 23

---Updates Panel Animation
function Panel.update()
	if mode == "HIDE" then
		y = math.min(23, y + (23 - y) / 4)
	elseif mode == "SHOW" then
		y = math.max(0, y - y / 4)
	end
end

---Draws Panel on screen
function Panel.draw()
	if y >= 23 then
		return
	end
	Graphics.fillRect(0, 960, 521 + y, 524 + y, Color.new(0, 0, 0, 32))
	Graphics.fillRect(0, 960, 522 + y, 524 + y, Color.new(0, 0, 0, 32))
	Graphics.fillRect(0, 960, 524 + y, 544, COLOR_PANEL)
	local x = 20
	for _, v in ipairs(hints) do
		if hints[v] then
			if textures_16x16[v] then
				if v == "Cross" and Settings.KeyType == "JP" then
					Graphics.drawImage(x, 526 + y, textures_16x16.Circle.e)
				elseif v == "Circle" and Settings.KeyType == "JP" then
					Graphics.drawImage(x, 526 + y, textures_16x16.Cross.e)
				else
					Graphics.drawImage(x, 526 + y, textures_16x16[v].e)
				end
				x = x + 20
			else
				Font.print(FONT16, x, 524 + y, v, COLOR_FONT)
				x = x + Font.getTextWidth(FONT16, v) + 5
			end
			Font.print(FONT16, x, 524 + y, hints[v], COLOR_FONT)
			x = x + Font.getTextWidth(FONT16, hints[v]) + 10
		end
	end
end
