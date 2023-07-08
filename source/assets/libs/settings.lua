Settings = {
	Language = "Default",
	Theme = "Light",
	Version = 0.911,
	NSFW = false,
	Orientation = "Horizontal",
	ZoomReader = "Smart",
	DoubleTapReader = true,
	PressEdgesToChangePage = false,
	KeyType = "EU",
	ReaderDirection = "RIGHT",
	HideInOffline = true,
	SkipFontLoad = false,
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
	SkipCacheChapterChecking = true,
	ConnectionTime = 10,
	FavouriteParsers = {},
	AnimatedGif = false,
	SaveDataPath = "ux0",
	LoadSummary = true
}

NSFWLock = System.doesFileExist("ux0:data/noboru/.lock")

local settingsDefaults = table.clone(Settings)

DeadZoneValues = { 20, 30, 40, 50, 90 }
SensitivityValues = { 0.25, 0.50, 0.75, 1, 1.25, 1.5, 1.75 }

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
local doesDirExist = System.doesDirExist
local createDirectory = System.createDirectory
local installApp = System.installApp
local launchApp = System.launchApp
local removeDirectory = RemoveDirectory

local is_app_updating = false

---@return boolean
---Gives true if app is updating
function settings.isAppUpdating()
	return is_app_updating
end

local copyFile = CopyFile

---Sets colors from Themes[Settings.Theme] to their values
local function setTheme(name)
	if Themes[name] then
		for k, v in pairs(Themes[name]) do
			_G[k] = v
		end
	end
end

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
				is_app_updating = false
			end
			return
		end
		closeFile(fh)
		removeDirectory("ux0:data/noboru/NOBORU")
		if notify then
			Notifications.push(Language[settings.Language].SETTINGS.UnzipingVPK)
			Notifications.push(Language[settings.Language].SETTINGS.PleaseWait, 60000)
		end
		Threads.insertTask(
			"ExtractingApp",
			{
				Type = "UnZip",
				DestPath = "ux0:data/noboru/NOBORU",
				Path = "NOBORU.vpk",
				OnComplete = function()
					deleteFile("ux0:data/noboru/NOBORU.vpk")
					removeDirectory("ux0:data/noboru/pkg")
					createDirectory("ux0:data/noboru/pkg")
					createDirectory("ux0:data/noboru/pkg/sce_sys")
					copyFile("app0:updater/eboot.bin", "ux0:data/noboru/pkg/eboot.bin")
					copyFile("app0:updater/param.sfo", "ux0:data/noboru/pkg/sce_sys/param.sfo")
					installApp("ux0:data/noboru/pkg")
					removeDirectory("ux0:data/noboru/pkg")
					launchApp("NOBORUPDT")
					is_app_updating = false
				end
			}
		)
	end
	if notify and not Threads.check("ExtractingApp") then
		Notifications.push(Language[settings.Language].SETTINGS.FailedToUpdate)
		is_app_updating = false
	end
end

function Settings.toggleFavouriteParser(Parser)
	if Parser and Parser.ID then
		settings.FavouriteParsers[Parser.ID] = not settings.FavouriteParsers[Parser.ID] and true or nil
		ChangeNSFW()
		Settings.save()
	end
end

function Settings.getSaveDrivePath()
	if settings.SaveDataPath == "uma0" and not doesDirExist("uma0:data/noboru") then
		return "ux0"
	else
		return settings.SaveDataPath
	end
end

---Table of all available options
local settingsListTree = {
	"Language",
	"ChangeUI",
	"Library",
	"Catalogs",
	"Reader",
	"Network",
	"Data",
	"AdvancedChaptersDeletion",
	"Other",
	"Controls",
	"About",
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
		"DoubleTapReader",
		"PressEdgesToChangePage",
		"AnimatedGif"
	},
	Network = {
		"ConnectionTime",
		"UseProxy",
		"ProxyIP",
		"ProxyPort",
		"UseProxyAuth",
		"ProxyAuth"
	},
	Data = {
		"SaveDataPath",
		"ClearLibrary",
		"ClearCache",
		"ClearAllCache",
		"ClearChapters",
		"ResetAllSettings"
	},
	AdvancedChaptersDeletion = {},
	Other = {
		"SkipFontLoading",
		"ChapterSorting",
		"SilentDownloads",
		"SkipCacheChapterChecking",
		"LoadSummary"
	},
	About = {
		"ShowVersion",
		"CheckUpdate",
		"ShowAuthor",
		"SupportDev",
		"DonatorsList",
		"Translators",
		DonatorsList = {}
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
local settingsListCurrentNode = settingsListTree
local settingsListCurrentPath = {}
local settingsListCurrentNodeName = "MainSettingsMenu"
local settingsListCurrentPathNames = {}

---@param source table
---@param settingName string
---@param values table
---Sets `settings[setting_name]` value to `source[setting_name]` if value is in `values` table
---
---Example:
---
---`setSetting(new_settings, "SpeedOfScrolling", {1,5,10}) ->`
---
---`sets Settings.SpeedOfScrolling to new_settings.SpeedOfScrolling if it is 1, 5 or 10 else sets to nil`
local function setSetting(source, settingName, values)
	local newValue = source[settingName]
	if newValue == nil then
		return
	end
	if #values == 0 then
		settings[settingName] = newValue
	end
	for _, v in pairs(values) do
		if newValue == v then
			settings[settingName] = newValue
			return
		end
	end
	if values[newValue] then
		settings[settingName] = newValue
	end
end

local SETTINGS_SAVE_PATH = "ux0:data/noboru/settings.ini"

---Loads settings from `ux0:data/noboru/settings.ini`
function settings.load()
	if doesFileExist(SETTINGS_SAVE_PATH) then
		local fh = openFile(SETTINGS_SAVE_PATH, FREAD)
		local suc = load("local " .. readFile(fh, sizeFile(fh)) .. " return Settings")
		if suc then
			local new = suc()
			if type(new) == "table" then
				setSetting(new, "Language", Language)
				if Language[settings.Language] == nil then
					settings.Language = "Default"
				end
				if NSFWLock then
					setSetting(new, "NSFW", { false })
					if settingsListTree and settingsListTree.Catalogs and settingsListTree.Catalogs[1] then
						table.remove(settingsListTree.Catalogs, 1)
						for k, v in pairs(Language) do
							Language[k].SETTINGS_DESCRIPTION.Catalogs = nil
						end
					end
				else
					setSetting(new, "NSFW", { true, false })
				end
				setSetting(new, "SkipFontLoad", { true, false })
				setSetting(new, "Orientation", { "Horizontal", "Vertical" })
				setSetting(new, "ZoomReader", { "Width", "Height", "Smart" })
				setSetting(new, "ReaderDirection", { "LEFT", "RIGHT", "DOWN" })
				setSetting(new, "KeyType", { "JP", "EU" })
				setSetting(new, "HideInOffline", { true, false })
				setSetting(new, "DoubleTapReader", { true, false })
				setSetting(new, "Theme", Themes)
				setSetting(new, "ParserLanguage", GetParserLanguages())
				setSetting(new, "LibrarySorting", { "Date added", "A-Z", "Z-A" })
				setSetting(new, "ChapterSorting", { "1->N", "N->1" })
				setSetting(new, "RefreshLibAtStart", { true, false })
				setSetting(new, "ChangingPageButtons", { "DPAD", "LR" })
				setSetting(new, "LeftStickDeadZone", DeadZoneValues)
				setSetting(new, "LeftStickSensitivity", SensitivityValues)
				setSetting(new, "RightStickDeadZone", DeadZoneValues)
				setSetting(new, "RightStickSensitivity", SensitivityValues)
				setSetting(new, "SilentDownloads", { true, false })
				setSetting(new, "UseProxy", { true, false })
				setSetting(new, "ProxyIP", {})
				setSetting(new, "ProxyPort", {})
				setSetting(new, "UseProxyAuth", { true, false })
				setSetting(new, "ProxyAuth", {})
				setSetting(new, "SkipCacheChapterChecking", { true, false })
				setSetting(new, "ConnectionTime", {})
				setSetting(new, "FavouriteParsers", {})
				setSetting(new, "SaveDataPath", { "ux0", "uma0" })
				setSetting(new, "PressEdgesToChangePage", { true, false })
				setSetting(new, "AnimatedGif", { true, false })
				setSetting(new, "LoadSummary", { true, false })
			end
		end
		closeFile(fh)
	end
	settings.save()
	GenPanels()
	Network.setConnectionTime(settings.ConnectionTime or 10)
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
	local copiedSettings = {}
	for k, v in pairs(settings) do
		if type(v) ~= "function" and k ~= "Version" then
			copiedSettings[k] = v
		end
	end
	local saveSettingsContent = "Settings = " .. table.serialize(copiedSettings)
	writeFile(fh, saveSettingsContent, #saveSettingsContent)
	closeFile(fh)
end

---@return table
---Return list of available options
function settings.list()
	return settingsListCurrentNode
end

---@param mode string
---@return boolean
---Checks if setting is submenu
function settings.isTab(mode)
	return settingsListCurrentNode[mode] ~= nil or settingsListCurrentNodeName == "AdvancedChaptersDeletion"
end

local listDirectory = System.listDirectory

---@param mode string
---Sets settings menu as submenu `mode`
function settings.setTab(mode)
	if settingsListCurrentNodeName == "AdvancedChaptersDeletion" then
		Reader.load(
			{
				{
					FastLoad = true,
					Name = mode.name,
					Link = "AABBCCDDEEFFGG",
					Path = mode.chapterPath,
					Pages = {},
					Manga = {
						Name = mode.name,
						Link = "AABBCCDDEEFFGG",
						ImageLink = "",
						ParserID = "IMPORTED"
					}
				}
			},
			1
		)
		AppMode = READER
	elseif settingsListCurrentNodeName == "DonatorsList" then
	else
		if settingsListCurrentNode[mode] then
			if mode == "AdvancedChaptersDeletion" then
				local possibilities = {}
				local cachedManga = Cache.getManga()
				for _, manga in pairs(cachedManga) do
					local chapters = Cache.loadChapters(manga)
					for _, chapter in ipairs(chapters) do
						possibilities[ChapterSaver.getKey(chapter)] = chapter
					end
				end
				local drives = { "ux0:", "uma0" }
				local t = {}
				for _, drive in ipairs(drives) do
					if doesDirExist(drive) then
						for _, v in pairs(listDirectory(drive .. "data/noboru/chapters")) do
							if v.directory and not v.name:find("^IMPORTED") then
								if possibilities[v.name] then
									local manga = possibilities[v.name].Manga
									local chapter = possibilities[v.name]
									t[#t + 1] = {
										name = (GetParserByID(manga.ParserID) and GetParserByID(manga.ParserID).Name or "Unknown Catalog") .. " - " .. manga.Name,
										info = chapter.Name,
										type = "savedChapter",
										chapterPath = drive .. "data/noboru/chapters/" .. v.name,
										key = v.name
									}
								else
									t[#t + 1] = {
										name = "Unknown Manga ID: " .. (v.name:match("^([^_]+)_") or "UNKNOWN"),
										info = v.name:match("^[^_]+_(.+)$") or v.name,
										type = "savedChapter",
										chapterPath = drive .. "data/noboru/chapters/" .. v.name,
										key = v.name
									}
								end
							end
						end
					end
				end
				settingsListCurrentNode[mode] = t
			elseif mode == "DonatorsList" then
				local t = {}
				t[#t + 1] = {
					name = Language[Settings.Language].MESSAGE.THANK_YOU,
					info = ""
				}
				if doesFileExist("ux0:data/noboru/donators") then
					local fh = openFile("ux0:data/noboru/donators", FREAD)
					local d_list = ToLines(readFile(fh, sizeFile(fh))) or {}
					for i = 1, #d_list do
						if d_list[i]:gsub("%s", "") ~= "" then
							t[#t + 1] = {
								name = d_list[i],
								info = ""
							}
						end
					end
					closeFile(fh)
				end
				settingsListCurrentNode[mode] = t
			end
			settingsListCurrentPath[#settingsListCurrentPath + 1] = settingsListCurrentNode
			settingsListCurrentNode = settingsListCurrentNode[mode]
			settingsListCurrentPathNames[#settingsListCurrentPathNames + 1] = settingsListCurrentNodeName
			settingsListCurrentNodeName = mode
		end
	end
end

---@param mode string
---Deletes `mode` submenu from settings
function settings.delTab(mode)
	if settingsListCurrentNodeName == "AdvancedChaptersDeletion" then
		for k, v in pairs(settingsListCurrentNode) do
			if v.chapterPath == mode.chapterPath then
				table.remove(settingsListCurrentNode, k)
			end
		end
		removeDirectory(mode.chapterPath)
		ChapterSaver.removeByKeyUnsafe(mode.key)
	end
end

---@return boolean
---Checks if settings not in main settings menu (subsettings screen)
function settings.inTab()
	return #settingsListCurrentPath > 0
end

---@return string
---Returns tab name of settings that user is in
function settings.getTab()
	return settingsListCurrentNodeName
end

---Throws in main settings menu
function settings.back()
	if #settingsListCurrentPath > 0 then
		settingsListCurrentNode = settingsListCurrentPath[#settingsListCurrentPath]
		settingsListCurrentPath[#settingsListCurrentPath] = nil
		settingsListCurrentNodeName = settingsListCurrentPathNames[#settingsListCurrentPathNames]
		settingsListCurrentPathNames[#settingsListCurrentPathNames] = nil
	end
end

local lastVpkLink
local lastVpkSize = "NaN"
local changesText

---Starting update for NOBORU Application
function settings.updateApp()
	if Threads.netActionUnSafe(Network.isWifiEnabled) then
		if lastVpkLink then
			is_app_updating = true
			Notifications.push(Language[settings.Language].SETTINGS.PleaseWait)
			Threads.insertTask(
				"DownloadAppUpdate",
				{
					Type = "FileDownload",
					Link = "https://github.com" .. lastVpkLink,
					Path = "NOBORU.vpk",
					OnComplete = function()
						UpdateApp()
					end
				}
			)
		end
	else
		Notifications.push(Language[settings.Language].SETTINGS.NoConnection)
	end
end

---Table with Option Names and their Functions
SettingsFunctions = {
	Language = function()
		Extra.setLanguage()
		--settings.Language = table.next(settings.Language, GetLanguages())
		--GenPanels()
	end,
	SkipFontLoading = function()
		settings.SkipFontLoad = not settings.SkipFontLoad
	end,
	ChangeUI = function()
		settings.Theme = table.next(settings.Theme, GetThemes())
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
		settings.Orientation = table.next(settings.Orientation, { "Horizontal", "Vertical" })
	end,
	ZoomReader = function()
		settings.ZoomReader = table.next(settings.ZoomReader, { "Width", "Height", "Smart" })
	end,
	ReaderDirection = function()
		settings.ReaderDirection = table.next(settings.ReaderDirection, { "LEFT", "RIGHT", "DOWN" })
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
			Threads.insertTask(
				"CheckLatestVersion",
				{
					Type = "StringRequest",
					Link = "https://github.com/Creckeryop/NOBORU/releases/latest",
					Table = file,
					Index = "string",
					OnComplete = function()
						local content = file.string or ""
						local tag = content:match("releases/tag/([0-9.]+)")

						if tag == nil then
							return
						end

						local latestVersion = tonumber(tag)
						if latestVersion == nil then
							return
						end

						local assetsFile = {}
						Threads.insertTask(
							"LoadAssetsData",
							{
								Type = "StringRequest",
								Link = "https://github.com/Creckeryop/NOBORU/releases/expanded_assets/" .. tag,
								Table = assetsFile,
								Index = "string",
								OnComplete = function ()
									local assetsContent = assetsFile.string or ""
									local link = assetsContent:match('href="([^"]-%.vpk)"') or ""
									local late = link:match("/([^/]-)/[^/]-%.vpk")
									if late then
										lastVpkLink = link
										lastVpkSize = assetsContent:match(">([0-9.]* MB)<") or "NaN"
										settings.LateVersion = latestVersion or settings.LateVersion
										local body = content:match('markdown%-body[^>]-">(.-)</div>') or ""
										changesText = body:gsub("\n+%s-(%S)", "\n%1"):gsub("<li>", " * "):gsub("<[^>]->", ""):gsub("\n\n", "\n"):gsub("^\n", ""):gsub("%s+$", "") or ""				
										if settings.LateVersion and settings.Version and tonumber(settings.LateVersion) > tonumber(settings.Version) then
											Changes.load(Language[settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE .. " : " .. settings.LateVersion .. "\n" .. Language[settings.Language].SETTINGS.CurrentVersionIs .. settings.Version .. "\n\n" .. changesText)
											Notifications.push(Language[settings.Language].NOTIFICATIONS.NEW_UPDATE_AVAILABLE .. " " .. settings.LateVersion)
										end
									end
								end
							}
						)
					end
				}
			)
		else
			Notifications.push(Language[settings.Language].SETTINGS.NoConnection)
		end
	end,
	CheckDonators = function()
		if Threads.netActionUnSafe(Network.isWifiEnabled) then
			Threads.insertTask(
				"CheckDonators",
				{
					Type = "FileDownload",
					Link = "https://creckeryop.github.io/DONATIONS.md",
					Path = "ux0:data/noboru/donators"
				}
			)
		end
	end,
	GetLastVpkSize = function()
		return lastVpkSize
	end,
	ShowAuthor = function()
		Notifications.push(Language[Settings.Language].NOTIFICATIONS.DEVELOPER_THING .. "\nhttps://github.com/Creckeryop/NOBORU")
	end,
	SwapXO = function()
		settings.KeyType = table.next(settings.KeyType, { "JP", "EU" })
		SCE_CTRL_CROSS = settings.KeyType == "JP" and circle or cross
		SCE_CTRL_CIRCLE = settings.KeyType == "JP" and cross or circle
	end,
	PreferredCatalogLanguage = function()
		settings.ParserLanguage = table.next(settings.ParserLanguage, GetParserLanguages())
		ChangeNSFW()
	end,
	LibrarySorting = function()
		settings.LibrarySorting = table.next(settings.LibrarySorting, { "Date added", "A-Z", "Z-A" })
	end,
	ChapterSorting = function()
		settings.ChapterSorting = table.next(settings.ChapterSorting, { "1->N", "N->1" })
	end,
	RefreshLibAtStart = function()
		settings.RefreshLibAtStart = table.next(settings.RefreshLibAtStart, { true, false })
	end,
	ChangingPageButtons = function()
		settings.ChangingPageButtons = table.next(settings.ChangingPageButtons, { "DPAD", "LR" })
		SCE_CTRL_RIGHTPAGE = settings.ChangingPageButtons == "DPAD" and SCE_CTRL_RIGHT or SCE_CTRL_RTRIGGER
		SCE_CTRL_LEFTPAGE = settings.ChangingPageButtons == "DPAD" and SCE_CTRL_LEFT or SCE_CTRL_LTRIGGER
	end,
	LeftStickDeadZone = function()
		settings.LeftStickDeadZone = table.next(settings.LeftStickDeadZone, DeadZoneValues)
		SCE_LEFT_STICK_DEADZONE = settings.LeftStickDeadZone
	end,
	LeftStickSensitivity = function()
		settings.LeftStickSensitivity = table.next(settings.LeftStickSensitivity, SensitivityValues)
		SCE_LEFT_STICK_SENSITIVITY = settings.LeftStickSensitivity
	end,
	RightStickDeadZone = function()
		settings.RightStickDeadZone = table.next(settings.RightStickDeadZone, DeadZoneValues)
		SCE_RIGHT_STICK_DEADZONE = settings.RightStickDeadZone
	end,
	RightStickSensitivity = function()
		settings.RightStickSensitivity = table.next(settings.RightStickSensitivity, SensitivityValues)
		SCE_RIGHT_STICK_SENSITIVITY = settings.RightStickSensitivity
	end,
	ResetAllSettings = function()
		for k, v in pairs(settingsDefaults) do
			if k ~= "FavouriteParsers" and k ~= "Language" and k ~= "Theme" then
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
	end,
	ConnectionTime = function()
		Keyboard.show(Language[settings.Language].SETTINGS.InputValue, settings.ConnectionTime, 128, TYPE_NUMBER, MODE_TEXT, OPT_NO_AUTOCAP)
		while Keyboard.getState() == RUNNING do
			Graphics.initBlend()
			Screen.clear()
			Graphics.termBlend()
			Screen.waitVblankStart()
			Screen.flip()
		end
		if Keyboard.getState() == FINISHED then
			local new_time = tonumber(Keyboard.getInput())
			if new_time and new_time > 0 then
				settings.ConnectionTime = Keyboard.getInput()
				Network.setConnectionTime(settings.ConnectionTime or 10)
			end
		end
		Keyboard.clear()
	end,
	PressEdgesToChangePage = function()
		settings.PressEdgesToChangePage = not settings.PressEdgesToChangePage
	end,
	SaveDataPath = function()
		settings.SaveDataPath = table.next(settings.SaveDataPath, { "ux0", "uma0" })
	end,
	AnimatedGif = function()
		settings.AnimatedGif = not settings.AnimatedGif
	end,
	LoadSummary = function()
		settings.LoadSummary = not settings.LoadSummary
	end
}
