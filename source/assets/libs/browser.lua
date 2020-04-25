Browser = {}

local function makeCookie(line)
    local args = {}
    line:gsub("[\t]?(.-)[\t\n]", function(a) args[#args+1] = a end)
    return {
        HttpOnly = args[1]:find("#HttpOnly_") and true,
        Domain = args[1]:gsub("#HttpOnly_",""):gsub("^%.",""),
        SubDomains = args[2] == "TRUE",
        Path = args[3],
        Secure = args[4] == "TRUE",
        Expires = tonumber(args[5]),
        Key = args[6],
        Value = args[7]
    }
end

local doesFileExist, openFile, readFile, sizeFile, closeFile = System.doesFileExist, System.openFile, System.readFile, System.sizeFile, System.closeFile
function Browser.getCookies(domain)
    if doesFileExist("ur0:user/00/savedata/NPXS10083/Cookie.jar.txt") then
        local fd = openFile("ur0:user/00/savedata/NPXS10083/Cookie.jar.txt", FREAD)
        local content = readFile(fd, sizeFile(fd)).."\n"
        closeFile(fd)
        local cookies = {}
        for line in content:gmatch("(.-\n)") do
            if line:find(domain) then
                cookies[#cookies + 1] = makeCookie(line)
            end
        end
        return cookies
    end
    return {}
end

local callUri = System.executeUri
local wait = System.wait
function Browser.open(link)
    callUri("webmodal: "..link)
    wait(1500000)
end

local getVersion = System.getVersion
function Browser.getUserAgent()
    return "Mozilla/5.0 (PlayStation Vita "..getVersion()..") AppleWebKit/537.73 (KHTML, like Gecko) Silk/3.2"
end