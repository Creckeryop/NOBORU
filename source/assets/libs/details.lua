DETAILS_START = 0
DETAILS_WAIT  = 1
DETAILS_END   = 2
local DETAILS_MODE = DETAILS_END

local Manga     = nil
local Fade      = 0
local Point     = {x = 0, y = 0}
local Center    = {x = 0, y = 0}
local alpha     = 255
local M         = 0.5
local AnimationTimer     = Timer.new()
local NameTimer          = Timer.new()

local easeInOutQuint = function(t)
    local tmp
    if t < 0.5  then
        tmp = t * t;
        return 16 * t * tmp * tmp;
    else
        t = t - 1
        tmp = t * t;
        return 1 + 16 * t * tmp * tmp;
    end
end

Details = {
    SetManga = function (manga, x, y)
        if manga ~= nil and x ~= nil and y ~= nil then
            Manga = manga
            DETAILS_MODE = DETAILS_START
            Point.x, Point.y = x, y
            alpha = 255
            M = 0.5
            Center.x, Center.y = (MANGA_WIDTH*1.5)/2 + 40, 272
            Timer.reset(AnimationTimer)
            Timer.reset(NameTimer)
        end
    end,
    Input = function (OldPad, Pad, OldTouch, Touch)
        if Controls.check(Pad, SCE_CTRL_CIRCLE) and not Controls.check(OldPad, SCE_CTRL_CIRCLE) then
            DETAILS_MODE = DETAILS_WAIT
            Timer.reset(AnimationTimer)
            alpha = 255*Fade
            M = 0.5*Fade
            Center.x = Point.x+(Center.x-Point.x)*Fade
            Center.y = Point.y+(Center.y-Point.y)*Fade
        end
    end,
    Update = function (delta)
        if DETAILS_MODE == DETAILS_START then
            Fade = easeInOutQuint(math.min((Timer.getTime(AnimationTimer)/500),1))
        elseif DETAILS_MODE == DETAILS_WAIT then
            Fade = 1 - easeInOutQuint(math.min((Timer.getTime(AnimationTimer)/500),1))
            if Fade == 0 then
                DETAILS_MODE = DETAILS_END
            end
        end
        if Manga then
            local t = math.min(math.max(0,Timer.getTime(NameTimer)-1500),3000)
            if t == 3000 then
                if Timer.getTime(NameTimer) > 5500 then
                    Timer.reset(NameTimer)
                end
            end
        end
    end,
    Draw = function ()
        if DETAILS_MODE~=DETAILS_END then
            Graphics.fillRect(0, 960, 0, 544, Color.new(18, 18, 18, alpha * Fade))
            if Manga then
                local dif = math.max(Font.getTextWidth(FONT24, Manga.Name)-880,0)
                local t = math.min(math.max(0,Timer.getTime(NameTimer)-1500),3000)
                DrawManga(Point.x+(Center.x-Point.x)*Fade, Point.y+(Center.y - Point.y)*Fade, Manga, 1 + (Fade * M))
                Font.print(FONT24, 40 - dif*t/4000,-40 + 70 * alpha / 255*Fade,Manga.Name,Color.new(255,255,255,alpha * Fade))
            end
        end
    end,
    GetMode = function ()
        return DETAILS_MODE
    end
}