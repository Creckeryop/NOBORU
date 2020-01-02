DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
dofile 'app0:assets/libs/parser.lua'
dofile 'app0:assets/libs/manga.lua'
dofile 'app0:assets/libs/reader.lua'
dofile 'app0:assets/libs/parsermanager.lua'
dofile 'app0:assets/libs/string.lua'
dofile 'app0:assets/libs/browser.lua'
ParserManager.updateParserList()
while #ParserManager.getParserList()==0 do
    Net.update ()
    ParserManager.update ()
end
ParserManager.setParser(ParserManager.getParserList()[1])
Browser.setPage(1)
BROWSING_MODE = 1
READING_MODE  = 2
MODE          = BROWSING_MODE
local pad = Controls.read ()
local oldpad = pad
local delta = 1

local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    if MODE == BROWSING_MODE then
        Browser.draw ()
    elseif MODE == READING_MODE then
        Reader.draw ()
    end
    if DEBUG_INFO then
        Graphics.fillRect(0, 960, 0, 20,Color.new(0,0,0,100))
        Graphics.debugPrint (0, 0, 'FPS: '..math.floor (60 / delta), LUA_COLOR_WHITE)
        Console.draw ()
    end
    Graphics.termBlend ()
    Screen.flip ()
    Screen.waitVblankStart ()
end
local function update (delta)
    if MODE == BROWSING_MODE then
        Browser.update ()
    elseif MODE == READING_MODE then
        Reader.update ()
    end
end
local function input ()
    if MODE == BROWSING_MODE then
        
    elseif MODE == READING_MODE then
        Reader.input (pad, oldpad)
    end
    if Controls.check (pad, SCE_CTRL_SQUARE) and not Controls.check (oldpad, SCE_CTRL_SQUARE) then
        DEBUG_INFO = not DEBUG_INFO
    end
    if Controls.check (pad, SCE_CTRL_START) then
        Net.shutDown ()
        System.exit ()
    end
end
Touch = {}
OldTouch = {}
Touch2 = {}
OldTouch2 = {}
while true do
    local timer = Timer.new ()
    oldpad, pad = pad, Controls.read ()
    OldTouch.x, OldTouch.y,OldTouch2.x,OldTouch2.y, Touch.x, Touch.y,Touch2.x, Touch2.y = Touch.x, Touch.y,Touch2.x, Touch2.y, Controls.readTouch ()
    input ()
    update (delta)
    draw ()
    Net.update ()
    ParserManager.update ()
    delta = Timer.getTime (timer) / 1000 * 60
    Timer.destroy (timer)
end