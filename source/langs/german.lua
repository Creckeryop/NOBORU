--German translation by lukrynka
local strings = {
    --Tabs
    appLibraryTab = "BIBLIOTHEK",
    appCatalogsTab = "KATALOGE",
    appSettingsTab = "EINSTELLUGEN",
    appDownloadTab = "DOWNLOADS",
    appImportTab = "IMPORTIEREN",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "VERLAUF",
    labelSearch = "Suche",
    --
    --Message-screen messages
    labelLostConnection = "Verbindung Fehlgeschlagen\n\nVerbindung wird Aufgebaut...\n\n(Minimiere die Anwendung, gehe zu WiFi Einstellugen und drücke auf Verbinden press)\n\nDrücke X um alle verbliebenden Downloads zu abzubrechen und die Nachricht zu schließen\n\nAlle Downloads werden fortgesetzt, wenn die Verbindung zum Internet wieder aufgebaut wird",
    labelPressToUpdate = "Drücke X Taste um zu Aktualisieren\nDrücke O Taste um abzubrechen",
    --
    --Information text
    labelEmptyLibrary = 'Keine Mangas/Comics in Ihrer Bibliothek.\nUm die hinzuzufügen, suche diese in "Kataloge" aus und drücke auf "Zur Bibliothek Hinzufügen".',
    labelEmptyHistory = "Es wurden keine Mangas/Comics in Ihrer Historie gefunden.\nDie werden hier irgendwann auftauchen",
    labelEmptyCatalog = "Es wurden keine Mangas/comics gefunden.\nServer verbindungs- oder Parser Fehler",
    labelEmptyDownloads = "Es werden keine Mangas/Comics heruntergeladen",
    labelEmptyParsers = "Es wurden keine Kataloge gefunden.\nDrücke Dreieck und warte bis alle Kataloge geladen wurden",
    --
    --Notification information texts
    msgThankYou = "Vielen Dank für die Unterstützung des Projektes!",
    msgNoConnection = "Verbindung Fehlgeschlagen",
    msgPleaseWait = "Bitte Warten",
    msgFailedToUpdate = "Aktualisierung der Anwendung Fehlgeschlagen",
    msgAddedToLibrary = "Zu Bibliothek Hinzugefügt",
    msgRemovedFromLibrary = "Von Bibliothek Entfernt",
    msgSearching = 'Suche nach "%s"',
    msgStartDownload = "%s: %s\nwird Herunterladen",
    msgEndDownload = "%s: %s\nerfolgreich Heruntergeladen!",
    msgCancelDownload = "%s: %s\ndownload wurde abgebrochen!",
    msgChapterRemove = "%s entfernt!",
    msgNetProblem = "Verbindungsproblem!",
    msgChaptersCleared = "Alle gespeicherten Kapitel wurden Entfernt!",
    msgLibraryCleared = "Bibliothek gelöscht!",
    msgCacheCleared = "Cache wurde gelöscht!",
    msgDeveloperThing = "Gebe der App ein Stern auf Github!",
    msgNewUpdateAvailable = "Neue Aktualisierung Verfügbar",
    msgNoSpaceLeft = "Der Speicher ist Voll!",
    msgRefreshCompleted = "Die Seite wurde Aktualisiert!",
    msgImportCompleted = "Import wurde Abgeschlossen!",
    msgSettingsReset = "Einstellungen wurden Zurückgesetzt",
    msgBadImageFound = "Es wurde eine Fehlerhafte Bilddatei gefunden!",
    msgCoverSetCompleted = "Das Cover wurde aktualisiert!",
    msgNoChapters = "Keine Kapitel",
    --
    --Sections
    prefCategoryLanguage = "Sprache",
    prefCategoryTheme = "Personalisierung der Oberfläche",
    prefCategoryLibrary = "Bibliothek",
    prefCategoryCatalogs = "Kataloge",
    prefCategoryReader = "Reader",
    prefCategoryNetwork = "Netzwerk",
    prefCategoryDataSettings = "Verwaltung der Daten",
    prefCategoryOther = "Andere",
    prefCategoryControls = "Bedienungseinstellungen",
    prefCategoryAdvancedChaptersDeletion = "Erweiterte Kapitellöschung",
    prefCategoryAbout = "Über die Anwendung",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Einstellungen für das Follgen der Manga",
    prefCategoryCatalogsDescription = "Sprache, NSFW Inhalt",
    prefCategoryReaderDescription = "Leserichtung, Orientierung und Zoom",
    prefCategoryNetworkDescription = "Verbindungsdauer, Proxy",
    prefCategoryDataSettingsDescription = "Speichern, Cache, Einstellungen",
    prefCategoryOtherDescription = "Schriftart, Kapitelorientierung, Benachrichtigungen",
    prefCategoryControlsDescription = "Tasten, Ändere die Seitentasten, Stick Einstellungen",
    prefCategoryAdvancedChaptersDeletionDescription = "Lesen, Entfernen",
    prefCategoryAboutDescription = "Version, Aktualisierung",
    --
    --Library section
    prefLibrarySorting = "Sortierung der Bibliothek",
    prefCheckChaptersAtStart = "Aktualisierung der Bibliothek bei Ausführung der Anwendung",
    --
    --Catalogs section
    prefShowNSFW = "NSFW Kataloge Anzeigen",
    prefHideInOffline = "Zeige nur die heruntergeladene Kapitel in Offline Modus",
    --
    --Catalogs labels
    labelShowNSFW = "Zeigen",
    labelHideNSFW = "Verbergen",
    --
    --Reader section
    prefReaderOrientation = "Standardmäßige Reader Orientierung",
    prefReaderScaling = "Reader Skalierung",
    prefReaderDirection = "Manga-Leserichtung",
    prefReaderDoubleTap = "Aktiviere doppeltes anklicken um zu vergrößern",
    prefPressEdgesToChangePage = "Wechsel Die Seite durch drücken auf die Ecken der Seite",
    prefAnimateGif = "GIF Animieren (Experimental)",
    --
    --Reader labels
    labelHorizontal = "Horizontal",
    labelVertical = "Vertikal",
    labelScalingSmart = "Smart",
    labelScalingHeight = "Höhe",
    labelScalingWidth = "Breite",
    labelDirectionLeft = "Rechts auf Links",
    labelDirectionRight = "Links auf Rechts",
    labelDirectionDown = "Von Oben auf Unten",
    labelDefault = "Standard",
    --
    --Network section
    prefConnectionTime = "Zeit für die Verbindungsdauer zum Server",
    prefUseProxy = "Proxy Benuzen",
    prefProxyIP = "IP Adresse",
    prefProxyPort = "Port",
    prefUseProxyAuth = "Benutze proxy Authentifizierung",
    prefProxyAuth = "login:kennwort",
    --
    --Network labels
    labelInputValue = "Wert Eingeben",
    --
    --Data settings section
    prefSaveDataPath = "Speicherort für Daten",
    prefClearLibrary = "Lösche die Bibliothek",
    prefClearCache = "Lösche die Cache von nicht gefolgten Inhalt",
    prefClearAllCache = "Lösche die gesamte Cache",
    prefClearChapters = "Lösche alle gespeicherten Kapitel",
    prefResetAllSettings = "Setze alle Einstellungen zurück",
    --
    --Other section
    prefSkipFontLoading = "Überspringe das Laden der Schriftart",
    prefChapterSorting = "Sortierung der Kapitel",
    prefSilentDownloads = "Zeige die Download-Benachrichtigungen nicht an",
    prefSkipCacheChapterChecking = "Überspringe die Prüfung der Cache und heruntergeladener Kapitel beim Laden",
    prefShowSummary = "Zeige die Zusammenfassung der Manga",
    --
    --Control setup section
    prefSwapXO = "Die Taste X durch O Ersetzen",
    prefChangePageButtons = "Knopf für das wechseln der Seite einstellen",
    prefLeftStickDeadZone = "L-Stick deadzone",
    prefLeftStickSensitivity = "Empfindlichkeit des L-Sticks",
    prefRightStickDeadZone = "R-Stick deadzone",
    prefRightStickSensitivity = "Empfindlichkeit des R-Sticks",
    --
    --Control setup labels
    labelControlLayoutEU = "Europa",
    labelControlLayoutJP = "Japan",
    labelLRTriggers = "L und R Trigger",
    labelUseDPad = "Benutze DPad",
    --
    --About section
    prefAppVersion = "App Version",
    prefCheckUpdate = "Nach Updates Suchen",
    prefShowAuthor = "Entwickler",
    prefDonatorList = "Spenderliste",
    prefSupportDev = "Unterstütze dem Entwickler",
    prefTranslators = "Vielen dank an die Übersetzer",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Neuste Version : ",
    prefDonatorListDescription = "Liste der Personen, die das Projekt unterstützt haben",
    --
    --About status labels
    labelUnzippingVPK = "Die VPK wird für die Installation ausgepackt",
    labelCurrentVersionIs = "Aktuelle Version der Anwendung:",
    labelSpace = "Speicher Belegt",
    labelVersionIsUpToDate = "Sie Verwenden bereits die aktuellste Version",
    prefPressAgainToAccept = "Drücke die Taste nochmal, um zu akzeptieren",
    prefPressAgainToUpdate = "Drücke die Taste nochmal, um die Updates am .. durchzuführen:",
    prefPreferredCatalogLanguage = "Bevorzugte Sprache",
    labelOpenInBrowser = "Öffne in Browser",
    labelSetPageAsCover = "Setze die Seite als Cover",
    labelResetCover = "Cover zurücksetzen",
    labelDownloadImageToMemory = "Bild Herunterladen",
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
    labelAddToLibrary = "Zur Bibliothek Hinzufügen",
    labelRemoveFromLibrary = "Entferne von Bibliothek",
    labelPage = "Seite : ",
    labelContinue = "Fortfahren",
    labelStart = "Lesen Beginnen",
    labelDone = "Fertig!",
    labelSummary = "Zusammenfassung",
    labelShrink = "Verkleinern",
    labelExpand = "Mehr Anzeigen",
    --
    --Parser modes
    parserPopular = "Populär",
    parserLatest = "Neuste",
    parserSearch = "Suche",
    parserAlphabet = "Alphabetisch",
    parserByLetter = "Nach Buchstaben Sortieren",
    parserByTag = "Nach Tag Sortieren",
    --
    --Panel labels
    labelPanelBack = "Zurück",
    labelPanelMode = "Modus",
    labelPanelRead = "Lesen",
    labelPanelJumpToPage = "Zu Seite wechseln",
    labelPanelSearch = "Suche",
    labelPanelSelect = "Auswählen",
    labelPanelChoose = "Wählen",
    labelPanelImport = "Importieren",
    labelPanelChangeSection = "Abschnitt Ändern",
    labelPanelUpdate = "Aktualisieren",
    labelPanelCancel = "Abbrechen",
    labelPanelDelete = "Löschen",
    labelPanelFollow = "Folgen",
    labelPanelUnfollow = "Entfolgen",
    --
    --Import labels
    labelExternalMemory = "Externes Speicher",
    labelDrive = "Laufwerk",
    labelFolder = "Ordner",
    labelGoBack = "Zurück",
    labelFile = "Datei",
    labelUnsupportedFile = "Datei wird nicht unterstützt",
    --
    --Buttons labels
    labelDownloadAll = "Alle Kapitel Herunterladen",
    labelRemoveAll = "Entferne Alle Kapitel",
    labelCancelAll = "Herunterladen der Kapitel abbrechen",
    labelClearBookmarks = "Lösche die Lesezeichen",
    labelOpenMangaInBrowser = "Öffne die Manga im Browser",
    --
    --Reader labels
    labelPreparingPages = "Seiten werden Vorbereitet",
    labelLoadingPage = "Seite wird Geladen",
    labelLoadingSegment = "Segment wird Geladen",
    --
    labelYes = "Ja",
    labelNo = "Nein",
    --Country codes alpha-3
    RUS = "Russisch",
    ENG = "Englisch",
    ESP = "Spanisch",
    PRT = "Portugiesisch",
    FRA = "Französisch",
    JAP = "Japanisch",
    DIF = "Andere",
    TUR = "Türkisch",
    ITA = "Italienisch",
    VIE = "Vietnamesisch",
    DEU = "Deutsch",
    BRA = "Brazilianisch",
    POL = "Polnisch",
    IDN = "Indonesisch",
    CHN = "Chinesisch",
    ROU = "Rumänisch",
    KOR = "Koreanisch",
    RAW = "RAW (Nicht Übersetzte Manga)",
    --Language translations
    Russian = "Russisch",
    English = "Englisch",
    Turkish = "Türkisch",
    Spanish = "Spanisch",
    Vietnamese = "Vietnamesisch",
    French = "Französisch",
    Italian = "Italienisch",
    PortugueseBR = "Brasilianisches Portugiesisch",
    SimplifiedChinese = "Vereinfachtes Chinesisch",
    TraditionalChinese = "Traditionelles Chinesisch",
    Romanian = "Rumänisch",
    Polish = "Polnisch",
    German = "Deutsch",
    Default = "Systemsprache"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "German", "DEU", "lukrynka", 4)
