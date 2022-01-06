Browser = {}

local doesFileExist = System.doesFileExist
local openFile = System.openFile
local readFile = System.readFile
local sizeFile = System.sizeFile
local closeFile = System.closeFile
local callUri = System.executeUri
local sleep = System.wait
local getVersion = System.getVersion

---@param line string|table
---@return table
---Parses cookie string and returns table
local function parseCookieString(line)
	local args = {}
	for a in line:gmatch("[\t]?(.-)[\t\n]") do
		args[#args + 1] = a
	end
	if #args == 7 then
		return {
			HttpOnly = args[1]:find("#HttpOnly_") and true,
			Domain = args[1]:gsub("#HttpOnly_", ""):gsub("^%.", ""),
			SubDomains = args[2] == "TRUE",
			Path = args[3],
			Secure = args[4] == "TRUE",
			Expires = tonumber(args[5]),
			Key = args[6],
			Value = args[7]
		}
	else
		return nil
	end
end

---@param domain string
---@return table
---Returns cookie table for given `domain`
---
---{[1] = {Key, Value, Expires, Path, Secure, SubDomains, Domain, HttpOnly} [2] = ..}
---
---`cookie['@'] = "key1=value1; key2=value2; "`
---
---`cookie[key1] = value1`
function Browser.getCookie(domain)
	local cookieLine = ""
	local cookieList = {}
	if doesFileExist("ur0:user/00/savedata/NPXS10083/Cookie.jar.txt") then
		local fh = openFile("ur0:user/00/savedata/NPXS10083/Cookie.jar.txt", FREAD)
		local content = readFile(fh, sizeFile(fh)) .. "\n"
		closeFile(fh)
		for line in content:gmatch("(.-\n)") do
			if line:find(domain) then
				local cookie = parseCookieString(line)
				if cookie then
					cookieList[#cookieList + 1] = cookie
					cookieList[cookie.Key] = cookie.Value
					cookieLine = cookieLine .. cookie.Key .. "=" .. cookie.Value .. "; "
				end
			end
		end
	end
	cookieList["@"] = cookieLine
	return cookieList
end

---@param link string
---Opens browser on `link`
function Browser.open(link)
	callUri("webmodal: " .. link)
	sleep(1500000)
	callUri("webmodal: file:///ux0:/data/noboru/temp/auth.html")
	sleep(1500000)
end

---@return string
---Gives user agent of browser
function Browser.getUserAgent()
	return "Mozilla/5.0 (PlayStation Vita " .. getVersion() .. ") AppleWebKit/537.73 (KHTML, like Gecko) Silk/3.2"
end
