local doesDirExist = System.doesDirExist
local listDirectory = System.listDirectory
local deleteFile = System.deleteFile
local deleteDirectory = System.deleteDirectory

DRAW_PHASE = false

local old_init = Graphics.initBlend
local old_term = Graphics.termBlend

function Graphics.initBlend()
    DRAW_PHASE = true
    old_init()
end

function Graphics.termBlend()
    DRAW_PHASE = false
    old_term()
end

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
    df("app0:assets/libs/" .. str .. ".lua")
end

local suc, err = xpcall(dofile, debug.traceback, "app0:main.lua")
if not suc then
    if DRAW_PHASE then
        old_term()
    end
    error(err)
end
