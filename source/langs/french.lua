--French translation created by Samilop "Cimmerian" Iter
local strings = {
    --Tabs
    appLibraryTab = "LIBRAIRIE",
    appCatalogsTab = "CATALOGUE",
    appSettingsTab = "PARAMETRES",
    appDownloadTab = "TELECHARGEMENT",
    appImportTab = "IMPORTER",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "HISTORIQUE",
    labelSearch = "Rechercher",
    --
    --Message-screen messages
    labelLostConnection = "Connexion perdu\n\nEn attente de la reconnexion......\n\n(Réduire l'application, aller au paramètres Wi-Fi et appuyez sur connexion)\n\nAppuyez sur X pour annuler tous les téléchargments et fermer le message\n\nTous les téléchargements reprondront une fois la connexion établie",
    labelPressToUpdate = "Appuyez sur X pour mettre à jour\nAppuyez sur O pour annuler",
    --
    --Information text
    labelEmptyLibrary = 'Pas de manga/comics.\nPour ajouter des mangas/comics,\nvous pouvez aller dans le menu"CATALOGUE" et appuyer "Ajouter à la librairie".',
    labelEmptyHistory = "Pas de manga/comics.\nCela viendra un jour",
    labelEmptyCatalog = "Pas de manga/comics.\nErreur de connexion, server ou d'analyseur",
    labelEmptyDownloads = "Pas de téléchargement de manga/comics",
    labelEmptyParsers = "Pas de catalogue.\nAppuyez sur Triangle et attendez jusqu'à ce que les catalogues soient chargé.",
    --
    --Notification information texts
    msgThankYou = "Merci de votre support envers le projet",
    msgNoConnection = "Pas de connection",
    msgPleaseWait = "Veuillez patienter",
    msgFailedToUpdate = "Impossible de mettre à jour",
    msgAddedToLibrary = "Ajouté à la librairie",
    msgRemovedFromLibrary = "Retiré de la librairie",
    msgSearching = 'En train de rechercher "%s"',
    msgStartDownload = "%s: %s\nle téléchargement a débuté!",
    msgEndDownload = "%s: %s\ntéléchargement complété!",
    msgCancelDownload = "%s: %s\nle téléchargement a été annulé!",
    msgChapterRemove = "%s supprimé!",
    msgNetProblem = "Un problème réseau est survenu.",
    msgChaptersCleared = "Les chapitres ont été vidé!",
    msgLibraryCleared = "La librairie a été vidé!",
    msgCacheCleared = "Le cache a été vidé!",
    msgDeveloperThing = "Donner une étoile a l'app sur github!",
    msgNewUpdateAvailable = "Nouvelle mise à jour disponible",
    msgNoSpaceLeft = "Plus d'espace disponible",
    msgRefreshCompleted = "Mise à jour complète!",
    msgImportCompleted = "Importation complète!",
    msgSettingsReset = "Les paramètres vont être restauré",
    msgBadImageFound = "Mauvaise image trouvée!",
    msgCoverSetCompleted = "La couverture a été mise à jour!",
    msgNoChapters = "Pas de chapitres",
    --
    --Sections
    prefCategoryLanguage = "Language",
    prefCategoryTheme = "Thème",
    prefCategoryLibrary = "Librairie",
    prefCategoryCatalogs = "Catalogue",
    prefCategoryReader = "Lecteur",
    prefCategoryNetwork = "Réseau",
    prefCategoryDataSettings = "Paramètre de la date",
    prefCategoryOther = "Autres",
    prefCategoryControls = "Paramètre des controles",
    prefCategoryAdvancedChaptersDeletion = "Suppression des chapitres sauvegardé avancé",
    prefCategoryAbout = "A propos du programme...",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Paramètres de suivi des mangas",
    prefCategoryCatalogsDescription = "Langage, contenu NSFW",
    prefCategoryReaderDescription = "Sens de lecture, orientation, zoom",
    prefCategoryNetworkDescription = "Durée du délai de connexion, proxy",
    prefCategoryDataSettingsDescription = "Sauvegarde, cache, paramètres",
    prefCategoryOtherDescription = "Chargement de la police, organisation des chapitres, notifications",
    prefCategoryControlsDescription = "Action o et x, bouton de changement de page, sticks settings",
    prefCategoryAdvancedChaptersDeletionDescription = "Lire, Supprimer",
    prefCategoryAboutDescription = "Version, mise à jour",
    --
    --Library section
    prefLibrarySorting = "Ordonner la librairie",
    prefCheckChaptersAtStart = "Rafraichir la librairie au démarrage",
    --
    --Catalogs section
    prefShowNSFW = "Montrer le NSFW",
    prefHideInOffline = "Montrer uniquement les chapitres hors ligne",
    --
    --Catalogs labels
    labelShowNSFW = "Montrer",
    labelHideNSFW = "Ne pas montrer",
    --
    --Reader section
    prefReaderOrientation = "Orientation du lecteur",
    prefReaderScaling = "Zoom du lecteur",
    prefReaderDirection = "Sens de lecture",
    prefReaderDoubleTap = "Activer le double tap pour zoomer",
    prefPressEdgesToChangePage = "Changer de page en appuyant sur le bord des pages",
    prefAnimateGif = "Animer les gif (Experimental)",
    --
    --Reader labels
    labelHorizontal = "Horizontale",
    labelVertical = "Verticale",
    labelScalingSmart = "Adapté",
    labelScalingHeight = "Hauteur",
    labelScalingWidth = "Longueur",
    labelDirectionLeft = "Droite à gauche",
    labelDirectionRight = "Gauche à droite",
    labelDirectionDown = "Haut en bas",
    labelDefault = "Défaut",
    --
    --Network section
    prefConnectionTime = "Temps de connexion au serveur",
    prefUseProxy = "Utiliser un proxy",
    prefProxyIP = "Adresse IP",
    prefProxyPort = "Port",
    prefUseProxyAuth = "Utiliser l'authentification Proxy",
    prefProxyAuth = "identifiant:mot de passe",
    --
    --Network labels
    labelInputValue = "Insérer une valeur",
    --
    --Data settings section
    prefSaveDataPath = "Emplacement de la sauvegarde",
    prefClearLibrary = "Vider la librairie",
    prefClearCache = "Vider le cache des mangas non suivie",
    prefClearAllCache = "Vider tout le cache",
    prefClearChapters = "Supprimer les chapitres sauvegardé",
    prefResetAllSettings = "Restaurer tous les paramètres",
    --
    --Other section
    prefSkipFontLoading = "Passer le chargement des polices",
    prefChapterSorting = "Ordonner les chapitres",
    prefSilentDownloads = "Pas de notifications de Téléchargement",
    prefSkipCacheChapterChecking = "Passer la vérification du cache et du chapitre pendant l'écran de chargement",
    prefShowSummary = "Afficher un résumé du manga",
    --
    --Control setup section
    prefSwapXO = "Changer entre X ou O",
    prefChangePageButtons = "Bouton pour changer de page",
    prefLeftStickDeadZone = "Deadzone du joystick gauche",
    prefLeftStickSensitivity = "Sensibilité du joystick gauche",
    prefRightStickDeadZone = "Deadzone du joystick droit",
    prefRightStickSensitivity = "Sensibilité du joystick droit",
    --
    --Control setup labels
    labelControlLayoutEU = "Europe",
    labelControlLayoutJP = "Japonais",
    labelLRTriggers = "Boutons L et R",
    labelUseDPad = "Utiliser le Dpad",
    --
    --About section
    prefAppVersion = "Version de l'app",
    prefCheckUpdate = "Chercher une mise à jour",
    prefShowAuthor = "Développeur",
    prefDonatorList = "Liste des donateurs",
    prefSupportDev = "Supporter le développeur",
    prefTranslators = "Merci aux traducteurs",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Dernière version : ",
    prefDonatorListDescription = "Liste des personnes qui ont supporté le projet",
    --
    --About status labels
    labelUnzippingVPK = "Extraction du vpk pour l'installation",
    labelCurrentVersionIs = "Version actuelle:",
    labelSpace = "Mémoire utilisé",
    labelVersionIsUpToDate = "La version est la plus récente",
    prefPressAgainToAccept = "Appuyez encore pour accepter",
    prefPressAgainToUpdate = "Appuyez encore pour mettre à jour:",
    prefPreferredCatalogLanguage = "Langue préféré",
    labelOpenInBrowser = "Ouvrir dans le navigateur",
    labelSetPageAsCover = "Choisir cette page comme couverture",
    labelResetCover = "Restaurer la couverture",
    labelDownloadImageToMemory = "Télécharger l'image",
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
    labelAddToLibrary = "Ajouter à la librairie",
    labelRemoveFromLibrary = "Enlever de la librairie",
    labelPage = "Page : ",
    labelContinue = "Continuer",
    labelStart = "Commencer à lire",
    labelDone = "Terminé !",
    labelSummary = "Résumé",
    labelShrink = "Réduire",
    labelExpand = "Lire plus",
    --
    --Parser modes
    parserPopular = "Populaire",
    parserLatest = "Nouveau",
    parserSearch = "Rechercher",
    parserAlphabet = "Alphabet",
    parserByLetter = "Par lettre",
    parserByTag = "Par Tag",
    --
    --Panel labels
    labelPanelBack = "Retourner",
    labelPanelMode = "Mode",
    labelPanelRead = "Lire",
    labelPanelJumpToPage = "Sauter à la page",
    labelPanelSearch = "Rechercher",
    labelPanelSelect = "Sélectionner",
    labelPanelChoose = "Choisir",
    labelPanelImport = "Importer",
    labelPanelChangeSection = "Changer de section",
    labelPanelUpdate = "Mettre à jour",
    labelPanelCancel = "Annuler",
    labelPanelDelete = "Supprimer",
    labelPanelFollow = "Suivre",
    labelPanelUnfollow = "Ne plus suivre",
    --
    --Import labels
    labelExternalMemory = "Mémoire Externe",
    labelDrive = "Disque",
    labelFolder = "Dossier",
    labelGoBack = "Retour",
    labelFile = "Fichier",
    labelUnsupportedFile = "Fichier non supporté",
    --
    --Buttons labels
    labelDownloadAll = "Télécharger tous les chapitres",
    labelRemoveAll = "Retirer tous les chapitres",
    labelCancelAll = "Annuler le téléchargement des chapitres",
    labelClearBookmarks = "Vider les marques pages",
    labelOpenMangaInBrowser = "Ouvrir le manga dans le navigateur",
    --
    --Reader labels
    labelPreparingPages = "Préparation des pages",
    labelLoadingPage = "Chargement de la page",
    labelLoadingSegment = "Chargement par parties",
    --
    labelYes = "Oui",
    labelNo = "Non",
    --Country codes alpha-3
    RUS = "Russe",
    ENG = "Anglais",
    ESP = "Espagnol",
    PRT = "Portugais",
    FRA = "Français",
    JAP = "Japonais",
    DIF = "Divers",
    TUR = "Turque",
    ITA = "Italien",
    VIE = "Vietnamien",
    DEU = "Allemand",
    BRA = "Brésilien",
    POL = "Polonais",
    IDN = "Indonésien",
    CHN = "Chine",
    ROU = "Roumaine",
    KOR = "Coréen",
    RAW = "Raw (Bandes dessinées non traduites)",
    --Language translations
    Russian = "Russe",
    English = "Anglais",
    Turkish = "Turque",
    Spanish = "Espagnol",
    Italian = "Italien",
    French = "Français",
    Vietnamese = "Vietnamien",
    PortugueseBR = "Portugais brésilien",
    SimplifiedChinese = "Chinois simplifié",
    TraditionalChinese = "Chinois traditionnel",
    Romanian = "Roumaine",
    Polski = "Polonaise",
    German = "Allemand",
    Default = "Système"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "French", "FRA", "Samilop \"Cimmerian\" Iter", 2)
