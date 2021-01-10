ConnectMessage = {}

local yOffset = 544
local yFinal = 0
local str

local easingFunction = EaseInOutCubic
local animationTimer = Timer.new()
local connectionTimer = Timer.new()

local is_active = false

function ConnectMessage.show()
	str = Language[Settings.Language].MESSAGE.LOST_CONNECTION
	is_active = true
	yFinal = 544 / 2 - (Font.getTextHeight(FONT20, str) + 20) / 2
	Timer.reset(animationTimer)
end

function ConnectMessage.input(pad)
	if Controls.check(pad, SCE_CTRL_REAL_CROSS) and is_active and yOffset == yFinal then
		ChapterSaver.clearDownloadingList()
		is_active = false
		return SCE_CTRL_REAL_CROSS
	end
end

function ConnectMessage.update()
	local time = Timer.getTime(animationTimer)
	if is_active then
		time = math.max(1 - time / 800, 0)
		if Timer.getTime(connectionTimer) > 1000 then
			if Threads.netActionUnSafe(Network.isWifiEnabled) then
				is_active = false
			end
			Timer.reset(connectionTimer)
		end
	else
		time = math.min(time / 800, 1)
		Timer.reset(connectionTimer)
	end
	yOffset = yFinal + 544 * easingFunction(time)
end

function ConnectMessage.draw()
	if str and yOffset < 544 then
		Graphics.fillRect(60, 900, yOffset, yOffset + Font.getTextHeight(FONT20, str) + 27, Color.new(0, 0, 0, 220))
		Font.print(FONT20, 80, yOffset + 10, str, COLOR_WHITE)
	end
end

function ConnectMessage.isActive()
	return is_active
end
