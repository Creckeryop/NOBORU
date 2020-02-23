Themes = {
    Dark = {
        COLOR_FONT = Color.new(255, 255, 255),
        COLOR_BACK = Color.new(0, 0, 0),
        COLOR_SELECTED = Color.new(24, 24, 24),
        COLOR_PANEL = Color.new(72, 72, 72),
        COLOR_ICON_EXTRACT = Color.new(255, 255, 255)
    },
    Light = {
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0)
    }
}

local themes = {}
for k, _ in pairs(Themes) do
    themes[#themes + 1] = k
end

---@return table
---Gives list of all available themes
function GetThemes()
    return themes
end