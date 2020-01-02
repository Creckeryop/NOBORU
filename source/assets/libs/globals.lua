LUA_APP_NAME    = 'vsKoob'
LUA_APP_DIR     = 'app0:'
LUA_APPDATA_DIR = 'ux0:data/'..LUA_APP_NAME..'/'
LUA_APPIMG_DIR = LUA_APP_DIR..'assets/images/'
LUA_COLOR_WHITE = Color.new (255, 255, 255, 255)
LUA_COLOR_RED   = Color.new (255,   0,   0, 255)
LUA_COLOR_GREEN = Color.new (  0, 255,   0, 255)
LUA_COLOR_BLUE  = Color.new (  0,   0, 255, 255)
LUA_COLOR_PURPLE= Color.new (255,   0, 255, 255)

LUA_FONT = Font.load("app0:roboto.ttf")
LUA_FONT32 = Font.load("app0:roboto.ttf")

Font.setPixelSizes(LUA_FONT32,32)

MANGA_WIDTH = 200
MANGA_HEIGHT = math.floor(MANGA_WIDTH * 1.5)

GlobalTimer = Timer.new()

if not System.doesDirExist(LUA_APPDATA_DIR) then
    System.createDirectory(LUA_APPDATA_DIR)
end

ReadAllText = function (path)
    local handle = System.openFile (path, FREAD)
    local content = System.readFile (handle, System.sizeFile (handle))
    System.closeFile (handle)
    return content
end

TableReverse = function (table)
    local new_table, j = {}, 1
    for i = #table, 1, -1 do
        new_table[i] = table[j]
        j = j + 1
    end
    return new_table
end