--[[
ParserManager is a pack of functions needed to work with
async functions related to parsers, it will help you to
get all available info from parsers, from manga List to
List of links to images of their chapter pages
]]
ParserManager = {}

local order = {}

local currentTask = nil
local trash = {}
local uniques = {}

local doesFileExist = System.doesFileExist

---Updates ParserManager functions
function ParserManager.update()
	if #order == 0 and not currentTask then
		return
	end
	if not currentTask then
		currentTask = table.remove(order, 1)
		if currentTask.Type == "Skip" then
			currentTask = nil
		else
			currentTask.Update = coroutine.create(currentTask.F)
		end
	else
		if coroutine.status(currentTask.Update) == "dead" then
			if currentTask.Type ~= "UpdateParsers" and currentTask.Type ~= "UpdateCounters" then
				currentTask.Table.Done = true
			end
			uniques[currentTask.Table] = nil
			currentTask = nil
		else
			local _, isSafeToleave = coroutine.resume(currentTask.Update)
			if currentTask.Stop then
				Network.stopCurrentDownload()
				uniques[currentTask.Table] = nil
				currentTask = nil
			end
			if not _ then
				Console.error(isSafeToleave)
			end
		end
	end
end

---@param mode string | "Popular" | "Latest" | "Search"
---@param parser Parser
---@param i number
---@param Table table
---@param data string | nil
---@param tag_data string | table | nil
---Puts all manga on `i` page in `mode` to `Table`
---
---`data` is search string works only if `mode` == "Search"
---`tag_data` is search string works only if `mode` == "Search"
function ParserManager.getMangaListAsync(mode, parser, i, Table, data, tag_data)
	if not parser or uniques[Table] then
		return
	end
	Console.write("Task created")
	if mode == "Search" then
		data = data:gsub("%%", "%%%%25"):gsub("!", "%%%%21"):gsub("#", "%%%%23"):gsub("%$", "%%%%24"):gsub("&", "%%%%26"):gsub("'", "%%%%27"):gsub("%(", "%%%%28"):gsub("%)", "%%%%29"):gsub("%*", "%%%%2A"):gsub("%+", "%%%%2B"):gsub(",", "%%%%2C"):gsub("%.", "%%%%2E"):gsub("/", "%%%%2F"):gsub(" ", "%+")
	end
	local T = {
		Type = "MangaList",
		F = function()
			if mode == "Popular" then
				if parser.getPopularManga then
					parser:getPopularManga(i, Table)
				else
					Console.write(parser.Name .. " doesn't support getPopularManga function", COLOR_GRAY)
				end
			elseif mode == "Latest" then
				if parser.getLatestManga then
					parser:getLatestManga(i, Table)
				else
					Console.write(parser.Name .. " doesn't support getLatestManga function", COLOR_GRAY)
				end
			elseif mode == "Alphabet" then
				if parser.getAZManga then
					parser:getAZManga(i, Table)
				else
					Console.write(parser.Name .. " doesn't support getAZManga function", COLOR_GRAY)
				end
			elseif mode == "ByLetter" then
				if parser.getLetterManga then
					parser:getLetterManga(i, Table, CatalogModes.getLetter())
				else
					Console.write(parser.Name .. " doesn't support getLetterManga function", COLOR_GRAY)
				end
			elseif mode == "ByTag" then
				if parser.getTagManga then
					parser:getTagManga(i, Table, CatalogModes.getTag())
				else
					Console.write(parser.Name .. " doesn't support getTagManga function", COLOR_GRAY)
				end
			elseif mode == "Search" then
				if parser.searchManga then
					parser:searchManga(data, i, Table, tag_data)
				else
					Console.write(parser.Name .. " doesn't support searchManga function", COLOR_GRAY)
				end
			end
		end,
		Table = Table
	}
	order[#order + 1] = T
	uniques[Table] = T
end

---@param manga table
---@param Table table
---@param Insert boolean
---Puts all chapters info from `manga` to `Table`, `insert` is priority (`true` for high or `false` for low)
---
---Chapter info table is a list of `{Name: string, Link: string, Manga: table}` values
function ParserManager.getChaptersAsync(manga, Table, Insert)
	local parser = GetParserByID(manga.ParserID)
	if not parser or uniques[Table] then
		return
	end
	local T = {
		Type = "Chapters",
		F = function()
			parser:getChapters(manga, Table)
		end,
		Table = Table
	}
	if Insert then
		table.insert(order, 1, T)
	else
		order[#order + 1] = T
	end
	uniques[Table] = T
end

---@param chapter table
---@param Table table
---@param insert boolean
---Puts all helpful for parser links to `Table`
function ParserManager.prepareChapter(chapter, Table, insert)
	local parser = GetParserByID(chapter.Manga.ParserID)
	if not parser or uniques[Table] then
		return
	end
	local T = {
		Type = "PrepareChapter",
		F = function()
			parser:prepareChapter(chapter, Table)
		end,
		Table = Table
	}
	if insert then
		table.insert(order, 1, T)
	else
		order[#order + 1] = T
	end
	uniques[Table] = T
end

---@param parserID string
---@param Link string
---@param Table table
---@param insert boolean
---Parses `Link` from prepareChapter function to image link of the page
function ParserManager.loadPageImage(parserID, Link, Table, insert)
	local parser = GetParserByID(parserID)
	if not parser or uniques[Table] then
		return
	end
	local T = {
		Type = "getPageImage",
		F = function()
			parser:loadChapterPage(Link, Table)
			coroutine.yield(true)
			local foo = insert and Threads.insertTask or Threads.addTask
			foo(
				Table,
				{
					Type = "ImageDownload",
					Link = Table.Link,
					Table = Table,
					Index = "Image",
					Animated = Settings.AnimatedGif
				}
			)
		end,
		Table = Table
	}
	if insert then
		table.insert(order, 1, T)
	else
		order[#order + 1] = T
	end
	uniques[Table] = T
end

---@param parserID string
---@param Link string
---@param Table table
---Parses `Link` from prepareChapter function to image link of the page
function ParserManager.getPageImage(parserID, Link, Table)
	local parser = GetParserByID(parserID)
	if not parser or uniques[Table] then
		return
	end
	local T = {
		Type = "getPageImage",
		F = function()
			parser:loadChapterPage(Link, Table)
		end,
		Table = Table
	}
	table.insert(order, 1, T)
	uniques[Table] = T
end

function ParserManager.updateCounters()
	if uniques["UpdateCounters"] then
		return
	end
	local T = {
		Type = "UpdateCounters",
		F = function()
			local list = Database.getMangaList()
			local is_wifi_enabled = Threads.netActionUnSafe(Network.isWifiEnabled)
			if is_wifi_enabled then
				for j = 1, #list do
					local v = list[j]
					local oldName = v.Name
					Cache.addManga(v)
					local parser = GetParserByID(v.ParserID)
					if parser then
						local chapters = {}
						parser:getChapters(v, chapters)
						if #chapters > 0 then
							Cache.saveChapters(v, chapters)
							Cache.loadBookmarks(v)
							v.Counter = #chapters
							local Latest = Cache.getLatestBookmark(v)
							for i = 1, #chapters do
								local key = chapters[i].Link:gsub("%p", "")
								if key == Latest then
									if Cache.getBookmark(chapters[i]) == true then
										v.Counter = #chapters - i
									else
										v.Counter = #chapters - i + 1
									end
									break
								end
							end
						else
							v.Counter = 0
						end
					elseif v.ParserID == "IMPORTED" then
						local chapters = Cache.loadChapters(v, true)
						if #chapters > 0 then
							Cache.loadBookmarks(v)
							v.Counter = #chapters
							local Latest = Cache.getLatestBookmark(v)
							for i = 1, #chapters do
								local key = chapters[i].Link:gsub("%p", "")
								if key == Latest then
									if Cache.getBookmark(chapters[i]) == true then
										v.Counter = #chapters - i
									else
										v.Counter = #chapters - i + 1
									end
									break
								end
							end
						else
							v.Counter = 0
						end
					end
					if oldName ~= v.Name then
						v.PrintName = nil
					end
				end
				Database.save()
			else
				for j = 1, #list do
					local v = list[j]
					local chapters = Cache.loadChapters(v, true)
					if #chapters > 0 then
						Cache.loadBookmarks(v)
						v.Counter = #chapters
						local Latest = Cache.getLatestBookmark(v)
						for i = 1, #chapters do
							local key = chapters[i].Link:gsub("%p", "")
							if key == Latest then
								if Cache.getBookmark(chapters[i]) == true then
									v.Counter = #chapters - i
								else
									v.Counter = #chapters - i + 1
								end
								break
							end
						end
					else
						v.Counter = 0
					end
				end
			end
			Notifications.push(Language[Settings.Language].NOTIFICATIONS.REFRESH_COMPLETED)
		end,
		Table = "UpdateCounters"
	}
	table.insert(order, 1, T)
	uniques["UpdateCounters"] = T
end

---@param Table table
---@return boolean
---Checks if task for `Table` is running or in order
function ParserManager.check(Table)
	return uniques[Table] ~= nil
end

---@param Table table
---Removes task for `Table` from is running or order list
function ParserManager.remove(Table)
	if uniques[Table] then
		if uniques[Table] == currentTask then
			currentTask.Table = trash
			currentTask.Stop = true
			Network.stopCurrentDownload()
		else
			uniques[Table].Type = "Skip"
		end
		uniques[Table] = nil
	end
end

---@param Table table
---@param Insert boolean
---Updates list of parsers from NOBORU-parsers GitHub page
function ParserManager.updateParserList(Table, Insert)
	if uniques["UpdateParsers"] then
		return
	end
	local T = {
		Type = "UpdateParsers",
		F = function()
			ClearParsers()
			local file = {}
			Threads.insertTask(
				file,
				{
					Type = "StringRequest",
					Link = "https://github.com/Creckeryop/NOBORU-parsers/tree/master/parsers",
					Table = file,
					Index = "string"
				}
			)
			while Threads.check(file) do
				coroutine.yield(false)
			end
			for name, path in file.string:gmatch('{"name":"([^"]-%.lua)","path":"(parsers/[^"]-)","contentType":"file"}') do
				local link2row = "https://raw.githubusercontent.com/Creckeryop/NOBORU-parsers/master/" .. path
				local path2row = "ux0:data/noboru/parsers/" .. name
				Threads.addTask(
					link2row,
					{
						Type = "FileDownload",
						Link = link2row,
						Path = "parsers/" .. name
					}
				)
				while Threads.check(link2row) do
					coroutine.yield(false)
				end
				if doesFileExist(path2row) then
					local suc, err = pcall(dofile, path2row)
					if not suc then
						Console.error("Cant load " .. path2row .. ":" .. err)
					end
				end
			end
			Notifications.push(Language[Settings.Language].NOTIFICATIONS.REFRESH_COMPLETED)
		end,
		Table = "UpdateParsers"
	}
	if Insert then
		table.insert(order, 1, T)
	else
		order[#order + 1] = T
	end
	uniques["UpdateParsers"] = T
end

---Clears ParserManager tasks
function ParserManager.clear()
	order = {}
	uniques = {}
	if currentTask then
		currentTask.Stop = true
		Network.stopCurrentDownload()
	end
end
