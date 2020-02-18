---@param name string
---@param foo function
---Checks `foo` function for working
local function test(name, foo)
	_Gcopy = {}
	for k, v in pairs(_G) do
		_Gcopy[k] = v
	end
	local oldprint = print
	print = function(text)
		oldprint("[log] "..name..": "..text)
	end
	xpcall(function()
		foo()
		oldprint("\27[32m[success] ".. name.."\27[00m")
	end,
	function(msg)
		oldprint("\27[31m[fail] "..name..": "..msg:match(":%d+: (.*)").."\27[00m")
	end)
	for k, v in pairs(_G) do
		if _Gcopy[k] == nil then
			_G[k] = nil
		else
			_G[k] = _Gcopy[k]
		end
	end
end

test("Language test", function()
	local success = true
	System = {
		getLanguage = function()
			return "Russian"
		end
	}
	dofile("../source/assets/libs/language.lua")
	Language.Default = nil
	local tabs = {}
	for name, Lang in pairs(Language) do
		for var, Cat in pairs(Lang) do
			if tabs[var] and type(tabs[var]) ~= type(Cat) then
				print("Conflict types of variable"..name.."."..var.." with AnotherLanguage."..var )
				success = false
			end
			if type(Cat) == "table" then
				tabs[var] = tabs[var] or {}
				for k, v in pairs(Cat) do
					tabs[var][k] = true
				end
			else
				tabs[var] = true
			end
		end
	end
	for name, Lang in pairs(Language) do
		for var, Cat in pairs(tabs) do
			if Lang[var] == nil then
				print(name.." "..var.." not found!")
				success = false
			end
			if type(Lang[var]) == "table" then
				for k, v in pairs(Cat) do
					if Lang[var][k] == nil then
						print(name.."."..var.."."..k.." not found!")
						success = false
					end
				end
			end
		end
	end
	if not success then
		error("Watch log to see conflicts")
	end
end)