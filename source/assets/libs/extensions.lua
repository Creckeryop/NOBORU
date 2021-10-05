Extensions = {}

local doesFileExist = System.doesFileExist
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local closeFile = System.closeFile

local extensionsList = {
    parsers = {}
}

local saveParserPath = "ux0:data/noboru/temp/parsersext.ini"
local counter = 0
function Extensions.RefreshList()
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        Threads.insertTask(
            "EXTENSIONSPARSERSCHECK",
            {
                Type = "FileDownload",
                Link = "https://raw.githubusercontent.com/Creckeryop/NOBORU-extensions/main/parsers.ini",
                Path = saveParserPath,
                OnComplete = function()
                    if doesFileExist(saveParserPath) then
                        local fh = openFile(saveParserPath, FREAD)
                        local ok, err = load(readFile(fh, sizeFile(fh)))
                        if ok then
                            extensionsList.parsers = ok() or {}
                            counter = 0
                            for k, v in pairs(extensionsList.parsers) do
                                v.ID = k
                                local parser = GetParserByID(k)
                                if parser then
                                    Console.write("Found " .. k .. " v" .. v.Version .. " parser in extensions (v" .. parser.Version .. " is installed)")
                                    if v.Version > parser.Version then
                                        counter = counter + 1
                                    end
                                end
                            end
                        else
                            Console.error("Can't load parsers.ini : " .. err)
                        end
                        closeFile(fh)
                    else
                        Console.error("Can't load parsers.ini : file is missing")
                    end
                end
            }
        )
    end
end

local is_cached = false
local cachedList = {}

function Extensions.GetList()
    if is_cached then
        return cachedList
    else
        local t = {}
        local uk = {}
        for _, v in pairs(GetParserRawList()) do
            if not uk[v.ID] then
                t[#t + 1] = v
                uk[v.ID] = v
                if not extensionsList.parsers[v.ID] then
                    uk[v.ID].Status = "Not Supported"
                else
                    uk[v.ID].Status = "Latest"
                end
            end
        end
        for k, v in pairs(extensionsList.parsers) do
            if not uk[k] then
                t[#t + 1] = v
                uk[k] = v
                uk[k].Status = "Not Installed"
            else
                if v.Version > uk[k].Version then
                    uk[k].isNewVersionAvailable = true
                    uk[k].Status = "New Version"
                end
            end
        end
        cachedList = t
        is_cached = true
        return cachedList
    end
end

function Extensions.ResetCache()
    is_cached = false
end

function Extensions.GetCounter()
    return counter
end
