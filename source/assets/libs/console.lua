local lines = {}
local console_color = Color.new(0, 0, 0, 128)
Console = {
    writeLine = function(line, color)
        color = color or Color.new(255, 255, 255)
        if #lines > 25 then
            table.remove(lines, 1)
        end
        lines[#lines + 1] = {line, color}
    end,
    clear = function()
        lines = {}
    end,
    draw = function()
        local y = 20
        for _, v in ipairs(lines) do
            Graphics.fillRect(0, 960, y, y + 20, console_color)
            Font.print(FONT, 0, y, v[1], v[2])
            y = y + 20
        end
    end
}
