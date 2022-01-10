--Vietnamese translation created by nguyenmao2101
local strings = {
    --Tabs
    appLibraryTab = "Thư viện",
    appCatalogsTab = "Danh mục",
    appSettingsTab = "Cài đặt",
    appDownloadTab = "Tải xuống",
    appImportTab = "Thêm truyện",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "Lịch sử",
    labelSearch = "Tìm",
    --
    --Message-screen messages
    labelLostConnection = "Mất kết nối\n\nĐang đợi mạng...\n\n(Hãy chạy ẩn ứng dụng, đi đến cài đặt và tiến hành kết nối mạng)\n\nNhấn X để hủy tất cả tiến trình tải và tắt thông báo\n\nCác tiến trình tải sẽ tự động tiếp tục khi có kết nối mạng",
    labelPressToUpdate = "Nhấn X để cập nhật\nNhấn O để hủy bỏ",
    --
    --Information text
    labelEmptyLibrary = 'Không có truyện nào.\nĐể thêm truyện, tìm ở phần "Danh Mục" và chọn "Thêm vào thư viện".',
    labelEmptyHistory = "Không có truyện nào.\nNó sẽ xuất hiện khi bạn bắt đầu sử dụng",
    labelEmptyCatalog = "Không có truyện nào.\nCó lỗi kết nối hoặc trình xử lý",
    labelEmptyDownloads = "Không có truyện đang tải nào",
    labelEmptyParsers = "Không có danh mục nào.\nNhấn nút tam giác và đợi đến khi các danh mục được cập nhật",
    --
    --Notification information texts
    msgThankYou = "Cảm ơn vì sự hỗ trợ của bạn!",
    msgNoConnection = "Không có kết nối",
    msgPleaseWait = "Xin chờ",
    msgFailedToUpdate = "Không thể cập nhật",
    msgAddedToLibrary = "Đã thêm vào thư viện",
    msgRemovedFromLibrary = "Đã xóa khỏi thư viện",
    msgSearching = 'Đang tìm "%s"',
    msgStartDownload = "Bắt đầu tải xuống!\n%s: %s",
    msgEndDownload = "Hoàn thành tải xuống!\n%s: %s",
    msgCancelDownload = "Đã hủy tải xuống!\n%s: %s",
    msgChapterRemove = "Đã xóa!\n%s",
    msgNetProblem = "Lỗi kết nối!",
    msgChaptersCleared = "Đã xóa tất cả tập đã lưu!",
    msgLibraryCleared = "Đã xóa lịch sử!",
    msgCacheCleared = "Đã xóa bộ nhớ tạm!",
    msgDeveloperThing = "Star app on Github!",
    msgNewUpdateAvailable = "Có bản cập nhật mới!",
    msgNoSpaceLeft = "Không đủ dung lượng lưu trữ!",
    msgRefreshCompleted = "Làm mới hoàn tất!",
    msgImportCompleted = "Nhập khẩu hoàn tất!",
    msgSettingsReset = "Đã đặt lại các cài đặt!",
    msgBadImageFound = "Đã tìm thấy hình ảnh xấu!",
    msgCoverSetCompleted = "Đã cập nhật ảnh bìa!",
    msgNoChapters = "Không có tập nào!",
    --
    --Sections
    prefCategoryLanguage = "Ngôn ngữ",
    prefCategoryTheme = "Giao diện",
    prefCategoryLibrary = "Thư viện",
    prefCategoryCatalogs = "Danh mục",
    prefCategoryReader = "Trình đọc truyện",
    prefCategoryNetwork = "Mạng",
    prefCategoryDataSettings = "Bộ nhớ",
    prefCategoryOther = "Khác",
    prefCategoryControls = "Điều khiển",
    prefCategoryAdvancedChaptersDeletion = "Xóa chương nâng cao",
    prefCategoryAbout = "Giới thiệu",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Cài đặt về tủ truyện",
    prefCategoryCatalogsDescription = "Ngôn ngữ và nội dung người lớn",
    prefCategoryReaderDescription = "Thiết lập về trình đọc truyện",
    prefCategoryNetworkDescription = "Thiết lập về mạng và bảo mật",
    prefCategoryDataSettingsDescription = "Thiết lập về dữ liệu",
    prefCategoryOtherDescription = "Các cài đặt về thông báo và font hiển thị",
    prefCategoryControlsDescription = "Thiết lập về điều khiển",
    prefCategoryAdvancedChaptersDeletionDescription = "Thiết lập đọc và xóa chương truyện",
    prefCategoryAboutDescription = "Thông tin phiên bản và cập nhật",
    --
    --Library section
    prefLibrarySorting = "Sắp xếp lại thư viện",
    prefCheckChaptersAtStart = "Làm mới thư viện khi khởi động",
    --
    --Catalogs section
    prefShowNSFW = "Nội dung người lớn",
    prefHideInOffline = "Chỉ hiện thị tập đã tải (offline mode)",
    --
    --Catalogs labels
    labelShowNSFW = "Hiện",
    labelHideNSFW = "Ẩn",
    --
    --Reader section
    prefReaderOrientation = "Trình đọc mặc định",
    prefReaderScaling = "Thay đổi kích thước",
    prefReaderDirection = "Thứ tự khung truyện",
    prefReaderDoubleTap = "Kích hoạt tính năng chạm hai lần để thu phóng",
    prefPressEdgesToChangePage = "Chuyển trang bằng chạm vào cạnh",
    prefAnimateGif = "Hình động (Thử nghiệm)",
    --
    --Reader labels
    labelHorizontal = "Dọc",
    labelVertical = "Ngang",
    labelScalingSmart = "Tự động",
    labelScalingHeight = "Chiều cao",
    labelScalingWidth = "Chiều rộng",
    labelDirectionLeft = "Phải sang trái",
    labelDirectionRight = "Trái sang phải",
    labelDirectionDown = "Trên xuống dưới",
    labelDefault = "Mặc định",
    --
    --Network section
    prefConnectionTime = "Thời gian kết nối máy chủ",
    prefUseProxy = "Dùng proxy",
    prefProxyIP = "Địa chỉ IP",
    prefProxyPort = "Cổng",
    prefUseProxyAuth = "Xác thực proxy",
    prefProxyAuth = "tài khoản:mật khẩu",
    --
    --Network labels
    labelInputValue = "Giá trị đầu vào",
    --
    --Data settings section
    prefSaveDataPath = "Lưu đường dẫn",
    prefClearLibrary = "Xóa lịch sử",
    prefClearCache = "Xóa dữ liệu tạm",
    prefClearAllCache = "Xóa tất cả dữ liệu",
    prefClearChapters = "Clear all saved chapters",
    prefResetAllSettings = "Đặt lại tất cả cài đặt",
    --
    --Other section
    prefSkipFontLoading = "Bỏ qua tải font chữ",
    prefChapterSorting = "Sắp xếp lại chương truyện",
    prefSilentDownloads = "Không hiển thị thông báo tải xuống",
    prefSkipCacheChapterChecking = "Bỏ qua kiểm tra bộ nhớ tạm",
    prefShowSummary = "Hiện tóm tắt truyện",
    --
    --Control setup section
    prefSwapXO = "Chuyển đổi phím chọn",
    prefChangePageButtons = "Nút chuyển trang",
    prefLeftStickDeadZone = "Deadzone cần điều khiển trái",
    prefLeftStickSensitivity = "Độ nhạy cần điều khiển trái",
    prefRightStickDeadZone = "Deadzone cần điều khiển phải",
    prefRightStickSensitivity = "Độ nhạy cần điều khiển phải",
    --
    --Control setup labels
    labelControlLayoutEU = "Europe",
    labelControlLayoutJP = "Japan",
    labelLRTriggers = "Sử dụng L và R",
    labelUseDPad = "Sử dụng DPad",
    --
    --About section
    prefAppVersion = "Phiên bản",
    prefCheckUpdate = "Kiểm tra cập nhật",
    prefShowAuthor = "Tác giả",
    prefDonatorList = "Danh sách người ủng hộ",
    prefSupportDev = "Hỗ trợ nhà phát triển",
    prefTranslators = "Cảm ơn đến các dịch giả",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Phiên bản mới nhất : ",
    prefDonatorListDescription = "Danh sách người hỗ trợ",
    --
    --About status labels
    labelUnzippingVPK = "Giải nén tập tin vpk",
    labelCurrentVersionIs = "Phiên bản hiện tại:",
    labelSpace = "Bộ nhớ đã dùng",
    labelVersionIsUpToDate = "Đã là phiên bản mới nhất",
    prefPressAgainToAccept = "Bấm lại để xác nhận",
    prefPressAgainToUpdate = "Bấm lại để cập nhật:",
    prefPreferredCatalogLanguage = "Ngôn ngữ ưa thích",
    labelOpenInBrowser = "Mở trong trình duyệt",
    labelSetPageAsCover = "Chọn trang làm bìa",
    labelResetCover = "Xóa ảnh bìa",
    labelDownloadImageToMemory = "Tải ảnh",
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
    labelAddToLibrary = "Thêm vào thư viện",
    labelRemoveFromLibrary = "Xóa khỏi thư viện",
    labelPage = "Trang : ",
    labelContinue = "Đọc tiếp",
    labelStart = "Đọc truyện",
    labelDone = "Hoàn thành!",
    labelSummary = "Tổng quan",
    labelShrink = "Thu lại",
    labelExpand = "Đọc thêm",
    --
    --Parser modes
    parserPopular = "Phổ biến",
    parserLatest = "Mới nhất",
    parserSearch = "Tìm",
    parserAlphabet = "Bảng chữ cái",
    parserByLetter = "Bằng chữ",
    parserByTag = "Bằng nhãn",
    --
    --Panel labels
    labelPanelBack = "Trở về",
    labelPanelMode = "Chế độ",
    labelPanelRead = "Đọc",
    labelPanelJumpToPage = "Đi đến trang",
    labelPanelSearch = "Tìm",
    labelPanelSelect = "Chọn",
    labelPanelChoose = "Điều khiển",
    labelPanelImport = "Nhập",
    labelPanelChangeSection = "Thay đổi danh mục",
    labelPanelUpdate = "Cập nhật",
    labelPanelCancel = "Hủy bỏ",
    labelPanelDelete = "Xóa bỏ",
    labelPanelFollow = "Theo dõi",
    labelPanelUnfollow = "Bỏ theo dõi",
    --
    --Import labels
    labelExternalMemory = "Bộ nhớ ngoài",
    labelDrive = "Ổ đĩa",
    labelFolder = "Thư mục",
    labelGoBack = "Trở lại",
    labelFile = "Tệp tin",
    labelUnsupportedFile = "Tệp không hỗ trợ",
    --
    --Buttons labels
    labelDownloadAll = "Tải xuống tất cả chương",
    labelRemoveAll = "Xóa tất cả chương",
    labelCancelAll = "Hủy bỏ việc tải xuống",
    labelClearBookmarks = "Xóa dấu trang",
    labelOpenMangaInBrowser = "Mở truyện trong trình duyệt",
    --
    --Reader labels
    labelPreparingPages = "Đang tải",
    labelLoadingPage = "Đang tải",
    labelLoadingSegment = "Đang tải",
    --
    labelYes = "Có",
    labelNo = "Không",
    --Country codes alpha-3
    RUS = "Nga",
    ENG = "Anh",
    ESP = "Tây Ban Nha",
    PRT = "Bồ Đào Nha",
    FRA = "Pháp",
    JAP = "Nhật",
    DIF = "Khác",
    TUR = "Thổ Nhĩ Kỳ",
    ITA = "Italia",
    VIE = "Việt Nam",
    DEU = "Tiếng Đức",
    BRA = "Brazil",
    POL = "Ba Lan",
    IDN = "Tiếng Indonesia",
    CHN = "Trung Quốc",
    ROU = "Tiếng Rumani",
    KOR = "Tiếng Hàn",
    RAW = "Raw (Truyện tranh chưa được dịch)",
    --Language translations
    Russian = "Tiếng Nga",
    English = "Tiếng Anh",
    Turkish = "Thổ Nhĩ Kỳ",
    Spanish = "Tiếng Tây Ban Nha",
    Italian = "Italia",
    French = "PhápF",
    Vietnamese = "Tiếng Việt",
    PortugueseBR = "Tiếng Bồ Đào Nha của người brazi",
    SimplifiedChinese = "Tiếng Trung Giản Thể",
    TraditionalChinese = "Truyền Thống Trung Quốc",
    Romanian = "Tiếng Rumani",
    Polish = "Tiếng ba lan",
    German = "Tiếng Đức",
    Default = "Hệ thống"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Vietnamese", "VIE", "nguyenmao2101", nil)
