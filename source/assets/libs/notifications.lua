Notifications = {}

---Order of notification messages
local order = {}

---Active notification message
local notification = nil

---Easing function that used here
local easing = EaseInOutCubic

---@param message string
---Adds notification with given message that will be shown on screen
function Notifications.push(message)
    order[#order + 1] = message
end

local animation_timer = Timer.new()

---Updates notification animation
function Notifications.update()
    if Timer.getTime(animation_timer) > 1900 or not notification then
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
    local width = (Font.getTextWidth(FONT20, notification) + 20) / 2
    local height = Font.getTextHeight(FONT20, notification) + 10
    Graphics.fillRect(480 - width, 480 + width, 544 - 100 * fade, 544 - 100 * fade + height, Color.new(20, 20, 20, 255 * fade))
    Font.print(FONT20, 480 - width + 10, 544 - 100 * fade + 2, notification, Color.new(255, 255, 255, 255 * fade))
end