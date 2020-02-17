Import = {}

local listDirectory = System.listDirectory

local fullpath = "ux0:data/noboru/import/"
local path = fullpath
local dir_list

---@return table
---Gives folder list of opened directory
---
---Table elements: {`name`: string, `directory`: boolean, `active`: boolean, `size`: number}
function Import.listDir()
    if dir_list == nil then
        local list = listDirectory(path) or {}
        local new_list = {}
        for _, v in ipairs(list) do
            if v.directory or v.name:find("%.cbz$") or v.name:find("%.zip$") then
                v.active = true
            else
                v.active = false
            end
            new_list[#new_list + 1] = v
        end
        if path ~= fullpath then
            table.insert(new_list, 1, {
                name = "...",
                directory = true,
                active = true,
                size = 0
            })
        end
        dir_list = new_list
    end
    return dir_list
end

---@param item table
---Opens `item` directory / file
function Import.go(item)
    if item.name == "..." and path ~= fullpath then
        path = path:match("(.*/).-/$")
        dir_list = nil
    elseif item.directory then
        path = path .. item.name .. "/"
        dir_list = nil
    elseif item.name:find("%.cbz$") or item.name:find("%.zip$") then
        Reader.load({{
            FastLoad = true,
            Name = item.name:match("(.*)%..-$"),
            Link = "AABBCCDDEEFFGG",
            Path = path .. item.name,
            Pages = {},
            Manga = {
                Name = item.name:match("(.*)%..-$)"),
                Link = "AABBCCDDEEFFGG",
                ImageLink = "",
                ParserID = "IMPORTED"
            }
        }}, 1)
        AppMode = READER
    end
end

---@param item table
---@return boolean
---Gives `true` if selected `item` is importable
function Import.canImport(item)
    return item.name ~= "..." and item.active
end

---@param item table
---@return string
---Returns fullpath of given item
function Import.getPath(item)
    return item and path .. item.name
end

---Go parent directory of current directory if it is possible
function Import.back()
    if path ~= fullpath then
        path = path:match("(.*/).-/$")
        dir_list = nil
    end
end

---@return boolean
---Says does current directory has accessible parent directory
function Import.canBack()
    return path ~= fullpath
end
