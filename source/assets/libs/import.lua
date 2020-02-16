Import = {}

local listDirectory = System.listDirectory

local fullpath = "ux0:data/noboru/import/"
local path = fullpath
local dir_list
function Import.listDir()
    if dir_list == nil then
        local list = listDirectory(path)
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

function Import.canImport(item)
    return item.name ~= "..."
end

function Import.getPath(item)
    return path .. item.name
end

function Import.back()
    if path ~= fullpath then
        path = path:match("(.*/).-/$")
        dir_list = nil
    end
end

function Import.canBack()
    return path ~= fullpath
end
