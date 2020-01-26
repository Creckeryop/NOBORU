---Order of notification messages
local Order = {}

---Active notification message
local Notification = nil

local animation_timer = Timer.new()

---@param time number @ in range of [0..1]
---Function to get easing value in range [0..1]
local function easeInOutCubic(time)
    return time < 0.5 and 4 * time * time * time or (time - 1) * (2 * time - 2) * (2 * time - 2) + 1
end

---Table for notification
Notifications = {}

---@param message string
---Adds notification with given message that will be shown on screen
function Notifications.Push(message)
    Order[#Order + 1] = message
end

---Updates notification animation
function Notifications.Update()
    if Timer.getTime(animation_timer) > 2000 or not Notification then
        Notification = table.remove(Order, 1)
        Timer.reset(animation_timer)
    end
end

---Draws notification on screen
function Notifications.Draw()
    if not Notification then return end
    local time = Timer.getTime(animation_timer)
    local fade = 0
    if time < 500 then
        fade = time / 500
    elseif time < 1300 then
        fade = 1
    elseif time < 1800 then
        fade = 1 - (time - 1300) / 500
    end
    fade = easeInOutCubic(fade)
    local width = (Font.getTextWidth(FONT20, Notification) + 20) * fade
    local w = Font.getTextWidth(FONT20, Notification) + 20
    local height = Font.getTextHeight(FONT20, Notification) + 10
    Graphics.fillRect(480 - width / 2, 480 + width / 2, 544 - 100 * fade, 544 - 100 * fade + height, Color.new(20, 20, 20, 255 * fade))
    Font.print(FONT20, 480 - w / 2 + 10, 544 - 100 * fade + 2, Notification, Color.new(255, 255, 255, 255 * fade))
end