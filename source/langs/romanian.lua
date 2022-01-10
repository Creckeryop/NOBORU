--Romanian translation by tmihai20
local strings = {
    --Tabs
    appLibraryTab = "BIBLIOTECĂ",
    appCatalogsTab = "CATALOAGE",
    appSettingsTab = "SETĂRI",
    appDownloadTab = "DESCĂRCĂRI",
    appImportTab = "IMPORTĂ",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "ISTORIC",
    labelSearch = "Căutare",
    --
    --Message-screen messages
    labelLostConnection = "Fără conexiune\n\nSe așteaptă conexiunea...\n\n(Minimizați aplicația, mergeți la setările Wi-Fi și apăsați Conectare)\n\nApăsați X pentru a anula toate descărcările și pentru a închide mesajul\n\nToate descărcările vor continua după restabilirea conexiunii",
    labelPressToUpdate = "Apăsați X pentru actualizare\nApăsați O pentru anulare",
    --
    --Information text
    labelEmptyLibrary = 'Nu există manga/comic-uri.\nPentru a adăuga manga/comic-uri, căutați-le în meniul "CATALOAGE" și apăsați "Adăugați la bibliotecă".',
    labelEmptyHistory = "Nu există manga/comic-uri.\nVa apare aici în viitor",
    labelEmptyCatalog = "Nu există manga/comic-uri.\nEroare de server, conexiune sau parser",
    labelEmptyDownloads = "Nu se descarcă manga/comic-uri.",
    labelEmptyParsers = "Nu există cataloage.\nApăsați Triunghi și așteptați până când toate cataloagele vor fi descărcate",
    --
    --Notification information texts
    msgThankYou = "Vă mulțumim pentru că susțineți acest proiect!",
    msgNoConnection = "Fără conexiune",
    msgPleaseWait = "Așteptați",
    msgFailedToUpdate = "Actualizare eșuată",
    msgAddedToLibrary = "Adăugat la bibliotecă",
    msgRemovedFromLibrary = "Șters din bibliotecă",
    msgSearching = 'Se caută "%s"',
    msgStartDownload = "%s: %s\ndescărcare începută!",
    msgEndDownload = "%s: %s\ndescărcat cu succes!",
    msgCancelDownload = "%s: %s\ndescărcare anulată!",
    msgChapterRemove = "%s a fost șters!",
    msgNetProblem = "Există o problemă cu conexiunea!",
    msgChaptersCleared = "Toate capitolele salvate au fost eliminate!",
    msgLibraryCleared = "Bibliotecă golită!",
    msgCacheCleared = "Cache-ul a fost golit!",
    msgDeveloperThing = "Pune o stea pe Github!",
    msgNewUpdateAvailable = "Actualizare nouă disponibilă",
    msgNoSpaceLeft = "Spațiu insuficient",
    msgRefreshCompleted = "Reîmprospătare finalizată!",
    msgImportCompleted = "Import terminat!",
    msgSettingsReset = "Setările au fost resetate",
    msgBadImageFound = "Imagine invalidă găsită!",
    msgCoverSetCompleted = "Coperta a fost actualizată!",
    msgNoChapters = "Nu există capitole",
    --
    --Sections
    prefCategoryLanguage = "Limbă",
    prefCategoryTheme = "Temă",
    prefCategoryLibrary = "Bibliotecă",
    prefCategoryCatalogs = "Cataloage",
    prefCategoryReader = "Cititor",
    prefCategoryNetwork = "Rețea",
    prefCategoryDataSettings = "Setări de date",
    prefCategoryOther = "Altele",
    prefCategoryControls = "Configurare taste",
    prefCategoryAdvancedChaptersDeletion = "Ștergere avansată a capitolelor",
    prefCategoryAbout = "Despre program",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Setări legate de urmărirea manga",
    prefCategoryCatalogsDescription = "Limbă, conținut NSFW",
    prefCategoryReaderDescription = "Direcție citire, orientare, redimensionare",
    prefCategoryNetworkDescription = "Timp maxim pentru conexiune, proxy",
    prefCategoryDataSettingsDescription = "Salvări, cache, setări",
    prefCategoryOtherDescription = "Încărcare fonturi, sortare capitole, notificări",
    prefCategoryControlsDescription = "Taste, schimbare butoane pagină, setări stick-uri",
    prefCategoryAdvancedChaptersDeletionDescription = "Citire, ștergere",
    prefCategoryAboutDescription = "Versiune, actualizare",
    --
    --Library section
    prefLibrarySorting = "Sortarea bibliotecii",
    prefCheckChaptersAtStart = "Actualizează librăria la pornire",
    --
    --Catalogs section
    prefShowNSFW = "Arătați cataloagele NSFW",
    prefHideInOffline = "Arată doar capitolele descărcate în modull offline",
    --
    --Catalogs labels
    labelShowNSFW = "Arată",
    labelHideNSFW = "Ascunde",
    --
    --Reader section
    prefReaderOrientation = "Orientare implicită a citirii",
    prefReaderScaling = "Redimensionare citire",
    prefReaderDirection = "Ordine de citire pentru manga",
    prefReaderDoubleTap = "Activați apăsarea dublă pentru zoom",
    prefPressEdgesToChangePage = "Schimbă paginile apăsând pe marginea foii",
    prefAnimateGif = "Animează gif (experimental)",
    --
    --Reader labels
    labelHorizontal = "Orizontală",
    labelVertical = "Verticală",
    labelScalingSmart = "Adaptiv",
    labelScalingHeight = "Înălțime",
    labelScalingWidth = "Lățime",
    labelDirectionLeft = "De la dreapta la stânga",
    labelDirectionRight = "De la stânga la dreapta",
    labelDirectionDown = "De sus în jos",
    labelDefault = "Implicit",
    --
    --Network section
    prefConnectionTime = "Timp maxim pentru conexiunea la server",
    prefUseProxy = "Folosește proxy",
    prefProxyIP = "Adresă IP",
    prefProxyPort = "Port",
    prefUseProxyAuth = "Folosește autentificarea pentru proxy",
    prefProxyAuth = "Utilizator:parolă",
    --
    --Network labels
    labelInputValue = "Introduceți valoare",
    --
    --Data settings section
    prefSaveDataPath = "Salvează calea pentru date",
    prefClearLibrary = "Goliți biblioteca",
    prefClearCache = "Goliți cache pentru conținut pe care nu-l urmăriți",
    prefClearAllCache = "Goliți tot cache-ul",
    prefClearChapters = "Eliminați toate capitolele salvate",
    prefResetAllSettings = "Resetați toate setările",
    --
    --Other section
    prefSkipFontLoading = "Ignoră încărcarea fontului",
    prefChapterSorting = "Sortarea capitolelor",
    prefSilentDownloads = "Nu arăta notificări despre descărcări",
    prefSkipCacheChapterChecking = "Nu mai verifica memoria cache sau capitolele salvate la încărcare",
    prefShowSummary = "Arată sumarul pentru manga/comic",
    --
    --Control setup section
    prefSwapXO = "Schimbă X cu O",
    prefChangePageButtons = "Butoane pentru a schimba pagina",
    prefLeftStickDeadZone = "Zonă moartă pentru stick-ul stânga",
    prefLeftStickSensitivity = "Sensibilitate pentru stick-ul stânga",
    prefRightStickDeadZone = "Zonă moartă pentru stick-ul dreapta",
    prefRightStickSensitivity = "Sensibilitate pentru stick-ul dreapta",
    --
    --Control setup labels
    labelControlLayoutEU = "Europa",
    labelControlLayoutJP = "Japonia",
    labelLRTriggers = "Butoane L și R",
    labelUseDPad = "Folosire DPad",
    --
    --About section
    prefAppVersion = "Versiune a aplicației",
    prefCheckUpdate = "Caută actualizări",
    prefShowAuthor = "Dezvoltator",
    prefDonatorList = "Listă de donatori",
    prefSupportDev = "Suportă dezvoltatorul",
    prefTranslators = "Mulțumim traducătorilor",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Ultima versiune: ",
    prefDonatorListDescription = "Listă a celor care susțin proiectul",
    --
    --About status labels
    labelUnzippingVPK = "Se extrage din vpk",
    labelCurrentVersionIs = "Versiunea curentă este:",
    labelSpace = "Memorie utilizată",
    labelVersionIsUpToDate = "Sunteți la zi",
    prefPressAgainToAccept = "Apăsați din nou pentru a accepta",
    prefPressAgainToUpdate = "Apăsați din nou pentru a actualiza pe:",
    prefPreferredCatalogLanguage = "Limba preferată",
    labelOpenInBrowser = "Deschide în browser",
    labelSetPageAsCover = "Setează pagina drept copertă",
    labelResetCover = "Resetează coperta",
    labelDownloadImageToMemory = "Descarcă imaginea",
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
    labelAddToLibrary = "Adaugă la bibliotecă",
    labelRemoveFromLibrary = "Șterge din bibliotecă",
    labelPage = "Pagina: ",
    labelContinue = "Contină",
    labelStart = "Începe să citești",
    labelDone = "Terminat!",
    labelSummary = "Sumar",
    labelShrink = "Micșorează",
    labelExpand = "Citește mai multe",
    --
    --Parser modes
    parserPopular = "Popular",
    parserLatest = "Noutăți",
    parserSearch = "Căutare",
    parserAlphabet = "Alfabetic",
    parserByLetter = "După literă",
    parserByTag = "După tag",
    --
    --Panel labels
    labelPanelBack = "Înapoi",
    labelPanelMode = "Mod",
    labelPanelRead = "Citește",
    labelPanelJumpToPage = "Sari la pagina",
    labelPanelSearch = "Căutare",
    labelPanelSelect = "Selectare",
    labelPanelChoose = "Alege",
    labelPanelImport = "Importă",
    labelPanelChangeSection = "Schimbă selecția",
    labelPanelUpdate = "Reîmprospătare",
    labelPanelCancel = "Anulare",
    labelPanelDelete = "Ștergere",
    labelPanelFollow = "Urmărește",
    labelPanelUnfollow = "Nu mai urmări",
    --
    --Import labels
    labelExternalMemory = "Memorie externă",
    labelDrive = "Partiție",
    labelFolder = "Director",
    labelGoBack = "Mergi înapoi",
    labelFile = "Fișier",
    labelUnsupportedFile = "Fișier necunoscut",
    --
    --Buttons labels
    labelDownloadAll = "Descarcă toate capitolele",
    labelRemoveAll = "Șterge toate capitolele",
    labelCancelAll = "Anulează descărcarea capitolelor",
    labelClearBookmarks = "Elimină semne de carte",
    labelOpenMangaInBrowser = "Deschide manga în browser",
    --
    --Reader labels
    labelPreparingPages = "Paginile sunt pregătite",
    labelLoadingPage = "Pagina se încarcă",
    labelLoadingSegment = "Segmentul se încarcă",
    --
    labelYes = "Da",
    labelNo = "Nu",
    --Country codes alpha-3
    RUS = "Rusă",
    ENG = "Engleză",
    ESP = "Spaniolă",
    PRT = "Portugheză",
    FRA = "Franceză",
    JAP = "Japoneză",
    DIF = "Diferit",
    TUR = "Turcă",
    ITA = "Italiană",
    VIE = "Vietnameză",
    DEU = "Germană",
    BRA = "Brazilină",
    POL = "Poloneză",
    IDN = "Indoneziană",
    CHN = "Chineză",
    ROU = "Română",
    KOR = "Korean",
    RAW = "Raw (netraduse)",
    --Language translations
    Russian = "Rusă",
    English = "Engleză",
    Turkish = "Turcă",
    Spanish = "Spaniolă",
    Vietnamese = "Vietnameză",
    French = "Franceză",
    Italian = "Italiană",
    PortugueseBR = "Portugheză braziliană",
    SimplifiedChinese = "Chineză simplificată",
    TraditionalChinese = "Chineză tradițională",
    Romanian = "Română",
    Polish = "Poloneza",
    German = "Germana",
    Default = "Limba sistemului"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Romanian", "ROU", "tmihai20", nil)
