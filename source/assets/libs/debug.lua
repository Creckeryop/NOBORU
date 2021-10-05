Debug = {}

local status = 0
local maxDebug = 2

local pad, oldPad = 0, 0

function Debug.input()
	oldPad, pad = pad, Controls.read()
	if bit32.bxor(pad, SCE_CTRL_START + SCE_CTRL_LEFT) == 0 and bit32.bxor(oldPad, SCE_CTRL_START + SCE_CTRL_LEFT) ~= 0 then
		status = (status + 1) % maxDebug
	end
end

local sleep = System.wait
function Debug.update()
	sleep(100)
end

local getRAM = System.getFreeRamMemory

function Debug.draw()
	if status == 1 then
		Graphics.fillRect(0, 960, 0, 40, Color.new(0, 0, 0, 128))
		Font.print(FONT16, 0, 0, "TASKS " .. Threads.getNonSkipTasksNum(), COLOR_WHITE)
		Font.print(FONT16, 930, 0, System.getAsyncState(), COLOR_WHITE)
		local netMemoryUsed = "NET: " .. BytesToStr(Threads.getMemoryDownloaded())
		Font.print(FONT16, 720 - Font.getTextWidth(FONT16, netMemoryUsed) / 2, 0, netMemoryUsed, Color.new(0, 255, 0))
		local varMemoryUsed = "VAR: " .. BytesToStr(collectgarbage("count") * 1024)
		Font.print(FONT16, 480 - Font.getTextWidth(FONT16, varMemoryUsed) / 2, 0, varMemoryUsed, Color.new(255, 128, 0))
		local ramMemoryUsed = "FREE_RAM: " .. BytesToStr(getRAM())
		Font.print(FONT16, 480 - Font.getTextWidth(FONT16, ramMemoryUsed) / 2, 20, ramMemoryUsed, Color.new(255, 128, 0))
		local texMemoryUsed = "GPU: " .. BytesToStr(GetGPUMemoryUsed())
		Font.print(FONT16, 240 - Font.getTextWidth(FONT16, texMemoryUsed) / 2, 0, texMemoryUsed, Color.new(0, 0, 255))
		local gpuMemoryFree = "FREE_GPU: " .. BytesToStr(Graphics.getFreeMemory())
		Font.print(FONT16, 240 - Font.getTextWidth(FONT16, gpuMemoryFree) / 2, 20, gpuMemoryFree, Color.new(0, 0, 255))
		Console.draw(1)
	elseif status == 2 then
		Graphics.fillRect(0, 960, 0, 40, Color.new(0, 0, 0, 128))
		local text = "CATALOGS CHECK MODE: Press Select on catalog to check"
		Font.print(FONT16, 480 - Font.getTextWidth(FONT16, text) / 2, 0, text, COLOR_WHITE)
		Console.draw(2)
	end
end

function Debug.getStatus()
	return status
end

function Debug.upgradeDebugMenu()
	maxDebug = 3
end
