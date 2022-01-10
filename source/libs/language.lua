Language = {}

Str = {appLibraryTab = "", appCatalogsTab = "", appSettingsTab = "", appDownloadTab = "", appImportTab = "", appExtensionsTab = "", appHistoryTab = "", labelSearch = "", labelLostConnection = "", labelPressToUpdate = "", labelEmptyLibrary = "", labelEmptyHistory = "", labelEmptyCatalog = "", labelEmptyDownloads = "", labelEmptyParsers = "", msgThankYou = "", msgNoConnection = "", msgPleaseWait = "", msgFailedToUpdate = "", msgAddedToLibrary = "", msgRemovedFromLibrary = "", msgSearching = "", msgStartDownload = "", msgEndDownload = "", msgCancelDownload = "", msgChapterRemove = "", msgNetProblem = "", msgChaptersCleared = "", msgLibraryCleared = "", msgCacheCleared = "", msgDeveloperThing = "", msgNewUpdateAvailable = "", msgNoSpaceLeft = "", msgRefreshCompleted = "", msgImportCompleted = "", msgSettingsReset = "", msgBadImageFound = "", msgCoverSetCompleted = "", msgNoChapters = "", prefCategoryLanguage = "", prefCategoryTheme = "", prefCategoryLibrary = "", prefCategoryCatalogs = "", prefCategoryReader = "", prefCategoryNetwork = "", prefCategoryDataSettings = "", prefCategoryOther = "", prefCategoryControls = "", prefCategoryAdvancedChaptersDeletion = "", prefCategoryAbout = "", prefCategoryLibraryDescription = "", prefCategoryCatalogsDescription = "", prefCategoryReaderDescription = "", prefCategoryNetworkDescription = "", prefCategoryDataSettingsDescription = "", prefCategoryOtherDescription = "", prefCategoryControlsDescription = "", prefCategoryAdvancedChaptersDeletionDescription = "", prefCategoryAboutDescription = "", prefLibrarySorting = "", prefCheckChaptersAtStart = "", prefShowNSFW = "", prefHideInOffline = "", labelShowNSFW = "", labelHideNSFW = "", prefReaderOrientation = "", prefReaderScaling = "", prefReaderDirection = "", prefReaderDoubleTap = "", prefPressEdgesToChangePage = "", prefAnimateGif = "", labelHorizontal = "", labelVertical = "", labelScalingSmart = "", labelScalingHeight = "", labelScalingWidth = "", labelDirectionLeft = "", labelDirectionRight = "", labelDirectionDown = "", labelDefault = "", prefConnectionTime = "", prefUseProxy = "", prefProxyIP = "", prefProxyPort = "", prefUseProxyAuth = "", prefProxyAuth = "", labelInputValue = "", prefSaveDataPath = "", prefClearLibrary = "", prefClearCache = "", prefClearAllCache = "", prefClearChapters = "", prefResetAllSettings = "", prefSkipFontLoading = "", prefChapterSorting = "", prefSilentDownloads = "", prefSkipCacheChapterChecking = "", prefShowSummary = "", prefSwapXO = "", prefChangePageButtons = "", prefLeftStickDeadZone = "", prefLeftStickSensitivity = "", prefRightStickDeadZone = "", prefRightStickSensitivity = "", labelControlLayoutEU = "", labelControlLayoutJP = "", labelLRTriggers = "", labelUseDPad = "", prefAppVersion = "", prefCheckUpdate = "", prefShowAuthor = "", prefDonatorList = "", prefSupportDev = "", prefTranslators = "", prefCheckUpdateLatestVersion = "", prefDonatorListDescription = "", labelUnzippingVPK = "", labelCurrentVersionIs = "", labelSpace = "", labelVersionIsUpToDate = "", prefPressAgainToAccept = "", prefPressAgainToUpdate = "", prefPreferredCatalogLanguage = "", labelOpenInBrowser = "", labelSetPageAsCover = "", labelResetCover = "", labelDownloadImageToMemory = "", labelNewVersionAvailable = "", labelNotSupported = "", labelInstalled = "", labelNotInstalled = "", labelCurrentVersion = "", labelLatestVersion = "", labelInstall = "", labelUpdate = "", labelRemove = "", labelLatestChanges = "", labelDownloading = "", labelLanguages = "", labelAddToLibrary = "", labelRemoveFromLibrary = "", labelPage = "", labelContinue = "", labelStart = "", labelDone = "", labelSummary = "", labelShrink = "", labelExpand = "", parserPopular = "", parserLatest = "", parserSearch = "", parserAlphabet = "", parserByLetter = "", parserByTag = "", labelPanelBack = "", labelPanelMode = "", labelPanelRead = "", labelPanelJumpToPage = "", labelPanelSearch = "", labelPanelSelect = "", labelPanelChoose = "", labelPanelImport = "", labelPanelChangeSection = "", labelPanelUpdate = "", labelPanelCancel = "", labelPanelDelete = "", labelPanelFollow = "", labelPanelUnfollow = "", labelExternalMemory = "", labelDrive = "", labelFolder = "", labelGoBack = "", labelFile = "", labelUnsupportedFile = "", labelDownloadAll = "", labelRemoveAll = "", labelCancelAll = "", labelClearBookmarks = "", labelOpenMangaInBrowser = "", labelPreparingPages = "", labelLoadingPage = "", labelLoadingSegment = "", labelYes = "", labelNo = "", RUS = "", ENG = "", ESP = "", PRT = "", FRA = "", JAP = "", DIF = "", TUR = "", ITA = "", VIE = "", DEU = "", BRA = "", POL = "", IDN = "", CHN = "", ROU = "", KOR = "", RAW = "", Russian = "", English = "", Turkish = "", Spanish = "", Vietnamese = "", French = "", Italian = "", PortugueseBR = "", SimplifiedChinese = "", TraditionalChinese = "", Romanian = "", Polish = "", German = "", Default = ""}

local stringsList = {}

LanguageNames = {}

local defaultLangName = "English"

function Language.registerStrings(strings, langName, langLetterCode, authorName, langCode)
	if not stringsList[langName] then
		LanguageNames[#LanguageNames + 1] = langName
	else
		for i = 1, #stringsList do
			if stringsList[i]._langName == langName then
				table.remove(stringsList, i)
				break
			end
		end
	end
	if langCode then
		stringsList[tostring(langCode)] = strings
	end
	local currentLangCode = System.getLanguage()
	if langCode == currentLangCode then
		defaultLangName = langName
	end
	stringsList[langName] = strings
	stringsList[#stringsList + 1] = strings
	strings._langLetterCode = langLetterCode
	strings._langName = langName
	strings._langCode = langCode
	strings._authorName = authorName
end

function Language.load()
	local translationFileList = System.listDirectory("app0:langs")
	for _, file in ipairs(translationFileList) do
		if not file.directory then
			xpcall(dofile, Console.error, "app0:langs/" .. file.name)
		end
	end
end

function Language.set(langName)
	local newStrings = {}
	for k, v in pairs(stringsList["English"]) do
		newStrings[k] = v
	end
	langName = langName == "Default" and defaultLangName or langName
	if stringsList[langName] then
		for k, v in pairs(stringsList[langName]) do
			newStrings[k] = v
		end
	else
		Console.error('Can\'t find "' .. langName .. '" translation')
	end
	Str = newStrings
end

function Language.getTranslation(stringKey, langName)
	langName = langName == "Default" and defaultLangName or langName or "English"
	local translatedString = stringsList[langName] and stringsList[langName][stringKey]
	if not translatedString then
		Console.error('Can\'t find value of "' .. stringKey .. '" for "' .. langName .. '" translation')
		return stringsList["English"][stringKey] or stringKey
	end
	return translatedString
end

Language.load()
