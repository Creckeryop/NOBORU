--Polish translation by tofudd
local strings = {
    --Tabs
    appLibraryTab = "BIBLIOTEKA",
    appCatalogsTab = "KATALOGI",
    appSettingsTab = "USTAWIENIA",
    appDownloadTab = "POBRANIE",
    appImportTab = "IMPORTUJ",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "HISTORIA",
    labelSearch = "Szukaj",
    --
    --Message-screen messages
    labelLostConnection = "Utracono połączenie.\n\nCzekanie na połączenie...\n\n(Zminimalizuj aplikację, wejdź do ustawień Wi-Fi i wybierz Połącz)\n\nNaciśnij X aby anulować pobieranie i zamknąć komunikat.\n\nPobieranie zostanie kontynuowane po odzyskaniu połączenia z siecią.",
    labelPressToUpdate = "Naciśnij X aby zaktualizować aplikację\nNaciśnij O aby anulować",
    --
    --Information text
    labelEmptyLibrary = 'Brak mang/komiksów.\nAby dodać mangi/komiksy znajdź je w menu "KATALOGI" i naciśnij "Dodaj do biblioteki".',
    labelEmptyHistory = "Brak mang/komiksów.\nKiedyś się tu pojawią",
    labelEmptyCatalog = "Brak mang/komiksów.\nBłąd serwera, połączenia lub parsera",
    labelEmptyDownloads = "Brak pobieranych mang/komiksów",
    labelEmptyParsers = "Brak katalogów.\nNaciśnij Trójkąt i poczekaj na załadowanie.",
    --
    --Notification information texts
    msgThankYou = "Dziękujemy Ci za wspieranie projektu!",
    msgNoConnection = "Brak połączenia",
    msgPleaseWait = "Proszę czekać",
    msgFailedToUpdate = "Aktualizacja zakończona niepowodzeniem",
    msgAddedToLibrary = "Dodano do biblioteki",
    msgRemovedFromLibrary = "Usunięto z biblioteki",
    msgSearching = 'Wyszukiwanie "%s"',
    msgStartDownload = "%s: %s\npobieranie rozpoczęte!",
    msgEndDownload = "%s: %s\npobieranie zakończone sukcesem!",
    msgCancelDownload = "%s: %s\npobieranie anulowane!",
    msgChapterRemove = "%s usunięte!",
    msgNetProblem = "Wystąpił problem z połączeniem!",
    msgChaptersCleared = "Wszystkie zapisane rozdziały zostały wyczyszczone!",
    msgLibraryCleared = "Biblioteka została wyczyszczona!",
    msgCacheCleared = "Pamięć podręczna została wyczyszczona!",
    msgDeveloperThing = "Daj gwiazdkę na GitHub!",
    msgNewUpdateAvailable = "Dostępna aktualizacja",
    msgNoSpaceLeft = "Brak dostępnej pamięci",
    msgRefreshCompleted = "Odświeżenie zakończone!",
    msgImportCompleted = "Import zakończone!",
    msgSettingsReset = "Ustawienia zostały zresetowane",
    msgBadImageFound = "Znaleziono nieprawidłowy obraz!",
    msgCoverSetCompleted = "Okładka została zaktualizowana!",
    msgNoChapters = "Brak rozdziałów",
    --
    --Sections
    prefCategoryLanguage = "Język",
    prefCategoryTheme = "Motyw",
    prefCategoryLibrary = "Biblioteka",
    prefCategoryCatalogs = "Katalogi",
    prefCategoryReader = "Czytnik",
    prefCategoryNetwork = "Sieć",
    prefCategoryDataSettings = "Dane",
    prefCategoryOther = "Inne",
    prefCategoryControls = "Sterowanie",
    prefCategoryAdvancedChaptersDeletion = "Zaawansowane usuwanie rozdziałów",
    prefCategoryAbout = "O programie",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Ustawienia śledzenia mangi",
    prefCategoryCatalogsDescription = "Język, zawartość NSFW",
    prefCategoryReaderDescription = "Kierunek czytania, orientacja ekranu, przybliżenie",
    prefCategoryNetworkDescription = "Przekroczono limit czasu połączenia, proxy",
    prefCategoryDataSettingsDescription = "Zapisy, pamięć podręczna, ustawienia",
    prefCategoryOtherDescription = "Ładowanie czcionek, sortowanie rozdziałów, powiadomienia",
    prefCategoryControlsDescription = "Typ klawiszy, przyciski zmiany stron, ustawienia gałek",
    prefCategoryAdvancedChaptersDeletionDescription = "Czytaj, usuń",
    prefCategoryAboutDescription = "Wersja, aktualizacje",
    --
    --Library section
    prefLibrarySorting = "Sortowanie biblioteki",
    prefCheckChaptersAtStart = "Odśwież bibliotekę po uruchomieniu",
    --
    --Catalogs section
    prefShowNSFW = "Pokaż katalogi NSFW",
    prefHideInOffline = "Pokazuj tylko pobrane rozdziały w trybie offline",
    --
    --Catalogs labels
    labelShowNSFW = "Tak",
    labelHideNSFW = "Nie",
    --
    --Reader section
    prefReaderOrientation = "Domyślna orientacja czytnika",
    prefReaderScaling = "Skalowanie czytnika",
    prefReaderDirection = "Kierunek czytania mangi",
    prefReaderDoubleTap = "Włącz przybliżanie podwójnym tapnięciem",
    prefPressEdgesToChangePage = "Zmieniaj strony przez naciskanie krawędzi",
    prefAnimateGif = "Animuj gify (Eksperymentalne)",
    --
    --Reader labels
    labelHorizontal = "Poziome",
    labelVertical = "Pionowe",
    labelScalingSmart = "Inteligentne",
    labelScalingHeight = "Wysokość",
    labelScalingWidth = "Szerokość",
    labelDirectionLeft = "Od prawej do lewej",
    labelDirectionRight = "Od lewej do prawej",
    labelDirectionDown = "Od góry do dołu",
    labelDefault = "Domyślne",
    --
    --Network section
    prefConnectionTime = "Czas połączenia z serwerem",
    prefUseProxy = "Użyj proxy",
    prefProxyIP = "Adres IP",
    prefProxyPort = "Port",
    prefUseProxyAuth = "Użyj uwierzytelnienia proxy",
    prefProxyAuth = "login:hasło",
    --
    --Network labels
    labelInputValue = "Wprowadź wartość",
    --
    --Data settings section
    prefSaveDataPath = "Zapisz ścieżkę do danych",
    prefClearLibrary = "Wyczyść bibliotekę",
    prefClearCache = "Wyczyść pamięć podręczną nie śledzonych mang",
    prefClearAllCache = "Wyczyść całą pamięć podręczną",
    prefClearChapters = "Wyczyść wszystkie zapisane rozdziały",
    prefResetAllSettings = "Zresetuj wszystkie ustawienia",
    --
    --Other section
    prefSkipFontLoading = "Pomiń ładowanie czcionek",
    prefChapterSorting = "Sortowanie rozdziałów",
    prefSilentDownloads = "Nie pokazuj powiadomień o stanie pobierania",
    prefSkipCacheChapterChecking = "Pomiń sprawdzanie pamięci podręcznej i zapisanych rozdziałów przy ładowaniu",
    prefShowSummary = "Pokaż podsumowanie mangi",
    --
    --Control setup section
    prefSwapXO = "Zamień X i O",
    prefChangePageButtons = "Przyciski zmieniające strony",
    prefLeftStickDeadZone = "Martwa strefa lewej gałki analogowej",
    prefLeftStickSensitivity = "Czułość lewej gałki analogowej",
    prefRightStickDeadZone = "Martwa strefa prawej gałki analogowej",
    prefRightStickSensitivity = "Czułość prawej gałki analogowej",
    --
    --Control setup labels
    labelControlLayoutEU = "Europa",
    labelControlLayoutJP = "Japonia",
    labelLRTriggers = "Spusty L i R",
    labelUseDPad = "Używaj D-Pada",
    --
    --About section
    prefAppVersion = "Wersja aplikacji",
    prefCheckUpdate = "Sprawdź aktualizacje",
    prefShowAuthor = "Deweloper",
    prefDonatorList = "Lista wspierających",
    prefSupportDev = "Wesprzyj twórcę",
    prefTranslators = "Podziękowania dla tłumaczy",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Ostatnia wersja : ",
    prefDonatorListDescription = "Lista wspierających projekt",
    --
    --About status labels
    labelUnzippingVPK = "Wypakowywanie pliku VPK",
    labelCurrentVersionIs = "Aktualna wersja to:",
    labelSpace = "Zużycie pamięci",
    labelVersionIsUpToDate = "Twoja wersja jest aktualna",
    prefPressAgainToAccept = "Naciśnij ponownie aby zaakceptować",
    prefPressAgainToUpdate = "Naciśnij ponownie aby zaktualizować:",
    prefPreferredCatalogLanguage = "Preferowany język",
    labelOpenInBrowser = "Otwórz w przeglądarce",
    labelSetPageAsCover = "Ustaw stronę jako okładkę",
    labelResetCover = "Zresetuj okładkę",
    labelDownloadImageToMemory = "Pobierz obraz",
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
    labelAddToLibrary = "Dodaj do biblioteki",
    labelRemoveFromLibrary = "Usuń z biblioteki",
    labelPage = "Strona : ",
    labelContinue = "Kontynuuj czytanie",
    labelStart = "Rozpocznij",
    labelDone = "Ukończone!",
    labelSummary = "Podsumowanie",
    labelShrink = "Zmniejsz",
    labelExpand = "Przeczytaj więcej",
    --
    --Parser modes
    parserPopular = "Popularne",
    parserLatest = "Ostatnie",
    parserSearch = "Szukaj",
    parserAlphabet = "Alfabetycznie",
    parserByLetter = "Po literze",
    parserByTag = "Po tagu",
    --
    --Panel labels
    labelPanelBack = "Powrót",
    labelPanelMode = "Tryb",
    labelPanelRead = "Czytaj",
    labelPanelJumpToPage = "Skocz do strony",
    labelPanelSearch = "Szukaj",
    labelPanelSelect = "Nawigacja",
    labelPanelChoose = "Wybierz",
    labelPanelImport = "Importuj",
    labelPanelChangeSection = "Wybór sekcja",
    labelPanelUpdate = "Odśwież",
    labelPanelCancel = "Anuluj",
    labelPanelDelete = "Usuń",
    labelPanelFollow = "Obserwuj",
    labelPanelUnfollow = "Przestań obserwować",
    --
    --Import labels
    labelExternalMemory = "Pamięć zewnętrzna",
    labelDrive = "Dysk",
    labelFolder = "Folder",
    labelGoBack = "Powrót",
    labelFile = "Plik",
    labelUnsupportedFile = "Nieobsługiwany format pliku",
    --
    --Buttons labels
    labelDownloadAll = "Pobierz wszystkie rozdziały",
    labelRemoveAll = "Usuń wszystkie rozdziały",
    labelCancelAll = "Anuluj pobieranie rozdziałów",
    labelClearBookmarks = "Wyczyść zakładki",
    labelOpenMangaInBrowser = "Otwórz mangę w przeglądarce",
    --
    --Reader labels
    labelPreparingPages = "Przygotowywanie stron",
    labelLoadingPage = "Ładowanie strony",
    labelLoadingSegment = "Ładowanie strony",
    --
    labelYes = "Tak",
    labelNo = "Nie",
    --Country codes alpha-3
    RUS = "Rosyjskie",
    ENG = "Angielskie",
    ESP = "Hiszpańskie",
    PRT = "Portugalskie",
    FRA = "Francuskie",
    JAP = "Japońskie",
    DIF = "Różne",
    TUR = "Tureckie",
    ITA = "Włoskie",
    VIE = "Wietnamskie",
    DEU = "Niemieckie",
    BRA = "Brazylijskie",
    POL = "Polskie",
    IDN = "Indonezyjskie",
    CHN = "Chińskie",
    ROU = "Rumuńskie",
    KOR = "Koreańskie",
    RAW = "RAW (Nieprzetłumaczona manga)",
    --Language translations
    Russian = "Rosyjski",
    English = "Angielski",
    Turkish = "Turecki",
    Spanish = "Hiszpański",
    Vietnamese = "Wietnamski",
    French = "Francuski",
    Italian = "Włoski",
    PortugueseBR = "Brazylijski portugalski",
    SimplifiedChinese = "Chiński uproszczony",
    TraditionalChinese = "Chiński tradycyjny",
    Romanian = "Rumuński",
    Polish = "Polski",
    German = "Niemiecki",
    Default = "Systemowy"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Polish", "POL", "tofudd", 16)
