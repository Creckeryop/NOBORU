---@param name string
---@param foo function
---Checks `foo` function for working
local function test(name, foo)
    _Gcopy = {}
    for k, v in pairs(_G) do
        _Gcopy[k] = v
    end
    local oldprint = print
    print = function(text)
        oldprint("[log] " .. name .. ": " .. text)
    end
    xpcall(function()
        foo()
        oldprint("\27[32m[success] " .. name .. "\27[00m")
    end,
    function(msg)
        oldprint("\27[31m[fail] " .. name .. ": " .. msg:match(":%d+: (.*)") .. "\27[00m")
    end)
    for k, v in pairs(_G) do
        if _Gcopy[k] == nil then
            _G[k] = nil
        else
            _G[k] = _Gcopy[k]
        end
    end
end

test("Language test", function()
    local success = true
    System = {
        getLanguage = function()
            return "Russian"
        end
    }
    dofile("../source/assets/libs/language.lua")
    Language.Default = nil
    local tabs = {}
    for name, Lang in pairs(Language) do
        for var, Cat in pairs(Lang) do
            if tabs[var] and type(tabs[var]) ~= type(Cat) then
                print("Conflict types of variable" .. name .. "." .. var .. " with AnotherLanguage." .. var)
                success = false
            end
            if type(Cat) == "table" then
                tabs[var] = tabs[var] or {}
                for k, _ in pairs(Cat) do
                    tabs[var][k] = true
                end
            else
                tabs[var] = true
            end
        end
    end
    for name, Lang in pairs(Language) do
        for var, Cat in pairs(tabs) do
            if Lang[var] == nil then
                print(name .. " " .. var .. " not found!")
                success = false
            end
            if type(Lang[var]) == "table" then
                for k, v in pairs(Cat) do
                    if Lang[var][k] == nil then
                        print(name .. "." .. var .. "." .. k .. " not found!")
                        success = false
                    end
                end
            end
        end
    end
    if not success then
        error("Watch log to see conflicts")
    end
end)

test("Settings-Language test", function()
    local success = true
    System = {
        getLanguage = function()
            return "Russian"
        end
    }
    dofile("../source/assets/libs/utils.lua")
    dofile("../source/assets/libs/language.lua")
    dofile("../source/assets/libs/settings.lua")
    Language.Default = nil
    local list = Settings.list()
    for name, Lang in pairs(Language) do
        for _, v in pairs(list) do
            if (type(v) == "table") then
                for _, sub_v in pairs(v) do
                    if Lang.SETTINGS[sub_v] == nil then
                        print("Setting '" .. sub_v .. "' is not translated to " .. name .. "")
                        success = false
                    end
                end
            elseif Lang.SETTINGS[v] == nil then
                print("Setting '" .. v .. "' is not translated to " .. name .. "")
                success = false
            end
        end
    end
    if not success then
        error("Watch log to see conflicts")
    end
    end)

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile
    pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function lines_from(file)
    local lines = {}
    for line in io.lines(file) do 
        lines[#lines + 1] = line
    end
    return table.concat(lines,"\n")
end

test("All-files Language test", function()
    local success = true
    System = {
        getLanguage = function()
            return "Russian"
        end
    }
    dofile("../source/assets/libs/language.lua")
    dofile("../source/assets/libs/settings.lua")
    Language.Default = nil
    local files = scandir("../source/assets/libs/")
    local blacklist = {"language.lua", ".", ".."}
    for _, b in ipairs(blacklist) do
        for i = 1, #files do
            if files[i] == b then
                table.remove(files,i)
                break
            end
        end
    end
    for _, file in ipairs(files) do
        local content = lines_from("../source/assets/libs/"..file)
        local a = 0
        for k in content:gmatch("(Language%[%s-Settings.Language%s-%][%.A-Za-z_]+)") do
            for lang, _ in pairs(Language) do
                local has = pcall(load("return "..k:gsub("Settings%.Language",'"'..lang..'"').."~=nil"))
                if not has then
                    print("\27[31m"..k.." for "..lang.." not found!\27[00m")
                    success = false
                end
            end
        end
    end
    if not success then
        error("Watch log to see conflicts")
    end
end)
