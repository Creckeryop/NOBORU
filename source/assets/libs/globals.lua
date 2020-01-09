LUA_APP_NAME = "vsKoob"
LUA_APP_DIR = "app0:"
LUA_APPDATA_DIR = "ux0:data/" .. LUA_APP_NAME .. "/"
LUA_APPIMG_DIR = LUA_APP_DIR .. "assets/images/"
LUA_COLOR_WHITE = Color.new(255, 255, 255, 255)
LUA_COLOR_RED = Color.new(255, 0, 0, 255)
LUA_COLOR_GREEN = Color.new(0, 255, 0, 255)
LUA_COLOR_BLUE = Color.new(0, 0, 255, 255)
LUA_COLOR_PURPLE = Color.new(255, 0, 255, 255)
LUA_COLOR_BLACK = Color.new(0, 0, 0, 255)
LUA_COLOR_SHADOW = Color.new(0, 0, 0, 100)

LUA_FONT = Font.load("app0:roboto.ttf")
LUA_FONT32 = Font.load("app0:roboto.ttf")

Font.setPixelSizes(LUA_FONT32, 32)

MANGA_WIDTH = 200
MANGA_HEIGHT = math.floor(MANGA_WIDTH * 1.5)

GlobalTimer = Timer.new()

if not System.doesDirExist(LUA_APPDATA_DIR) then
    System.createDirectory(LUA_APPDATA_DIR)
end

ReadAllText = function(path)
    local handle = System.openFile(path, FREAD)
    local content = System.readFile(handle, System.sizeFile(handle))
    System.closeFile(handle)
    return content
end

TableReverse = function(table)
    local new_table, j = {}, 1
    for i = #table, 1, -1 do
        new_table[i] = table[j]
        j = j + 1
    end
    return new_table
end
Merge = function(ts)
	local new_t = {}
	for i, t in ipairs(ts) do
		for k, v in pairs(t) do
			if type(v)=="table" then
				new_t[k] = Merge{new_t[k] or {}, v}
			else
				new_t[k] = v
			end
		end
	end
	return new_t
end
local function setmt__gc(t, mt)
    local prox = newproxy(true)
    getmetatable(prox).__gc = function()
        mt.__gc(t)
    end
    t[prox] = true
    return setmetatable(t, mt)
end
Image = {
    __gc = function(self)
        if self.e ~= nil then
            Graphics.freeImage(self.e)
            Console.addLine("Freed!")
        end
    end,
    new = function(self, image)
        if image == nil then
            return nil
        end
        local p = {e = image}
        setmt__gc(p, self)
        self.__index = self
        return p
    end
}

DatabaseExecQuery = function(query)
    local db = Database.open(LUA_APPDATA_DIR..'save.db')
    local result = Database.execQuery(db, query)
    Database.close(db)
    return result
end
DatabaseExecQuery("CREATE TABLE IF NOT EXISTS Library (ParserID int, url varchar(255))")
GetLibrary = function()
    DatabaseExecQuery("INSERT INTO Library (ParserID, url) VALUES (1,'/help_me_im_dying')")
    DatabaseExecQuery("INSERT INTO Library (ParserID, url) VALUES (2,'/help_me_im_dying2')")
    DatabaseExecQuery("INSERT INTO Library (ParserID, url) VALUES (3,'/help_me_im_3dying')")
    DatabaseExecQuery("INSERT INTO Library (ParserID, url) VALUES (1,'/help_me_im_5dying')")
    return Merge{DatabaseExecQuery("SELECT ParserID FROM Library"),DatabaseExecQuery("SELECT url FROM Library")}
end
--collectgarbage( "setpause", 120)
--collectgarbage( "setstepmul", 4500)