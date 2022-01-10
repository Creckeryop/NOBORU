--SimplifiedChinese translation by @Qingyu510
local strings = {
    --Tabs
    appLibraryTab = "书架",
    appCatalogsTab = "目录",
    appSettingsTab = "设置",
    appDownloadTab = "下载",
    appImportTab = "导入",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "历史",
    labelSearch = "搜索",
    --
    --Message-screen messages
    labelLostConnection = "连接失败\n\n等待连接...\n\n(最小化应用程序 , 转到设置到WIFI设置 , 然后选择连接网络)\n\n按 × 取消所有下载并关闭消息\n\n如果网络恢复正常 , 将继续所有下载",
    labelPressToUpdate = "按 × 更新\n按 ○ 取消",
    --
    --Information text
    labelEmptyLibrary = "没有漫画。\n想要添加漫画, 请在“目录”菜单中寻找漫画, 然后按“添加到书架”。",
    labelEmptyHistory = "没有漫画\n它总有一天会出现在这里",
    labelEmptyCatalog = "没有漫画\n服务器、连接或解析器错误",
    labelEmptyDownloads = "没有下载的漫画",
    labelEmptyParsers = "没有目录\n请按△并进行等待，直到所有列表加载完成",
    --
    --Notification information texts
    msgThankYou = "感谢您对该项目的支持!",
    msgNoConnection = "没有网络连接",
    msgPleaseWait = "请稍候",
    msgFailedToUpdate = "应用更新失败",
    msgAddedToLibrary = "已添加到书架",
    msgRemovedFromLibrary = "从书架中已删除",
    msgSearching = '正在搜索 "%s"',
    msgStartDownload = "%s: %s\n开始下载!",
    msgEndDownload = "%s: %s\n下载成功!",
    msgCancelDownload = "%s: %s\n下载已取消",
    msgChapterRemove = "%s 删除",
    msgNetProblem = "连接出现错误",
    msgChaptersCleared = "已清除保存的章节!",
    msgLibraryCleared = "书架已清除!",
    msgCacheCleared = "缓存已被清除!",
    msgDeveloperThing = "在Github上为应用标注星号!",
    msgNewUpdateAvailable = "发现新版本",
    msgNoSpaceLeft = "没有剩余空间",
    msgRefreshCompleted = "刷新完成!",
    msgImportCompleted = "导入完成!",
    msgSettingsReset = "设置已重置",
    msgBadImageFound = "导入图像错误!",
    msgCoverSetCompleted = "漫画封面已更新!",
    msgNoChapters = "没有章节",
    --
    --Sections
    prefCategoryLanguage = "语言",
    prefCategoryTheme = "主题",
    prefCategoryLibrary = "书架",
    prefCategoryCatalogs = "目录",
    prefCategoryReader = "阅读",
    prefCategoryNetwork = "网络",
    prefCategoryDataSettings = "数据",
    prefCategoryOther = "其他",
    prefCategoryControls = "控制器",
    prefCategoryAdvancedChaptersDeletion = "高级章节删除",
    prefCategoryAbout = "关于",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "书架排序, 漫画追踪相关的设置",
    prefCategoryCatalogsDescription = "语言, NSFW 内容",
    prefCategoryReaderDescription = "屏幕方向, 阅读方向, 页面缩放",
    prefCategoryNetworkDescription = "连接超时, 网络代理",
    prefCategoryDataSettingsDescription = "储存路径, 清除缓存, 重置设置",
    prefCategoryOtherDescription = "字体加载, 章节排序, 下载通知",
    prefCategoryControlsDescription = "按键类型, 变更翻页按键, 摇杆设置",
    prefCategoryAdvancedChaptersDeletionDescription = "阅读, 删除",
    prefCategoryAboutDescription = "版本, 更新",
    --
    --Library section
    prefLibrarySorting = "书架排序",
    prefCheckChaptersAtStart = "启动时刷新库",
    --
    --Catalogs section
    prefShowNSFW = "显示成人内容",
    prefHideInOffline = "仅在离线模式下显示下载的章节",
    --
    --Catalogs labels
    labelShowNSFW = "显示",
    labelHideNSFW = "不显示",
    --
    --Reader section
    prefReaderOrientation = "屏幕方向",
    prefReaderScaling = "页面缩放",
    prefReaderDirection = "阅读方向",
    prefReaderDoubleTap = "启用双击缩放",
    prefPressEdgesToChangePage = "点击屏幕边缘进行翻页",
    prefAnimateGif = "GIF动画（实验性）",
    --
    --Reader labels
    labelHorizontal = "竖屏",
    labelVertical = "横屏",
    labelScalingSmart = "适应屏幕",
    labelScalingHeight = "匹配高度",
    labelScalingWidth = "匹配宽度",
    labelDirectionLeft = "从右到左",
    labelDirectionRight = "从左到右",
    labelDirectionDown = "从上到下",
    labelDefault = "默认",
    --
    --Network section
    prefConnectionTime = "服务器连接时间",
    prefUseProxy = "使用代理",
    prefProxyIP = "IP 地址",
    prefProxyPort = "端口",
    prefUseProxyAuth = "使用代理认证",
    prefProxyAuth = "验证密码",
    --
    --Network labels
    labelInputValue = "输入值",
    --
    --Data settings section
    prefSaveDataPath = "储存路径",
    prefClearLibrary = "清除书架",
    prefClearCache = "清除未导入的缓存",
    prefClearAllCache = "清除所有缓存",
    prefClearChapters = "清除所有保存的章节",
    prefResetAllSettings = "重置所有设置",
    --
    --Other section
    prefSkipFontLoading = "跳过字体加载",
    prefChapterSorting = "漫画章节排序",
    prefSilentDownloads = "不显示下载通知",
    prefSkipCacheChapterChecking = "跳过验证缓存和保存文件",
    prefShowSummary = "显示漫画摘要",
    --
    --Control setup section
    prefSwapXO = "变更按键类型",
    prefChangePageButtons = "变更翻页按键",
    prefLeftStickDeadZone = "左摇杆死区",
    prefLeftStickSensitivity = "左摇杆灵敏度",
    prefRightStickDeadZone = "右摇杆死区",
    prefRightStickSensitivity = "右摇杆灵敏度",
    --
    --Control setup labels
    labelControlLayoutEU = "欧洲",
    labelControlLayoutJP = "日本",
    labelLRTriggers = "L和R按键",
    labelUseDPad = "使用DPad",
    --
    --About section
    prefAppVersion = "应用程序版本",
    prefCheckUpdate = "检查更新",
    prefShowAuthor = "开发者",
    prefDonatorList = "捐赠人员名单",
    prefSupportDev = "支持开发者",
    prefTranslators = "感谢以下翻译人员",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "最新版本 : ",
    prefDonatorListDescription = "支持项目的人员名单",
    --
    --About status labels
    labelUnzippingVPK = "解压vpk安装",
    labelCurrentVersionIs = "当前版本 : ",
    labelSpace = "已用内存",
    labelVersionIsUpToDate = "已是最新版本",
    prefPressAgainToAccept = "再次确认操作",
    prefPressAgainToUpdate = "再次确认更新 : ",
    prefPreferredCatalogLanguage = "首选语言",
    labelOpenInBrowser = "在浏览器中打开",
    labelSetPageAsCover = "将此页面设置为漫画封面",
    labelResetCover = "重置封面",
    labelDownloadImageToMemory = "下载图像",
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
    labelAddToLibrary = "添加到书架",
    labelRemoveFromLibrary = "从书架中删除",
    labelPage = "当前页 : ",
    labelContinue = "继续阅读",
    labelStart = "开始阅读",
    labelDone = "已看完",
    labelSummary = "簡介",
    labelShrink = "收展",
    labelExpand = "阅读更多",
    --
    --Parser modes
    parserPopular = "热门",
    parserLatest = "最新",
    parserSearch = "搜索",
    parserAlphabet = "按字母",
    parserByLetter = "按信息",
    parserByTag = "按标签",
    --
    --Panel labels
    labelPanelBack = "返回",
    labelPanelMode = "模式",
    labelPanelRead = "阅读",
    labelPanelJumpToPage = "跳转到页面",
    labelPanelSearch = "搜索",
    labelPanelSelect = "确认",
    labelPanelChoose = "选择",
    labelPanelImport = "导入",
    labelPanelChangeSection = "变更页面",
    labelPanelUpdate = "刷新",
    labelPanelCancel = "取消",
    labelPanelDelete = "删除",
    labelPanelFollow = "关注",
    labelPanelUnfollow = "取消关注",
    --
    --Import labels
    labelExternalMemory = "外部内存",
    labelDrive = "驱动",
    labelFolder = "文件夹",
    labelGoBack = "返回",
    labelFile = "文件",
    labelUnsupportedFile = "不支持文件",
    --
    --Buttons labels
    labelDownloadAll = "下载所有章节",
    labelRemoveAll = "删除所有章节",
    labelCancelAll = "取消下载章节",
    labelClearBookmarks = "删除书签",
    labelOpenMangaInBrowser = "用浏览器打开漫画",
    --
    --Reader labels
    labelPreparingPages = "准备页面",
    labelLoadingPage = "加载页面",
    labelLoadingSegment = "加载阶段",
    --
    labelYes = "是",
    labelNo = "否",
    --Country codes alpha-3
    RUS = "俄国",
    ENG = "英国",
    ESP = "西班牙",
    PRT = "葡萄牙",
    FRA = "法国",
    JAP = "日本",
    DIF = "全语言",
    TUR = "土耳其",
    ITA = "意大利",
    VIE = "越南",
    DEU = "德国",
    BRA = "巴西",
    POL = "波兰",
    IDN = "印度尼西亚",
    CHN = "中国",
    ROU = "罗马尼亚",
    KOR = "韩国",
    RAW = "生肉 (未翻译的原版漫画)",
    --Language translations
    Russian = "俄语",
    English = "英语",
    Turkish = "土耳其语",
    Spanish = "西班牙语",
    Vietnamese = "越南语",
    French = "法语",
    Italian = "意大利语",
    PortugueseBR = "巴西葡萄牙语",
    SimplifiedChinese = "简体中文",
    TraditionalChinese = "繁体中文",
    Romanian = "罗马尼亚",
    Polish = "波兰语",
    German = "德语",
    Default = "默认"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "SimplifiedChinese", "CHN", "@Qingyu510", 11)
