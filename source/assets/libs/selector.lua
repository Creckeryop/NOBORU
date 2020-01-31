--@class Selector
Selector = {}

function Selector:new(up, down, left, right)
    local p = {}
    local selected_item = 0
    local dup = up or -1
    local ddown = down or 1
    local dleft = left or -3
    local dright = right or 3
    local control_timer = Timer.new()
    local time_space = 400
    
    function p:input(sourcecount, upper, oldpad, pad, touch_x)
        if selected_item > sourcecount then
            selected_item = sourcecount
        end
        if touch_x ~= nil then
            selected_item = 0
            time_space = 400
        elseif Timer.getTime(control_timer) > time_space or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT)) then
            if Controls.check(pad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_RIGHT) or Controls.check(pad, SCE_CTRL_LEFT) then
                if selected_item == 0 then
                    selected_item = upper
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
    end
    
    function p:getSelected()
        return selected_item
    end
    
    function p:resetSelected()
        selected_item = 0
    end
    
    setmetatable(p, self)
    self.__index = self
    return p
end
