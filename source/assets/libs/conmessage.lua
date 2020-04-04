local Offset = 544
local FinalY = 0
local active = false
local str
ConnectMessage = {}

local easing = EaseInOutCubic
local animation_timer = Timer.new()

function ConnectMessage.show()
    str = Language[Settings.Language].MESSAGE.LOST_CONNECTION
    active = true
    FinalY = 544 / 2 - (Font.getTextHeight(FONT20, str) + 20) / 2
    Timer.reset(animation_timer)
end

function ConnectMessage.input(pad, oldpad)
    if Controls.check(pad, SCE_CTRL_REAL_CROSS) and active and Offset == FinalY then
        ChapterSaver.clearDownloadingList()
        active = false
        return SCE_CTRL_REAL_CROSS
    end
end

local connection_timer = Timer.new()

function ConnectMessage.update()
    local time = Timer.getTime(animation_timer)
    if active then
        time = math.max(1 - time / 800, 0)
        if Timer.getTime(connection_timer) > 1000 then
            if Threads.netActionUnSafe(Network.isWifiEnabled) then
                active = false
            end
            Timer.reset(connection_timer)
        end
    else
        time = math.min(time / 800, 1)
        Timer.reset(connection_timer)
    end
    Offset = FinalY + 544 * easing(time)
end

function ConnectMessage.draw()
    if str and Offset < 544 then
        Graphics.fillRect(60, 900, Offset, Offset + Font.getTextHeight(FONT20, str) + 27, Color.new(0, 0, 0, 220))
        Font.print(FONT20, 80, Offset + 10, str, COLOR_WHITE)
    end
end

function ConnectMessage.isActive()
    return active
end
