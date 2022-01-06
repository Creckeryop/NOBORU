Threads = {}

local IMAGE_CACHE_PATH = "ux0:data/noboru/temp/cache.image"

local orderList = {}
local currentTask = nil

MAX_VRAM_MEMORY = 88 * 1024 * 1024

local trash = {
	Type = nil,
	Garbage = nil
}

local bytes = 0
local uniques = {}

local getAsyncResult = System.getAsyncResult
local closeFile = System.closeFile
local deleteFile = System.deleteFile
local openFile = System.openFile
local sizeFile = System.sizeFile
local doesFileExist = System.doesFileExist
local removeDirectory = RemoveDirectory
local getImageFormat = System.getImageFormat

local function img2bytes(width, height, dScale)
	return bit32.band(width + 7, bit32.bnot(7)) * height * 4 / (dScale * dScale) + 1024
end

local isNetworkInitiated = false

---Updates threads tasks
function Threads.update()
	if isNetworkInitiated and not currentTask and #orderList == 0 then
		Network.term()
		isNetworkInitiated = false
	end
	if not isNetworkInitiated and (#orderList ~= 0 or currentTask) then
		Network.init()
		isNetworkInitiated = true
	end
	if (#orderList == 0 and not currentTask) or System.getAsyncState() == 0 then
		return
	end
	if not currentTask then
		local newOrderList = {}
		for i = 1, #orderList do
			if orderList[i].Type == "Skip" then
				Console.write("NET: Skip", Color.new(255, 255, 0))
			else
				newOrderList[#newOrderList + 1] = orderList[i]
			end
		end
		orderList = newOrderList
		if #orderList == 0 then
			return
		end
		currentTask = table.remove(orderList, 1)
		currentTask.Final = true
		if currentTask.Type == "StringRequest" then
			if currentTask.Link then
				Network.requestStringAsync(currentTask.Link, DEFAULT_USER_AGENT, currentTask.HttpMethod, currentTask.PostData, currentTask.ContentType, currentTask.Cookie, currentTask.Header1, currentTask.Header2, currentTask.Header3, currentTask.Header4, currentTask.Proxy, currentTask.ProxyAuth)
			else
				Console.error("No Link given or internet connection problem")
				uniques[currentTask.UniqueKey] = nil
				currentTask = nil
			end
		elseif currentTask.Type == "FileDownload" or currentTask.Type == "ImageDownload" then
			if doesFileExist(currentTask.Path) then
				deleteFile(currentTask.Path)
			end
			if currentTask.Link then
				if currentTask.Path then
					Network.downloadFileAsync(currentTask.Link, currentTask.Path, DEFAULT_USER_AGENT, currentTask.HttpMethod, currentTask.PostData, currentTask.ContentType, currentTask.Cookie, currentTask.Header1, currentTask.Header2, currentTask.Header3, currentTask.Header4, currentTask.Proxy, currentTask.ProxyAuth)
					if currentTask.Type == "ImageDownload" then
						currentTask.Type = "Image"
						currentTask.Final = false
					end
				else
					Console.error("No Path given")
					uniques[currentTask.UniqueKey] = nil
					currentTask = nil
				end
			else
				Console.error("No Link given or internet connection problem")
				uniques[currentTask.UniqueKey] = nil
				currentTask = nil
			end
		elseif currentTask.Type == "UnZip" then
			if currentTask.DestPath then
				removeDirectory(currentTask.DestPath)
				if currentTask.Path then
					System.extractZipAsync(currentTask.Path, currentTask.DestPath)
				else
					Console.error("No Path given")
					uniques[currentTask.UniqueKey] = nil
					currentTask = nil
				end
			else
				Console.error("No DestPath given")
				uniques[currentTask.UniqueKey] = nil
				currentTask = nil
			end
		elseif currentTask.Type == "UnZipFile" then
			if currentTask.Extract then
				if currentTask.DestPath then
					if currentTask.Path then
						System.extractFromZipAsync(currentTask.Path, currentTask.Extract, currentTask.DestPath)
					else
						Console.error("No Path given")
						uniques[currentTask.UniqueKey] = nil
						currentTask = nil
					end
				else
					Console.error("No DestPath given")
					uniques[currentTask.UniqueKey] = nil
					currentTask = nil
				end
			else
				Console.error("No Extract file path given")
				uniques[currentTask.UniqueKey] = nil
				currentTask = nil
			end
		end
		if currentTask then
			Console.write(string.format("NET: #%s %s", 4 - currentTask.Retry, currentTask.Link or currentTask.Path or currentTask.UniqueKey), Color.new(0, 255, 0))
		end
	else
		Console.write("(" .. currentTask.Type .. ")" .. (currentTask.Link or currentTask.Path or currentTask.UniqueKey), Color.new(0, 255, 0))
		local saveFunction = function()
			trash.Type = currentTask.Type
			trash.Link = currentTask.Link
			if currentTask.Type == "StringRequest" then
				currentTask.Table[currentTask.Index] = getAsyncResult() or ""
				local len = #currentTask.Table[currentTask.Index]
				if len > 0 then
					bytes = bytes + len
					if len < 100 then
						Console.write("NET:" .. currentTask.Table[currentTask.Index])
					end
				end
			elseif currentTask.Type == "Image" then
				if doesFileExist(currentTask.Path) then
					local Width, Height = System.getPictureResolution(currentTask.Path)
					if not Width or Width < 0 then
						currentTask.Type = currentTask.Link and "ImageDownload" or currentTask.Type
						if currentTask.Type == "ImageDownload" then
							error("Retrying to download the file")
						elseif currentTask.Type == "Image" then
							Console.error("Loaded file isn't picture")
							uniques[currentTask.UniqueKey] = nil
							currentTask = nil
							return
						end
					end
					Console.write(Width .. "x" .. Height .. " Image got")
					if img2bytes(Width, Height, 1) > Graphics.getFreeMemory() and Height <= 4096 and Height / Width <= 2 then
						Console.error("No enough memory to load image")
						uniques[currentTask.UniqueKey] = nil
						currentTask = nil
					else
						if Height > 4096 and Height / Width > 2 and not currentTask.MaxHeight then
							if img2bytes(Width, Height, 1) > Graphics.getFreeMemory() then
								if img2bytes(Width, Height, 2) > Graphics.getFreeMemory() then
									Console.error("No enough memory to load image")
									uniques[currentTask.UniqueKey] = nil
									currentTask = nil
								else
									currentTask.Image = {
										Width = Width / 2,
										Height = Height / 2,
										RealWidth = Width,
										RealHeight = Height,
										Parts = math.ceil(Height / 8192)
									}
								end
							else
								currentTask.Image = {
									Width = Width,
									Height = Height,
									RealWidth = Width,
									RealHeight = Height,
									Parts = math.ceil(Height / 4096)
								}
							end
							Console.write(currentTask.Image.Parts)
							currentTask.Type = "ImageLoadTable"
						else
							local scale = 1
							if currentTask.MaxWidth and currentTask.MaxHeight then
								if Width > Height then
									scale = Width / currentTask.MaxWidth
								else
									scale = Height / currentTask.MaxHeight
								end
							elseif currentTask.MaxWidth then
								scale = Width / currentTask.MaxWidth
							elseif currentTask.MaxHeight then
								scale = Height / currentTask.MaxHeight
							end
							if scale <= 1 then
								scale = 1
							elseif scale <= 2 then
								scale = 2
							elseif scale <= 4 then
								scale = 4
							elseif scale <= 8 then
								scale = 8
							elseif scale <= 16 then
								scale = 16
							elseif scale <= 32 then
								scale = 32
							else
								scale = 64
							end
							if scale == 1 and currentTask.Animated and getImageFormat(currentTask.Path) == "gif" then
								Graphics.loadGifAsync(currentTask.Path, scale)
								currentTask.Type = "ImageLoad"
								currentTask.Animated = true
							else
								Graphics.loadImageAsync(currentTask.Path, scale)
								currentTask.Type = "ImageLoad"
								currentTask.Animated = false
							end
						end
					end
				else
					currentTask.Type = currentTask.Link and "ImageDownload" or currentTask.Type
					if currentTask.Type == "ImageDownload" then
						error("(Image)File not found")
					elseif currentTask.Type == "Image" then
						Console.error("(Image)File not found")
						uniques[currentTask.UniqueKey] = nil
						currentTask = nil
						return
					end
				end
				return
			elseif currentTask.Type == "ImageLoad" then
				if doesFileExist(currentTask.Path) then
					if currentTask.Animated then
						local res = getAsyncResult()
						if res ~= nil then
							local gif = Graphics.returnGif(res)
							if gif ~= nil then
								currentTask.Table[currentTask.Index] = {}
								for i = 1, #gif do
									currentTask.Table[currentTask.Index][i] = {
										Image = Image:new(gif[i].image, FILTER_LINEAR),
										Delay = gif[i].delay
									}
								end
								currentTask.Table[currentTask.Index].Height = Graphics.getImageHeight(gif[1].image)
								currentTask.Table[currentTask.Index].Width = Graphics.getImageWidth(gif[1].image)
							end
						end
					else
						currentTask.Table[currentTask.Index] = Image:new(getAsyncResult(), FILTER_LINEAR)
					end
					currentTask.Final = true
				else
					Console.error("(ImageLoad)File not found")
				end
			elseif currentTask.Type == "ImageLoadTable" then
				if not currentTask.Image.i then
					currentTask.Image.i = 0
					currentTask.Table[currentTask.Index] = {}
					currentTask.Table[currentTask.Index].Parts = currentTask.Image.Parts
					currentTask.Table[currentTask.Index].SliceHeight = math.floor(currentTask.Image.Height / currentTask.Image.Parts)
					currentTask.Table[currentTask.Index].Height = currentTask.Image.Height
					currentTask.Table[currentTask.Index].Width = currentTask.Image.Width
					currentTask.Image.free = function(self)
						for i = 1, #self do
							if self[i] and self[i].free then
								self[i]:free()
							end
						end
					end
				elseif currentTask.Image.i < currentTask.Image.Parts then
					currentTask.Image.i = currentTask.Image.i + 1
					if currentTask.Table[currentTask.Index] == trash.Garbage then
						trash.Garbage = Image:new(getAsyncResult())
						trash.Type = "ImageLoadTable2"
						return
					end
					currentTask.Table[currentTask.Index][currentTask.Image.i] = Image:new(getAsyncResult(), FILTER_LINEAR)
					if not currentTask.Table[currentTask.Index][currentTask.Image.i] then
						error("error with part function")
					else
						Console.write(string.format("Got %s image", currentTask.Image.i))
					end
				else
					currentTask.Final = true
					uniques[currentTask.UniqueKey] = nil
					currentTask = nil
					return
				end
				local sliceHeight = math.floor(currentTask.Image.RealHeight / currentTask.Image.Parts)
				local Height = sliceHeight
				if currentTask.Image.i == currentTask.Image.Parts - 1 then
					Height = currentTask.Image.RealHeight - (currentTask.Image.i) * Height
				end
				if currentTask.Image.i < currentTask.Image.Parts then
					Console.write(string.format("Getting %s %sx%s Image", sliceHeight * currentTask.Image.i, currentTask.Image.RealWidth, Height))
					Graphics.loadPartImageAsync(currentTask.Path, 0, sliceHeight * currentTask.Image.i, currentTask.Image.RealWidth, Height)
				else
					uniques[currentTask.UniqueKey] = nil
					currentTask = nil
				end
				return
			elseif currentTask.Type == "FileDownload" then
				if doesFileExist(currentTask.Path) then
					local handle = openFile(currentTask.Path, FREAD)
					bytes = bytes + sizeFile(handle)
					closeFile(handle)
				end
			elseif currentTask.Type == "Skip" then
				Console.error("WOW HOW THAT HAPPENED?")
			end
			uniques[currentTask.UniqueKey] = nil
			currentTask = nil
		end
		local tempTask = currentTask
		local success, err = pcall(saveFunction)
		if success then
			if currentTask == nil then
				if tempTask.OnComplete then
					tempTask.OnComplete()
					Console.write("OnComplete executing for " .. tempTask.Type .. " " .. (tempTask.Link or tempTask.Path or tempTask.UniqueKey))
				end
				if tempTask.Final then
					if tempTask.OnFinalComplete then
						tempTask.OnFinalComplete()
					end
				end
			end
		elseif currentTask ~= nil then
			Console.error("NET: " .. err)
			currentTask.Retry = currentTask.Retry - 1
			if currentTask.Retry > 0 and currentTask.Table ~= trash then
				table.insert(orderList, currentTask)
			else
				uniques[currentTask.UniqueKey] = nil
			end
			currentTask = nil
		end
	end
	if trash.Garbage then
		if trash.Type == "ImageLoad" then
			Console.write("NET:(Freeing Image)", Color.new(255, 0, 255))
			if trash.Garbage and trash.Garbage.free then
				trash.Garbage:free()
			end
		elseif trash.Type == "ImageLoadTable2" then
			Console.write("NET:(Freeing Table Image)", Color.new(255, 0, 255))
			if trash.Garbage and trash.Garbage.free then
				trash.Garbage:free()
			end
		end
		trash.Garbage = nil
	end
end

---Delete all traces
function Threads.clear()
	orderList = {}
	uniques = {}
	if currentTask ~= nil then
		currentTask.Table = trash
		currentTask.Index = "Garbage"
		Network.stopCurrentDownload()
	end
end

---Gives boolean that is any task is running
function Threads.isDownloadRunning()
	return System.getAsyncState() == 0 or #orderList ~= 0 or currentTask ~= nil
end

---You can use Network function in here if you sure that your function is safe
function Threads.netActionUnSafe(foo)
	if not isNetworkInitiated then
		Network.init()
		local result = foo()
		Network.term()
		return result
	else
		return foo()
	end
end

---Add Network function that uses curl in Task and execute it
function Threads.netActionSafe(foo)
	repeat
	until System.getAsyncState() ~= 0
	return Threads.netActionUnSafe(foo)
end

---Checks if given parameters is enough to execute task
local function checkTaskParameters(t)
	local task = t
	if task.Type == "FileDownload" then
		if task.Link and task.Path then
			return true
		end
	else
		return true
	end
	return false
end

---@param uniqueKey any
---@param params table of parameters
---@param foo function
---Adds task to order with given `t` parameters
local function addTaskInOrder(uniqueKey, params, foo)
	if uniqueKey and uniques[uniqueKey] and checkTaskParameters(params) or not uniqueKey then
		return false
	end
	local newTask = {
		Type = params.Type,
		Link = params.Link,
		Table = params.Table,
		Index = params.Index,
		DestPath = params.DestPath,
		Header1 = params.Header1 or "",
		Header2 = params.Header2 or "",
		Header3 = params.Header3 or "",
		Header4 = params.Header4 or "",
		MaxHeight = params.MaxHeight,
		MaxWidth = params.MaxWidth,
		Animated = params.Animated,
		OnComplete = params.OnComplete,
		OnFinalComplete = params.OnFinalComplete,
		Extract = params.Extract,
		Path = params.Path and (params.Path:find("^...?0:") and params.Path or ("ux0:data/noboru/" .. params.Path)) or IMAGE_CACHE_PATH,
		Retry = 3,
		HttpMethod = params.HttpMethod or GET_METHOD,
		PostData = params.PostData or "",
		ContentType = params.ContentType or XWWW,
		Cookie = params.Cookie or "",
		UniqueKey = uniqueKey
	}
	if type(newTask.Link) == "table" then
		local newParams = newTask.Link
		newTask.Link = newParams.Link
		newTask.Header1 = newParams.Header1 or newTask.Header1 or ""
		newTask.Header2 = newParams.Header2 or newTask.Header2 or ""
		newTask.Header3 = newParams.Header3 or newTask.Header3 or ""
		newTask.Header4 = newParams.Header4 or newTask.Header4 or ""
		newTask.HttpMethod = newParams.HttpMethod or newTask.HttpMethod or GET_METHOD
		newTask.PostData = newParams.PostData or newTask.PostData or ""
		newTask.ContentType = newParams.ContentType or newTask.ContentType or XWWW
		newTask.Cookie = newParams.Cookie or newTask.Cookie or ""
	end
	if type(newTask.Link) == "string" then
		newTask.Link = newTask.Link:match("^(.-)%s*$") or ""
		newTask.Link = newTask.Link:gsub("([^%%])%%([^%%])", "%1%%%%%2"):gsub(" ", "%%%%20"):gsub("([^%%])%%$", "%1%%%%"):gsub("^%%([^%%])", "%%%%%1")
	end
	newTask.Proxy = Settings.UseProxy and (Settings.ProxyIP .. ":" .. Settings.ProxyPort) or ""
	newTask.ProxyAuth = Settings.UseProxyAuth and Settings.ProxyAuth or ""
	foo(newTask)
	uniques[uniqueKey] = newTask
	return true
end

local function insertTask(task)
	table.insert(orderList, 1, task)
end

---@param uniqueKey string
---@param t table
---@return boolean
---Inserts task to threads
function Threads.insertTask(uniqueKey, t)
	return addTaskInOrder(uniqueKey, t, insertTask)
end

local function addTask(task)
	orderList[#orderList + 1] = task
end

---@param uniqueKey string
---@param t table
---@return boolean
---Adds task to threads
function Threads.addTask(uniqueKey, t)
	return addTaskInOrder(uniqueKey, t, addTask)
end

---Terminates Threads functions and net features
function Threads.terminate()
	if isNetworkInitiated then
		Threads.clear()
		while currentTask do
			Threads.update()
		end
		Network.term()
		isNetworkInitiated = false
	end
end

function Threads.getProgress(uniqueKey)
	local task = uniques[uniqueKey]
	if task then
		if currentTask == task then
			if task.Type == "ImageDownload" or task.Type == "StringRequest" or task.Type == "FileDownload" or (task.Type == "Image" and task.Link) then
				return math.max(math.min(1, Network.getDownloadedBytes() / Network.getTotalBytes()), 0)
			else
				return 1
			end
		else
			return 0
		end
	end
	return 0
end

---@param uniqueKey string
---Removes task by given `UniqueKey`
function Threads.removeTask(uniqueKey)
	if uniques[uniqueKey] then
		if currentTask == uniques[uniqueKey] then
			currentTask.Table, currentTask.Index = trash, "Garbage"
			Network.stopCurrentDownload()
		else
			uniques[uniqueKey].Type = "Skip"
		end
		uniques[uniqueKey] = nil
	end
end

---@param uniqueKey string
---Checks if task is in order by `UniqueKey`
function Threads.check(uniqueKey)
	return uniques[uniqueKey] ~= nil
end

---@return number
---Returns count of bytes downloaded by Threads functions
function Threads.getMemoryDownloaded()
	return bytes
end

---@return integer
---Returns count of all tasks
function Threads.getCountOfTasks()
	return #orderList + (currentTask and 1 or 0)
end

---@return integer
---Returns count of not skipped tasks
function Threads.getCountOfActiveTasks()
	local counter = 0
	for i = 1, #orderList do
		if orderList[i].Type ~= "Skip" then
			counter = counter + 1
		end
	end
	return counter + (currentTask and currentTask.Type ~= "Skip" and 1 or 0)
end
