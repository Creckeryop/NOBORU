--Traditional Chinese translation by @Qingyu510
local strings = {
    --Tabs
    appLibraryTab = "書架",
    appCatalogsTab = "目錄",
    appSettingsTab = "設置",
    appDownloadTab = "下載",
    appImportTab = "導入",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "歷史",
    labelSearch = "搜索",
    --
    --Message-screen messages
    labelLostConnection = "連接失敗\n\n等待連接...\n\n(最小化應用程序 , 轉到設置到WIFI設置 , 然後選擇連接網絡)\n\n按 × 取消所有下載並關閉消息\n\n如果網絡恢復正常 , 將繼續所有下載",
    labelPressToUpdate = "按 × 更新\n按 ○ 取消",
    --
    --Information text
    labelEmptyLibrary = "沒有漫畫。\n想要添加漫畫, 請在“目錄”菜單中尋找漫畫, 然後按“添加到書架”。",
    labelEmptyHistory = "沒有漫畫\n它總有壹天會出現在這裡",
    labelEmptyCatalog = "沒有漫畫\n服務器、連接或解析器錯誤",
    labelEmptyDownloads = "沒有下載的漫畫",
    labelEmptyParsers = "沒有目錄\n請按△並進行等待, 直到所有列表加載完成",
    --
    --Notification information texts
    msgThankYou = "感謝您對該項目的支持!",
    msgNoConnection = "沒有網絡連接",
    msgPleaseWait = "請稍候",
    msgFailedToUpdate = "應用更新失敗",
    msgAddedToLibrary = "已添加到書架",
    msgRemovedFromLibrary = "從書架中已刪除",
    msgSearching = '正在搜索 "%s"',
    msgStartDownload = "%s: %s\n開始下載!",
    msgEndDownload = "%s: %s\n下載成功!",
    msgCancelDownload = "%s: %s\n下載已取消",
    msgChapterRemove = "%s 刪除",
    msgNetProblem = "連接出現錯誤",
    msgChaptersCleared = "已清除保存的章節!",
    msgLibraryCleared = "書架已清除!",
    msgCacheCleared = "緩存已被清除!",
    msgDeveloperThing = "在Github上為應用標註星號!",
    msgNewUpdateAvailable = "發現新版本",
    msgNoSpaceLeft = "沒有剩余空間",
    msgRefreshCompleted = "刷新完成!",
    msgImportCompleted = "導入完成!",
    msgSettingsReset = "設置已重置",
    msgBadImageFound = "導入圖像錯誤!",
    msgCoverSetCompleted = "漫畫封面已更新!",
    msgNoChapters = "沒有章節",
    --
    --Sections
    prefCategoryLanguage = "語言",
    prefCategoryTheme = "主題",
    prefCategoryLibrary = "書架",
    prefCategoryCatalogs = "目錄",
    prefCategoryReader = "閱讀",
    prefCategoryNetwork = "網絡",
    prefCategoryDataSettings = "數據",
    prefCategoryOther = "其他",
    prefCategoryControls = "控制器",
    prefCategoryAdvancedChaptersDeletion = "高級章節刪除",
    prefCategoryAbout = "關於",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "書架排序, 漫畫追蹤相關的設置",
    prefCategoryCatalogsDescription = "語言, NSFW 內容",
    prefCategoryReaderDescription = "屏幕方向, 閱讀方向, 頁面縮放",
    prefCategoryNetworkDescription = "連接超時, 網絡代理",
    prefCategoryDataSettingsDescription = "儲存路徑, 清除緩存, 重置設置",
    prefCategoryOtherDescription = "字體加載, 章節排序, 下載通知",
    prefCategoryControlsDescription = "按鍵類型, 變更翻頁按鍵, 搖桿設置",
    prefCategoryAdvancedChaptersDeletionDescription = "閱讀, 刪除",
    prefCategoryAboutDescription = "版本, 更新",
    --
    --Library section
    prefLibrarySorting = "書架排序",
    prefCheckChaptersAtStart = "啟動時刷新庫",
    --
    --Catalogs section
    prefShowNSFW = "顯示成人內容",
    prefHideInOffline = "僅在離線模式下顯示下載的章節",
    --
    --Catalogs labels
    labelShowNSFW = "顯示",
    labelHideNSFW = "不顯示",
    --
    --Reader section
    prefReaderOrientation = "屏幕方向",
    prefReaderScaling = "頁面縮放",
    prefReaderDirection = "閱讀方向",
    prefReaderDoubleTap = "啟用雙擊縮放",
    prefPressEdgesToChangePage = "點擊屏幕邊緣進行翻頁",
    prefAnimateGif = "GIF動畫（實驗性）",
    --
    --Reader labels
    labelHorizontal = "豎屏",
    labelVertical = "橫屏",
    labelScalingSmart = "適應屏幕",
    labelScalingHeight = "匹配高度",
    labelScalingWidth = "匹配寬度",
    labelDirectionLeft = "從右到左",
    labelDirectionRight = "從左到右",
    labelDirectionDown = "從上到下",
    labelDefault = "默認",
    --
    --Network section
    prefConnectionTime = "服務器連接時間",
    prefUseProxy = "使用代理",
    prefProxyIP = "IP 地址",
    prefProxyPort = "端口",
    prefUseProxyAuth = "使用代理認證",
    prefProxyAuth = "驗證密碼",
    --
    --Network labels
    labelInputValue = "輸入值",
    --
    --Data settings section
    prefSaveDataPath = "儲存路徑",
    prefClearLibrary = "清除書架",
    prefClearCache = "清除未導入的緩存",
    prefClearAllCache = "清除所有緩存",
    prefClearChapters = "清除所有保存的章節",
    prefResetAllSettings = "重置所有設置",
    --
    --Other section
    prefSkipFontLoading = "跳過字體加載",
    prefChapterSorting = "漫畫章節排序",
    prefSilentDownloads = "不顯示下載通知",
    prefSkipCacheChapterChecking = "跳過驗證緩存和保存文件",
    prefShowSummary = "顯示漫畫摘要",
    --
    --Control setup section
    prefSwapXO = "變更按鍵類型",
    prefChangePageButtons = "變更翻頁按鍵",
    prefLeftStickDeadZone = "左搖桿死區",
    prefLeftStickSensitivity = "左搖桿靈敏度",
    prefRightStickDeadZone = "右搖桿死區",
    prefRightStickSensitivity = "右搖桿靈敏度",
    --
    --Control setup labels
    labelControlLayoutEU = "歐洲",
    labelControlLayoutJP = "日本",
    labelLRTriggers = "L和R按鍵",
    labelUseDPad = "使用DPad",
    --
    --About section
    prefAppVersion = "應用程序版本",
    prefCheckUpdate = "檢查更新",
    prefShowAuthor = "開發者",
    prefDonatorList = "捐贈人員名單",
    prefSupportDev = "支持開發者",
    prefTranslators = "感謝以下翻譯人員",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "最新版本 : ",
    prefDonatorListDescription = "支持項目的人員名單",
    --
    --About status labels
    labelUnzippingVPK = "解壓vpk安裝",
    labelCurrentVersionIs = "當前版本 : ",
    labelSpace = "已用內存",
    labelVersionIsUpToDate = "已是最新版本",
    prefPressAgainToAccept = "再次確認操作",
    prefPressAgainToUpdate = "再次確認更新 : ",
    prefPreferredCatalogLanguage = "首選語言",
    labelOpenInBrowser = "在瀏覽器中打開",
    labelSetPageAsCover = "將此頁面設置為漫畫封面",
    labelResetCover = "重置封面",
    labelDownloadImageToMemory = "下載圖像",
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
    labelAddToLibrary = "添加到書架",
    labelRemoveFromLibrary = "從書架中刪除",
    labelPage = "當前頁 : ",
    labelContinue = "繼續閱讀",
    labelStart = "開始閱讀",
    labelDone = "已看完",
    labelSummary = "概要",
    labelShrink = "收展",
    labelExpand = "閱讀更多",
    --
    --Parser modes
    parserPopular = "熱門",
    parserLatest = "最新",
    parserSearch = "搜索",
    parserAlphabet = "按字母",
    parserByLetter = "按信息",
    parserByTag = "按標簽",
    --
    --Panel labels
    labelPanelBack = "返回",
    labelPanelMode = "模式",
    labelPanelRead = "閱讀",
    labelPanelJumpToPage = "跳轉到頁面",
    labelPanelSearch = "搜索",
    labelPanelSelect = "確認",
    labelPanelChoose = "選擇",
    labelPanelImport = "導入",
    labelPanelChangeSection = "變更頁面",
    labelPanelUpdate = "刷新",
    labelPanelCancel = "取消",
    labelPanelDelete = "刪除",
    labelPanelFollow = "關註",
    labelPanelUnfollow = "取消關註",
    --
    --Import labels
    labelExternalMemory = "外部內存",
    labelDrive = "驅動",
    labelFolder = "文件夾",
    labelGoBack = "返回",
    labelFile = "文件",
    labelUnsupportedFile = "不支持文件",
    --
    --Buttons labels
    labelDownloadAll = "下載所有章節",
    labelRemoveAll = "刪除所有章節",
    labelCancelAll = "取消下載章節",
    labelClearBookmarks = "刪除書簽",
    labelOpenMangaInBrowser = "用瀏覽器打開漫畫",
    --
    --Reader labels
    labelPreparingPages = "準備頁面",
    labelLoadingPage = "加載頁面",
    labelLoadingSegment = "加載階段",
    --
    labelYes = "是",
    labelNo = "否",
    --Country codes alpha-3
    RUS = "俄國",
    ENG = "英國",
    ESP = "西班牙",
    PRT = "葡萄牙",
    FRA = "法國",
    JAP = "日本",
    DIF = "全語言",
    TUR = "土耳其",
    ITA = "意大利",
    VIE = "越南",
    DEU = "德國",
    BRA = "巴西",
    POL = "波蘭",
    IDN = "印度尼西亞",
    CHN = "中國",
    ROU = "羅馬尼亞",
    KOR = "韓國",
    RAW = "生肉 (未經翻譯的原版漫畫)",
    --Language translations
    Russian = "俄語",
    English = "英語",
    Turkish = "土耳其語",
    Spanish = "西班牙語",
    Vietnamese = "越南語",
    French = "法語",
    Italian = "意大利語",
    PortugueseBR = "巴西葡萄牙語",
    SimplifiedChinese = "簡體中文",
    TraditionalChinese = "繁體中文",
    Romanian = "羅馬尼亞",
    Polski = "波蘭語",
    German = "德語",
    Default = "默認"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "TraditionalChinese", "CHN", "@Qingyu510", 10)
