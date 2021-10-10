Extensions = {}

local doesFileExist = System.doesFileExist
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local closeFile = System.closeFile

local networkList = {}
local loadedList = {}

local INI_SAVE_PATH = "ux0:data/noboru/temp/extensions.ini"
local updatesCounter = 0

local is_cached = false
local cachedList = {}
local sortFunction = function(a, b)
    if a.Type == b.Type then
        local scoreA = GetLanguagePriority(a.Language)
        local scoreB = GetLanguagePriority(b.Language)
        if scoreA == scoreB then
            if a.Language == b.Language then
                return string.upper(a.ID) < string.upper(b.ID)
            else
                return a.Language < b.Language
            end
        else
            return scoreA < scoreB
        end
    else
        return a.Type < b.Type
    end
end

local function resetList()
    is_cached = false
end

local function refreshList()
    if not is_cached then
        local t = {}
        local loadedListCopy = table.clone(loadedList)
        table.sort(loadedListCopy, sortFunction)
        for _, v in ipairs(loadedListCopy) do
            local id = v.ID
            local extInfo = table.clone(v)
            t[#t + 1] = extInfo
            t[id] = extInfo
            t[id].Status = networkList[id] and "Installed" or "Not supported"
            t[id].LatestVersion = v.Version
        end
        local networkListCopy = table.clone(networkList)
        table.sort(networkListCopy, sortFunction)
        for _, v in ipairs(networkListCopy) do
            local id = v.ID
            if not t[id] then
                if Settings.NSFW or not v.NSFW then
                    local extInfo = table.clone(v)
                    t[#t + 1] = extInfo
                    t[id] = extInfo
                    t[id].Status = "Available"
                    t[id].LatestVersion = v.Version
                end
            elseif v.Version ~= t[id].Version then
                t[id].Status = "New version"
                t[id].LatestVersion = v.Version
                if v.Type == "Parsers" then
                    t[id].LatestChanges = v.LatestChanges
                end
            end
        end
        cachedList = t
        is_cached = true
    end
end

function Extensions.UpdateList()
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        if not Threads.check("EXTENSIONSCHECK") then
            if doesFileExist(INI_SAVE_PATH) then
                deleteFile(INI_SAVE_PATH)
            end
            Threads.insertTask(
                "EXTENSIONSCHECK",
                {
                    Type = "FileDownload",
                    Link = "https://raw.githubusercontent.com/Creckeryop/NOBORU-extensions/main/extensions.ini",
                    Path = INI_SAVE_PATH,
                    OnComplete = function()
                        if doesFileExist(INI_SAVE_PATH) then
                            local file = openFile(INI_SAVE_PATH, FREAD)
                            local ok, err = load(readFile(file, sizeFile(file)))
                            closeFile(file)
                            if ok then
                                local uk = {}
                                networkList = {}
                                updatesCounter = 0
                                local temp = ok() or {}
                                for id, ext in pairs(temp) do
                                    if not uk[id] then
                                        if ext.Type == "Parsers" then
                                            if ext.Name and ext.Version and ext.Link and ext.Language then
                                                local extInfo = {
                                                    ID = id,
                                                    Type = ext.Type,
                                                    Name = ext.Name,
                                                    Link = ext.Link,
                                                    Language = ext.Language,
                                                    Version = ext.Version,
                                                    NSFW = ext.NSFW or false,
                                                    LatestChanges = ext.LatestChanges or ""
                                                }
                                                networkList[#networkList + 1] = extInfo
                                                networkList[id] = extInfo
                                                local loaded = loadedList[id]
                                                if loaded then
                                                    Console.write("Found " .. id .. " v" .. extInfo.Version .. " extension in extensions (v" .. loaded.Version .. " is installed)")
                                                    if ext.Version ~= loaded.Version then
                                                        updatesCounter = updatesCounter + 1
                                                    end
                                                end
                                                uk[id] = true
                                            else
                                                Console.error('Extension "' .. id .. '" : Important parameters not found')
                                            end
                                        end
                                    end
                                end
                            else
                                Console.error("Can't load extensions.ini : " .. err)
                            end
                            resetList()
                        else
                            Console.error("Can't load extensions.ini : file is missing")
                        end
                    end
                }
            )
        end
    else
        networkList = {}
        updatesCounter = 0
        Notifications.push(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM)
        resetList()
    end
end

function Extensions.getByID(id)
    refreshList()
    return cachedList[id]
end

function Extensions.GetList()
    refreshList()
    return cachedList
end

function Extensions.Install(id)
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        if not Threads.check(id .. "_INSTALL") then
            local scriptPath = "ux0:data/noboru/ext/" .. id .. ".lua"
            if doesFileExist(scriptPath) then
                deleteFile(scriptPath)
            end
            Threads.insertTask(
                id .. "_INSTALL",
                {
                    Type = "FileDownload",
                    Link = "https://raw.githubusercontent.com/Creckeryop/NOBORU-extensions/main/ext/" .. id .. ".lua",
                    Path = scriptPath,
                    OnComplete = function()
                        if doesFileExist(scriptPath) then
                            Extensions.Unload(id)
                            Extensions.Load(id)
                            resetList()
                        else
                            Console.error("Can't find " .. id .. ".lua : file is missing")
                        end
                    end
                }
            )
        end
    else
        Notifications.push(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM)
        resetList()
    end
end

function Extensions.Register(id, ext)
    if not loadedList[id] then
        if ext.Type == "Parsers" then
            if ext.Name and ext.Version and ext.Link and ext.Language and ext.Parsers then
                local extInfo = {
                    ID = id,
                    Type = ext.Type,
                    Name = ext.Name,
                    Link = ext.Link,
                    Language = ext.Language,
                    Version = ext.Version,
                    NSFW = ext.NSFW or false,
                    Parsers = ext.Parsers,
                    LatestChanges = ext.LatestChanges or ""
                }
                loadedList[#loadedList + 1] = extInfo
                loadedList[id] = extInfo
            else
                Console.error('Extension "' .. id .. '" : Important parameters not found')
            end
        end
    end
end

function Extensions.Load(id)
    if not loadedList[id] then
        if doesFileExist("ux0:data/noboru/ext/" .. id .. ".lua") then
            local uk = {}
            for _, v in ipairs(loadedList) do
                uk[v.ID] = true
            end
            uk[id] = true
            local suc, err = pcall(dofile, "ux0:data/noboru/ext/" .. id .. ".lua")
            for key, _ in pairs(uk) do
                if not uk[key] then
                    for i = 1, #loadedList do
                        if loadedList[i].ID == key then
                            table.remove(loadedList, i)
                            loadedList[key] = nil
                            break
                        end
                    end
                end
            end
            if not suc then
                Console.error("Can't load " .. id .. ".lua file :" .. err)
            elseif not loadedList[id] then
                Console.error(id .. " extension isn't registered!")
            else
                if loadedList[id].Type == "Parsers" then
                    for _, v in ipairs(loadedList[id].Parsers) do
                        LoadParser(v.ID, v)
                    end
                end
            end
        end
    else
        Console.error(id .. " is already loaded (try to unload and load again)")
    end
end

function Extensions.Unload(id)
    if loadedList[id] then
        if loadedList[id].Type == "Parsers" then
            for _, v in ipairs(loadedList[id].Parsers) do
                UnloadParser(v.ID)
            end
        end
        for i = 1, #loadedList do
            if loadedList[i].ID == id then
                table.remove(loadedList, i)
                break
            end
        end
        loadedList[id] = nil
    end
end

function Extensions.Remove(id)
    if id and loadedList[id] then
        Extensions.Unload(id)
        local scriptPath = "ux0:data/noboru/ext/" .. id .. ".lua"
        if doesFileExist(scriptPath) then
            deleteFile(scriptPath)
        else
            Console.error("Can't find " .. id .. ".lua to delete : file is missing")
        end
        resetList()
    end
end

function Extensions.GetCounter()
    return updatesCounter
end
