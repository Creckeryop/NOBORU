local lines = {}
Console = {
    addLine = function (line)
        if #lines > 25 then
            table.remove (lines,1)
        end
        lines[#lines + 1] = line
    end,
    clear = function ()
        lines = {}
    end,
    draw = function ()
        local y = 20
        for _, v in ipairs (lines) do
            Graphics.debugPrint (0, y, v, LUA_COLOR_WHITE)
            y = y + 20
        end
    end
}