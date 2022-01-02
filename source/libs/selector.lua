--@class Selector
Selector = {}

function Selector:new(dUp, dDown, dLeft, dRight, capFunction)
	local p = {}
	local itemSelected = 0
	local controlTimer = Timer.new()
	local timeInterval = 400
	local onCrossFunction = nil
	function p:input(sourcecount, oldpad, pad, touchX)
		if itemSelected > sourcecount then
			itemSelected = sourcecount
		end
		if touchX ~= nil then
			itemSelected = 0
			timeInterval = 400
		elseif Timer.getTime(controlTimer) > timeInterval or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT)) then
			if Controls.check(pad, SCE_CTRL_DOWN + SCE_CTRL_UP + SCE_CTRL_LEFT + SCE_CTRL_RIGHT) then
				if itemSelected == 0 then
					itemSelected = capFunction()
				elseif itemSelected ~= 0 then
					if Controls.check(pad, SCE_CTRL_DOWN) then
						if itemSelected + dDown > 0 and itemSelected + dDown <= sourcecount then
							itemSelected = itemSelected + dDown
						end
					elseif Controls.check(pad, SCE_CTRL_UP) then
						if itemSelected + dUp > 0 and itemSelected + dUp <= sourcecount then
							itemSelected = itemSelected + dUp
						end
					elseif Controls.check(pad, SCE_CTRL_RIGHT) then
						itemSelected = itemSelected + dRight
					elseif Controls.check(pad, SCE_CTRL_LEFT) then
						itemSelected = itemSelected + dLeft
					end
				end
				if sourcecount > 0 then
					if itemSelected <= 0 then
						itemSelected = 1
					elseif itemSelected > sourcecount then
						itemSelected = sourcecount
					end
				else
					itemSelected = 0
				end
				if timeInterval > 50 then
					timeInterval = math.max(50, timeInterval / 2)
				end
				Timer.reset(controlTimer)
			else
				timeInterval = 400
			end
		end
		if onCrossFunction then
			if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
				onCrossFunction(itemSelected)
			end
		end
	end
	function p:getSelected()
		return itemSelected
	end
	function p:resetSelected()
		itemSelected = 0
	end
	function p:xaction(foo)
		onCrossFunction = foo
	end
	setmetatable(p, self)
	self.__index = self
	return p
end
