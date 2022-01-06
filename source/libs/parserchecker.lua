ParserChecker = {}

local parserCoroutine = nil

function ParserChecker.update()
	if parserCoroutine then
		if coroutine.status(parserCoroutine) ~= "dead" then
			local a, b = coroutine.resume(parserCoroutine)
			if not a then
				Console.error(b, 2)
			end
		else
			parserCoroutine = nil
		end
	end
end

local function F(parser)
	local name = parser.Name
	local methods = {"getPopularManga", "getLatestManga", "getAZManga", "getLetterManga", "getTagManga", "searchManga", "searchManga", "searchManga"}
	local imageTestChapter = {}
	local filters = parser.Filters or {}
	local checked = {}
	Console.write("Start checking /" .. name .. "/", Color.new(0, 0, 255), 2)
	coroutine.yield()
	for k, v in ipairs(filters) do
		v.visible = false
		local default = v.Default
		if v.Type == "check" or v.Type == "checkcross" then
			checked[k] = {}
			for i, _ in ipairs(v.Tags) do
				checked[k][i] = false
			end
			if default then
				if v.Type == "checkcross" then
					for i = 1, #default.include do
						for e, t in ipairs(v.Tags) do
							if t == default.include[i] then
								checked[k][e] = true
							end
						end
					end
					for i = 1, #default.exclude do
						for e, t in ipairs(v.Tags) do
							if t == default.exclude[i] then
								checked[k][e] = "cross"
							end
						end
					end
				elseif v.Type == "check" then
					for i = 1, #default do
						for e, t in ipairs(v.Tags) do
							if t == default[i] then
								checked[k][e] = true
							end
						end
					end
				end
			end
		elseif v.Type == "radio" then
			checked[k] = 1
			if default then
				for e, t in ipairs(v.Tags) do
					if t == default then
						checked[k] = e
					end
				end
			end
		end
	end
	local filter = {}
	for i, fil in ipairs(filters) do
		if fil.Type == "check" then
			local list = {}
			for j, v in ipairs(checked[i]) do
				if v then
					list[#list + 1] = fil.Tags[j]
				end
			end
			filter[#filter + 1] = list
			filter[fil.Name] = list
		elseif fil.Type == "checkcross" then
			local include = {}
			for j, c in ipairs(checked[i]) do
				if c == true then
					include[#include + 1] = fil.Tags[j]
				end
			end
			local exclude = {}
			for j, c in ipairs(checked[i]) do
				if c == "cross" then
					exclude[#exclude + 1] = fil.Tags[j]
				end
			end
			filter[#filter + 1] = {
				include = include,
				exclude = exclude
			}
			filter[fil.Name] = filter[#filter]
		elseif fil.Type == "radio" then
			filter[#filter + 1] = fil.Tags[checked[i]] or ""
			filter[fil.Name] = fil.Tags[checked[i]] or ""
		end
	end
	local search_i = 1
	local searchWordsList = {"a", "Naruto", "one piece"}
	for _, v in ipairs(methods) do
		local f = parser[v]
		if f then
			local Manga = {}
			local additionalText = ""
			if v == "getLetterManga" then
				local letter = (parser.Letters or {})[1]
				if letter then
					additionalText = letter
					f(parser, 1, Manga, letter)
				end
			elseif v == "getTagManga" then
				local tag = (parser.Tags or {})[1]
				if tag then
					additionalText = tag
					f(parser, 1, Manga, tag)
				end
			elseif v == "searchManga" then
				local searchWord = searchWordsList[search_i] or ""
				search_i = search_i + 1
				additionalText = searchWord
				f(parser, searchWord, 1, Manga, filter)
			else
				f(parser, 1, Manga)
			end
			Console.write("Checking /" .. name .. ":" .. v .. '("' .. additionalText .. '")/', Color.new(0, 255, 0), 2)
			while ParserManager.check(Manga) do
				coroutine.yield()
			end
			local foundMangaCount = #(Manga or {})
			Console.write("Got '" .. foundMangaCount .. "' manga", nil, 2)
			if foundMangaCount == 0 then
				Console.error("function: " .. name .. ":" .. v .. '("' .. additionalText .. '") probably have an error', 2)
			else
				local mangaListToCheck = math.min(3, foundMangaCount)
				local chaptersListToCheck = {}
				local manga = nil
				Console.write("Checking " .. mangaListToCheck .. " first mangas for having chapters", Color.new(0, 255, 0), 2)
				local log = {}
				for i = 1, mangaListToCheck do
					local chapters = {}
					parser:getChapters(Manga[i], chapters)
					while ParserManager.check(chapters) do
						coroutine.yield()
					end
					if #chaptersListToCheck < #chapters then
						chaptersListToCheck = chapters
						manga = Manga[i]
					end
					log[#log + 1] = #(chapters or {})
				end
				Console.write("Done got '" .. table.concat(log, ", ") .. "'!", nil, 2)
				if manga then
					local numOfChaptersToCheck = math.min(3, #chaptersListToCheck)
					Console.write("Checking " .. numOfChaptersToCheck .. " first chapters of " .. manga.Name .. " for having pages", Color.new(0, 255, 0), 2)
					log = {}
					for i = 1, numOfChaptersToCheck do
						local images = {}
						parser:prepareChapter(chaptersListToCheck[i], images)
						while ParserManager.check(images) do
							coroutine.yield()
						end
						if #images > #imageTestChapter then
							imageTestChapter = images
						end
						log[#log + 1] = #(images or {})
					end
					Console.write("Done got '" .. table.concat(log, ", ") .. "' images!", nil, 2)
				else
					Console.error("No chapters found for first manga", 2)
				end
			end
		end
	end
	if #imageTestChapter > 0 then
		Console.write("Checking 1 image to download " .. tostring(imageTestChapter[1]), nil, 2)
		local Table = {}
		parser:loadChapterPage(imageTestChapter[1], Table)
		while ParserManager.check(Table) do
			coroutine.yield()
		end
		Threads.insertTask(
			Table,
			{
				Type = "ImageDownload",
				Link = Table.Link,
				Table = Table,
				Index = "Image"
			}
		)
		while Threads.check(Table) do
			coroutine.yield()
		end
		if Table.Image == nil then
			Console.error("Error getting image", 2)
		elseif Table.Image.free then
			Table.Image:free()
			Console.write("All OK!", nil, 2)
		end
	end
	Console.write("Checking " .. name .. " done!", COLOR_ROYAL_BLUE, 2)
end

function ParserChecker.addCheck(Parser)
	if parserCoroutine then
		Console.error("Can't start other check, while one is active, try again later", 2)
	else
		parserCoroutine =
			coroutine.create(
			function()
				F(Parser)
			end
		)
	end
end
