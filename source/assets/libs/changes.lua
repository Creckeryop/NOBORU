local Y = 544
local FinalY = 0
local active = false
local str
Changes = {}

function Changes.load(string)
    str = string
    active = true
    FinalY = 544 / 2 - Font.getTextHeight(FONT20, string)/2 - 10
end

function Changes.close()
    if math.ceil(Y - FinalY) < 10 then
        active = false
    end
end

function Changes.update()
    if active then
        Y = math.max(Y + (FinalY - Y) / 8, FinalY)
    else
        Y = math.min(Y + (544 - Y) / 8, 544)
    end
end

function Changes.draw()
    if str and Y ~= 544 then
        Graphics.fillRect(0, 960, Y, Y + Font.getTextHeight(FONT20, str) + 10, COLOR_BLACK)
        Font.print(FONT20, 20, Y+5, str, COLOR_WHITE)
    end
end

function Changes.isActive()
    return active
end
