local function r_dir(path)
    if System.doesDirExist(path) then
        for k, v in ipairs(System.listDirectory(path)) do
            if v.directory then
                r_dir(path .. "/" .. v.name)
            else
                System.deleteFile(path .. "/" .. v.name)
            end
        end
        System.deleteDirectory(path)
    end
end

if System.checkApp("NOBORUPDT") then
    System.removeApp("NOBORUPDT")
    r_dir("ux0:data/noboru/NOBORU")
end

System.removeApp = nil
System.checkApp = nil

local rewrite_dir_fs = {
    "deleteFile",
    "deleteDirectory",
    "doesDirExist",
    "doesFileExist",
    "openFile",
    "listDirectory",
    "createDirectory",
    "rename"
}
for _, f in ipairs(rewrite_dir_fs) do
    local old_f = System[f]
    System[f] = function(...)
        local path = ({...})[1]
        if path:find("^ux0:data/noboru/") or path:find("^ux0:/data/noboru/") or path:find("^ux0:/data/noboru$") or path:find("^ux0:data/noboru$") then
            if not path:find("/%.%.") then
                return old_f(...)
            else
                error(".. in deletion not allowed by me DIO")
            end
        else
            error("no access to dirs lower than noboru folder")
        end
    end
end

local df = dofile
function loadlib(str)
    df("app0:assets/libs/"..str..".lua")
end
local suc, err = xpcall(function() dofile "app0:main.lua" end, debug.traceback)
if not suc then
    error(err)
end