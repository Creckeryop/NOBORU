local MODE_HIDE = 0
local MODE_SHOW = 1
local Mode = MODE_HIDE

---Textures for PS Buttons
textures_16x16 = {
    Cross = Image:new(Graphics.loadImage("app0:assets/images/cross_button.png")),
    Triangle = Image:new(Graphics.loadImage("app0:assets/images/triangle_button.png")),
    Square = Image:new(Graphics.loadImage("app0:assets/images/square_button.png")),
    Circle = Image:new(Graphics.loadImage("app0:assets/images/circle_button.png")),
    DPad = Image:new(Graphics.loadImage("app0:assets/images/dpad.png"))
}

---Table of actions
local hints = {}

---Table of Panel functions
Panel = {}

---Hides Panel
function Panel.hide()
    if Mode ~= MODE_SHOW then return end
    Mode = MODE_HIDE
end

---Shows Panel
function Panel.show()
    if Mode ~= MODE_HIDE then return end
    Mode = MODE_SHOW
end

---@param buttons table
---Sets table of actions
function Panel.set(buttons)
    hints = buttons
end

---Local variable used as vertical offset of panel
local Y = 23

---Updates Panel Animation
function Panel.update()
    if Mode == MODE_HIDE then
        Y = math.min(23, Y + (23 - Y) / 4)
    elseif Mode == MODE_SHOW then
        Y = math.max(0, Y - Y / 4)
    end
end

---Draws Panel on screen
function Panel.draw()
    if Y >= 23 then return end
    Graphics.fillRect(0, 960, 521 + Y, 524 + Y, Color.new(0, 0, 0, 32))
    Graphics.fillRect(0, 960, 522 + Y, 524 + Y, Color.new(0, 0, 0, 32))
    Graphics.drawImage(0, 524 + Y, LUA_PANEL)
    local x = 20
    for _, v in ipairs(hints) do
        if textures_16x16[v] then
            Graphics.drawImage(x, 526 + Y, textures_16x16[v].e)
            x = x + 20
        else
            Font.print(FONT12, x, 526 + Y, v, COLOR_BLACK)
            x = x + Font.getTextWidth(FONT12, v) + 5
        end
        Font.print(FONT12, x, 526 + Y, hints[v], COLOR_BLACK)
        x = x + Font.getTextWidth(FONT12, hints[v]) + 10
    end
end
