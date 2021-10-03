Extensions = {}

local doesFileExist = System.doesFileExist
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local closeFile = System.closeFile

local extensionsList = {
    parsers = {}
}

local counter = 0

function Extensions.UpdateList()
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        local savePath = "ux0:data/noboru/temp/parsersext.ini"
        Threads.insertTask(
            "EXTENSIONSCHECK",
            {
                Type = "FileDownload",
                Link = "https://raw.githubusercontent.com/Creckeryop/NOBORU-extensions/main/parsers.ini",
                Path = savePath,
                OnComplete = function()
                    if doesFileExist(savePath) then
                        local fh = openFile(savePath, FREAD)
                        local ok, err = load(readFile(fh, sizeFile(fh)))
                        if ok then
                            extensionsList.parsers = ok() or {}
                            counter = 0
                            for k, v in pairs(extensionsList.parsers) do
                                local parser = GetParserByID(k)
                                if parser then
                                    Console.write("Found " .. k .. " v" .. v.Version .. " parser in extension (v" .. parser.Version .. "is installed)")
                                    if v.Version > parser.Version then
                                        counter = counter + 1
                                    end
                                end
                            end
                        else
                            Console.error("Can't load parsers.ini : " .. err)
                        end
                        closeFile(fh)
                    end
                end
            }
        )
    end
end

function Extensions.GetCounter()
    return counter
end
