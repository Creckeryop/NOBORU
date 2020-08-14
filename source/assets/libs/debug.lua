Debug = {}

local DEBUG_MODE = 0

local pad, oldpad = 0
function Debug.input()
    oldpad, pad = pad, Controls.read()
    if bit32.bxor(pad, SCE_CTRL_START + SCE_CTRL_LEFT) == 0 and bit32.bxor(oldpad, SCE_CTRL_START + SCE_CTRL_LEFT) ~= 0 then
        DEBUG_MODE = (DEBUG_MODE + 1) % 3
    end
end

local wait = System.wait
function Debug.update()
    wait(100)
end

function Debug.draw()
    if DEBUG_MODE == 1 then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        Font.print(FONT16, 0, 0, "TASKS " .. Threads.getNonSkipTasksNum(), COLOR_WHITE)
        Font.print(FONT16, 930, 0, System.getAsyncState(), COLOR_WHITE)
        local mem_net = "NET: " .. MemToStr(Threads.getMemoryDownloaded())
        Font.print(FONT16, 720 - Font.getTextWidth(FONT16, mem_net) / 2, 0, mem_net, Color.new(0, 255, 0))
        local mem_var = "VAR: " .. MemToStr(collectgarbage("count") * 1024)
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, mem_var) / 2, 0, mem_var, Color.new(255, 128, 0))
        local mem_gpu = "GPU: " .. MemToStr(GetTextureMemoryUsed())
        Font.print(FONT16, 240 - Font.getTextWidth(FONT16, mem_gpu) / 2, 0, mem_gpu, Color.new(0, 0, 255))
        Console.draw(1)
    elseif DEBUG_MODE == 2 then
        Graphics.fillRect(0, 960, 0, 20, Color.new(0, 0, 0, 128))
        local text = "CATALOGS CHECK MODE: Press Select on catalog to check"
        Font.print(FONT16, 480 - Font.getTextWidth(FONT16, text) / 2, 0, text, COLOR_WHITE)
        Console.draw(2)
    end
end

function Debug.getMode()
    return DEBUG_MODE
end
