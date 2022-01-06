Notifications = {}

---Order of notification messages
local messageList = {}

---Active notification message
local currentMessage = nil

---Easing function that used here
local easingFunction = EaseInOutCubic
local animationTimer = Timer.new()

---@param message string
---@param ms number
---Adds notification with given message that will be shown on screen
function Notifications.push(message, ms)
	messageList[#messageList + 1] = {
		StringToLines(message),
		ms or 800,
		message
	}
end

---@param message string
---@param ms number
---Adds unique notification (if `message` is not in order) with given message that will be shown on screen
function Notifications.pushUnique(message, ms)
	if currentMessage and currentMessage[3] == message then
		return
	end
	for i = 1, #messageList do
		if messageList[i][3] == message then
			return
		end
	end
	messageList[#messageList + 1] = {
		StringToLines(message),
		ms or 800,
		message
	}
end

---Updates notification animation
function Notifications.update()
	if not currentMessage or Timer.getTime(animationTimer) > 1000 + currentMessage[2] then
		currentMessage = table.remove(messageList, 1)
		Timer.reset(animationTimer)
	end
end

---Draws notification on screen
function Notifications.draw()
	if not currentMessage then
		return
	end
	local time = Timer.getTime(animationTimer)
	local fade = 0
	if time < 500 then
		fade = time / 500
	elseif time < 500 + currentMessage[2] then
		fade = 1
	elseif time < 1000 + currentMessage[2] then
		fade = 1 - (time - 500 - currentMessage[2]) / 500
	end
	fade = easingFunction(fade)
	local colorWhiteFade = Color.new(255, 255, 255, 255 * fade)
	local colorGrayFade = Color.new(20, 20, 20, 255 * fade)
	local y = 0
	for i = 1, #currentMessage[1] do
		local v = currentMessage[1][i]
		local width = (Font.getTextWidth(FONT20, v) + 20) / 2
		Graphics.fillRect(480 - width, 480 + width, 544 - 100 * fade + y, 544 - 100 * fade + y + 30, colorGrayFade)
		Font.print(FONT20, 480 - width + 10, 544 - 100 * fade + y + 2, v, colorWhiteFade)
		y = y + 30
	end
end
