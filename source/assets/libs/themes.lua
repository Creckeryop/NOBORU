Themes = {
    Dark = {
        COLOR_LEFT_BACK = Color.new(0, 0, 0),
        COLOR_FONT = Color.new(255, 255, 255),
        COLOR_BACK = Color.new(0, 0, 0),
        COLOR_SELECTED = Color.new(24, 24, 24),
        COLOR_PANEL = Color.new(72, 72, 72),
        COLOR_ICON_EXTRACT = Color.new(255, 255, 255),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(137, 30, 43),
        COLOR_SELECTOR_DETAILS = Color.new(255, 0, 51),
        COLOR_SELECTOR_MENU = Color.new(65, 105, 226)
    },
    Light = {
        COLOR_LEFT_BACK = Color.new(0, 0, 0),
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(137, 30, 43),
        COLOR_SELECTOR_DETAILS = Color.new(255, 0, 51),
        COLOR_SELECTOR_MENU = Color.new(65, 105, 226)
    },
    --[[
    Blue = {
        COLOR_LEFT_BACK = Color.new(15, 17, 50),
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(65, 105, 226),
        COLOR_SELECTOR_DETAILS = Color.new(255, 0, 51),
        COLOR_SELECTOR_MENU = Color.new(65, 105, 226)
    },
    Crimson = {
        COLOR_LEFT_BACK = Color.new(137, 30, 43),
        COLOR_FONT = Color.new(0, 0, 0),
        COLOR_BACK = Color.new(255, 255, 255),
        COLOR_SELECTED = Color.new(200, 200, 200),
        COLOR_PANEL = Color.new(255, 255, 255),
        COLOR_ICON_EXTRACT = Color.new(0, 0, 0),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(137, 30, 43),
        COLOR_SELECTOR_DETAILS = Color.new(255, 0, 51),
        COLOR_SELECTOR_MENU = Color.new(65, 105, 226)
    },
    --]]
    PiCrestOne = {
        COLOR_LEFT_BACK = Color.new(0, 0, 0),
        COLOR_FONT = Color.new(255, 255, 255),
        COLOR_BACK = Color.new(0, 0, 0),
        COLOR_SELECTED = Color.new(24, 24, 24),
        COLOR_PANEL = Color.new(200, 0, 64),
        COLOR_ICON_EXTRACT = Color.new(255, 255, 255),
        COLOR_DETAILS_BACK = Color.new(0, 0, 0),
        COLOR_LABEL = Color.new(4, 100, 100),
        COLOR_SELECTOR_DETAILS = Color.new(104, 0, 200),
        COLOR_SELECTOR_MENU = Color.new(104, 0, 200)
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
