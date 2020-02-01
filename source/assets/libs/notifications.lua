Notifications = {}

local function to_lines(str)
    if str:sub(-1)~="\n" then
        str = str.."\n"
    end
    local lines = {}
    for line in str:gmatch("(.-)\n") do
        lines[#lines+1] = line
    end
    return lines
end

---Order of notification messages
local order = {}

---Active notification message
local notification = nil

---Easing function that used here
local easing = EaseInOutCubic

---@param message string
---Adds notification with given message that will be shown on screen
function Notifications.push(message)
    order[#order + 1] = to_lines(message)
end

local animation_timer = Timer.new()

---Updates notification animation
function Notifications.update()
    if Timer.getTime(animation_timer) > 1800 or not notification then
        notification = table.remove(order, 1)
        Timer.reset(animation_timer)
    end
end

---Draws notification on screen
function Notifications.draw()
    if not notification then return end
    local time = Timer.getTime(animation_timer)
    local fade = 0
    if time < 500 then
        fade = time / 500
    elseif time < 1300 then
        fade = 1
    elseif time < 1800 then
        fade = 1 - (time - 1300) / 500
    end
    fade = easing(fade)
    local NEW_WHITE = Color.new(255, 255, 255, 255 * fade)
    local NEW_GRAY = Color.new(20, 20, 20, 255 * fade)
    local y = 0
    for i, v in ipairs(notification) do
        local width = (Font.getTextWidth(FONT20, v) + 20) / 2
        Graphics.fillRect(480 - width, 480 + width, 544 - 100 * fade + y, 544 - 100 * fade + y + 30, NEW_GRAY)
        Font.print(FONT20, 480 - width + 10, 544 - 100 * fade + y + 2, v, NEW_WHITE)
        y = y + 30
    end
end
