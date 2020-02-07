Settings = {
    Language = "Default",
    NSFW = false,
    Orientation = "Horizontal",
    ZoomReader = "Smart",
    Version = 0.28,
    KeyType = "EU",
    ReaderDirection = "RIGHT"
}
Settings.LateVersion = Settings.Version
local cross = SCE_CTRL_CROSS
local circle = SCE_CTRL_CIRCLE
local function cpy_file(source_path, dest_path)
    local fh1 = System.openFile(source_path, FREAD)
    local fh2 = System.openFile(dest_path, FCREATE)
    local contentFh1 = System.readFile(fh1, System.sizeFile(fh1))
    System.writeFile(fh2, contentFh1, contentFh1:len())
    System.closeFile(fh1)
    System.closeFile(fh2)
end
local function UpdateApp()
    local notify = Notifications~=nil
    if System.doesFileExist("ux0:data/noboru/NOBORU.vpk") then
        local fh = System.openFile("ux0:data/noboru/NOBORU.vpk", FREAD)
        if System.sizeFile(fh) < 1000 then
            System.closeFile(fh)
            System.deleteFile("ux0:data/noboru/NOBORU.vpk")
            if notify then
                Notifications.push(Language[Settings.Language].SETTINGS.FailedToUpdate)
            end
            return
        end
        System.closeFile(fh)
        RemoveDirectory("ux0:data/noboru/NOBORU")
        if notify then
            Notifications.push(Language[Settings.Language].SETTINGS.UnzipingVPK)
            Notifications.push(Language[Settings.Language].SETTINGS.PleaseWait, 60000)
        end
        Threads.insertTask("ExtractingApp", {
            Type = "UnZip",
            DestPath = "ux0:data/noboru/NOBORU",
            Path = "NOBORU.vpk",
            OnComplete = function ()
                System.deleteFile("ux0:data/noboru/NOBORU.vpk")
                RemoveDirectory("ux0:data/noboru/pkg")
                System.createDirectory("ux0:data/noboru/pkg")
                System.createDirectory("ux0:data/noboru/pkg/sce_sys")
                cpy_file("app0:updater/eboot.bin", "ux0:data/noboru/pkg/eboot.bin")
                cpy_file("app0:updater/param.sfo", "ux0:data/noboru/pkg/sce_sys/param.sfo")
                System.installApp("ux0:data/noboru/pkg")
                RemoveDirectory("ux0:data/noboru/pkg")
                System.launchApp("NOBORUPDT")
            end
        })
    end
    if notify and not Threads.check("ExtractingApp") then
        Notifications.push(Language[Settings.Language].SETTINGS.FailedToUpdate)
    end
end
function Settings:load()
    if System.doesFileExist("ux0:data/noboru/settings.ini") then
        local fh = System.openFile("ux0:data/noboru/settings.ini", FREAD)
        local suc, set = pcall(function() return load("local " .. System.readFile(fh, System.sizeFile(fh)) .. " return Settings")() end)
        if suc then
            self.Language = Language[set.Language] and set.Language or self.Language
            self.NSFW = set.NSFW or self.NSFW
            self.Orientation = set.Orientation or self.Orientation
            self.ZoomReader = set.ZoomReader or self.ZoomReader
            self.ReaderDirection = set.ReaderDirection or self.ReaderDirection
            self.KeyType = set.KeyType or self.KeyType
            SCE_CTRL_CROSS = self.KeyType == "JP" and circle or cross
            SCE_CTRL_CIRCLE = self.KeyType == "JP" and cross or circle
        end
    end
    self:save()
end

function Settings:save()
    if System.doesFileExist("ux0:data/noboru/settings.ini") then
        System.deleteFile("ux0:data/noboru/settings.ini")
    end
    local fh = System.openFile("ux0:data/noboru/settings.ini", FCREATE)
    local set = table.serialize({
        Language = self.Language,
        NSFW = self.NSFW,
        Orientation = self.Orientation,
        ZoomReader = self.ZoomReader,
        KeyType = self.KeyType,
        ReaderDirection = self.ReaderDirection
    }, "Settings")
    System.writeFile(fh, set, set:len())
    System.closeFile(fh)
end

function Settings:list()
    return {
        "Language",
        "ShowNSFW",
        "ReaderOrientation",
        "ZoomReader",
        "ReaderDirection",
        "SwapXO",
        "ClearLibrary",
        "ClearCache",
        "ClearAllCache",
        "ClearChapters",
        "ShowVersion",
        "CheckUpdate",
        "ShowAuthor"
    }
end

function Settings:nextLanguage()
    local next_f = false
    for k, _ in pairs(Language) do
        if next_f then
            self.Language = k
            next_f = false
            break
        end
        if self.Language == k then
            next_f = true
        end
    end
    if next_f then
        for k, _ in pairs(Language) do
            self.Language = k
            break
        end
    end
    self:save()
end

function Settings:clearChapters()
    ChapterSaver.clear()
end

function Settings:changeNSFW()
    ChangeNSFW()
    self.NSFW = not self.NSFW
    self:save()
end

function Settings:clearLibrary()
    Database.clear()
    Notifications.push(Language[Settings.Language].NOTIFICATIONS.LIBRARY_CLEARED)
end

function Settings:clearCache()
    Cache.clear()
    Notifications.push(Language[Settings.Language].NOTIFICATIONS.CACHE_CLEARED)
end

function Settings:clearAllCache()
    Cache.clear("all")
    Notifications.push(Language[Settings.Language].NOTIFICATIONS.CACHE_CLEARED)
end

function Settings:changeOrientation()
    Settings.Orientation = Settings.Orientation == "Vertical" and "Horizontal" or "Vertical"
    self:save()
end

function Settings:changeZoom()
    self.ZoomReader = self.ZoomReader == "Smart" and "Height" or self.ZoomReader == "Height" and "Width" or "Smart"
    self:save()
end

function Settings:changeReaderDirection()
    self.ReaderDirection = self.ReaderDirection == "LEFT" and "RIGHT" or "LEFT"
    self:save()
end

function Settings:swapXO()
    self.KeyType = self.KeyType == "EU" and "JP" or "EU"
    SCE_CTRL_CROSS = self.KeyType == "JP" and circle or cross
    SCE_CTRL_CIRCLE = self.KeyType == "JP" and cross or circle
    self:save()
end
local last_vpk_link
local changes
function Settings:checkUpdate(showMessage)
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        local file = {}
        Threads.insertTask("CheckLatestVersion", {
            Type = "StringRequest",
            Link = "https://github.com/Creckeryop/NOBORU/releases/latest",
            Table = file,
            Index = "string",
            OnComplete = function ()
                local content = file.string or ""
                local late
                late, last_vpk_link = content:match('d%-block mb%-1.-title=\"(.-)\".-"(%S-.vpk)"')
                Settings.LateVersion = late or Settings.LateVersion
                local body = content:match('markdown%-body">(.-)</div>') or ""
                changes = body:gsub("\n+%s-(%S)","\n%1"):gsub("<li>"," * "):gsub("<[^>]->",""):gsub("\n\n","\n"):gsub("^\n",""):gsub("%s+$","") or ""
                if Settings.LateVersion and Settings.Version and tonumber(Settings.LateVersion) > tonumber(Settings.Version) then
                    if showMessage then
                        Changes.load(Language[Settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE..": "..Settings.LateVersion.."\n"..Language[Settings.Language].SETTINGS.CurrentVersionIs..Settings.Version.."\n\n".. changes)
                    else
                        Notifications.push(Language[Settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE.." "..Settings.LateVersion)
                    end
                end
            end
        })
    else
        Notifications.push(Language[Settings.Language].SETTINGS.NoConnection)
    end
end

function Settings:updateApp()
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        if last_vpk_link then
            Notifications.push(Language[Settings.Language].SETTINGS.PleaseWait)
            Threads.insertTask("DownloadAppUpdate",{
                Type = "FileDownload",
                Link = "https://github.com"..last_vpk_link,
                Path = "NOBORU.vpk",
                OnComplete = function ()
                    UpdateApp()
                end
            })
        end
    else
        Notifications.push(Language[Settings.Language].SETTINGS.NoConnection)
    end
end