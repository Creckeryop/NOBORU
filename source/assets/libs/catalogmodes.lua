local mode = "END"

local fade, old_fade = 0

CatalogModes = {}

local animation_timer = Timer.new()

local Modes = {}
local Modes_fade = {}

local Filters = {}
local Checked = {}

local now_mode = 1
local TOUCH = TOUCH()
local Slider = Slider()
local SelectedId = 0
local control_timer = Timer.new()
local time_space = 400
StartSearch = false
local searchData = ""

local function getFiltersHeight()
    local h = 0
    for _, v in ipairs(Filters) do
        h = h + 50
        if v.visible then
            h = h + 50 * #v.Tags
        end
    end
    return h
end

local function countFilterElements()
    local c = 0
    for _, v in ipairs(Filters) do
        c = c + 1
        if v.visible then
            c = c + #v.Tags
        end
    end
    return c
end

---Updates scrolling movement
local function scrollUpdate()
    Slider.Y = Slider.Y + Slider.V
    Slider.V = Slider.V / 1.12
    if math.abs(Slider.V) < 0.1 then
        Slider.V = 0
    end
    if Slider.Y < 0 then
        Slider.Y = 0
        Slider.V = 0
    elseif Slider.Y > (getFiltersHeight() - 544 + 8 + #Modes * 50 + 8 + 6) then
        Slider.Y = math.max(0, getFiltersHeight() - 544 + 8 + #Modes * 50 + 8 + 6)
    end
end

local easing = EaseInOutCubic

local function animationUpdate()
    if mode == "START" then
        fade = easing(math.min((Timer.getTime(animation_timer) / 500), 1))
    elseif mode == "WAIT" then
        if fade == 0 then
            mode = "END"
        end
        fade = 1 - easing(math.min((Timer.getTime(animation_timer) / 500), 1))
    end
end

function CatalogModes.load(parser)
    if parser and parser.ID and parser.ID ~= "IMPORTED" then
        Modes = {}
        if parser.getPopularManga then
            Modes[#Modes + 1] = "Popular"
        end
        if parser.getLatestManga then
            Modes[#Modes + 1] = "Latest"
        end
        if parser.getAZManga then
            Modes[#Modes + 1] = "Alphabet"
        end
        if parser.searchManga then
            Modes[#Modes + 1] = "Search"
        end
        Modes_fade = {}
        for _, v in ipairs(Modes) do
            Modes_fade[v] = 0
        end
        Filters = parser.Filters or {}
        Checked = {}
        for k, v in ipairs(Filters) do
            if v.Type == "check" or v.Type == "checkcross" then
                Checked[k] = {}
                for i, _ in ipairs(v.Tags) do
                    Checked[k][i] = false
                end
            elseif v.Type == "radio" then
                Checked[k] = 1
            end
        end
        now_mode = 1
        searchData = ""
        Slider.Y = -50
    end
end

function CatalogModes.show()
    mode = "START"
    old_fade = 1
    Timer.reset(animation_timer)
    SelectedId = 0
end

local function setMode(id)
    if now_mode ~= id or Modes[id] == "Search" then
        if Modes[id] == "Search" then
            Keyboard.show(Language[Settings.Language].APP.SEARCH, searchData, 128, TYPE_DEFAULT, MODE_TEXT, OPT_NO_AUTOCAP)
            StartSearch = true
        else
            now_mode = id
            mode = "WAIT"
            Timer.reset(animation_timer)
            old_fade = fade
            Catalogs.terminate()
        end
    end
end

function CatalogModes.input(pad, oldpad, touch, oldtouch)
    if mode == "START" then
        if TOUCH.MODE == TOUCH.NONE and oldtouch.x and touch.x and touch.x > 240 then
            TOUCH.MODE = TOUCH.READ
            Slider.TouchY = touch.y
        elseif TOUCH.MODE ~= TOUCH.NONE and not touch.x then
            if TOUCH.MODE == TOUCH.READ and oldtouch.x then
                if oldtouch.x > 960 - 350 * fade * old_fade then
                    if oldtouch.y > 8 + 8 + 50 * #Modes then
                        local id = math.floor((Slider.Y + oldtouch.y - (8 + 8 + 50 * #Modes)) / 50) + 1
                        if id > 0 then
                            for i, f in ipairs(Filters) do
                                id = id - 1
                                if id == 0 then
                                    f.visible = not f.visible
                                    break
                                end
                                if f.visible then
                                    if id <= #f.Tags then
                                        if f.Type == "check" then
                                            Checked[i][id] = not Checked[i][id]
                                        elseif f.Type == "radio" then
                                            Checked[i] = id
                                        elseif f.Type == "checkcross" then
                                            if Checked[i][id] == "cross" then
                                                Checked[i][id] = false
                                            elseif Checked[i][id] == false then
                                                Checked[i][id] = true
                                            elseif Checked[i][id] == true then
                                                Checked[i][id] = "cross"
                                            end
                                        end
                                        break
                                    else
                                        id = id - #f.Tags
                                    end
                                end
                            end
                        end
                    else
                        local id = math.floor((oldtouch.y - 8) / 50) + 1
                        if id > 0 and id <= #Modes then
                            setMode(id)
                        end
                    end
                end
            end
            TOUCH.MODE = TOUCH.NONE
        elseif touch.x then
            if touch.x < 960 - 350 * fade * old_fade then
                mode = "WAIT"
                Timer.reset(animation_timer)
                old_fade = fade
            end
        end
        if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) or Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
            mode = "WAIT"
            Timer.reset(animation_timer)
            old_fade = fade
        elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
            if SelectedId > 0 then
                if SelectedId <= #Modes then
                    setMode(SelectedId)
                else
                    local id = SelectedId - #Modes
                    if id > 0 then
                        for i, f in ipairs(Filters) do
                            id = id - 1
                            if id == 0 then
                                f.visible = not f.visible
                                break
                            end
                            if f.visible then
                                if id <= #f.Tags then
                                    if f.Type == "check" then
                                        Checked[i][id] = not Checked[i][id]
                                    elseif f.Type == "radio" then
                                        Checked[i] = id
                                    elseif f.Type == "checkcross" then
                                        if Checked[i][id] == "cross" then
                                            Checked[i][id] = false
                                        elseif Checked[i][id] == false then
                                            Checked[i][id] = true
                                        elseif Checked[i][id] == true then
                                            Checked[i][id] = "cross"
                                        end
                                    end
                                    break
                                else
                                    id = id - #f.Tags
                                end
                            end
                        end
                    end
                end
            end
        end
        if touch.x then
            SelectedId = 0
            time_space = 400
        elseif Timer.getTime(control_timer) > time_space or (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) or Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP)) then
            if Controls.check(pad, SCE_CTRL_DOWN + SCE_CTRL_UP) then
                if Controls.check(pad, SCE_CTRL_UP) then
                    if SelectedId == 0 then
                        SelectedId = 1
                    elseif SelectedId > 1 then
                        SelectedId = SelectedId - 1
                    end
                elseif Controls.check(pad, SCE_CTRL_DOWN) then
                    if SelectedId == 0 then
                        SelectedId = 1
                    elseif SelectedId < #Modes + countFilterElements() then
                        SelectedId = SelectedId + 1
                    end
                end
                if time_space > 50 then
                    time_space = math.max(50, time_space / 2)
                end
                Timer.reset(control_timer)
            else
                time_space = 400
            end
        end
        if TOUCH.MODE == TOUCH.READ then
            if math.abs(Slider.V) > 0.1 or math.abs(touch.y - Slider.TouchY) > 10 then
                TOUCH.MODE = TOUCH.SLIDE
            end
        elseif TOUCH.MODE == TOUCH.SLIDE then
            if touch.x and oldtouch.x then
                Slider.V = oldtouch.y - touch.y
            end
        end
    end
end

function CatalogModes.update()
    if mode ~= "END" then
        if SelectedId > 0 then
            Slider.Y = Slider.Y + ((SelectedId - #Modes) * 50 - 160 - Slider.Y) / 8
        end
        animationUpdate()
        for i, v in ipairs(Modes) do
            if now_mode == i then
                Modes_fade[v] = math.min(Modes_fade[v] + 0.1, 1)
            else
                Modes_fade[v] = math.max(Modes_fade[v] - 0.1, 0)
            end
        end
        scrollUpdate()
        if StartSearch then
            if Keyboard.getState() ~= RUNNING then
                if Keyboard.getState() == FINISHED then
                    local data = Keyboard.getInput()
                    Console.write('Searching for "' .. data .. '"')
                    Catalogs.terminate()
                    for i, v in ipairs(Modes) do
                        if v == "Search" then
                            now_mode = i
                            break
                        end
                    end
                    searchData = data
                    mode = "WAIT"
                    Timer.reset(animation_timer)
                    old_fade = fade
                    if data:gsub("%s", "") ~= "" then
                        Notifications.push(string.format(Language[Settings.Language].NOTIFICATIONS.SEARCHING, data))
                    end
                end
                StartSearch = false
                Keyboard.clear()
            end
        end
    end
end

function CatalogModes.draw()
    if mode ~= "END" then
        local M = old_fade * fade
        Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, 150 * M))
        Graphics.fillRect(960 - M * 350, 960, 8 + 8 + 50 * #Modes, 544, Color.new(0, 0, 0))
        local y = 8 + 50 * #Modes + 17 - Slider.Y
        for k, f in ipairs(Filters) do
            Font.print(FONT16, 960 - M * 350 + 52, y, f.Name, COLOR_WHITE)
            if not f.visible then
                Graphics.drawImage(960 - M * 350 + 14, y - 1, Show_icon.e)
            else
                Graphics.drawImage(960 - M * 350 + 14, y - 1, Hide_icon.e)
            end
            y = y + 50
            if f.visible then
                for i, v in ipairs(f.Tags) do
                    if y - 1 > 544 then
                        break
                    end
                    if y - 1 + 24 > 8 + 50 * #Modes + 8 then
                        if f.Type == "check" then
                            if Checked[k][i] then
                                Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Checkbox_checked_icon.e)
                            else
                                Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Checkbox_icon.e)
                            end
                        elseif f.Type == "checkcross" then
                            if Checked[k][i] then
                                if Checked[k][i] == "cross" then
                                    Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Checkbox_crossed_icon.e, Color.new(255, 255, 255, 100))
                                else
                                    Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Checkbox_checked_icon.e)
                                end
                            else
                                Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Checkbox_icon.e)
                            end
                        elseif f.Type == "radio" then
                            if Checked[k] == i then
                                Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Radio_checked_icon.e)
                            else
                                Graphics.drawImage(960 - M * 350 + 14 + 20, y - 1, Radio_icon.e)
                            end
                        end
                        if type(Checked[k]) == "table" and Checked[k][i] == "cross" then
                            Font.print(FONT16, 960 - M * 350 + 52 + 20, y, v, Color.new(255, 255, 255, 100))
                        else
                            Font.print(FONT16, 960 - M * 350 + 52 + 20, y, v, COLOR_WHITE)
                        end
                    end
                    y = y + 50
                end
            end
        end
        Graphics.fillRect(960 - M * 350, 960, 0, 8 + 8 + 50 * #Modes, Color.new(0, 0, 0))
        for i, v in ipairs(Modes) do
            if v == "Popular" then
                Graphics.drawImage(960 - M * 350 + 14, 25 + (i - 1) * 50 - 1, Hot_icon.e, COLOR_GRADIENT(COLOR_WHITE, COLOR_ROYAL_BLUE, Modes_fade[v]))
            elseif v == "Latest" then
                Graphics.drawImage(960 - M * 350 + 14, 25 + (i - 1) * 50 - 1, History_icon.e, COLOR_GRADIENT(COLOR_WHITE, COLOR_ROYAL_BLUE, Modes_fade[v]))
            elseif v == "Search" then
                Graphics.drawImage(960 - M * 350 + 14, 25 + (i - 1) * 50 - 1, Search_icon.e, COLOR_GRADIENT(COLOR_WHITE, COLOR_ROYAL_BLUE, Modes_fade[v]))
            elseif v == "Alphabet" then
                Graphics.drawImage(960 - M * 350 + 14, 25 + (i - 1) * 50 - 1, Az_icon.e, COLOR_GRADIENT(COLOR_WHITE, COLOR_ROYAL_BLUE, Modes_fade[v]))
            end
            local text = Modes[i]
            if Modes[i] == "Search" and searchData:gsub("%s", "") ~= "" then
                text = text .. " : " .. searchData
            end
            Font.print(FONT16, 960 - M * 350 + 52, 25 + (i - 1) * 50, text, COLOR_GRADIENT(COLOR_WHITE, COLOR_ROYAL_BLUE, Modes_fade[v]))
            if i == SelectedId then
                local y = 10 + (i - 1) * 50
                local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
                local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
                for n = ks, ks + 1 do
                    Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, Themes[Settings.Theme].COLOR_SELECTOR_DETAILS)
                    Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, SELECTED_RED)
                end
            end
        end
        if SelectedId > #Modes then
            local y = 8 + 50 * #Modes - Slider.Y + 50 * (SelectedId - #Modes - 1) + 2
            local SELECTED_RED = Color.new(255, 255, 255, 100 * M * math.abs(math.sin(Timer.getTime(GlobalTimer) / 500)))
            local ks = math.ceil(2 * math.sin(Timer.getTime(GlobalTimer) / 100))
            for n = ks, ks + 1 do
                Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, Themes[Settings.Theme].COLOR_SELECTOR_DETAILS)
                Graphics.fillEmptyRect(960 + 5 - 350 * M + n, 960 - 10 - n - 350 * M + 350, y + n + 2, y + 50 - n + 1, SELECTED_RED)
            end
        end
        Graphics.fillRect(960 - M * 350 + (350 - 5), 960, 8 + 8 + 50 * #Modes, 544, COLOR_BLACK)
        if countFilterElements() > 7 then
            local h = getFiltersHeight() / (544 - 8 - 8 - 50 * #Modes)
            Graphics.fillRect(960 - M * 350 + (350 - 5), 960, 8 + 8 + 50 * #Modes + (Slider.Y) / h, 8 + 8 + 50 * #Modes + (Slider.Y + (544 - 8 - 8 - 50 * #Modes)) / h, COLOR_WHITE)
        end
    end
end

function CatalogModes.getMode()
    return mode
end

function CatalogModes.getFade()
    return fade * old_fade
end

function CatalogModes.getMangaMode()
    return Modes[now_mode]
end

function CatalogModes.getSearchData()
    return searchData
end

function CatalogModes.getTagsData()
    local filter = {}
    for k, f in ipairs(Filters) do
        if f.Type == "check" then
            local list = {}
            for i, v in ipairs(Checked[k]) do
                if v then
                    list[#list + 1] = f.Tags[i]
                end
            end
            filter[#filter + 1] = list
            filter[f.Name] = list
        elseif f.Type == "checkcross" then
            local include = {}
            for i, v in ipairs(Checked[k]) do
                if v == true then
                    include[#include + 1] = f.Tags[i]
                end
            end
            local exclude = {}
            for i, v in ipairs(Checked[k]) do
                if v == "cross" then
                    exclude[#exclude + 1] = f.Tags[i]
                end
            end
            filter[#filter + 1] = {
                include = include,
                exclude = exclude
            }
            filter[f.Name] = filter[#filter]
        elseif f.Type == "radio" then
            filter[#filter + 1] = f.Tags[Checked[k]] or ""
            filter[f.Name] = f.Tags[Checked[k]] or ""
        end
    end
    return filter
end
