local Y = 23
local MODE_HIDE = 0
local MODE_SHOW = 1
local MODE      = MODE_HIDE
local cross     = Image:new(Graphics.loadImage("app0:assets/images/cross_button.png"))
local triangle  = Image:new(Graphics.loadImage("app0:assets/images/triangle_button.png"))
local square    = Image:new(Graphics.loadImage("app0:assets/images/square_button.png"))
local circle    = Image:new(Graphics.loadImage("app0:assets/images/circle_button.png"))
local dpad      = Image:new(Graphics.loadImage("app0:assets/images/dpad.png"))
local Hints = {}
Panel = {
    Hide = function ()
        if MODE == MODE_SHOW then
            MODE = MODE_HIDE
        end
    end,
    Show = function ()
        if MODE == MODE_HIDE then
            MODE = MODE_SHOW
        end
    end,
    Set = function (buttons)
        if type(buttons) == "table" then
            Hints = {}
            for k, v in pairs(buttons) do
                Hints[k] = v
            end
        end
    end,
    Update = function ()
        if MODE == MODE_HIDE then
            Y = math.min(23, Y + (23-Y)/4)
        elseif MODE == MODE_SHOW then
            Y = math.max(0, Y - Y/4)
        end
    end,
    Draw = function ()
        Graphics.fillRect(0, 960, 521 + Y, 524 + Y, Color.new(0, 0, 0, 32))
        Graphics.fillRect(0, 960, 522 + Y, 524 + Y, Color.new(0, 0, 0, 32))
        Graphics.drawImage(0, 524 + Y, LUA_PANEL)
        
        local x = 20
        for k, v in pairs(Hints) do
            if k == "Triangle" then
                if triangle then
                    Graphics.drawImage(x, 526 + Y, triangle.e)
                end
                x = x + 20
            elseif k == "Square" then
                if square then
                    Graphics.drawImage(x, 526 + Y, square.e)
                end
                x = x + 20
            elseif k == "Circle" then
                if circle then
                    Graphics.drawImage(x, 526 + Y, circle.e)
                end
                x = x + 20
            elseif k == "Cross" then
                if cross then
                    Graphics.drawImage(x, 526 + Y, cross.e)
                end
                x = x + 20
            elseif k == "DPad" then
                if dpad then
                    Graphics.drawImage(x, 526 + Y, dpad.e)
                end
                x = x + 20
            else
                Font.print(FONT12, x, 526 + Y, k, Color.new(0, 0, 0))
                x = x + Font.getTextWidth(FONT12, k) + 5
            end
            Font.print(FONT12, x, 526 + Y, v, Color.new(0, 0, 0))
            x = x + Font.getTextWidth(FONT12, v) + 20
        end
    end
}