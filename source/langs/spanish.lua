--Spanish translation created by SamuEDL
local strings = {
    --Tabs
    appLibraryTab = "LIBRERIA",
    appCatalogsTab = "CATALOGO",
    appSettingsTab = "AJUSTES",
    appDownloadTab = "DESCARGAS",
    appImportTab = "IMPORTAR",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "HISTORIAL",
    labelSearch = "Buscar",
    --
    --Message-screen messages
    labelLostConnection = "Se ha perdido la conexión\n\nEsperando conexión...\n\n(Minimiza la app, vete a los ajustes wifi y conectate a tu red wifi)\n\nPresiona X para cancelar todas las descargas y cerrar el mensaje\n\nTodas las descargas continuaran, cuando la conexión sea restaurada.",
    labelPressToUpdate = "Presiona X para actualizar\nPresiona O para cancelar",
    --
    --Information text
    labelEmptyLibrary = 'No manga/comics.\nAñade el manga/comics, buscandolo en el menu "CATALOGS" y presionando "Add to library".',
    labelEmptyHistory = "No manga/comics.\nAparecera aqui algo, algun dia",
    labelEmptyCatalog = "No manga/comics.\nError del servidor, conexion o parsers",
    labelEmptyDownloads = "No hay manga/comics descargando",
    labelEmptyParsers = "No catalogo.\nPresiona el Triangulo y espera a que cargue todo el catalogo",
    --
    --Notification information texts
    msgThankYou = "Gracias por apoyar este proyecto",
    msgNoConnection = "No hay conexión",
    msgPleaseWait = "Espere, por favor",
    msgFailedToUpdate = "Fallo la actualización",
    msgAddedToLibrary = "Añadir a la librería",
    msgRemovedFromLibrary = "Eliminar de la librería",
    msgSearching = 'Buscando "%s"',
    msgStartDownload = "%s: %s\nla descargando!",
    msgEndDownload = "%s: %s\ndescargado con éxito!",
    msgCancelDownload = "%s: %s\nla descaga se ha cancelado!",
    msgChapterRemove = "%s eliminado!",
    msgNetProblem = "Hay problemas con la conexion!",
    msgChaptersCleared = "Todos los capítulos guardados, han sido eliminados!",
    msgLibraryCleared = "La librería ha sido eliminada!",
    msgCacheCleared = "La cache ha sido eliminada!",
    msgDeveloperThing = "Pon una estrella en la app de Github!",
    msgNewUpdateAvailable = "Nueva actualización disponible",
    msgNoSpaceLeft = "No hay espacio",
    msgRefreshCompleted = "Refresco completado!",
    msgImportCompleted = "Importación completado!",
    msgSettingsReset = "Los ajustes han sido resteados",
    msgBadImageFound = "Se encontró una imagen incorrecta!",
    msgCoverSetCompleted = "Portada actualizada!",
    msgNoChapters = "No hay capítulos",
    --
    --Sections
    prefCategoryLanguage = "Idioma:",
    prefCategoryTheme = "Tema:",
    prefCategoryLibrary = "Libreria",
    prefCategoryCatalogs = "Catalogo",
    prefCategoryReader = "Lector",
    prefCategoryNetwork = "Red",
    prefCategoryDataSettings = "Datos",
    prefCategoryOther = "Otros",
    prefCategoryControls = "Controles",
    prefCategoryAdvancedChaptersDeletion = "Eliminacion avanzada de capitulos",
    prefCategoryAbout = "Información del programa",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Configuración relacionada con los mangas en seguimiento",
    prefCategoryCatalogsDescription = "Lenguaje, Contenido NSFW",
    prefCategoryReaderDescription = "Dirección de lectura, orientacion, zoom",
    prefCategoryNetworkDescription = "Tiempo de conexion, proxy",
    prefCategoryDataSettingsDescription = "Guardado, cache, ajustes",
    prefCategoryOtherDescription = "Cargado de fuentes, clasificacion de capitulos, notificaciones",
    prefCategoryControlsDescription = "KeyType, Botones para cambiar paginas, sensibilidad del stick",
    prefCategoryAdvancedChaptersDeletionDescription = "Leer, eliminar",
    prefCategoryAboutDescription = "Version, actualizar",
    --
    --Library section
    prefLibrarySorting = "Organización de librería:",
    prefCheckChaptersAtStart = "Refrescar libreria al iniciar:",
    --
    --Catalogs section
    prefShowNSFW = "Mostrar servidores NSFW:",
    prefHideInOffline = "Mostrar solo los capítulos descargados en modo offline:",
    --
    --Catalogs labels
    labelShowNSFW = "Mostrar",
    labelHideNSFW = "No mostrar",
    --
    --Reader section
    prefReaderOrientation = "Orientación de lectura:",
    prefReaderScaling = "Escala de lectura:",
    prefReaderDirection = "Dirección de lectura:",
    prefReaderDoubleTap = "Activar doble toque para hacer zoom:",
    prefPressEdgesToChangePage = "Cambiar de pagina presionando el borde",
    prefAnimateGif = "Animar gif (Experimental)",
    --
    --Reader labels
    labelHorizontal = "Horizontal",
    labelVertical = "Vertical",
    labelScalingSmart = "Inteligente",
    labelScalingHeight = "Alto",
    labelScalingWidth = "Ancho",
    labelDirectionLeft = "Derecha a izquierda",
    labelDirectionRight = "Izquierda a derecha",
    labelDirectionDown = "Arriba a abajo",
    labelDefault = "Por defecto",
    --
    --Network section
    prefConnectionTime = "Tiempo de conexion con el servidor:",
    prefUseProxy = "Usar Proxy:",
    prefProxyIP = "Dirección IP:",
    prefProxyPort = "Puerto:",
    prefUseProxyAuth = "Usar autenticación proxy:",
    prefProxyAuth = "login:contraseña",
    --
    --Network labels
    labelInputValue = "Introduce un valor",
    --
    --Data settings section
    prefSaveDataPath = "Guarda ruta de datos",
    prefClearLibrary = "Limpiar librería",
    prefClearCache = "Eliminar la cache de los mangas que no sigo",
    prefClearAllCache = "Eliminar toda la cache",
    prefClearChapters = "Eliminar todos los capítulos guardados",
    prefResetAllSettings = "Resetear todos los ajustes",
    --
    --Other section
    prefSkipFontLoading = "Saltar carga de fuentes:",
    prefChapterSorting = "Organización de capitulos:",
    prefSilentDownloads = "No mostrar notificaciones de descargas:",
    prefSkipCacheChapterChecking = "Saltar chequeo de cache y capitulos en la pantalla de carga:",
    prefShowSummary = "Mostrar resumen del manga",
    --
    --Control setup section
    prefSwapXO = "Cambiar KeyType:",
    prefChangePageButtons = "Botones para cambiar de pagina:",
    prefLeftStickDeadZone = "Zona muerta del jostick izquierdo:",
    prefLeftStickSensitivity = "Sensibilidad del jostick izquierdo:",
    prefRightStickDeadZone = "Zona muerta del jostick derecho:",
    prefRightStickSensitivity = "Sensibilidad del jostick derecho:",
    --
    --Control setup labels
    labelControlLayoutEU = "Europeo",
    labelControlLayoutJP = "Japonés",
    labelLRTriggers = "Botones L y R",
    labelUseDPad = "Usar DPad",
    --
    --About section
    prefAppVersion = "Versión de la APP",
    prefCheckUpdate = "Buscar actualizaciones",
    prefShowAuthor = "Autor",
    prefDonatorList = "Lista de donadores",
    prefSupportDev = "Apoya al desarrollador",
    prefTranslators = "Traductores",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Ultima versión : ",
    prefDonatorListDescription = "Lista de personas que apoyan el proyecto",
    --
    --About status labels
    labelUnzippingVPK = "Extrayendo vpk para instalar",
    labelCurrentVersionIs = "La versión actual es:",
    labelSpace = "Memoria usada",
    labelVersionIsUpToDate = "La versión esta al día",
    prefPressAgainToAccept = "Presiona renuevo para aceptar.",
    prefPressAgainToUpdate = "Presiona renuevo para actualizar a:",
    prefPreferredCatalogLanguage = "Idioma preferido:",
    labelOpenInBrowser = "Abrir en navegador",
    labelSetPageAsCover = "Establecer pagina como portada",
    labelResetCover = "Resetear portada",
    labelDownloadImageToMemory = "Descargar imagen",
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
    labelAddToLibrary = "Añadir a la libreria",
    labelRemoveFromLibrary = "Eliminar de la librería",
    labelPage = "Página : ",
    labelContinue = "Continuar",
    labelStart = "Comenzar lectura",
    labelDone = "Сompletado!",
    labelSummary = "Resumen",
    labelShrink = "Encoger",
    labelExpand = "Leer mas",
    --
    --Parser modes
    parserPopular = "Populares",
    parserLatest = "Ultimos",
    parserSearch = "Buscar",
    parserAlphabet = "Alfabeticamente",
    parserByLetter = "Por letra",
    parserByTag = "Por tag",
    --
    --Panel labels
    labelPanelBack = "Volver",
    labelPanelMode = "Modo",
    labelPanelRead = "Leer",
    labelPanelJumpToPage = "Saltar a la pagina",
    labelPanelSearch = "Buscar",
    labelPanelSelect = "Seleccionar",
    labelPanelChoose = "Escoger",
    labelPanelImport = "Import",
    labelPanelChangeSection = "Cambiar sección",
    labelPanelUpdate = "Actualizar",
    labelPanelCancel = "Cancelar",
    labelPanelDelete = "Eliminar",
    labelPanelFollow = "Seguir",
    labelPanelUnfollow = "Dejar de seguir",
    --
    --Import labels
    labelExternalMemory = "Memoria Externa",
    labelDrive = "Drive",
    labelFolder = "Carpeta",
    labelGoBack = "Volver",
    labelFile = "Archivo",
    labelUnsupportedFile = "Archivo no soportado",
    --
    --Buttons labels
    labelDownloadAll = "Descargar todos los capítulos",
    labelRemoveAll = "Eliminar todos los capítulos",
    labelCancelAll = "Cancelar la descarga de los capítulos",
    labelClearBookmarks = "Eliminar marcadores",
    labelOpenMangaInBrowser = "Abrir el manga en el navegador",
    --
    --Reader labels
    labelPreparingPages = "Preparando paginas",
    labelLoadingPage = "Cargando paginas",
    labelLoadingSegment = "Cargando segmentos",
    --
    labelYes = "Si",
    labelNo = "No",
    --Country codes alpha-3
    RUS = "Ruso",
    ENG = "Ingles",
    ESP = "Español",
    PRT = "Portugués",
    FRA = "Francés",
    JAP = "Japonés",
    DIF = "Diferentes",
    TUR = "Turco",
    ITA = "Italiano",
    VIE = "Vietnamita",
    DEU = "Aleman",
    BRA = "Brasileño",
    POL = "Polaco",
    IDN = "Indonesia",
    CHN = "China",
    ROU = "Rumano",
    KOR = "Coreano",
    RAW = "Raw (Cómics sin traducir)",
    --Language translations
    Russian = "Ruso",
    English = "Ingles",
    Turkish = "Turco",
    Spanish = "Español",
    Vietnamese = "Vietnamita",
    French = "Francés",
    Italian = "Italiano",
    PortugueseBR = "Portugués Brasileño",
    SimplifiedChinese = "Chino Simplificado",
    TraditionalChinese = "Chino Tradicional",
    Polish = "Polaco",
    Romanian = "Rumano",
    German = "Almanca",
    Default = "Sistema"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Spanish", "ESP", "SamuEDL", 3)
