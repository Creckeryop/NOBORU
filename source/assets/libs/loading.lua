---Table of Loading functions
Loading = {}

local mode = "NONE"

---Color of loading circles
local color = 0

---Center of loading animation
local center = {
    x = 480,
    y = 272
}

---Animation timer
local animation_timer = Timer.new()

---@param new_mode string | '"NONE"' | '"WHITE"' | '"BLACK"'
---@param x number
---@param y number
---Sets Loading mode
function Loading.setMode(new_mode, x, y)
    if mode == new_mode then return end
    mode = new_mode
    if mode ~= "NONE" then
        center.x = x or 480
        center.y = y or 272
        if mode == "BLACK" then
            color = 0
        elseif mode == "WHITE" then
            color = 255
        end
    end
    Timer.reset(animation_timer)
end

---Draws Loading circles
function Loading.draw()
    local time = Timer.getTime(animation_timer) / 200
    time = math.min(math.max(mode == "NONE" and 1 - time or time, 0), 1)
    for i = 1, 4 do
        local a = math.max(math.sin(Timer.getTime(GlobalTimer) / 500 * PI + i * PI / 2), 0)
        Graphics.fillCircle(center.x + (i - 2) * 12, center.y - 1 - 12 * a, 5, Color.new(color, color, color, (127 + 128 * a) * time))
    end
end
