--Italian translation created by theHeroGAC and some strings by Rinnegatamante
local strings = {
    --Tabs
    appLibraryTab = "LIBRERIA",
    appCatalogsTab = "CATALOGHI",
    appSettingsTab = "IMPOSTAZIONI",
    appDownloadTab = "DOWNLOADS",
    appImportTab = "IMPORTA",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "CRONOLOGIA",
    labelSearch = "Ricerca",
    --
    --Message-screen messages
    labelLostConnection = "Connessione persa \n\nIn attesa di connessione ......\n\n(Riduci a icona l'applicazione, vai su Impostazioni Wi-Fi e premi Connetti)\n\nPremi X per annullare tutti i download e chiudere il messaggio \n\nTutti i download continueranno se la rete viene ripristinata",
    labelPressToUpdate = "Premi X per aggiornare\nPremi O per annullare",
    --
    --Information text
    labelEmptyLibrary = 'Nessun manga/fumetto.\nPer aggiungere manga/fumetti, trovalo in "CATALOGHI" menu e premi "Aggiungi alla libreria".',
    labelEmptyHistory = "Nessun manga/fumetto.\nApparirà qui prossimamente",
    labelEmptyCatalog = "Nessun manga/fumetto.\nErrore del server, della connessione o del parser",
    labelEmptyDownloads = "Nessun download di manga / fumetti",
    labelEmptyParsers = "Nessun catalogo.\nPremi Triangolo e attendi il caricamento di tutti i cataloghi",
    --
    --Notification information texts
    msgThankYou = "Thank you for supporting this project!",
    msgNoConnection = "Nessuna connessione",
    msgPleaseWait = "Attendere prego",
    msgFailedToUpdate = "Impossibile aggiornare l'app",
    msgAddedToLibrary = "Aggiunto alla libreria",
    msgRemovedFromLibrary = "Rimosso dalla libreria",
    msgSearching = 'Ricerca in corso "%s"',
    msgStartDownload = "%s: %s\ndownload avviato!",
    msgEndDownload = "%s: %s\nscaricato con successo!",
    msgCancelDownload = "%s: %s\ndownload è stato cancellato!",
    msgChapterRemove = "%s cancellato!",
    msgNetProblem = "Ci sono problemi con la connessione!",
    msgChaptersCleared = "Tutti i capitoli salvati vengono cancellati!",
    msgLibraryCleared = "Libreria cancellata!",
    msgCacheCleared = "La cache è stata cancellata!",
    msgDeveloperThing = "dare una stella por lei app su Github!",
    msgNewUpdateAvailable = "Nuovo aggiornamento disponibile",
    msgNoSpaceLeft = "Non è rimasto spazio",
    msgRefreshCompleted = "Aggiornamento completato!",
    msgImportCompleted = "Importazione completato!",
    msgSettingsReset = "Le impostazioni sono state ripristinate",
    msgBadImageFound = "È stata trovata una cattiva immagine!",
    msgCoverSetCompleted = "La cover è stata aggiornata!",
    msgNoChapters = "Nessun capitolo",
    --
    --Sections
    prefCategoryLanguage = "Linguaggio",
    prefCategoryTheme = "Tema",
    prefCategoryLibrary = "Libreria",
    prefCategoryCatalogs = "Cataloghi",
    prefCategoryReader = "Reader",
    prefCategoryNetwork = "Rete",
    prefCategoryDataSettings = "Impostazioni dei dati",
    prefCategoryOther = "Altro",
    prefCategoryControls = "Impostazioni dei controlli",
    prefCategoryAdvancedChaptersDeletion = "Cancellazione capitoli avanzati",
    prefCategoryAbout = "A proposito del programma...",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Impostazioni relative al tracciamento dei manga",
    prefCategoryCatalogsDescription = "Linguaggio, contenuto NSFW",
    prefCategoryReaderDescription = "Direzione di lettura, orientamento, zoom",
    prefCategoryNetworkDescription = "Timeout connessione, proxy",
    prefCategoryDataSettingsDescription = "Salvataggi, cache, impostazioni",
    prefCategoryOtherDescription = "Caricamento dei caratteri, ordinamento dei capitoli, notifiche",
    prefCategoryControlsDescription = "KeyType, pulsanti di modifica della pagina, impostazioni degli stick",
    prefCategoryAdvancedChaptersDeletionDescription = "Leggi, rimuovi",
    prefCategoryAboutDescription = "Versione, aggiornamento",
    --
    --Library section
    prefLibrarySorting = "Ordinamento della libreria",
    prefCheckChaptersAtStart = "Aggiorna libreria all'avvio",
    --
    --Catalogs section
    prefShowNSFW = "Mostra parser NSFW",
    prefHideInOffline = "Mostra solo i capitoli scaricati offline",
    --
    --Catalogs labels
    labelShowNSFW = "Mostra",
    labelHideNSFW = "Non mostrare",
    --
    --Reader section
    prefReaderOrientation = "Orientamento lettore predefinito",
    prefReaderScaling = "Ridimensionamento del lettore",
    prefReaderDirection = "Direzione di lettura Manga",
    prefReaderDoubleTap = "Abilita il doppio tocco per ingrandire la funzione",
    prefPressEdgesToChangePage = "Cambia le pagine premendo i bordi della pagina",
    prefAnimateGif = "Gif Animate (Sperimentale)",
    --
    --Reader labels
    labelHorizontal = "Orizzontale",
    labelVertical = "Verticale",
    labelScalingSmart = "Smart",
    labelScalingHeight = "Altezza",
    labelScalingWidth = "Larghezza",
    labelDirectionLeft = "Da destra a sinistra",
    labelDirectionRight = "Da sinistra a destra",
    labelDirectionDown = "Dall'alto verso il basso",
    labelDefault = "Default",
    --
    --Network section
    prefConnectionTime = "Tempo di connessione per server",
    prefUseProxy = "Utilizza proxy",
    prefProxyIP = "Indirizzo IP",
    prefProxyPort = "Porta",
    prefUseProxyAuth = "Utilizza autenticazione proxy",
    prefProxyAuth = "login:password",
    --
    --Network labels
    labelInputValue = "Valore di Input",
    --
    --Data settings section
    prefSaveDataPath = "Salva percorso dati",
    prefClearLibrary = "Cancella libreria",
    prefClearCache = "Cancella tutta la cache creata per i manga non tracciati",
    prefClearAllCache = "Cancella tutta la cache",
    prefClearChapters = "Cancella tutti i capitoli salvati",
    prefResetAllSettings = "Resetta tutte le impostazioni",
    --
    --Other section
    prefSkipFontLoading = "Salta il caricamento del carattere",
    prefChapterSorting = "Ordinamento dei capitoli",
    prefSilentDownloads = "Non mostrare le notifiche di download",
    prefSkipCacheChapterChecking = "Salta controllo della cache e del capitolo nella schermata di caricamento",
    prefShowSummary = "Mostra il riepilogo di un manga",
    --
    --Control setup section
    prefSwapXO = "Cambia pulsanti X o O",
    prefChangePageButtons = "Pulsanti per cambiare pagina",
    prefLeftStickDeadZone = "Deadzone della levetta sinistra",
    prefLeftStickSensitivity = "Sensibilità levetta sinistra",
    prefRightStickDeadZone = "Deadzone della levetta destra",
    prefRightStickSensitivity = "Sensibilità levetta destra",
    --
    --Control setup labels
    labelControlLayoutEU = "Europa",
    labelControlLayoutJP = "Giappone",
    labelLRTriggers = "L e R triggers",
    labelUseDPad = "Utilizza DPad",
    --
    --About section
    prefAppVersion = "Versione APP",
    prefCheckUpdate = "Controlla gli aggiornamenti",
    prefShowAuthor = "Sviluppatore",
    prefDonatorList = "Lista dei Donatori",
    prefSupportDev = "Supporta lo sviluppatore",
    prefTranslators = "Grazie ai traduttori",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Ultima versione : ",
    prefDonatorListDescription = "Elenco degli utenti che hanno sostenuto il progetto",
    --
    --About status labels
    labelUnzippingVPK = "Estrazione del vpk per l' installazione",
    labelCurrentVersionIs = "La versione attuale è:",
    labelSpace = "Memoria usata",
    labelVersionIsUpToDate = "La tua versione è aggiornata",
    prefPressAgainToAccept = "Premere di nuovo per accettare",
    prefPressAgainToUpdate = "Premere di nuovo per aggiornare su:",
    prefPreferredCatalogLanguage = "Lingua preferita",
    labelOpenInBrowser = "Apri nel browser",
    labelSetPageAsCover = "Imposta la pagina come cover",
    labelResetCover = "Ripristina le cover",
    labelDownloadImageToMemory = "Scarica immagine",
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
    labelAddToLibrary = "Aggiungi alla libreria",
    labelRemoveFromLibrary = "Rimuovi dalla libreria",
    labelPage = "Pagina : ",
    labelContinue = "Continua",
    labelStart = "Inizia a leggere",
    labelDone = "Сompletato!",
    labelSummary = "Sommario",
    labelShrink = "Riduci",
    labelExpand = "Continua a leggere",
    --
    --Parser modes
    parserPopular = "Popolare",
    parserLatest = "Più Recente",
    parserSearch = "Ricerca",
    parserAlphabet = "Alfabetico",
    parserByLetter = "Per Lettera",
    parserByTag = "Per Tag",
    --
    --Panel labels
    labelPanelBack = "Indietro",
    labelPanelMode = "Modalità",
    labelPanelRead = "Leggi",
    labelPanelJumpToPage = "Salta alla pagina",
    labelPanelSearch = "Ricerca",
    labelPanelSelect = "Seleziona",
    labelPanelChoose = "Scegli",
    labelPanelImport = "Importa",
    labelPanelChangeSection = "Cambia sezione",
    labelPanelUpdate = "Aggiorna",
    labelPanelCancel = "Cancella",
    labelPanelDelete = "Elimina",
    labelPanelFollow = "Segui",
    labelPanelUnfollow = "Smetti di seguire",
    --
    --Import labels
    labelExternalMemory = "Memoria esterna",
    labelDrive = "Drive",
    labelFolder = "Cartella",
    labelGoBack = "Torna Indietro",
    labelFile = "File",
    labelUnsupportedFile = "File non supportato",
    --
    --Buttons labels
    labelDownloadAll = "Scarica tutti i capitoli",
    labelRemoveAll = "Rimuovi tutti i capitoli",
    labelCancelAll = "Annulla il download dei capitoli",
    labelClearBookmarks = "Cancella segnalibri",
    labelOpenMangaInBrowser = "Apri manga nel browser",
    --
    --Reader labels
    labelPreparingPages = "Preparazione delle pagine",
    labelLoadingPage = "Caricamento pagina",
    labelLoadingSegment = "Caricamento segmento",
    --
    labelYes = "Si",
    labelNo = "No",
    --Country codes alpha-3
    RUS = "Russo",
    ENG = "Inglese",
    ESP = "Spagnolo",
    PRT = "Portoghese",
    FRA = "Francese",
    JAP = "Giapponese",
    DIF = "Diverso",
    TUR = "Turco",
    ITA = "Italiano",
    VIE = "Vietnamese",
    DEU = "Tedesco",
    BRA = "Brasiliano",
    POL = "Polacco",
    IDN = "Indonesiano",
    CHN = "Cina",
    ROU = "Rumena",
    KOR = "Coreano",
    RAW = "Raw (Fumetti non tradotti)",
    --Language translations
    Russian = "Russo",
    English = "Inglese",
    Turkish = "Turco",
    Spanish = "Spagnolo",
    Italian = "Italiano",
    French = "Francese",
    Vietnamese = "Vietnamese",
    PortugueseBR = "Portoghese Brasiliano",
    SimplifiedChinese = "Cinese Semplificato",
    TraditionalChinese = "Cinese Tradizionale",
    Romanian = "Rumeno",
    Polski = "Polacco",
    German = "Tedesco",
    Default = "Sistema"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Italian", "ITA", "theHeroGAC", 5)
