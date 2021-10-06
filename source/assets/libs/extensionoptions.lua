ExtensionOptions = {}

local status = "END"

local fade = 0
local oldFade = 0

local animationTimer = Timer.new()

local Name = ""
local extension = {}
local isInstalled = false
local parserStatus = ""
local selectedIndex = 0
local controlTimer = Timer.new()
local controlInterval = 400

local easingFunction = EaseInOutCubic

local buttons = {}

local function animationUpdate()
	if status == "START" then
		fade = easingFunction(math.min((Timer.getTime(animationTimer) / 500), 1))
	elseif status == "WAIT" then
		if fade == 0 then
			status = "END"
		end
		fade = 1 - easingFunction(math.min((Timer.getTime(animationTimer) / 500), 1))
	end
end


function ExtensionOptions.load(parser)
	if parser and parser.ID then
		Name = parser.Name
        extension = parser
        isInstalled = parser and parser.Installed == true
        parserStatus = parser and parser.Status or ""
        buttons = {}
        if isInstalled then
            if parserStatus == "Not supported" then
                buttons[#buttons+1] = "Remove"
            else
                buttons[#buttons+1] = "Update"
                buttons[#buttons+1] = "Remove"
            end
        else
            buttons[#buttons+1] = "Install"
        end
	end
end

function ExtensionOptions.show()
    if parserStatus == "" then
        Console.error("Invalid parser")
    else
        status = "START"
        oldFade = 1
        Timer.reset(animationTimer)
        selectedIndex = 0
    end
end

function ExtensionOptions.input(pad, oldpad, touch, oldtouch)
	if status == "START" then
		if TOUCH_MODES.MODE == TOUCH_MODES.NONE and oldtouch.x and touch.x and touch.x > 240 then
			TOUCH_MODES.MODE = TOUCH_MODES.READ
		elseif TOUCH_MODES.MODE ~= TOUCH_MODES.NONE and not touch.x then
			if TOUCH_MODES.MODE == TOUCH_MODES.READ and oldtouch.x then
				if oldtouch.x > 960 - 350 * fade * oldFade then
					if oldtouch.y <= 40 + 8 + 50 * #buttons then
						local id = math.floor((oldtouch.y - 40) / 50)
						if id > 0 and id <= #buttons then
							--
						end
					end
				end
			end
			TOUCH_MODES.MODE = TOUCH_MODES.NONE
		elseif touch.x then
			if touch.x < 960 - 350 * fade * oldFade then
				status = "WAIT"
				Timer.reset(animationTimer)
				oldFade = fade
			end
		end
		if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
			status = "WAIT"
			Timer.reset(animationTimer)
			oldFade = fade
		elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
			if selectedIndex > 0 then
				if selectedIndex <= #buttons then
					--
				end
			end
		end
		if touch.x then
			selectedIndex = 0
			controlInterval = 400
		elseif Timer.getTime(controlTimer) > controlInterval or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP)) then
			if Controls.check(pad, SCE_CTRL_DOWN + SCE_CTRL_UP + SCE_CTRL_LEFT + SCE_CTRL_RIGHT) then
				if Controls.check(pad, SCE_CTRL_UP) then
					if selectedIndex == 0 then
						selectedIndex = 1
					elseif selectedIndex > 1 then
						selectedIndex = selectedIndex - 1
					end
				elseif Controls.check(pad, SCE_CTRL_DOWN) then
					if selectedIndex == 0 then
						selectedIndex = 1
					elseif selectedIndex < #buttons then
						selectedIndex = selectedIndex + 1
					end
				end
				if controlInterval > 50 then
					controlInterval = math.max(50, controlInterval / 2)
				end
				Timer.reset(controlTimer)
			else
				controlInterval = 400
			end
		end
	end
end

function ExtensionOptions.update()
	if status ~= "END" then
		animationUpdate()
	end
end

function ExtensionOptions.draw()
	if status ~= "END" then
		local M = oldFade * fade
		Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 150 * M))
		Graphics.fillRect(960 - M * 350, 960, 0, 544, Color.new(0, 0, 0))
		for i = 1, #buttons do
			local v = buttons[i]
			if v == "Update" then
                if parserStatus == "New version" then
				    Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + i * 50 - 1, DownloadIcon.e, Color.new(136, 0, 255))
                else
                    Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + i * 50 - 1, DownloadIcon.e, COLOR_GRAY)
                end
			elseif v == "Remove" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + i * 50 - 1, RemoveIcon.e, Color.new(255, 74, 58))
			elseif v == "Install" then
				Graphics.drawImage(960 - M * 350 + 14, 17 + 40 + i * 50 - 1, DownloadIcon.e, COLOR_ROYAL_BLUE)
			end
			local text = Language[Settings.Language].MODES[buttons[i]] or buttons[i] or ""
            if parserStatus == "New version" and v == "Update" or v ~= "Update"  then
			    Font.print(FONT16, 960 - M * 350 + 52, 17 + 40 + i * 50, text, COLOR_WHITE)
            else
                Font.print(FONT16, 960 - M * 350 + 52, 17 + 40 + i * 50, text, COLOR_GRAY)
            end
			if i == selectedIndex then
				local y = 42 + i * 50
				local selectedRedColor = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
				local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
				for n = ks, ks + 1 do
					Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, Color.new(255, 0, 51))
					Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, selectedRedColor)
				end
			end
		end
		Font.print(BONT30, 960 - (M - 0.5) * 350 - Font.getTextWidth(BONT30, Name) / 2, 4, Name, COLOR_WHITE)
	end
end

function ExtensionOptions.getStatus()
	return status
end

function ExtensionOptions.getFade()
	return fade * oldFade
end