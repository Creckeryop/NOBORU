DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
dofile 'app0:assets/libs/parser.lua'
dofile 'app0:assets/libs/manga.lua'
local pad = Controls.read ()
local oldpad = pad
local delta = 1
Network.init ()
Mangas = Parser:getManga(0)
for i = 1, #Mangas do
    Net.downloadImageAsync(Mangas[i].img_link, Mangas[i], "image")
end
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    for i = 1, #Mangas do
        if not (Mangas[i].image == nil) then
            Graphics.drawImage(0+i*30,0,Mangas[i].image)
        end
    end
    if DEBUG_INFO then
        Graphics.debugPrint (0, 0, 'FPS: '.. (60 / delta), LUA_COLOR_WHITE)
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