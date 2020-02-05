Settings = {
    Language = "Default",
    NSFW = false,
    Orientation = "Horizontal",
    ZoomReader = "Smart",
    Version = 0.17,
    KeyType = "EU"
}
local cross = SCE_CTRL_CROSS
local circle = SCE_CTRL_CIRCLE

function Settings:load()
    if System.doesFileExist("ux0:data/noboru/settings.ini") then
        local fh = System.openFile("ux0:data/noboru/settings.ini", FREAD)
        local suc, set = pcall(function() return load("local " .. System.readFile(fh, System.sizeFile(fh)) .. " return Settings")() end)
        if suc then
            self.Language = set.Language or self.Language
            self.NSFW = set.NSFW or self.NSFW
            self.Orientation = set.Orientation or self.Orientation
            self.ZoomReader = set.ZoomReader or self.ZoomReader
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
        KeyType = self.KeyType
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
        "SwapXO",
        "ClearLibrary",
        "ClearCache",
        "ClearAllCache",
        "ClearChapters",
        "ShowVersion",
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

function Settings:swapXO()
    self.KeyType = self.KeyType == "EU" and "JP" or "EU"
    SCE_CTRL_CROSS = self.KeyType == "JP" and circle or cross
    SCE_CTRL_CIRCLE = self.KeyType == "JP" and cross or circle
    self:save()
end