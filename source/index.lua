local doesDirExist = System.doesDirExist
local listDirectory = System.listDirectory
local deleteFile = System.deleteFile
local deleteDirectory = System.deleteDirectory

local function r_dir(path)
    if doesDirExist(path) then
        local dir = listDirectory(path) or {}
        for k, v in ipairs(dir) do
            if v.directory then
                r_dir(path .. "/" .. v.name)
            else
                deleteFile(path .. "/" .. v.name)
            end
        end
        deleteDirectory(path)
    end
end

if System.checkApp("NOBORUPDT") then
    System.removeApp("NOBORUPDT")
    r_dir("ux0:data/noboru/NOBORU")
end

System.removeApp = nil
System.checkApp = nil

local df = dofile
function loadlib(str)
    df("app0:assets/libs/"..str..".lua")
end
local suc, err = xpcall(function() dofile "app0:main.lua" end, debug.traceback)
if not suc then
    error(err)
end