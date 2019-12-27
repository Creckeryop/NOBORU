dofile 'app0:assets/libs/net.lua'
local DEBUG_INFO = true
local pad = Controls.read()
local oldpad = pad
local delta = 1
local function draw()
    Graphics.initBlend()
    Screen.clear()
    if DEBUG_INFO then
        Graphics.debugPrint(0, 0, "FPS: "..(60 / delta), Color.new(255,255,255,255))
    end
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end
local function update(delta)
    
end
local function input()
    if Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldpad, SCE_CTRL_RTRIGGER) then
        DEBUG_INFO = not DEBUG_INFO
    end
    if Controls.check(pad, SCE_CTRL_START) then
        System.exit()
    end
end
while true do
    local timer = Timer.new()
    pad = Controls.read()
    input()
    update(delta)
    draw()
    oldpad = pad
    delta = Timer.getTime(timer) / 1000 * 60
    Timer.destroy(timer)
end