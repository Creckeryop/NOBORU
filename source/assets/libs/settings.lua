Settings = {
    Language = "Default",
    NSFW = false,
    Orientation = "Horizontal",
    ZoomReader = "Smart",
    DoubleTapReader = true,
    Version = 0.51,
    KeyType = "EU",
    ReaderDirection = "RIGHT",
    HideInOffline = true,
    SkipFontLoad = false,
    Theme = "Light",
    ParserLanguage = "DIF",
    LibrarySorting = "Date added",
    ChapterSorting = "1->N",
    RefreshLibAtStart = false,
    ChangingPageButtons = "LR",
    LeftStickDeadZone = 30,
    LeftStickSensitivity = 1,
    RightStickDeadZone = 30,
    RightStickSensitivity = 1,
    SilentDownloads = false,
    UseProxy = false,
    ProxyIP = "192.168.0.1",
    ProxyPort = "8080",
    UseProxyAuth = false,
    ProxyAuth = "login:password",
    SkipCacheChapterChecking = true
}

local SettingsDefaults = table.clone(Settings)

DeadZoneValues = {20, 30, 40, 50, 90}
SensitivityValues = {0.25, 0.50, 0.75, 1, 1.25, 1.5, 1.75}

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

---@return boolean
---Gives true if app is updating
function settings.isAppUpdating()
    return AppIsUpdating
end

---@param source_path string
---@param dest_path string
---Copies file source_path to dest_path (creates file)
---
---Example:
---
---`cpy_file("ux0:data/noboru/cache.image","ux0:cover.jpeg") -> cover.jpeg appeared in ux0:`
local function cpy_file(source_path, dest_path)
    local fh1 = openFile(source_path, FREAD)
    local fh2 = openFile(dest_path, FCREATE)
    local contentFh1 = readFile(fh1, sizeFile(fh1))
    writeFile(fh2, contentFh1, #contentFh1)
    closeFile(fh1)
    closeFile(fh2)
end

---Sets colors from Themes[Settings.Theme] to their values
local function setTheme(name)
    if Themes[name] then
        for k, v in pairs(Themes[name]) do
            _G[k] = v
        end
    end
end

local installApp = System.installApp
local launchApp = System.launchApp
---Unpacks downloaded NOBORU.vpk and installing it
local function UpdateApp()
    local notify = Notifications ~= nil
    if doesFileExist("ux0:data/noboru/NOBORU.vpk") then
        local fh = openFile("ux0:data/noboru/NOBORU.vpk", FREAD)
        if sizeFile(fh) < 1000 then
            closeFile(fh)
            deleteFile("ux0:data/noboru/NOBORU.vpk")
            if notify then
                Notifications.push(Language[settings.Language].SETTINGS.FailedToUpdate)
                AppIsUpdating = false
            end
            return
        end
        closeFile(fh)
        rem_dir("ux0:data/noboru/NOBORU")
        if notify then
            Notifications.push(Language[settings.Language].SETTINGS.UnzipingVPK)
            Notifications.push(Language[settings.Language].SETTINGS.PleaseWait, 60000)
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
        Notifications.push(Language[settings.Language].SETTINGS.FailedToUpdate)
        AppIsUpdating = false
    end
end

---@param source table
---@param setting_name string
---@param values table
---Sets `settings[setting_name]` value to `source[setting_name]` if value is in `values` table
---
---Example:
---
---`setSetting(new_settings, "SpeedOfScrolling", {1,5,10}) ->`
---
---`sets Settings.SpeedOfScrolling to new_settings.SpeedOfScrolling if it is 1, 5 or 10 else sets to nil`
local function setSetting(source, setting_name, values)
    local new_set = source[setting_name]
    if new_set == nil then
        return
    end
    if #values == 0 then
        settings[setting_name] = new_set
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

---@param old_value any
---@param values table
---@return any
---Gives next to `old_value` table value from `values` or first
---
---Example:
---
---`nextTableValue("cat", {"dog", "cat", "parrot"}) -> "parrot"`
---
---`nextTableValue("parrot", {"dog", "cat", "parrot"}) -> "dog"`
---
---`nextTableValue("whale", {"dog", "cat", "parrot"}) -> "dog"`
local function nextTableValue(old_value, values)
    local found = false
    for _, v in ipairs(values) do
        if found then
            return v
        elseif old_value == v then
            found = true
        end
    end
    return values[1]
end

local SETTINGS_SAVE_PATH = "ux0:data/noboru/settings.ini"

---Loads settings from `ux0:data/noboru/settings.ini`
function settings.load()
    if doesFileExist(SETTINGS_SAVE_PATH) then
        local fh = openFile(SETTINGS_SAVE_PATH, FREAD)
        local suc, new = pcall(function() return load("local " .. readFile(fh, sizeFile(fh)) .. " return Settings")() end)
        if suc and type(new) == "table" then
            setSetting(new, "Language", Language)
            setSetting(new, "NSFW", {true, false})
            setSetting(new, "SkipFontLoad", {true, false})
            setSetting(new, "Orientation", {"Horizontal", "Vertical"})
            setSetting(new, "ZoomReader", {"Width", "Height", "Smart"})
            setSetting(new, "ReaderDirection", {"LEFT", "RIGHT", "DOWN"})
            setSetting(new, "KeyType", {"JP", "EU"})
            setSetting(new, "HideInOffline", {true, false})
            setSetting(new, "DoubleTapReader", {true, false})
            setSetting(new, "Theme", Themes)
            setSetting(new, "ParserLanguage", GetParserLanguages())
            setSetting(new, "LibrarySorting", {"Date added", "A-Z", "Z-A"})
            setSetting(new, "ChapterSorting", {"1->N", "N->1"})
            setSetting(new, "RefreshLibAtStart", {true, false})
            setSetting(new, "ChangingPageButtons", {"DPAD", "LR"})
            setSetting(new, "LeftStickDeadZone", DeadZoneValues)
            setSetting(new, "LeftStickSensitivity", SensitivityValues)
            setSetting(new, "RightStickDeadZone", DeadZoneValues)
            setSetting(new, "RightStickSensitivity", SensitivityValues)
            setSetting(new, "SilentDownloads", {true, false})
            setSetting(new, "UseProxy", {true, false})
            setSetting(new, "ProxyIP", {})
            setSetting(new, "ProxyPort", {})
            setSetting(new, "UseProxyAuth", {true, false})
            setSetting(new, "ProxyAuth", {})
            setSetting(new, "SkipCacheChapterChecking", {true, false})
        end
        closeFile(fh)
    end
    settings.save()
    SCE_CTRL_CROSS = settings.KeyType == "JP" and circle or cross
    SCE_CTRL_CIRCLE = settings.KeyType == "JP" and cross or circle
    SCE_CTRL_RIGHTPAGE = settings.ChangingPageButtons == "DPAD" and SCE_CTRL_RIGHT or SCE_CTRL_RTRIGGER
    SCE_CTRL_LEFTPAGE = settings.ChangingPageButtons == "DPAD" and SCE_CTRL_LEFT or SCE_CTRL_LTRIGGER
    SCE_LEFT_STICK_DEADZONE = settings.LeftStickDeadZone
    SCE_LEFT_STICK_SENSITIVITY = settings.LeftStickSensitivity
    SCE_RIGHT_STICK_DEADZONE = settings.RightStickDeadZone
    SCE_RIGHT_STICK_SENSITIVITY = settings.RightStickSensitivity
    setTheme(settings.Theme)
end

---Saves settings in `ux0:data/noboru/settings.ini`
function settings.save()
    if doesFileExist(SETTINGS_SAVE_PATH) then
        deleteFile(SETTINGS_SAVE_PATH)
    end
    local fh = openFile(SETTINGS_SAVE_PATH, FCREATE)
    local copy_settings = {}
    for k, v in pairs(settings) do
        if type(v) ~= "function" and k ~= "Version" then
            copy_settings[k] = v
        end
    end
    local save_content = table.serialize(copy_settings, "Settings")
    writeFile(fh, save_content, #save_content)
    closeFile(fh)
end

---Table of all available options
local set_list = {
    "Language", "ChangeUI", "Library", "Catalogs", "Reader", "Network", "Data", "Other", "Controls", "About",
    Library = {
        "LibrarySorting",
        "RefreshLibAtStart"
    },
    Catalogs = {
        "ShowNSFW",
        "HideInOffline",
        "PreferredCatalogLanguage"
    },
    Reader = {
        "ReaderOrientation",
        "ZoomReader",
        "ReaderDirection",
        "DoubleTapReader"
    },
    Network = {
        "UseProxy",
        "ProxyIP",
        "ProxyPort",
        "UseProxyAuth",
        "ProxyAuth"
    },
    Data = {
        "ClearLibrary",
        "ClearCache",
        "ClearAllCache",
        "ClearChapters",
        "ResetAllSettings"
    },
    Other = {
        "SkipFontLoading",
        "ChapterSorting",
        "SilentDownloads",
        "SkipCacheChapterChecking"
    },
    About = {
        "ShowVersion",
        "CheckUpdate",
        "ShowAuthor",
        "Translators"
    },
    Controls = {
        "SwapXO",
        "ChangingPageButtons",
        "LeftStickDeadZone",
        "LeftStickSensitivity",
        "RightStickDeadZone",
        "RightStickSensitivity"
    }
}

---Table of current options
local set_list_tab = set_list

---@return table
---Return list of available options
function settings.list()
    return set_list_tab
end

---@param mode string
---@return boolean
---Checks if setting is submenu
function settings.isTab(mode)
    return set_list[mode] ~= nil
end

---@param mode string
---Sets settings menu as submenu `mode`
function settings.setTab(mode)
    if set_list[mode] then
        set_list_tab = set_list[mode]
    end
end

---@return boolean
---Checks if settings not in main settings menu (subsettings screen)
function settings.inTab()
    return set_list_tab ~= set_list
end

---Throws in main settings menu
function settings.back()
    set_list_tab = set_list
end

local last_vpk_link
local last_vpk_size = "NaN"
local changes

---Starting update for NOBORU Application
function settings.updateApp()
    if Threads.netActionUnSafe(Network.isWifiEnabled) then
        if last_vpk_link then
            AppIsUpdating = true
            Notifications.push(Language[settings.Language].SETTINGS.PleaseWait)
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
        Notifications.push(Language[settings.Language].SETTINGS.NoConnection)
    end
end

---Table with Option Names and their Functions
SettingsFunctions = {
    Language = function()
        settings.Language = nextTableValue(settings.Language, GetLanguages())
    end,
    SkipFontLoading = function()
        settings.SkipFontLoad = not settings.SkipFontLoad
    end,
    ChangeUI = function()
        settings.Theme = nextTableValue(settings.Theme, GetThemes())
        setTheme(settings.Theme)
    end,
    ShowNSFW = function()
        ChangeNSFW()
        settings.NSFW = not settings.NSFW
    end,
    HideInOffline = function()
        settings.HideInOffline = not settings.HideInOffline
    end,
    ReaderOrientation = function()
        settings.Orientation = nextTableValue(settings.Orientation, {"Horizontal", "Vertical"})
    end,
    ZoomReader = function()
        settings.ZoomReader = nextTableValue(settings.ZoomReader, {"Width", "Height", "Smart"})
    end,
    ReaderDirection = function()
        settings.ReaderDirection = nextTableValue(settings.ReaderDirection, {"LEFT", "RIGHT", "DOWN"})
    end,
    DoubleTapReader = function()
        settings.DoubleTapReader = not settings.DoubleTapReader
    end,
    ClearLibrary = function()
        Database.clear()
        Notifications.push(Language[settings.Language].NOTIFICATIONS.LIBRARY_CLEARED)
    end,
    ClearCache = function()
        Cache.clear()
        Notifications.push(Language[settings.Language].NOTIFICATIONS.CACHE_CLEARED)
    end,
    ClearAllCache = function()
        Cache.clear("all")
        Notifications.push(Language[settings.Language].NOTIFICATIONS.CACHE_CLEARED)
    end,
    ClearChapters = function()
        ChapterSaver.clear()
    end,
    CheckUpdate = function()
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
                    late, last_vpk_link, last_vpk_size = content:match('d%-block mb%-1.-title=\"(.-)\".-"(%S-.vpk)".-<small.->(.-)</small>')
                    if late == nil then
                        late, last_vpk_link, last_vpk_size = content:match('d%-block mb%-1.-title=\"(.-)\".-"(%S-.vpk)"'), "NaN"
                    end
                    settings.LateVersion = late or settings.LateVersion
                    local body = content:match('markdown%-body">(.-)</div>') or ""
                    changes = body:gsub("\n+%s-(%S)", "\n%1"):gsub("<li>", " * "):gsub("<[^>]->", ""):gsub("\n\n", "\n"):gsub("^\n", ""):gsub("%s+$", "") or ""
                    if settings.LateVersion and settings.Version and tonumber(settings.LateVersion) > tonumber(settings.Version) then
                        Changes.load(Language[settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE .. " : " .. settings.LateVersion .. "\n" .. Language[settings.Language].SETTINGS.CurrentVersionIs .. settings.Version .. "\n\n" .. changes)
                        Notifications.push(Language[settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE .. " " .. settings.LateVersion)
                    end
                end
            })
        else
            Notifications.push(Language[settings.Language].SETTINGS.NoConnection)
        end
    end,
    GetLastVpkSize = function()
        return last_vpk_size
    end,
    ShowAuthor = function()
        Notifications.push(Language[Settings.Language].NOTIFICATIONS.DEVELOPER_THING .. "\nhttps://github.com/Creckeryop/NOBORU")
    end,
    SwapXO = function()
        settings.KeyType = nextTableValue(settings.KeyType, {"JP", "EU"})
        SCE_CTRL_CROSS = settings.KeyType == "JP" and circle or cross
        SCE_CTRL_CIRCLE = settings.KeyType == "JP" and cross or circle
    end,
    PreferredCatalogLanguage = function()
        settings.ParserLanguage = nextTableValue(settings.ParserLanguage, GetParserLanguages())
        ChangeNSFW()
    end,
    LibrarySorting = function()
        settings.LibrarySorting = nextTableValue(settings.LibrarySorting, {"Date added", "A-Z", "Z-A"})
    end,
    ChapterSorting = function()
        settings.ChapterSorting = nextTableValue(settings.ChapterSorting, {"1->N", "N->1"})
    end,
    RefreshLibAtStart = function()
        settings.RefreshLibAtStart = nextTableValue(settings.RefreshLibAtStart, {true, false})
    end,
    ChangingPageButtons = function()
        settings.ChangingPageButtons = nextTableValue(settings.ChangingPageButtons, {"DPAD", "LR"})
        SCE_CTRL_RIGHTPAGE = settings.ChangingPageButtons == "DPAD" and SCE_CTRL_RIGHT or SCE_CTRL_RTRIGGER
        SCE_CTRL_LEFTPAGE = settings.ChangingPageButtons == "DPAD" and SCE_CTRL_LEFT or SCE_CTRL_LTRIGGER
    end,
    LeftStickDeadZone = function()
        settings.LeftStickDeadZone = nextTableValue(settings.LeftStickDeadZone, DeadZoneValues)
        SCE_LEFT_STICK_DEADZONE = settings.LeftStickDeadZone
    end,
    LeftStickSensitivity = function()
        settings.LeftStickSensitivity = nextTableValue(settings.LeftStickSensitivity, SensitivityValues)
        SCE_LEFT_STICK_SENSITIVITY = settings.LeftStickSensitivity
    end,
    RightStickDeadZone = function()
        settings.RightStickDeadZone = nextTableValue(settings.RightStickDeadZone, DeadZoneValues)
        SCE_RIGHT_STICK_DEADZONE = settings.RightStickDeadZone
    end,
    RightStickSensitivity = function()
        settings.RightStickSensitivity = nextTableValue(settings.RightStickSensitivity, SensitivityValues)
        SCE_RIGHT_STICK_SENSITIVITY = settings.RightStickSensitivity
    end,
    ResetAllSettings = function()
        for k, v in pairs(SettingsDefaults) do
            if k ~= "Language" and k ~= "Theme" then
                settings[k] = v
            end
        end
        Notifications.push(Language[Settings.Language].NOTIFICATIONS.SETTINGS_RESET)
    end,
    SilentDownloads = function()
        settings.SilentDownloads = not settings.SilentDownloads
    end,
    UseProxy = function()
        settings.UseProxy = not settings.UseProxy
    end,
    ProxyIP = function()
        Keyboard.show(Language[Settings.Language].SETTINGS.ProxyIP, settings.ProxyIP, 32, TYPE_EXT_NUMBER, MODE_TEXT, OPT_NO_AUTOCAP)
        while Keyboard.getState() == RUNNING do
            Graphics.initBlend()
            Screen.clear()
            Graphics.termBlend()
            Screen.waitVblankStart()
            Screen.flip()
        end
        if Keyboard.getState() == FINISHED then
            settings.ProxyIP = Keyboard.getInput()
        end
        Keyboard.clear()
    end,
    ProxyPort = function()
        Keyboard.show(Language[Settings.Language].SETTINGS.ProxyPort, settings.ProxyPort, 5, TYPE_EXT_NUMBER, MODE_TEXT, OPT_NO_AUTOCAP)
        while Keyboard.getState() == RUNNING do
            Graphics.initBlend()
            Screen.clear()
            Graphics.termBlend()
            Screen.waitVblankStart()
            Screen.flip()
        end
        if Keyboard.getState() == FINISHED then
            settings.ProxyPort = Keyboard.getInput()
        end
        Keyboard.clear()
    end,
    UseProxyAuth = function()
        settings.UseProxyAuth = not settings.UseProxyAuth
    end,
    ProxyAuth = function()
        Keyboard.show(Language[Settings.Language].SETTINGS.ProxyAuth, settings.ProxyAuth, 128, TYPE_LATIN, MODE_TEXT, OPT_NO_AUTOCAP)
        while Keyboard.getState() == RUNNING do
            Graphics.initBlend()
            Screen.clear()
            Graphics.termBlend()
            Screen.waitVblankStart()
            Screen.flip()
        end
        if Keyboard.getState() == FINISHED then
            settings.ProxyAuth = Keyboard.getInput()
        end
        Keyboard.clear()
    end,
    SkipCacheChapterChecking = function()
        settings.SkipCacheChapterChecking = not settings.SkipCacheChapterChecking
    end
}
