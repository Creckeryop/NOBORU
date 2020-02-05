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
local df = dofile
function loadlib(str)
    df("app0:assets/libs/"..str..".lua")
end
local suc, err = xpcall(function() dofile "app0:main.lua" end, debug.traceback)
if not suc then
    error(err)
end