DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
dofile 'app0:assets/libs/parser.lua'
dofile 'app0:assets/libs/manga.lua'
Network.init ()
Net.downloadFile ('https://raw.githubusercontent.com/Creckeryop/vsKoob-parsers/master/parsers.lua', LUA_APPDATA_DIR..'parsers.lua')
dofile (LUA_APPDATA_DIR..'parsers.lua')
count = Parsers[2]:getPagesCount(Parsers[2]:getChapters(Parsers[2]:getManga(0)[1])[1])
Console.addLine(count)
local pad = Controls.read ()
local oldpad = pad
local delta = 1
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    if DEBUG_INFO then
        Graphics.debugPrint (0, 0, 'FPS: '..math.floor (60 / delta), LUA_COLOR_WHITE)
        Console.draw ()
    end
    Graphics.termBlend ()
    Screen.flip ()
    Screen.waitVblankStart ()
end
local function update (delta)

end
local function input ()
    if Controls.check (pad, SCE_CTRL_RTRIGGER) and not Controls.check (oldpad, SCE_CTRL_RTRIGGER) then
        DEBUG_INFO = not DEBUG_INFO
    end
    if Controls.check (pad, SCE_CTRL_START) then
        Network.term ()
        System.exit ()
    end
end
while true do
    local timer = Timer.new ()
    pad = Controls.read ()
    input ()
    update (delta)
    draw ()
    Net.update ()
    oldpad = pad
    delta = Timer.getTime (timer) / 1000 * 60
    Timer.destroy (timer)
end