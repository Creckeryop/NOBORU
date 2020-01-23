local Order = {}
local Notification = nil
local AnimationTimer = Timer.new()
local function easeInOutCubic(t)
    return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
end
Notifications = {
    Push = function (message)
        Order[#Order + 1] = message
    end,
    Update = function ()
        if Timer.getTime(AnimationTimer) > 3000 or Notification == nil then
            Notification = table.remove(Order, 1)
            Timer.reset(AnimationTimer)
        end
    end,
    Draw = function ()
        local time = Timer.getTime(AnimationTimer)
        local fade
        if time < 500 then
            fade = time / 500
        elseif time < 1300 then
            fade = 1
        elseif time < 1800 then
            fade = 1 - (time - 1300) / 500
        else
            fade = 0
        end
        local fate = easeInOutCubic(fade)
        if Notification then
            local width = (Font.getTextWidth(FONT20, Notification) + 20) * fate
            local w = Font.getTextWidth(FONT20, Notification) + 20
            local height = (Font.getTextHeight(FONT20, Notification) + 10) * fate
            Graphics.fillRect(480 - width / 2, 480 + width / 2, 544 - 100 * fate, 544 - 100 * fate + height, Color.new(20, 20, 20, 255 * fate))
            Font.print(FONT20, 480 - w / 2+10, 544 - 100 * fate + 2, Notification, Color.new(255, 255, 255, 255 * fate))
        end
    end
}