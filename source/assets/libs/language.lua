Language = {
    Russian = {
        APP = {
            LIBRARY = "БИБЛИОТЕКА",
            CATALOGS = "КАТАЛОГИ",
            SETTINGS = "НАСТРОЙКИ",
            DOWNLOAD = "ЗАГРУЗКИ",
            SEARCH = "Поиск"
        },
        SETTINGS = {
            Language = "Язык",
            ClearChapters = "Очистить сохраненные главы",
            ShowNSFW = "Показывать пр0н парсеры",
            ClearLibrary = "Очистить библиотеку",
            ReaderOrientation = "Ориентация читалки по умолчанию",
            ZoomReader = "Масштабирование читалки",
            Space = "Памяти занято",
            PressAgainToAccept = "Нажмите ещё раз чтобы подтвердить"
        },
        NSFW = {
            [true] = "Показывать",
            [false] = "Не показывать"
        },
        PARSERS = {
            RUS = "Русский",
            ENG = "Английский",
            DIF = "Разные"
        },
        WARNINGS = {
            NO_CHAPTERS = "Нет глав"
        },
        READER = {
            PREPARING_PAGES = "Подготовка страниц",
            LOADING_PAGE = "Загрузка страницы",
            LOADING_SEGMENT = "Загрузка сегмента страницы",
            Horizontal = "Горизонтальная",
            Vertical = "Вертикальная",
            Smart = "Умное",
            Height = "По высоте",
            Width = "По ширине"
        },
        DETAILS = {
            ADD_TO_LIBRARY = "Добавить в библиотеку",
            REMOVE_FROM_LIBRARY = "Удалить из библиотеки"
        },
        NOTIFICATIONS = {
            ADDED_TO_LIBRARY = "Добавлено в библиотеку",
            REMOVED_FROM_LIBRARY = "Удалено из библиотеки",
            SEARCHING = 'Поиск "%s"',
            START_DOWNLOAD = "%s: %s\nзагрузка началась!",
            END_DOWNLOAD = "%s: %s\nзагрузка завершена!",
            CANCEL_DOWNLOAD = "%s: %s\nзагрузка прервана!",
            CHAPTER_REMOVE = "%s удалено!",
            NET_PROBLEM = "Возникли проблемы с интернетом!",
            CHAPTERS_CLEARED = "Сохраненые главы удалены!",
            LIBRARY_CLEARED = "Библиотека очищена!"
        },
        PANEL = {
            BACK = "Назад",
            MODE_POPULAR = "Режим: Популярность",
            MODE_LATEST = "Режим: Недавнее",
            MODE_SEARCHING = 'Режим: Поиск "%s"',
            SEARCH = "Поиск",
            SELECT = "Выбрать",
            CHOOSE = "Сменить выделенное",
            CHANGE_SECTION = "Сменить меню",
            UPDATE = "Обновить",
            CANCEL = "Отменить"
        }
    },
    English = {
        APP = {
            LIBRARY = "LIBRARY",
            CATALOGS = "CATALOGS",
            SETTINGS = "SETTINGS",
            DOWNLOAD = "DOWNLOADS",
            SEARCH = "Search"
        },
        SETTINGS = {
            Language = "Language",
            ClearChapters = "Clear saved chapters",
            ShowNSFW = "Show NSFW parsers",
            ClearLibrary = "Clear library",
            ReaderOrientation = "Standart reader orientation",
            ZoomReader = "Reader scaling",
            Space = "Memory used",
            PressAgainToAccept = "Press again to accept"
        },
        NSFW = {
            [true] = "Show",
            [false] = "Don't show"
        },
        PARSERS = {
            RUS = "Russian",
            ENG = "English",
            DIF = "Different"
        },
        WARNINGS = {
            NO_CHAPTERS = "No chapters"
        },
        READER = {
            PREPARING_PAGES = "Preparing pages",
            LOADING_PAGE = "Loading page",
            LOADING_SEGMENT = "Loading segment",
            Horizontal = "Horizontal",
            Vertical = "Vertical",
            Smart = "Smart",
            Height = "Height",
            Width = "Width"
        },
        DETAILS = {
            ADD_TO_LIBRARY = "Add to library",
            REMOVE_FROM_LIBRARY = "Remove from library"
        },
        NOTIFICATIONS = {
            ADDED_TO_LIBRARY = "Added to library",
            REMOVED_FROM_LIBRARY = "Removed from library",
            SEARCHING = 'Searching "%s"',
            START_DOWNLOAD = "%s: %s\ndownloading started!",
            END_DOWNLOAD = "%s: %s\nsuccessfuly downloaded!",
            CANCEL_DOWNLOAD = "%s: %s\ndownload is canceled!",
            CHAPTER_REMOVE = "%s deleted!",
            NET_PROBLEM = "There is problems with connection!",
            CHAPTERS_CLEARED = "All saved chapters are cleared!",
            LIBRARY_CLEARED = "Library cleared!"
        },
        PANEL = {
            BACK = "Back",
            MODE_POPULAR = "Mode: Popular",
            MODE_LATEST = "Mode: Latest",
            MODE_SEARCHING = 'Mode: Searching "%s"',
            SEARCH = "Search",
            SELECT = "Select",
            CHOOSE = "Choose",
            CHANGE_SECTION = "Change section",
            UPDATE = "Update",
            CANCEL = "Cancel"
        }
    }
}
LanguageNames = {
    Russian = {
        Russian = "Русский",
        English = "Английский",
        Default = "Системный"
    },
    English = {
        Russian = "Russian",
        English = "English",
        Default = "System"
    }
}
local language_now = System.getLanguage()
if language_now == 8 then
    Language.Default = Language.Russian
    LanguageNames.Default = LanguageNames.Russian
else
    Language.Default = Language.English
    LanguageNames.Default = LanguageNames.English
end