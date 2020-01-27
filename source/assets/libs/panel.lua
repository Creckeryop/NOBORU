local mode = "HIDE"

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
    if mode ~= "SHOW" then return end
    mode = "HIDE"
end

---Shows Panel
function Panel.show()
    if mode ~= "HIDE" then return end
    mode = "SHOW"
end

---@param buttons table
---Sets table of actions
function Panel.set(buttons)
    hints = buttons
end

---Local variable used as vertical offset of panel
local y = 23

---Updates Panel Animation
function Panel.update(dt)
    if mode == "HIDE" then
        y = math.min(23, y + dt * (23 - y) / 4)
    elseif mode == "SHOW" then
        y = math.max(0, y - dt * y / 4)
    end
end

---Draws Panel on screen
function Panel.draw()
    if y >= 23 then return end
    Graphics.fillRect(0, 960, 521 + y, 524 + y, Color.new(0, 0, 0, 32))
    Graphics.fillRect(0, 960, 522 + y, 524 + y, Color.new(0, 0, 0, 32))
    Graphics.drawImage(0, 524 + y, LUA_PANEL)
    local x = 20
    for _, v in ipairs(hints) do
        if textures_16x16[v] then
            Graphics.drawImage(x, 526 + y, textures_16x16[v].e)
            x = x + 20
        else
            Font.print(FONT12, x, 526 + y, v, COLOR_BLACK)
            x = x + Font.getTextWidth(FONT12, v) + 5
        end
        Font.print(FONT12, x, 526 + y, hints[v], COLOR_BLACK)
        x = x + Font.getTextWidth(FONT12, hints[v]) + 10
    end
end
