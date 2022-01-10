--
local strings = {
    --Tabs
    appLibraryTab = "LIBRARY",
    appCatalogsTab = "CATALOGS",
    appSettingsTab = "SETTINGS",
    appDownloadTab = "DOWNLOADS",
    appImportTab = "IMPORT",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "HISTORY",
    labelSearch = "Search",
    --
    --Message-screen messages
    labelLostConnection = "Connection is lost\n\nWaiting for connection...\n\n(Minimize application, go Wi-Fi Settings and press Connect)\n\nPress X to cancel all downloads and close message\n\nAll downloads will continue if the network is restored",
    labelPressToUpdate = "Press X to update\nPress O to cancel",
    --
    --Information text
    labelEmptyLibrary = 'No manga/comics.\nTo add manga/comics, find it in "CATALOGS" menu and press "Add to library".',
    labelEmptyHistory = "No manga/comics.\nIt will appear here someday",
    labelEmptyCatalog = "No manga/comics.\nServer, connection or parser error",
    labelEmptyDownloads = "No downloading manga/comics",
    labelEmptyParsers = "No catalogs.\nPress Triangle and wait until all catalogs will be loaded",
    --
    --Notification information texts
    msgThankYou = "Thank you for supporting this project!",
    msgNoConnection = "No connection",
    msgPleaseWait = "Please wait",
    msgFailedToUpdate = "Failed to update app",
    msgAddedToLibrary = "Added to library",
    msgRemovedFromLibrary = "Removed from library",
    msgSearching = 'Searching "%s"',
    msgStartDownload = "%s: %s\ndownloading started!",
    msgEndDownload = "%s: %s\nsuccessfully downloaded!",
    msgCancelDownload = "%s: %s\ndownload is canceled!",
    msgChapterRemove = "%s deleted!",
    msgNetProblem = "There is problems with connection!",
    msgChaptersCleared = "All saved chapters are cleared!",
    msgLibraryCleared = "Library cleared!",
    msgCacheCleared = "Cache has been cleared!",
    msgDeveloperThing = "Star app on Github!",
    msgNewUpdateAvailable = "New update available",
    msgNoSpaceLeft = "No space left",
    msgRefreshCompleted = "Refresh completed!",
    msgImportCompleted = "Import completed!",
    msgSettingsReset = "Settings have been reset",
    msgBadImageFound = "Bad Image found!",
    msgCoverSetCompleted = "Cover was updated!",
    msgNoChapters = "No chapters",
    --
    --Sections
    prefCategoryLanguage = "Language",
    prefCategoryTheme = "Theme",
    prefCategoryLibrary = "Library",
    prefCategoryCatalogs = "Catalogs",
    prefCategoryReader = "Reader",
    prefCategoryNetwork = "Network",
    prefCategoryDataSettings = "Data settings",
    prefCategoryOther = "Other",
    prefCategoryControls = "Controls Setup",
    prefCategoryAdvancedChaptersDeletion = "Advanced chapters deletion",
    prefCategoryAbout = "About program",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Settings related to manga tracking",
    prefCategoryCatalogsDescription = "Language, NSFW content",
    prefCategoryReaderDescription = "Read direction, orientation, zoom",
    prefCategoryNetworkDescription = "Connection timeout, proxy",
    prefCategoryDataSettingsDescription = "Saves, cache, settings",
    prefCategoryOtherDescription = "Font loading, chapters sorting, notifications",
    prefCategoryControlsDescription = "Controls layout, change page buttons, sticks settings",
    prefCategoryAdvancedChaptersDeletionDescription = "Read, remove",
    prefCategoryAboutDescription = "Version, update",
    --
    --Library section
    prefLibrarySorting = "Library sorting",
    prefCheckChaptersAtStart = "Check for the new chapters at startup",
    --
    --Catalogs section
    prefShowNSFW = "Show NSFW catalogs",
    prefHideInOffline = "Show only downloaded chapters in offline mode",
    --
    --Catalogs labels
    labelShowNSFW = "Show",
    labelHideNSFW = "Don't show",
    --
    --Reader section
    prefReaderOrientation = "Default reader orientation",
    prefReaderScaling = "Default reader image scaling",
    prefReaderDirection = "Default reading direction",
    prefReaderDoubleTap = "Enable double tap zoom",
    prefPressEdgesToChangePage = "Change pages by pressing edges of page",
    prefAnimateGif = "Animate gif (Experimental)",
    --
    --Reader labels
    labelHorizontal = "Horizontal",
    labelVertical = "Vertical",
    labelScalingSmart = "Smart",
    labelScalingHeight = "Height",
    labelScalingWidth = "Width",
    labelDirectionLeft = "Right to left",
    labelDirectionRight = "Left to right",
    labelDirectionDown = "Up to down",
    labelDefault = "Default",
    --
    --Network section
    prefConnectionTime = "Connection time for server",
    prefUseProxy = "Use proxy",
    prefProxyIP = "IP address",
    prefProxyPort = "Port",
    prefUseProxyAuth = "Use proxy authentication",
    prefProxyAuth = "login:password",
    --
    --Network labels
    labelInputValue = "Input value",
    --
    --Data settings section
    prefSaveDataPath = "Save data path",
    prefClearLibrary = "Clear library",
    prefClearCache = "Clear cache of non followed manga",
    prefClearAllCache = "Clear all cache",
    prefClearChapters = "Clear all saved chapters",
    prefResetAllSettings = "Reset all settings",
    --
    --Other section
    prefSkipFontLoading = "Skip font loading",
    prefChapterSorting = "Chapters sorting",
    prefSilentDownloads = "Don't show downloads notifications",
    prefSkipCacheChapterChecking = "Skip checking cache and saved chapters while loading",
    prefShowSummary = "Show summary",
    --
    --Control setup section
    prefSwapXO = "Swap X and O",
    prefChangePageButtons = "Buttons to change page",
    prefLeftStickDeadZone = "Left stick deadzone",
    prefLeftStickSensitivity = "Left stick sensitivity",
    prefRightStickDeadZone = "Right stick deadzone",
    prefRightStickSensitivity = "Right stick sensitivity",
    --
    --Control setup labels
    labelControlLayoutEU = "Europe",
    labelControlLayoutJP = "Japan",
    labelLRTriggers = "L and R triggers",
    labelUseDPad = "Using DPad",
    --
    --About section
    prefAppVersion = "App version",
    prefCheckUpdate = "Check for updates",
    prefShowAuthor = "Developer",
    prefDonatorList = "List of donators",
    prefSupportDev = "Support the developer",
    prefTranslators = "Thanks to translators",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Latest version : ",
    prefDonatorListDescription = "List of guys who supported project",
    --
    --About status labels
    labelUnzippingVPK = "Extracting vpk to install",
    labelCurrentVersionIs = "Current version is:",
    labelSpace = "Memory used",
    labelVersionIsUpToDate = "Your version is up to date",
    prefPressAgainToAccept = "Press again to accept",
    prefPressAgainToUpdate = "Press again to update on:",
    prefPreferredCatalogLanguage = "Preferred Language",
    labelOpenInBrowser = "Open in browser",
    labelSetPageAsCover = "Set page as cover",
    labelResetCover = "Reset cover",
    labelDownloadImageToMemory = "Download image",
    --
    --Extension tab labels
    labelNewVersionAvailable = "New version available",
    labelNotSupported = "Extension isn't supported",
    labelInstalled = "Installed",
    labelNotInstalled = "Not installed",
    labelCurrentVersion = "Current version",
    labelLatestVersion = "Latest version",
    labelInstall = "Install",
    labelUpdate = "Update",
    labelRemove = "Remove",
    labelLatestChanges = "Latest changes",
    labelDownloading = "Downloading...",
    labelLanguages = "Languages",
    --
    --Book info labels
    labelAddToLibrary = "Add to library",
    labelRemoveFromLibrary = "Remove from library",
    labelPage = "Page : ",
    labelContinue = "Continue",
    labelStart = "Start reading",
    labelDone = "Completed!",
    labelSummary = "Summary",
    labelShrink = "Shrink",
    labelExpand = "Read more",
    --
    --Parser modes
    parserPopular = "Popular",
    parserLatest = "Latest",
    parserSearch = "Search",
    parserAlphabet = "Alphabet",
    parserByLetter = "By Letter",
    parserByTag = "By Tag",
    --
    --Panel labels
    labelPanelBack = "Back",
    labelPanelMode = "Mode",
    labelPanelRead = "Read",
    labelPanelJumpToPage = "Jump to page",
    labelPanelSearch = "Search",
    labelPanelSelect = "Select",
    labelPanelChoose = "Choose",
    labelPanelImport = "Import",
    labelPanelChangeSection = "Change section",
    labelPanelUpdate = "Refresh",
    labelPanelCancel = "Cancel",
    labelPanelDelete = "Delete",
    labelPanelFollow = "Follow",
    labelPanelUnfollow = "Unfollow",
    --
    --Import labels
    labelExternalMemory = "External Memory",
    labelDrive = "Drive",
    labelFolder = "Folder",
    labelGoBack = "Go back",
    labelFile = "File",
    labelUnsupportedFile = "Unsupported file",
    --
    --Buttons labels
    labelDownloadAll = "Download all chapters",
    labelRemoveAll = "Remove all chapters",
    labelCancelAll = "Cancel downloading chapters",
    labelClearBookmarks = "Clear bookmarks",
    labelOpenMangaInBrowser = "Open manga in browser",
    --
    --Reader labels
    labelPreparingPages = "Preparing pages",
    labelLoadingPage = "Loading page",
    labelLoadingSegment = "Loading segment",
    --
    labelYes = "Yes",
    labelNo = "No",
    --Country codes alpha-3
    RUS = "Russian",
    ENG = "English",
    ESP = "Spanish",
    PRT = "Portuguese",
    FRA = "French",
    JAP = "Japanese",
    DIF = "Different",
    TUR = "Turkish",
    ITA = "Italian",
    VIE = "Vietnamese",
    DEU = "German",
    BRA = "Brazil",
    POL = "Polish",
    IDN = "Indonesian",
    CHN = "Chinese",
    ROU = "Romanian",
    KOR = "Korean",
    RAW = "Raw (Untranslated manga)",
    --Language translations
    Russian = "Russian",
    English = "English",
    Turkish = "Turkish",
    Spanish = "Spanish",
    Vietnamese = "Vietnamese",
    French = "French",
    Italian = "Italian",
    PortugueseBR = "Brazilian portuguese",
    SimplifiedChinese = "Simplified Chinese",
    TraditionalChinese = "Traditional Chinese",
    Romanian = "Romanian",
    Polish = "Polish",
    German = "German",
    Default = "System",
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "English", "ENG", "creckeryop", 1)
