---Table of console methods
Console = {
	Lines = {}
}

local CONSOLE_COLOR = Color.new(0, 0, 0, 128)
local ERROR_COLOR = Color.new(255, 0, 0)

---@param message string
---@param color number
---Prints message line in console output
function Console.write(message, color, mode)
	mode = mode or 1
	if Console.Lines[mode] == nil then
		Console.Lines[mode] = {}
	end
	local Lines = Console.Lines[mode]
	if #Lines > 25 then
		table.remove(Lines, 1)
	end
	Lines[#Lines + 1] = {
		message,
		color or COLOR_WHITE
	}
end

---@param message string
---Prints error line in console output
function Console.error(message, mode)
	Console.write(message, ERROR_COLOR, mode)
end

---Clears console
function Console.clear(mode)
	mode = mode or 1
	Console.Lines[mode] = {}
end

---Draws console
function Console.draw(mode)
	mode = mode or 1
	if Console.Lines[mode] then
		local y = 40
		for i = 1, #Console.Lines[mode] do
			local line = Console.Lines[mode][i]
			Graphics.fillRect(0, 960, y, y + 20, CONSOLE_COLOR)
			Font.print(FONT16, 0, y, line[1], line[2])
			y = y + 20
		end
	end
end
