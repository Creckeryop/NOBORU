ConnectMessage = {}

local yOffset = 544
local yMax = 0
local message

local easingFunction = EaseInOutCubic
local animationTimer = Timer.new()
local connectionTimer = Timer.new()

local isActive = false

function ConnectMessage.show()
	message = Language[Settings.Language].MESSAGE.LOST_CONNECTION
	isActive = true
	yMax = 544 / 2 - (Font.getTextHeight(FONT20, message) + 20) / 2
	Timer.reset(animationTimer)
end

function ConnectMessage.input(pad)
	if Controls.check(pad, SCE_CTRL_REAL_CROSS) and isActive and yOffset == yMax then
		ChapterSaver.clearDownloadingList()
		isActive = false
		return SCE_CTRL_REAL_CROSS
	end
end

function ConnectMessage.update()
	local time = Timer.getTime(animationTimer)
	if isActive then
		time = math.max(1 - time / 800, 0)
		if Timer.getTime(connectionTimer) > 1000 then
			if Threads.netActionUnSafe(Network.isWifiEnabled) then
				isActive = false
			end
			Timer.reset(connectionTimer)
		end
	else
		time = math.min(time / 800, 1)
		Timer.reset(connectionTimer)
	end
	yOffset = yMax + 544 * easingFunction(time)
end

function ConnectMessage.draw()
	if message and yOffset < 544 then
		Graphics.fillRect(60, 900, yOffset, yOffset + Font.getTextHeight(FONT20, message) + 27, Color.new(0, 0, 0, 220))
		Font.print(FONT20, 80, yOffset + 10, message, COLOR_WHITE)
	end
end

function ConnectMessage.isActive()
	return isActive
end
