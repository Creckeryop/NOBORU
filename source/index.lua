dofile 'assets/libs/net.lua'
local pad = Controls.read()
local oldpad = pad
local function draw()
    Graphics.initBlend()
    Screen.clear()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVBlankStart()
end
local function update(delta)
    
end
local function input()
    if Controls.check(pad, SCE_CTRL_START) then
        System.exit()
    end
end
while true do
    pad = Controls.read()
    input()
    update()
    draw()
    oldpad = pad
end