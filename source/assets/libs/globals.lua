LUA_APP_NAME = 'vsKoob'
LUA_APP_DIR = 'app0:'
LUA_APPDATA_DIR = 'ux0:data/'..LUA_APP_NAME..'/'
LUA_COLOR_WHITE = Color.new (255, 255, 255, 255)

if not System.doesDirExist(LUA_APPDATA_DIR) then
    System.createDirectory(LUA_APPDATA_DIR)
end