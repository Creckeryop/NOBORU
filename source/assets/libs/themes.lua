Themes = {
    Dark = {
        COLOR_LEFT_BACK = Color.new(0, 0, 0),
        COLOR_FONT = Color.new(255, 255, 255),
        COLOR_BACK = Color.new(0, 0, 0),
        COLOR_SELECTED = Color.new(24, 24, 24),
        COLOR_PANEL = Color.new(72, 72, 72),
        COLOR_ICON_EXTRACT = Color.new(255, 255, 255),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(137, 30, 43)
    },
    Light = {
        COLOR_LEFT_BACK = Color.new(0, 0, 0),
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(137, 30, 43)
    },
    Blue = {
        COLOR_LEFT_BACK = Color.new(15, 17, 50),
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0),
        COLOR_DETAILS_BACK = Color.new(15, 17, 50),
        COLOR_LABEL = Color.new(65, 105, 226)
    },
    Crimson = {
        COLOR_LEFT_BACK = Color.new(137, 30, 43),
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0),
        COLOR_DETAILS_BACK = Color.new(87, 28, 39),
        COLOR_LABEL = Color.new(137, 30, 43)
    },
    PiCrestOne = {
        COLOR_LEFT_BACK = Color.new(16, 0, 33),
        COLOR_FONT = Color.new(255, 255, 255),
        COLOR_BACK = Color.new(16, 0, 33),
        COLOR_SELECTED = Color.new(24, 24, 24),
        COLOR_PANEL = Color.new(200, 0, 64),
        COLOR_ICON_EXTRACT = Color.new(255, 255, 255),
        COLOR_DETAILS_BACK = Color.new(16, 0, 33),
        COLOR_LABEL = Color.new(4, 100, 100)
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
