Settings = {
    Language = "Default",
    NSFW = false,
    Orientation = "Horizontal",
    ZoomReader = "Smart",
    Version = 0.35,
    KeyType = "EU",
    ReaderDirection = "RIGHT",
    HideInOffline = true,
    SkipFontLoad = false,
    Theme = "Light",
}

local settings = Settings

settings.LateVersion = settings.Version

local cross = SCE_CTRL_CROSS
local circle = SCE_CTRL_CIRCLE
local writeFile = System.writeFile
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local createDirectory = System.createDirectory
local rem_dir = RemoveDirectory

local AppIsUpdating = false

function settings.isAppUpdating()
    return AppIsUpdating
end

local function cpy_file(source_path, dest_path)
    local fh1 = openFile(source_path, FREAD)
    local fh2 = openFile(dest_path, FCREATE)
    local contentFh1 = readFile(fh1, sizeFile(fh1))
    writeFile(fh2, contentFh1, #contentFh1)
    closeFile(fh1)
    closeFile(fh2)
end

local installApp = System.installApp
local launchApp = System.launchApp

local function setTheme(name)
    if Themes[name] then
        for k, v in pairs(Themes[name]) do
            _G[k] = v
        end
    end
end

local function UpdateApp()
    local notify = Notifications ~= nil
    if doesFileExist("ux0:data/noboru/NOBORU.vpk") then
        local fh = openFile("ux0:data/noboru/NOBORU.vpk", FREAD)
        if sizeFile(fh) < 1000 then
            closeFile(fh)
            deleteFile("ux0:data/noboru/NOBORU.vpk")
            if notify then
                Notifications.push(Language[settings.Language].settings.FailedToUpdate)
                AppIsUpdating = false
            end
            return
        end
        closeFile(fh)
        rem_dir("ux0:data/noboru/NOBORU")
        if notify then
            Notifications.push(Language[settings.Language].settings.UnzipingVPK)
            Notifications.push(Language[settings.Language].settings.PleaseWait, 60000)
        end
        Threads.insertTask("ExtractingApp", {
            Type = "UnZip",
            DestPath = "ux0:data/noboru/NOBORU",
            Path = "NOBORU.vpk",
            OnComplete = function()
                deleteFile("ux0:data/noboru/NOBORU.vpk")
                rem_dir("ux0:data/noboru/pkg")
                createDirectory("ux0:data/noboru/pkg")
                createDirectory("ux0:data/noboru/pkg/sce_sys")
                cpy_file("app0:updater/eboot.bin", "ux0:data/noboru/pkg/eboot.bin")
                cpy_file("app0:updater/param.sfo", "ux0:data/noboru/pkg/sce_sys/param.sfo")
                installApp("ux0:data/noboru/pkg")
                rem_dir("ux0:data/noboru/pkg")
                launchApp("NOBORUPDT")
                AppIsUpdating = false
            end
        })
    end
    if notify and not Threads.check("ExtractingApp") then
        Notifications.push(Language[settings.Language].settings.FailedToUpdate)
        AppIsUpdating = false
    end
end

local function setSetting(source, setting_name, values)
    local new_set = source[setting_name]
    if new_set == nil then
        return
    end
    for _, v in pairs(values) do
        if new_set == v then
            settings[setting_name] = new_set
            return
        end
    end
    if values[new_set] then
        settings[setting_name] = new_set
    end
end

local function nextTableValue(old_value, values)
    local found = false
    for k, v in ipairs(values) do
        if found then
            return v
        elseif old_value == v then
            found = true
        end
    end
    return values[1]
end

function settings.load()
    if doesFileExist("ux0:data/noboru/settings.ini") then
        local fh = openFile("ux0:data/noboru/settings.ini", FREAD)
        local suc, new = pcall(function() return load("local " .. readFile(fh, sizeFile(fh)) .. " return settings")() end)
        if suc then
            setSetting(new, "Language", Language)
            setSetting(new, "NSFW", {true, false})
            setSetting(new, "SkipFontLoad", {true, false})
            setSetting(new, "Orientation", {"Horizontal", "Vertical"})
            setSetting(new, "ZoomReader", {"Width", "Height", "Smart"})
            setSetting(new, "ReaderDirection", {"LEFT", "RIGHT"})
            setSetting(new, "KeyType",  {"JP", "EU"})
            setSetting(new, "HideInOffline", {true, false})
            setSetting(new, "Theme", Themes)
        end
        closeFile(fh)
    end
    settings.save()
    SCE_CTRL_CROSS = settings.KeyType == "JP" and circle or cross
    SCE_CTRL_CIRCLE = settings.KeyType == "JP" and cross or circle
    setTheme(settings.Theme)
end

function settings.save()
    if doesFileExist("ux0:data/noboru/settings.ini") then
        deleteFile("ux0:data/noboru/settings.ini")
    end
    local fh = openFile("ux0:data/noboru/settings.ini", FCREATE)
    local copy_settings = {}
    for k, v in pairs(settings) do
        if type(v) ~= "function" and k ~= "Version" then
            copy_settings[k] = v
        end
    end
    local save_content = table.serialize(copy_settings, "settings")
    writeFile(fh, save_content, #save_content)
    closeFile(fh)
end

local set_list = {
    "Language", "SkipFontLoading", "ChangeUI", "Catalogs", "Reader", "Data", "Controls", "About",
    Catalogs = {
        "ShowNSFW",
        "HideInOffline"
    },
    Reader = {
        "ReaderOrientation",
        "ZoomReader",
        "ReaderDirection"
    },
    Data = {
        "ClearLibrary",
        "ClearCache",
        "ClearAllCache",
        "ClearChapters"
    },
    About = {
        "ShowVersion",
        "CheckUpdate",
        "ShowAuthor",
    },
    Controls = {
        "SwapXO"
    }
}

local set_list_tab = set_list

function settings.list()
    return set_list_tab
end

function settings.isTab(mode)
    return set_list[mode] ~= nil
end

function settings.setTab(mode)
    if set_list[mode] then
        set_list_tab = set_list[mode]
    end
end

function settings.inTab()
    return set_list_tab ~= set_list
end

function settings.back()
    set_list_tab = set_list
end

local last_vpk_link
local changes

function settings.updateApp()
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        if last_vpk_link then
            AppIsUpdating = true
            Notifications.push(Language[settings.Language].settings.PleaseWait)
            Threads.insertTask("DownloadAppUpdate", {
                Type = "FileDownload",
                Link = "https://github.com" .. last_vpk_link,
                Path = "NOBORU.vpk",
                OnComplete = function()
                    UpdateApp()
                end
            })
        end
    else
        Notifications.push(Language[settings.Language].settings.NoConnection)
    end
end

SettingsFunctions = {
    Language = function()
        settings.Language = nextTableValue(settings.Language, GetLanguages())
    end,
    SkipFontLoading = function()
        settings.SkipFontLoad = not settings.SkipFontLoad
    end,
    ChangeUI = function ()
        settings.Theme = nextTableValue(settings.Theme, GetThemes())
        setTheme(settings.Theme)
    end,
    ShowNSFW = function ()
        ChangeNSFW()
        settings.NSFW = not settings.NSFW
    end,
    HideInOffline = function ()
        settings.HideInOffline = not settings.HideInOffline
    end,
    ReaderOrientation = function ()
        settings.ReaderOrientation = nextTableValue(settings.ReaderOrientation, {"Horizontal", "Vertical"})
    end,
    ZoomReader = function ()
        settings.ZoomReader = nextTableValue(settings.ZoomReader, {"Width", "Height", "Smart"})
    end,
    ReaderDirection = function ()
        settings.ReaderDirection = nextTableValue(settings.ReaderDirection, {"LEFT", "RIGHT"})
    end,
    ClearLibrary = function ()
        Database.clear()
        Notifications.push(Language[settings.Language].NOTIFICATIONS.LIBRARY_CLEARED)
    end,
    ClearCache = function ()
        Cache.clear()
        Notifications.push(Language[settings.Language].NOTIFICATIONS.CACHE_CLEARED)
    end,
    ClearAllCache = function ()
        Cache.clear("all")
        Notifications.push(Language[settings.Language].NOTIFICATIONS.CACHE_CLEARED)
    end,
    ClearChapters = function ()
        ChapterSaver.clear()
    end,
    CheckUpdate = function ()
        if Threads.netActionUnSafe(Network.isWifiEnabled) then
            local file = {}
            Threads.insertTask("CheckLatestVersion", {
                Type = "StringRequest",
                Link = "https://github.com/Creckeryop/NOBORU/releases/latest",
                Table = file,
                Index = "string",
                OnComplete = function()
                    local content = file.string or ""
                    local late
                    late, last_vpk_link = content:match('d%-block mb%-1.-title=\"(.-)\".-"(%S-.vpk)"')
                    settings.LateVersion = late or settings.LateVersion
                    local body = content:match('markdown%-body">(.-)</div>') or ""
                    changes = body:gsub("\n+%s-(%S)", "\n%1"):gsub("<li>", " * "):gsub("<[^>]->", ""):gsub("\n\n", "\n"):gsub("^\n", ""):gsub("%s+$", "") or ""
                    if settings.LateVersion and settings.Version and tonumber(settings.LateVersion) > tonumber(settings.Version) then
                        Changes.load(Language[settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE .. " : " .. settings.LateVersion .. "\n" .. Language[settings.Language].settings.CurrentVersionIs .. settings.Version .. "\n\n" .. changes)
                        Notifications.push(Language[settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE .. " " .. settings.LateVersion)
                    end
                end
            })
        else
            Notifications.push(Language[settings.Language].settings.NoConnection)
        end
    end,
    ShowAuthor = function ()
        Notifications.push(Language[Settings.Language].NOTIFICATIONS.DEVELOPER_THING .. "\nhttps://github.com/Creckeryop/NOBORU")
    end,
    SwapXO = function ()
        settings.KeyType = nextTableValue(settings.KeyType, {"JP", "EU"})
        SCE_CTRL_CROSS = settings.KeyType == "JP" and circle or cross
        SCE_CTRL_CIRCLE = settings.KeyType == "JP" and cross or circle
    end
}