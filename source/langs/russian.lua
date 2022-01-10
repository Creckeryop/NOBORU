--
local strings = {
    --Tabs
    appLibraryTab = "БИБЛИОТЕКА",
    appCatalogsTab = "КАТАЛОГИ",
    appSettingsTab = "НАСТРОЙКИ",
    appDownloadTab = "ЗАГРУЗКИ",
    appImportTab = "ИМПОРТ",
    appExtensionsTab = "РАСШИРЕНИЯ",
    appHistoryTab = "ИСТОРИЯ",
    labelSearch = "Поиск",
    --
    --Message-screen messages
    labelLostConnection = "Соединение потеряно\n\nОжидание подключения...\n\n(Сверните приложение, Зайдите в настройки соединения, нажмите Присоединиться)\n\nНажмите X для отмены всех загрузок и закрытия сообщения\n\nВсе загрузки продолжаться, если соединение восстановится",
    labelPressToUpdate = "Нажмите X для обновления\nНажмите O для отмены",
    --
    --Information text
    labelEmptyLibrary = 'Нет манги/комиксов.\nЧтобы добавить мангу/комикс, найдите в меню "КАТАЛОГИ".\nЗатем нажмите "Добавить в библиотеку".',
    labelEmptyHistory = "Нет манги/комиксов.\nКогда нибудь они здесь появятся",
    labelEmptyCatalog = "Нет манги/комиксов.\nОшибка сервера, соединения либо парсера",
    labelEmptyDownloads = "Нет скачиваемых манги/комиксов",
    labelEmptyParsers = "Нет каталогов.\nНажмите Треугольник и дождитесь загрузки всех каталогов",
    --
    --Notification information texts
    msgThankYou = "Спасибо за поддержку этого проекта!",
    msgNoConnection = "Нет соединения",
    msgPleaseWait = "Пожалуйста, подождите",
    msgFailedToUpdate = "Не получилось обновить приложение",
    msgAddedToLibrary = "Добавлено в библиотеку",
    msgRemovedFromLibrary = "Удалено из библиотеки",
    msgSearching = 'Поиск "%s"',
    msgStartDownload = "%s: %s\nзагрузка началась!",
    msgEndDownload = "%s: %s\nзагрузка завершена!",
    msgCancelDownload = "%s: %s\nзагрузка прервана!",
    msgChapterRemove = 'Кэш-глава "%s" удалена!',
    msgNetProblem = "Возникли проблемы с интернетом!",
    msgChaptersCleared = "Сохраненные главы удалены!",
    msgLibraryCleared = "Библиотека очищена!",
    msgCacheCleared = "Кэш очищен!",
    msgDeveloperThing = "Поставь звезду на Github!",
    msgNewUpdateAvailable = "Доступно новое обновление",
    msgNoSpaceLeft = "Недостаточно места",
    msgRefreshCompleted = "Обновление выполнено!",
    msgImportCompleted = "Импорт завершен!",
    msgSettingsReset = "Настройки были сброшены",
    msgBadImageFound = "Обнаружено недопустимое изображение!",
    msgCoverSetCompleted = "Обложка обновлена!",
    msgNoChapters = "Главы не найдены",
    --
    --Sections
    prefCategoryLanguage = "Язык",
    prefCategoryTheme = "Тема",
    prefCategoryLibrary = "Библиотека",
    prefCategoryCatalogs = "Каталоги",
    prefCategoryReader = "Читалка",
    prefCategoryNetwork = "Интернет",
    prefCategoryDataSettings = "Данные",
    prefCategoryOther = "Другое",
    prefCategoryControls = "Параметры клавиш",
    prefCategoryAdvancedChaptersDeletion = "Расширенное удаление глав",
    prefCategoryAbout = "О программе",
    --
    --Sections descriptions
    prefCategoryLibraryDescription = "Настройки связанные с отслеживанием манги",
    prefCategoryCatalogsDescription = "Язык, NSFW контент",
    prefCategoryReaderDescription = "Направление чтения, ориентация, масштаб",
    prefCategoryNetworkDescription = "Время отклика сервера, прокси",
    prefCategoryDataSettingsDescription = "Сохранения, кэш, настройки",
    prefCategoryOtherDescription = "Загрузка шрифтов, сортировки глав, уведомления",
    prefCategoryControlsDescription = "Настройки раскладки, кнопки смены страниц, настройка стиков",
    prefCategoryAdvancedChaptersDeletionDescription = "Чтение, удаление",
    prefCategoryAboutDescription = "Версия, обновление",
    --
    --Library section
    prefLibrarySorting = "Сортировка библиотеки",
    prefCheckChaptersAtStart = "Обновлять библиотеку при запуске",
    --
    --Catalogs section
    prefShowNSFW = "Показывать контент для взрослых",
    prefHideInOffline = "Показывать только загруженные главы в офлайне",
    --
    --Catalogs labels
    labelShowNSFW = "Показывать",
    labelHideNSFW = "Не показывать",
    --
    --Reader section
    prefReaderOrientation = "Ориентация читалки по умолчанию",
    prefReaderScaling = "Масштабирование страниц манги",
    prefReaderDirection = "Направление чтения манги",
    prefReaderDoubleTap = "Включить двойное нажатие для приближения",
    prefPressEdgesToChangePage = "Смена страниц по нажатию на грани страницы",
    prefAnimateGif = "Анимировать Гифки (Экспериментально)",
    --
    --Reader labels
    labelHorizontal = "Горизонтальная",
    labelVertical = "Вертикальная",
    labelScalingSmart = "Умное",
    labelScalingHeight = "По высоте",
    labelScalingWidth = "По ширине",
    labelDirectionLeft = "Справа налево",
    labelDirectionRight = "Слева направо",
    labelDirectionDown = "Сверху вниз",
    labelDefault = "По умолчанию",
    --
    --Network section
    prefConnectionTime = "Время подсоединения к серверу",
    prefUseProxy = "Использовать прокси",
    prefProxyIP = "IP адрес прокси",
    prefProxyPort = "Порт",
    prefUseProxyAuth = "Аутентификация прокси",
    prefProxyAuth = "логин:пароль",
    --
    --Network labels
    labelInputValue = "Введите значение",
    --
    --Data settings section
    prefSaveDataPath = "Место сохранения данных",
    prefClearLibrary = "Очистить библиотеку",
    prefClearCache = "Очистить кэш для неотслеживаемых манг",
    prefClearAllCache = "Очистить ВЕСЬ кэш",
    prefClearChapters = "Очистить все сохраненные главы",
    prefResetAllSettings = "Сбросить все настройки",
    --
    --Other section
    prefSkipFontLoading = "Пропускать загрузку шрифтов",
    prefChapterSorting = "Сортировка глав",
    prefSilentDownloads = "Не показывать уведомления связанные с загрузкой",
    prefSkipCacheChapterChecking = "Пропускать проверки целостности кеша при запуске приложения",
    prefShowSummary = "Загружать краткое описание манги",
    --
    --Control setup section
    prefSwapXO = "Сменить раскладку",
    prefChangePageButtons = "Кнопки для смены страницы",
    prefLeftStickDeadZone = "Мёртвая зона левого джойстика",
    prefLeftStickSensitivity = "Чувствительность левого джойстика",
    prefRightStickDeadZone = "Мёртвая зона правого джойстика",
    prefRightStickSensitivity = "Чувствительность правого джойстика",
    --
    --Control setup labels
    labelControlLayoutEU = "Европейская",
    labelControlLayoutJP = "Японская",
    labelLRTriggers = "L и R триггеры",
    labelUseDPad = "Используя крестовину",
    --
    --About section
    prefAppVersion = "Версия",
    prefCheckUpdate = "Проверить на обновления",
    prefShowAuthor = "Разработчик",
    prefDonatorList = "Поддержавшие проект",
    prefSupportDev = "Поддержать разработчика",
    prefTranslators = "Спасибо переводчикам",
    --
    --About section descriptions
    prefCheckUpdateLatestVersion = "Последняя версия : ",
    prefDonatorListDescription = "Список поддержавших проект",
    --
    --About status labels
    labelUnzippingVPK = "Извлечение установочного файла",
    labelCurrentVersionIs = "Текущая версия:",
    labelSpace = "Памяти занято",
    labelVersionIsUpToDate = "У вас уже стоит последняя версия",
    prefPressAgainToAccept = "Нажмите ещё раз, чтобы подтвердить",
    prefPressAgainToUpdate = "Нажмите ещё раз, чтобы обновиться до:",
    prefPreferredCatalogLanguage = "Предпочитаемый язык",
    labelOpenInBrowser = "Открыть в браузере",
    labelSetPageAsCover = "Установить в качестве обложки манги",
    labelResetCover = "Сбросить обложку",
    labelDownloadImageToMemory = "Сохранить в память",
    --
    --Extension tab labels
    labelNewVersionAvailable = "Доступна новая версия",
    labelNotSupported = "Каталог не поддерживается",
    labelInstalled = "Установлен",
    labelNotInstalled = "Не установлен",
    labelCurrentVersion = "Текущая версия",
    labelLatestVersion = "Последняя версия",
    labelInstall = "Установить",
    labelUpdate = "Обновить",
    labelRemove = "Удалить",
    labelLatestChanges = "Последние изменения",
    labelDownloading = "Загрузка...",
    labelLanguages = "Языки",
    --
    --Book info labels
    labelAddToLibrary = "Добавить в библиотеку",
    labelRemoveFromLibrary = "Удалить из библиотеки",
    labelPage = "Страница : ",
    labelContinue = "Продолжить",
    labelStart = "Начать чтение",
    labelDone = "Прочитано!",
    labelSummary = "Описание",
    labelShrink = "Скрыть",
    labelExpand = "Раскрыть",
    --
    --Parser modes
    parserPopular = "Популярная",
    parserLatest = "Последняя",
    parserSearch = "Поиск",
    parserAlphabet = "Алфавит",
    parserByLetter = "По букве",
    parserByTag = "По тегу",
    --
    --Panel labels
    labelPanelBack = "Назад",
    labelPanelMode = "Режим",
    labelPanelRead = "Читать",
    labelPanelJumpToPage = "Страница",
    labelPanelSearch = "Поиск",
    labelPanelSelect = "Выбрать",
    labelPanelChoose = "Сменить выделение",
    labelPanelImport = "Импортировать",
    labelPanelChangeSection = "Сменить меню",
    labelPanelUpdate = "Обновить",
    labelPanelCancel = "Отменить",
    labelPanelDelete = "Удалить",
    labelPanelFollow = "Отслеживать",
    labelPanelUnfollow = "Не отслеживать",
    --
    --Import labels
    labelExternalMemory = "Внешняя Память",
    labelDrive = "Раздел",
    labelFolder = "Папка",
    labelGoBack = "Вернуться",
    labelFile = "Файл",
    labelUnsupportedFile = "Неподдерживаемый файл",
    --
    --Buttons labels
    labelDownloadAll = "Скачать все главы",
    labelRemoveAll = "Удалить все главы",
    labelCancelAll = "Отменить загрузку глав",
    labelClearBookmarks = "Очистить закладки",
    labelOpenMangaInBrowser = "Открыть мангу в браузере",
    --
    --Reader labels
    labelPreparingPages = "Подготовка страниц",
    labelLoadingPage = "Загрузка страницы",
    labelLoadingSegment = "Загрузка сегмента страницы",
    --
    labelYes = "Да",
    labelNo = "Нет",
    --Country codes alpha-3
    RUS = "Русский",
    ENG = "Английский",
    ESP = "Испанский",
    PRT = "Португальский",
    FRA = "Французский",
    JAP = "Японский",
    DIF = "Разные",
    TUR = "Турецкий",
    ITA = "Итальянский",
    VIE = "Вьетнамский",
    DEU = "Немецкий",
    BRA = "Бразильский",
    POL = "Польский",
    IDN = "Индонезийский",
    CHN = "Китайский",
    ROU = "Румынский",
    KOR = "Корейский",
    RAW = "Оригинал (Непереведенные комиксы)",
    --Language translations
    Russian = "Русский",
    English = "Английский",
    Turkish = "Турецкий",
    Spanish = "Испанский",
    Vietnamese = "Вьетнамский",
    French = "Французский",
    Italian = "Итальянский",
    PortugueseBR = "Бразильский португальский",
    SimplifiedChinese = "Упрощенный китайский",
    TraditionalChinese = "Традиционный китайский",
    Romanian = "Румынский",
    Polish = "Польский",
    German = "Немецкий",
    Default = "Системный"
}

--Registering language
--Table of strings, Language name on english (oneWord), Language Letter Code, Author name, Language digit Code from site or nil
--langCode is in "number" column in this table https://playstationdev.wiki/psvitadevwiki/index.php/Languages
Language.registerStrings(strings, "Russian", "RUS", "creckeryop", 8)
