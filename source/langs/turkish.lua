--Turkish translation created by @kemalsanli
local strings = {
    --Tabs
    appLibraryTab = "KÜTÜPHANE",
    appCatalogsTab = "KATALOG",
    appSettingsTab = "SEÇENEKLER",
    appDownloadTab = "İNDİRİLENLER",
    appImportTab = "İÇE AKTAR",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "GEÇMİŞ",
    labelSearch = "Ara",
    --
    --Message-screen messages
    labelLostConnection = "Bağlantı kesildi\n\nBağlantı için bekleniyor...\n\n(Uygulamayı küçültün, Wi-Fİ seçeneklerine gidin ve ağa bağlanın)\n\nMesajı kapatmak ve bütün indirmeleri iptal etmek için X e basın\n\nAğa bağlanınca tüm indirmeler devam edecek.",
    labelPressToUpdate = "Güncellemek için X e basın\nVazgeçmek için O ya basın.",
    --
    --Information text
    labelEmptyLibrary = 'Hiç Çizgi Roman veya Manga Yok\nManga veya Çizgi Roman Eklemek İçin,\n"KATALOGLAR" Menüsünü Açıp "Kütüphaneye Ekle" Seçeneğini Seçin.',
    labelEmptyHistory = "Hiç Çizgi Roman veya Manga Yok\nAma bir gün burada olacak.",
    labelEmptyCatalog = "Hiç Çizgi Roman veya Manga Yok\nSunucu Bağlantısı veya Okuma Hatası.",
    labelEmptyDownloads = "İndirilen Hiç Çizgi Roman veya Manga Yok",
    labelEmptyParsers = "Hiç Katalog Yok\nÜçgene basıp tüm kataloglar yüklenene kadar bekleyin.",
    --
    --Notification information texts
    msgThankYou = "Bu projeyi desteklediğiniz için teşekkür ederim!",
    msgNoConnection = "Bağlantı Yok",
    msgPleaseWait = "Lütfen Bekleyiniz",
    msgFailedToUpdate = "Uygulamayı Güncelleme Başarısız Oldu",
    msgAddedToLibrary = "Kütüphaneye Eklendi",
    msgRemovedFromLibrary = "Kütüphaneden Silindi",
    msgSearching = '"%s" Aranıyor',
    msgStartDownload = "%s: %s\nİndirme Başladı!",
    msgEndDownload = "%s: %s\nBaşarılı Bir Şekilde İndirildi!",
    msgCancelDownload = "%s: %s\nİndirme İptal Edildi!",
    msgChapterRemove = "%s Silindi!",
    msgNetProblem = "Bağlantıda Sorunlar Var!",
    msgChaptersCleared = "Tüm Kaydedilmiş Bölümler Temizlendi!",
    msgLibraryCleared = "Kütüphane Temizlendi!",
    msgCacheCleared = "Bellek Temizlendi!",
    msgDeveloperThing = "Github'da Uygulamayı Yıldızlayın!",
    msgNewUpdateAvailable = "Yeni Güncelleme Mevcut",
    msgNoSpaceLeft = "Hafıza Yetersiz",
    msgRefreshCompleted = "Yenileme Tamamlandı",
    msgImportCompleted = "İçe Aktarma Tamamlandı",
    msgSettingsReset = "Seçenekler Sıfırlandı",
    msgBadImageFound = "Kötü Görüntü bulundu!",
    msgCoverSetCompleted = "Kapak Güncellendi!",
    msgNoChapters = "Hiç Bölüm Yok",
    --
    --Sections
    prefCategoryLanguage = "Dil",
    prefCategoryTheme = "Tema",
    prefCategoryLibrary = "Kütüphane",
    prefCategoryCatalogs = "Kataloglar",
    prefCategoryReader = "Okuyucu",
    prefCategoryNetwork = "Ağ",
    prefCategoryDataSettings = "Veri Seçenekleri",
    prefCategoryOther = "Diğer",
    prefCategoryControls = "Kontrol Seçenekleri",
    prefCategoryAdvancedChaptersDeletion = "Gelişmiş Bölüm Silme",
    prefCategoryAbout = "Program Hakkında",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Manga Takibi İle İlgili Ayarlar.",
    prefCategoryCatalogsDescription = "Dil, Uygunsuz İçerik",
    prefCategoryReaderDescription = "Okuyucu Yönü, Yön Değiştirme, Yakınlaştırma",
    prefCategoryNetworkDescription = "Bağlantı Zaman Aşımı, Proxy",
    prefCategoryDataSettingsDescription = "Kayıtlar, Bellek, Seçenekler",
    prefCategoryOtherDescription = "Font Yükleniyor, Bölüm Sıralaması, Bildirimler",
    prefCategoryControlsDescription = "AnahtarTipi, Sayfa Butonlarını Değiştir, Çubuk Seçenekleri",
    prefCategoryAdvancedChaptersDeletionDescription = "Oku, Sil",
    prefCategoryAboutDescription = "Sürüm, Güncelleme",
    --
    --Library section
    prefLibrarySorting = "Kütüphane Sıralama",
    prefCheckChaptersAtStart = "Başlangıçta Kütüphaneyi Yenile",
    --
    --Catalogs section
    prefShowNSFW = "Uygunsuz İçeriği Göster",
    prefHideInOffline = "Çevrimdışında Sadece İndirilmiş Bölümleri Göster",
    --
    --Catalogs labels
    labelShowNSFW = "Göster",
    labelHideNSFW = "Gösterme",
    --
    --Reader section
    prefReaderOrientation = "Varsayılan Okuyucu Yönü",
    prefReaderScaling = "Okuyucu Ölçeklendirmesi",
    prefReaderDirection = "Manga Okuyucu Yönü",
    prefReaderDoubleTap = "Çift Tıkla Yakınlaştırmayı Etkinleştir",
    prefPressEdgesToChangePage = "Sayfaların Kenralarına Basarak Sayfaları Değiştirin",
    prefAnimateGif = "Gif'i Oynat (Deneysel)",
    --
    --Reader labels
    labelHorizontal = "Yatay",
    labelVertical = "Dikey",
    labelScalingSmart = "Akıllı Ölçeklendirme",
    labelScalingHeight = "Yüksekliğe Göre",
    labelScalingWidth = "Genişliğe Göre",
    labelDirectionLeft = "Sola Doğru",
    labelDirectionRight = "Sağa Doğru",
    labelDirectionDown = "Aşağı Doğru",
    labelDefault = "Varsayılan",
    --
    --Network section
    prefConnectionTime = "Server'a Bağlanmak İçin Gereken Zaman",
    prefUseProxy = "Proxy Kullan",
    prefProxyIP = "IP Adresi",
    prefProxyPort = "Port",
    prefUseProxyAuth = "Proxy Doğrulamayı Kullan",
    prefProxyAuth = "GirişBilgisi:Şifre",
    --
    --Network labels
    labelInputValue = "Giriş Değeri",
    --
    --Data settings section
    prefSaveDataPath = "Kaydetme Yolu",
    prefClearLibrary = "Kütüphaneyi Temizle",
    prefClearCache = "Bellekteki Takip Edilmeyen Mangaları Sil",
    prefClearAllCache = "Belleği Temizle",
    prefClearChapters = "Kaydedilen Tüm Bölümleri Sil",
    prefResetAllSettings = "Tüm Seçenekleri Sıfırla",
    --
    --Other section
    prefSkipFontLoading = "Font Yüklemesini Atla",
    prefChapterSorting = "Bölüm Sıralama",
    prefSilentDownloads = "İndirme Bildirimleri Gösterme",
    prefSkipCacheChapterChecking = "Yükleme Ekranında Bellek ve Bölüm Kontrolünü Atla",
    prefShowSummary = "Manga Özetini Göster",
    --
    --Control setup section
    prefSwapXO = "Tuş Düzenini Değiştir(X/O)",
    prefChangePageButtons = "Sayfayı Çevirmeye Yarayan Tuşlar",
    prefLeftStickDeadZone = "Sol Çubuk Ölü Alanı",
    prefLeftStickSensitivity = "Sol Çubuk Hassasiyeti",
    prefRightStickDeadZone = "Sağ Çubuk Ölü Alanı",
    prefRightStickSensitivity = "Sağ Çubuk Hassasiyeti",
    --
    --Control setup labels
    labelControlLayoutEU = "Avrupa",
    labelControlLayoutJP = "Japonya",
    labelLRTriggers = "L1 R1 Tuşları",
    labelUseDPad = "DPAD Tuşları",
    --
    --About section
    prefAppVersion = "Uygulama Sürümü",
    prefCheckUpdate = "Güncellemeleri Denetle",
    prefShowAuthor = "Geliştirici",
    prefDonatorList = "Bağışçı Listesi",
    prefSupportDev = "Geliştiriciye Destek Ol",
    prefTranslators = "Çevirmenlere Teşekkürler",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "En Son Sürüm : ",
    prefDonatorListDescription = "Bu Projeyi Destekleyen İnsanların Bir Listesi",
    --
    --About status labels
    labelUnzippingVPK = "Vpk Yüklemek İçin Çıkarılıyor",
    labelCurrentVersionIs = "Mevcut Sürüm:",
    labelSpace = "Kullanılan Hafıza",
    labelVersionIsUpToDate = "En Güncel Sürümü Kullanıyorsunuz",
    prefPressAgainToAccept = "Kabul Etmek İçin Tekrar Basın",
    prefPressAgainToUpdate = "Güncellemek İçin Tekrar Basın:",
    prefPreferredCatalogLanguage = "Tercih Edilen Dil",
    labelOpenInBrowser = "Tarayıcıda Aç",
    labelSetPageAsCover = "Bu sayfayı Kapak Olarak Ayarla",
    labelResetCover = "Kapağı Sıfırla",
    labelDownloadImageToMemory = "Görseli İndir",
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
    labelAddToLibrary = "Kütüphaneye Ekle",
    labelRemoveFromLibrary = "Kütüphaneden Sil",
    labelPage = "Sayfa : ",
    labelContinue = "Devam Et",
    labelStart = "Okumaya Başla",
    labelDone = "Tamamlandı!",
    labelSummary = "Konusu",
    labelShrink = "Daha Az",
    labelExpand = "Daha Fazla",
    --
    --Parser modes
    parserPopular = "Popüler",
    parserLatest = "En Yeni",
    parserSearch = "Ara",
    parserAlphabet = "Alfabetik",
    parserByLetter = "Harflerle",
    parserByTag = "Tag'a Göre",
    --
    --Panel labels
    labelPanelBack = "Geri",
    labelPanelMode = "Mod",
    labelPanelRead = "Oku",
    labelPanelJumpToPage = "Sayfaya Atla",
    labelPanelSearch = "Ara",
    labelPanelSelect = "Seç",
    labelPanelChoose = "Seç",
    labelPanelImport = "İçe Aktar",
    labelPanelChangeSection = "Kategoriyi Değiştir",
    labelPanelUpdate = "Yenile",
    labelPanelCancel = "Vazgeç",
    labelPanelDelete = "Sil",
    labelPanelFollow = "Takip Et",
    labelPanelUnfollow = "Takibi Bırak",
    --
    --Import labels
    labelExternalMemory = "Taşınabilir Bellek",
    labelDrive = "Cihaz Hafızası",
    labelFolder = "Klasör",
    labelGoBack = "Geri Dön",
    labelFile = "Dosya",
    labelUnsupportedFile = "Desteklenmeyen Dosya",
    --
    --Buttons labels
    labelDownloadAll = "Tüm Bölümleri İndir",
    labelRemoveAll = "Tüm Bölümleri Sil",
    labelCancelAll = "Bölümleri İndirmeyi İptal Et",
    labelClearBookmarks = "Yer İmlerini Temizle",
    labelOpenMangaInBrowser = "Manga'yı Tarayıcıda Aç",
    --
    --Reader labels
    labelPreparingPages = "Sayfalar Hazırlanıyor",
    labelLoadingPage = "Sayfalar Yükleniyor",
    labelLoadingSegment = "Segment Yükleniyor",
    --
    labelYes = "Evet",
    labelNo = "Hayır",
    --Country codes alpha-3
    RUS = "Rusça",
    ENG = "İnglizce",
    ESP = "İspanyolca",
    PRT = "Portekizce",
    FRA = "Fransızca",
    JAP = "Japonca",
    DIF = "Diğer",
    TUR = "Türkçe",
    ITA = "İtalyanca",
    VIE = "Vietnam Dili",
    DEU = "Almanca",
    BRA = "Brezilya Dili",
    POL = "Lehçe",
    IDN = "Endonezya",
    CHN = "Çin",
    ROU = "Romence",
    KOR = "Korece",
    RAW = "Raw (Çevrilmemiş çizgi romanlar)",
    --Language translations
    Russian = "Rusça",
    English = "İngilizce",
    Turkish = "Türkçe",
    Spanish = "İspanyolca",
    Vietnamese = "Vietnam Dili",
    French = "Fransızca",
    Italian = "İtalyanca",
    PortugueseBR = "Brezilya Portekizcesi",
    SimplifiedChinese = "Basitleştirilmiş Çince",
    TraditionalChinese = "Geleneksel Çince",
    Romanian = "Romence",
    Polish = "Lehçe",
    German = "Alman Dili",
    Default = "Sistem Dili"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Turkish", "TUR", "@kemalsanli", 19)
