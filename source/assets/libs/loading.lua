LOADING_NONE    = 0
LOADING_WHITE   = 1
LOADING_BLACK   = 2
local MODE      = LOADING_NONE

local LoadingColor = 0
local LoadingTimer = Timer.new()

Loading = {
    SetMode = function (new_mode)
        if MODE == new_mode then return end
        Timer.reset(LoadingTimer)
        MODE = new_mode
        if MODE == LOADING_BLACK then
            LoadingColor = 0
        elseif MODE == LOADING_WHITE then
            LoadingColor = 255
        end
    end,
    Draw = function ()
        if MODE == LOADING_NONE then
            local time = math.max(1-Timer.getTime(LoadingTimer) / 200, 0)
            for i = 1, 4 do
                local a = math.max(math.sin(Timer.getTime(GlobalTimer)/500*PI+i*PI/2),0)
                Graphics.fillCircle(480-2*12+i*12,272-1-12*a,5,Color.new(LoadingColor,LoadingColor,LoadingColor,(127+128*a)*time))
            end
        else
            local time = math.min(Timer.getTime(LoadingTimer) / 200, 1)
            for i = 1, 4 do
                local a = math.max(math.sin(Timer.getTime(GlobalTimer)/500*PI+i*PI/2),0)
                Graphics.fillCircle(480-2*12+i*12,272-1-12*a,5,Color.new(LoadingColor,LoadingColor,LoadingColor,(127+128*a)*time))
            end
        end
    end
}
Loading.SetMode(LOADING_WHITE)