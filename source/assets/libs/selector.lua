--@class Selector
Selector = {}

function Selector:new(dup, ddown, dleft, dright, cap_foo)
	local p = {}
	local selected_item = 0
	local control_timer = Timer.new()
	local time_space = 400
	local on_x_function = nil
	function p:input(sourcecount, oldpad, pad, touch_x)
		if selected_item > sourcecount then
			selected_item = sourcecount
		end
		if touch_x ~= nil then
			selected_item = 0
			time_space = 400
		elseif Timer.getTime(control_timer) > time_space or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT)) then
			if Controls.check(pad, SCE_CTRL_DOWN + SCE_CTRL_UP + SCE_CTRL_LEFT + SCE_CTRL_RIGHT) then
				if selected_item == 0 then
					selected_item = cap_foo()
				elseif selected_item ~= 0 then
					if Controls.check(pad, SCE_CTRL_DOWN) then
						if selected_item + ddown > 0 and selected_item + ddown <= sourcecount then
							selected_item = selected_item + ddown
						end
					elseif Controls.check(pad, SCE_CTRL_UP) then
						if selected_item + dup > 0 and selected_item + dup <= sourcecount then
							selected_item = selected_item + dup
						end
					elseif Controls.check(pad, SCE_CTRL_RIGHT) then
						selected_item = selected_item + dright
					elseif Controls.check(pad, SCE_CTRL_LEFT) then
						selected_item = selected_item + dleft
					end
				end
				if sourcecount > 0 then
					if selected_item <= 0 then
						selected_item = 1
					elseif selected_item > sourcecount then
						selected_item = sourcecount
					end
				else
					selected_item = 0
				end
				if time_space > 50 then
					time_space = math.max(50, time_space / 2)
				end
				Timer.reset(control_timer)
			else
				time_space = 400
			end
		end
		if on_x_function then
			if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
				on_x_function(selected_item)
			end
		end
	end
	function p:getSelected()
		return selected_item
	end
	function p:resetSelected()
		selected_item = 0
	end
	function p:xaction(foo)
		on_x_function = foo
	end
	setmetatable(p, self)
	self.__index = self
	return p
end
