local CONSOLE_COLOR = Color.new(0, 0, 0, 128)

---Table of console methods
Console = {
    Lines = {}
}

---@param message string
---@param color number
---Prints message line to console output
function Console.write(message, color)
    local Lines = Console.Lines
    if #Lines > 25 then
        table.remove(Lines, 1)
    end
    Lines[#Lines + 1] = {
        message,
        color or COLOR_WHITE
    }
end

---Clears console
function Console.clear()
    Console.Lines = {}
end

---Draws console
function Console.draw()
    local y = 20
    for _, v in ipairs(Console.Lines) do
        Graphics.fillRect(0, 960, y, y + 20, CONSOLE_COLOR)
        Font.print(FONT16, 0, y, v[1], v[2])
        y = y + 20
    end
end
