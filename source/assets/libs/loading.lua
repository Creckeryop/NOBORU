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

Circle_icon = Image:new(Graphics.loadImage("app0:assets/icons/circle.png"))
--Circle_large_icon = Image:new(Graphics.loadImage("app0:assets/icons/circle-large.png"))

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
        Graphics.drawImage(center.x + (i - 3) * 13, center.y - 1 - 16 * a, Circle_icon.e, Color.new(color, color, color, (127 + 128 * a) * time))
    end
end
