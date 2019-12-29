DEBUG_INFO = true
dofile 'app0:assets/libs/globals.lua'
dofile 'app0:assets/libs/console.lua'
dofile 'app0:assets/libs/net.lua'
local pad = Controls.read ()
local oldpad = pad
local delta = 1
Network.init ()
Photos = {}
Net.downloadImageAsync('https://cs7.pikabu.ru/post_img/big/2018/09/11/0/1536615685128564974.png', Photos, 1)
Net.downloadImageAsync('https://avatanplus.com/files/resources/mid/5ba90158746581660c2d419d.png', Photos, 2)
local function draw ()
    Graphics.initBlend ()
    Screen.clear ()
    if DEBUG_INFO then
        for i = 1, 2 do
            if Photos[i]~=nil then
                Graphics.drawScaleImage ((i-1)*100, 0, Photos[i], 0.25, 0.25)
            end
        end
        Graphics.debugPrint (0, 0, "FPS: ".. (60 / delta), LUA_COLOR_WHITE)
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