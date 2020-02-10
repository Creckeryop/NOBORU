local doesDirExist = System.doesDirExist
local listDirectory = System.listDirectory
local deleteFile = System.deleteFile
local deleteDirectory = System.deleteDirectory

utf8ascii = {
    ["А"] = "%%C0",
    ["Б"] = "%%C1",
    ["В"] = "%%C2",
    ["Г"] = "%%C3",
    ["Д"] = "%%C4",
    ["Е"] = "%%C5",
    ["Ё"] = "%%A8",
    ["Ж"] = "%%C6",
    ["З"] = "%%C7",
    ["И"] = "%%C8",
    ["Й"] = "%%C9",
    ["К"] = "%%CA",
    ["Л"] = "%%CB",
    ["М"] = "%%CC",
    ["Н"] = "%%CD",
    ["О"] = "%%CE",
    ["П"] = "%%CF",
    ["Р"] = "%%D0",
    ["С"] = "%%D1",
    ["Т"] = "%%D2",
    ["У"] = "%%D3",
    ["Ф"] = "%%D4",
    ["Х"] = "%%D5",
    ["Ц"] = "%%D6",
    ["Ч"] = "%%D7",
    ["Ш"] = "%%D8",
    ["Щ"] = "%%D9",
    ["Ъ"] = "%%DA",
    ["Ы"] = "%%DB",
    ["Ь"] = "%%DC",
    ["Э"] = "%%DD",
    ["Ю"] = "%%DE",
    ["Я"] = "%%DF",
    ["а"] = "%%E0",
    ["б"] = "%%E1",
    ["в"] = "%%E2",
    ["г"] = "%%E3",
    ["д"] = "%%E4",
    ["е"] = "%%E5",
    ["ё"] = "%%B8",
    ["ж"] = "%%E6",
    ["з"] = "%%E7",
    ["и"] = "%%E8",
    ["й"] = "%%E9",
    ["к"] = "%%EA",
    ["л"] = "%%EB",
    ["м"] = "%%EC",
    ["н"] = "%%ED",
    ["о"] = "%%EE",
    ["п"] = "%%EF",
    ["р"] = "%%F0",
    ["с"] = "%%F1",
    ["т"] = "%%F2",
    ["у"] = "%%F3",
    ["ф"] = "%%F4",
    ["х"] = "%%F5",
    ["ц"] = "%%F6",
    ["ч"] = "%%F7",
    ["ш"] = "%%F8",
    ["щ"] = "%%F9",
    ["ъ"] = "%%FA",
    ["ы"] = "%%FB",
    ["ь"] = "%%FC",
    ["э"] = "%%FD",
    ["ю"] = "%%FE",
    ["я"] = "%%FF"
}

function it_utf8(str)
    return string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)")
end

function string.sub(str, i, k)
    k = k or -1
    local text = {}
    for c in it_utf8(str) do
        if i == 1 then
            if k ~= 0 then
                text[#text + 1] = c
                k = k - 1
            else
                break
            end
        else
            i = i - 1
        end
    end
    return table.concat(text)
end

---@param t table
---@param name string
---@return string
---Converts table to string
function table.serialize(t, name)
    local concat = table.concat
    local type = type
    local function serialize(_t, _name)
        local P = {}
        for k, v in pairs(_t) do
            if type(v) == "string" then
                if type(k) == "string" then
                    P[#P + 1] = '["' .. k:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. '"]="' .. v:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. '"'
                else
                    P[#P + 1] = '[' .. k .. ']="' .. v:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. '"'
                end
            elseif type(v) == "table" then
                if type(k) == "string" then
                    P[#P + 1] = serialize(v, '["' .. k:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. '"]')
                else
                    P[#P + 1] = serialize(v, '[' .. k .. ']')
                end
            elseif type(v) == "boolean" or type(v) == "number" then
                if type(k) == "string" then
                    P[#P + 1] = '["' .. k:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. '"]=' .. tostring(v) .. ''
                else
                    P[#P + 1] = '[' .. k .. ']=' .. tostring(v) .. ''
                end
            else
                if type(k) == "string" then
                    P[#P + 1] = '["' .. k:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. '"]="' .. tostring(v) .. '"'
                else
                    P[#P + 1] = '[' .. k .. ']="' .. tostring(v) .. '"'
                end
            end
        end
        return _name .. " = {" .. concat(P, ", ") .. "}"
    end
    return serialize(t, name)
end

---@param t table
---Reverses table
function table.reverse(t)
    local i, j = 1, #t
    while i < j do
        t[i], t[j] = t[j], t[i]
        i = i + 1
        j = j - 1
    end
end

---@param t table
---@return table
---Creates copyied table
function table.clone(t)
    local pairs = pairs
    local type = type
    local function clone(_t)
        local new_t = {}
        for k, v in pairs(_t) do
            if type(v) == "table" then
                new_t[k] = clone(v)
            else
                new_t[k] = v
            end
        end
        return new_t
    end
    return clone(t)
end

local a2u8 = {
    [128] = "\208\130",
    [129] = "\208\131",
    [130] = "\226\128\154",
    [131] = "\209\147",
    [132] = "\226\128\158",
    [133] = "\226\128\166",
    [134] = "\226\128\160",
    [135] = "\226\128\161",
    [136] = "\226\130\172",
    [137] = "\226\128\176",
    [138] = "\208\137",
    [139] = "\226\128\185",
    [140] = "\208\138",
    [141] = "\208\140",
    [142] = "\208\139",
    [143] = "\208\143",
    [144] = "\209\146",
    [145] = "\226\128\152",
    [146] = "\226\128\153",
    [147] = "\226\128\156",
    [148] = "\226\128\157",
    [149] = "\226\128\162",
    [150] = "\226\128\147",
    [151] = "\226\128\148",
    [152] = "\194\152",
    [153] = "\226\132\162",
    [154] = "\209\153",
    [155] = "\226\128\186",
    [156] = "\209\154",
    [157] = "\209\156",
    [158] = "\209\155",
    [159] = "\209\159",
    [160] = "\194\160",
    [161] = "\209\142",
    [162] = "\209\158",
    [163] = "\208\136",
    [164] = "\194\164",
    [165] = "\210\144",
    [166] = "\194\166",
    [167] = "\194\167",
    [168] = "\208\129",
    [169] = "\194\169",
    [170] = "\208\132",
    [171] = "\194\171",
    [172] = "\194\172",
    [173] = "\194\173",
    [174] = "\194\174",
    [175] = "\208\135",
    [176] = "\194\176",
    [177] = "\194\177",
    [178] = "\208\134",
    [179] = "\209\150",
    [180] = "\210\145",
    [181] = "\194\181",
    [182] = "\194\182",
    [183] = "\194\183",
    [184] = "\209\145",
    [185] = "\226\132\150",
    [186] = "\209\148",
    [187] = "\194\187",
    [188] = "\209\152",
    [189] = "\208\133",
    [190] = "\209\149",
    [191] = "\209\151"
}

local byte, char = string.byte, string.char

function AnsiToUtf8(s)
    local r, b = {}
    for i = 1, s and s:len() or 0 do
        b = byte(s, i)
        if b < 128 then
            r[#r + 1] = char(b)
        else
            if b > 239 then
                r[#r + 1] = "\209"
                r[#r + 1] = char(b - 112)
            elseif b > 191 then
                r[#r + 1] = "\208"
                r[#r + 1] = char(b - 48)
            elseif a2u8[b] then
                r[#r + 1] = a2u8[b]
            else
                r[#r + 1] = "_"
            end
        end
    end
    return table.concat(r)
end

function u8c(code)
    if code <= 0x7F then
        return char(code)
    elseif code <= 0x7FF then
        return char(0xC0 + math.floor(code / 0x40), 0x80 + (code % 0x40))
    elseif code <= 0xFFFF then
        return char(0xE0 + math.floor(code / 0x1000), 0x80 + (math.floor(code / 0x40) % 0x40), 0x80 + (code % 0x40))
    elseif code <= 0x10FFFF then
        local b3 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local b2 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local b1 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local b0 = 0xF0 + code;
        return char(b0, b1, b2, b3)
    end
end

function Setmt__gc(t, mt)
    local prox = newproxy(true)
    getmetatable(prox).__gc = function()
        mt.__gc(t)
    end
    t[prox] = true
    return setmetatable(t, mt)
end

---@param time number @ in range of [0..1]
---Function to get easing value in range [0..1]
function EaseInOutCubic(time)
    return time < 0.5 and 4 * time * time * time or (time - 1) * (2 * time - 2) * (2 * time - 2) + 1
end

---@param x number
---@return number
---Returns sign of number `x`
function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

---@param path string
---DFS directory removing
local r_dir
function RemoveDirectory(path)
    if doesDirExist(path) then
        for _, v in ipairs(listDirectory(path)) do
            if v.directory then
                r_dir(path .. "/" .. v.name)
            else
                deleteFile(path .. "/" .. v.name)
                Console.write("Delete " .. path .. "/" .. v.name)
            end
        end
        deleteDirectory(path)
        Console.write("Delete " .. path)
    end
end
r_dir = RemoveDirectory
