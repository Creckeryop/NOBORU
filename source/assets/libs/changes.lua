local Offset = 544
local FinalY = 0
local active = false
local str
Changes = {}

local easing = EaseInOutCubic
local updating = false
local animation_timer = Timer.new()

function Changes.load(string)
    str = string .. "\n\nPress X to update\nPress O to cancel"
    active = true
    FinalY = 544 / 2 - (Font.getTextHeight(FONT20, str) + 20) / 2
    Timer.reset(animation_timer)
end

function Changes.close(pad)
    if not updating then
        if Controls.check(pad, SCE_CTRL_CIRCLE) then
            if math.ceil(Offset - FinalY) < 10 then
                active = false
                Timer.reset(animation_timer)
                return SCE_CTRL_CIRCLE
            end
        elseif Controls.check(pad, SCE_CTRL_CROSS) then
            Settings:updateApp()
            updating = true
        end
    end
end

function Changes.update()
    local time = Timer.getTime(animation_timer)
    if active then
        time = math.max(1 - time / 800, 0)
    else
        time = math.min(time / 800, 1)
    end
    Offset = FinalY + 544 * easing(time)
    if updating and not Settings:isAppUpdating() then
        updating = false
        active = false
    end
end

function Changes.draw()
    if str and Offset < 544 then
        Graphics.fillRect(60, 900, Offset, Offset + Font.getTextHeight(FONT20, str) + 20, Color.new(0, 0, 0, 220))
        Font.print(FONT20, 80, Offset + 10, updating and str:match("(.+)\n(.-)\n(.-)$") .. "\n" .. Language[Settings.Language].SETTINGS.PleaseWait or str, COLOR_WHITE)
    end
end

function Changes.isActive()
    return active
end
