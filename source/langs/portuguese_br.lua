--PortugueseBR translation created by @rutantan
local strings = {
    --Tabs
    appLibraryTab = "BIBLIOTECA",
    appCatalogsTab = "CATÁLOGOS",
    appSettingsTab = "CONFIGURAÇÕES",
    appDownloadTab = "DOWNLOADS",
    appImportTab = "IMPORTAR",
    appExtensionsTab = "EXTENSIONS",
    appHistoryTab = "HISTÓRICO",
    labelSearch = "Pesquisar",
    --
    --Message-screen messages
    labelLostConnection = "Conexão foi perdida\n\nEsperando por conexão...\n\n(Minimize a aplicação, vá para as configurações do Wi-Fi e pressione Conectar)\n\nAperte X para cancelar todos os downloads e fechar a mensagem\n\nTodos os downloads vão continuar se a conexão for restaurada",
    labelPressToUpdate = "Aperte X para atualizar\nAperte O para cancelar",
    --
    --Information text
    labelEmptyLibrary = 'Nenhum mangá/HQ.\nPara adicionar mangá/HQ, encontre-os no menu "CATÁLOGOS" e aperte "Adicionar a biblioteca".',
    labelEmptyHistory = "Nenhum mangá/HQ.\nVai aparecer aqui algum dia",
    labelEmptyCatalog = "Nenhum mangá/HQ.\nErro de servidor, conexão ou de analisador",
    labelEmptyDownloads = "Nenhum mangá/HQ sendo baixado",
    labelEmptyParsers = "Nenhum catálogo.\nAperte Triângulo e espere até todos os catálogos serem carregados",
    --
    --Notification information texts
    msgThankYou = "Obrigado por contribuir com esse projeto!",
    msgNoConnection = "Sem conexão",
    msgPleaseWait = "Por favor aguarde",
    msgFailedToUpdate = "Falha ao atualizar o aplicativo",
    msgAddedToLibrary = "Adicionado a biblioteca",
    msgRemovedFromLibrary = "Removido da biblioteca",
    msgSearching = 'Pesquisando "%s"',
    msgStartDownload = "%s: %s\ndownload iniciado!",
    msgEndDownload = "%s: %s\ndownload completado!",
    msgCancelDownload = "%s: %s\ndownload foi cancelado!",
    msgChapterRemove = "%s deletado!",
    msgNetProblem = "Existem problemas com a conexão!",
    msgChaptersCleared = "Todos os capítulos salvos foram apagados!",
    msgLibraryCleared = "Biblioteca foi apagada!",
    msgCacheCleared = "Cache foi limpo!",
    msgDeveloperThing = "Dar uma estrela ao programa no Github!",
    msgNewUpdateAvailable = "Nova atualização disponível",
    msgNoSpaceLeft = "Sem espaço",
    msgRefreshCompleted = "Atualização completada!",
    msgImportCompleted = "Importação completa!",
    msgSettingsReset = "Configurações foram resetadas",
    msgBadImageFound = "Imagem ruim encontrada!",
    msgCoverSetCompleted = "Capa foi atualizada!",
    msgNoChapters = "Sem capítulos",
    --
    --Sections
    prefCategoryLanguage = "Idioma",
    prefCategoryTheme = "Tema",
    prefCategoryLibrary = "Biblioteca",
    prefCategoryCatalogs = "Catálogos",
    prefCategoryReader = "Leitor",
    prefCategoryNetwork = "Rede",
    prefCategoryDataSettings = "Configurações de dados",
    prefCategoryOther = "Outros",
    prefCategoryControls = "Configuração de controle",
    prefCategoryAdvancedChaptersDeletion = "Exclusão avançada de capítulos",
    prefCategoryAbout = "Sobre o programa",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Configurações relacionadas ao rastreamento de mangás",
    prefCategoryCatalogsDescription = "Idioma, conteúdo NSFW",
    prefCategoryReaderDescription = "Direção de leitura, orientação, zoom",
    prefCategoryNetworkDescription = "Tempo de conexão, proxy",
    prefCategoryDataSettingsDescription = "Arquivos salvos, cache, configurações",
    prefCategoryOtherDescription = "Carregamento de fonte, ordenação de caítulos, notificações",
    prefCategoryControlsDescription = "Teclas, mudar botões de página, configurações do analógico",
    prefCategoryAdvancedChaptersDeletionDescription = "Ler, remover",
    prefCategoryAboutDescription = "Versão, atualização",
    --
    --Library section
    prefLibrarySorting = "Ordenação da biblioteca",
    prefCheckChaptersAtStart = "Atualizar biblioteca ao iniciar",
    --
    --Catalogs section
    prefShowNSFW = "Mostrar sites NSFW",
    prefHideInOffline = "Mostrar apenas capítulos baixados no modo offline",
    --
    --Catalogs labels
    labelShowNSFW = "Exibir",
    labelHideNSFW = "Não exibir",
    --
    --Reader section
    prefReaderOrientation = "Orientação padrão do leitor",
    prefReaderScaling = "Escala do leitor",
    prefReaderDirection = "Direção de leitura do manga",
    prefReaderDoubleTap = "Habilitar toque duplo para zoom",
    prefPressEdgesToChangePage = "Mude as páginas apertando as bordas da página",
    prefAnimateGif = "Animar gif (Experimental)",
    --
    --Reader labels
    labelHorizontal = "Horizontal",
    labelVertical = "Vertical",
    labelScalingSmart = "Inteligente",
    labelScalingHeight = "Altura",
    labelScalingWidth = "Largura",
    labelDirectionLeft = "Direita para a esquerda",
    labelDirectionRight = "Esquerda para a direita",
    labelDirectionDown = "Cima para baixo",
    labelDefault = "Padrão",
    --
    --Network section
    prefConnectionTime = "Tempo de conexão com o servidor",
    prefUseProxy = "Usar proxy",
    prefProxyIP = "Endereço IP",
    prefProxyPort = "Porta",
    prefUseProxyAuth = "Usar autenticação de proxy",
    prefProxyAuth = "usuário:senha",
    --
    --Network labels
    labelInputValue = "Insira um valor",
    --
    --Data settings section
    prefSaveDataPath = "Salvar caminho dos dados",
    prefClearLibrary = "Limpar biblioteca",
    prefClearCache = "Limpar cache de mangas não seguidos",
    prefClearAllCache = "Limpar todo cache",
    prefClearChapters = "Limpar todos os capítulos salvos",
    prefResetAllSettings = "Resetar todas as configurações",
    --
    --Other section
    prefSkipFontLoading = "Pular carregamento de fontes",
    prefChapterSorting = "Ordenação dos capítulos",
    prefSilentDownloads = "Não exibir notificações de downloads",
    prefSkipCacheChapterChecking = "Pular verificação de cache e capítulo na tela de carregamento",
    prefShowSummary = "Mostrar sumário do mangá",
    --
    --Control setup section
    prefSwapXO = "Mudar tipo de tecla",
    prefChangePageButtons = "Botões para mudar página",
    prefLeftStickDeadZone = "Zona morta do analógico esquerdo",
    prefLeftStickSensitivity = "Sensibilidade do analógico esquerdo",
    prefRightStickDeadZone = "Zona morta do analógico direito",
    prefRightStickSensitivity = "Sensibilidade do analógico direito",
    --
    --Control setup labels
    labelControlLayoutEU = "Europa",
    labelControlLayoutJP = "Japão",
    labelLRTriggers = "Botões L e R",
    labelUseDPad = "Usando DPad",
    --
    --About section
    prefAppVersion = "Versão do programa",
    prefCheckUpdate = "Verificar por atualizações",
    prefShowAuthor = "Desenvolvedor",
    prefDonatorList = "Lista de doadores",
    prefSupportDev = "Apoie o desenvolvedor",
    prefTranslators = "Agradecimentos aos tradutores",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Última versão : ",
    prefDonatorListDescription = "Lista de contribuidores do projeto",
    --
    --About status labels
    labelUnzippingVPK = "Extraindo vpk para instalar",
    labelCurrentVersionIs = "Versão atual:",
    labelSpace = "Memória usada",
    labelVersionIsUpToDate = "Sua versão está atualizada",
    prefPressAgainToAccept = "Pressione novamente para aceitar",
    prefPressAgainToUpdate = "Pressione novamente para atualizar:",
    prefPreferredCatalogLanguage = "Idioma preferido",
    labelOpenInBrowser = "Abrir no navegador",
    labelSetPageAsCover = "Utilizar página como capa",
    labelResetCover = "Resetar capa",
    labelDownloadImageToMemory = "Baixar imagem",
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
    labelAddToLibrary = "Adicionar a biblioteca",
    labelRemoveFromLibrary = "Remover da biblioteca",
    labelPage = "Página : ",
    labelContinue = "Continuar",
    labelStart = "Começar leitura",
    labelDone = "Completado!",
    labelSummary = "Sumário",
    labelShrink = "Encolher",
    labelExpand = "Ler mais",
    --
    --Parser modes
    parserPopular = "Popular",
    parserLatest = "Últimos",
    parserSearch = "Pesquisar",
    parserAlphabet = "Alfabeto",
    parserByLetter = "Por letra",
    parserByTag = "Por marcador",
    --
    --Panel labels
    labelPanelBack = "Voltar",
    labelPanelMode = "Modo:",
    labelPanelRead = "Ler",
    labelPanelJumpToPage = "Ir para página",
    labelPanelSearch = "Pesquisar",
    labelPanelSelect = "Selecionar",
    labelPanelChoose = "Escolher",
    labelPanelImport = "Importar",
    labelPanelChangeSection = "Mudar seção",
    labelPanelUpdate = "Atualizar",
    labelPanelCancel = "Cancelar",
    labelPanelDelete = "Deletar",
    labelPanelFollow = "Seguir",
    labelPanelUnfollow = "Parar de seguir",
    --
    --Import labels
    labelExternalMemory = "Memória externa",
    labelDrive = "Disco",
    labelFolder = "Pasta",
    labelGoBack = "Voltar",
    labelFile = "Arquivo",
    labelUnsupportedFile = "Arquivo não suportado",
    --
    --Buttons labels
    labelDownloadAll = "Baixar todos os capítulos",
    labelRemoveAll = "Remover todos os capítulos",
    labelCancelAll = "Cancelar download de capítulos",
    labelClearBookmarks = "Limpar marcadores de página",
    labelOpenMangaInBrowser = "Abrir manga no navegador",
    --
    --Reader labels
    labelPreparingPages = "Preparando páginas",
    labelLoadingPage = "Carregando página",
    labelLoadingSegment = "Carregando segmento",
    --
    labelYes = "Sim",
    labelNo = "Não",
    --Country codes alpha-3
    RUS = "Russo",
    ENG = "Inglês",
    ESP = "Espanhol",
    PRT = "Português",
    FRA = "Francês",
    JAP = "Japonês",
    DIF = "Diferente",
    TUR = "Turco",
    ITA = "Italiano",
    VIE = "Vietnamita",
    DEU = "Alemão",
    BRA = "Português-Brasil",
    POL = "Polonês",
    IDN = "Indonésien",
    CHN = "China",
    ROU = "Romeno",
    KOR = "Koreano",
    RAW = "Raw (Quadrinhos não traduzidos)",
    --Language translations
    Russian = "Russo",
    English = "Inglês",
    Turkish = "Turco",
    Spanish = "Espanhol",
    Italian = "Italiano",
    French = "Francês",
    Vietnamese = "Vietnamita",
    PortugueseBR = "Português Brasileiro",
    SimplifiedChinese = "Chinês Simplificado",
    TraditionalChinese = "Chinês Tradicional",
    Romanian = "Romeno",
    Polish = "Polonesa",
    German = "Alemão",
    Default = "Sistema"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "PortugueseBR", "PRT", "@rutantan", 17)
