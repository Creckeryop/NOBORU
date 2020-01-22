local Y = 23
local MODE_HIDE = 0
local MODE_SHOW = 1
local MODE      = MODE_HIDE

Panel = {
    Hide = function ()
        if MODE == MODE_SHOW then
            MODE = MODE_HIDE
        end
    end,
    Show = function ()
        if MODE == MODE_HIDE then
            MODE = MODE_SHOW
        end
    end,
    Update = function ()
        if MODE == MODE_HIDE then
            Y = math.min(23, Y + (23-Y)/4)
        elseif MODE == MODE_SHOW then
            Y = math.max(0, Y - Y/4)
        end
    end,
    Draw = function ()
        Graphics.fillRect(0, 960, 521 + Y, 524 + Y, Color.new(0, 0, 0, 32))
        Graphics.fillRect(0, 960, 522 + Y, 524 + Y, Color.new(0, 0, 0, 32))
        Graphics.drawImage(0, 524 + Y, LUA_PANEL)
    end
}