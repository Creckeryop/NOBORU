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
                        Extensions.ResetCache()
                        Extensions.GetList()
                    else
                        Console.error("Can't load parsers.ini : file is missing")
                    end
                end
            }
        )
    else
        extensionsList.parsers = {}
        counter = 0
        Notifications.push(Language[Settings.Language].NOTIFICATIONS.NET_PROBLEM)
        Extensions.ResetCache()
        Extensions.GetList()
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
                local extInfo = {
                    Type = "Parser",
                    Name = v.Name or "ERROR_NO_NAME",
                    Link = v.Link or "ERROR_NO_LINK",
                    Lang = v.Lang or "ERROR_NO_LANG",
                    ID = v.ID or "ERROR_NO_ID",
                    Version = v.Version or -1,
                    NewVersion = v.Version or -1,
                    Installed = true,
                    Status = not extensionsList.parsers[v.ID] and "Not supported" or "Latest",
                    LastChange = "",
                    NSFW = v.NSFW or false
                }
                t[#t + 1] = extInfo
                uk[v.ID] = extInfo
            else
                Console.error("Found 2 same ID's: " .. v.Name .. ", " .. uk[v.ID].Name)
            end
        end
        local extParsers = table.clone(extensionsList.parsers)
        table.sort(
            extParsers,
            function(a, b)
                local scoreA = GetLanguagePriority(a.Lang)
                local scoreB = GetLanguagePriority(b.Lang)
                if scoreA == scoreB then
                    if a.Lang == b.Lang then
                        return string.upper(a.ID) < string.upper(b.ID)
                    else
                        return a.Lang < b.Lang
                    end
                else
                    return scoreA < scoreB
                end
            end
        )
        for k, v in pairs(extParsers) do
            local extInfo = {
                Type = "Parser",
                Name = v.Name or "ERROR_NO_NAME",
                Link = v.Link or "ERROR_NO_LINK",
                Lang = v.Lang or "ERROR_NO_LANG",
                ID = v.ID or "ERROR_NO_ID",
                Version = v.Version or -1,
                NewVersion = v.Version or -1,
                Installed = false,
                LastChange = v.LastChange or "",
                NSFW = v.NSFW or false
            }
            if not uk[k] then
                if v.NSFW and Settings.NSFW or not v.NSFW then
                    t[#t + 1] = extInfo
                    uk[k] = extInfo
                    extInfo.Status = "Installable"
                end
            elseif v.Version > uk[k].Version then
                uk[k].Status = "New version"
                uk[k].NewVersion = v.Version
                uk[k].LastChange = v.LastChange or ""
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
