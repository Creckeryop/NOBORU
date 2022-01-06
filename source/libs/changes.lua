local yOffset = 544
local yMax = 0
local rawChangesText
Changes = {}

local easingFunction = EaseInOutCubic
local animationTimer = Timer.new()

local isActive = false
local isAppUpdating = false

function Changes.load(string)
	rawChangesText = string .. "\n\n" .. Language[Settings.Language].MESSAGE.PRESS_TO_UPDATE
	isActive = true
	yMax = (544 - (Font.getTextHeight(FONT20, rawChangesText) + 20)) / 2
	Timer.reset(animationTimer)
end

function Changes.close(pad)
	if not isAppUpdating then
		if Controls.check(pad, SCE_CTRL_REAL_CIRCLE) then
			if math.ceil(yOffset - yMax) < 10 then
				isActive = false
				Timer.reset(animationTimer)
				return SCE_CTRL_REAL_CIRCLE
			end
		elseif Controls.check(pad, SCE_CTRL_REAL_CROSS) then
			Settings.updateApp()
			isAppUpdating = true
		end
	end
end

function Changes.update()
	local time = Timer.getTime(animationTimer)
	if isActive then
		time = math.max(1 - time / 800, 0)
	else
		time = math.min(time / 800, 1)
	end
	yOffset = yMax + 544 * easingFunction(time)
	if isAppUpdating and not Settings.isAppUpdating() then
		isAppUpdating = false
		isActive = false
	end
end

function Changes.draw()
	if rawChangesText and yOffset < 544 then
		Graphics.fillRect(60, 900, yOffset, yOffset + Font.getTextHeight(FONT20, rawChangesText) + 20, Color.new(0, 0, 0, 220))
		local formattedChangesText = rawChangesText
		if isAppUpdating then
			formattedChangesText = rawChangesText:match("(.+)\n(.-)\n(.-)$") .. "\n"
			.. "(" .. BytesToStr(Network.getDownloadedBytes())	.. "/" .. SettingsFunctions.GetLastVpkSize() .. ") "
			.. Language[Settings.Language].SETTINGS.PleaseWait
		end
		Font.print(FONT20, 80, yOffset + 10, formattedChangesText, COLOR_WHITE)
	end
end

function Changes.isActive()
	return isActive
end
