local SliderY       = 0
local SliderVel     = 0

local SelectedManga = nil
local DownloadedImage = {}
local page = 1
local TouchTimer = Timer.new()
Library = {
    Input = function(OldPad, Pad, OldTouch, Touch)
        if OldTouch.x ~= nil and Touch.x ~= nil and Touch.x > 240  then
            SliderVel = OldTouch.y - Touch.y
            Timer.reset(TouchTimer)
        end
    end,
    Update = function(delta)
        if Lib ~= nil then
            if SliderVel == 0 then
                local start = math.max(1,math.floor((SliderY - 20) / (MANGA_HEIGHT+24))*4 + 1)
                if #DownloadedImage > 12 then
                    local new_table = {}
                    for k = 1, #DownloadedImage do
                        local i = DownloadedImage[k]
                        if i<start or i>math.min(#Lib,start+11) then
                            if Lib[i].ImageDownload then
                                Threads.DeleteUnique("ImgLoad"..i)
                                if Lib[i].image ~= nil then
                                    Graphics.freeImage(Lib[i].image)
                                    Lib[i].image = nil
                                end
                                Lib[i].ImageDownload = nil
                            end
                        else
                            new_table[#new_table+1] = i
                        end
                    end
                    DownloadedImage = new_table
                end
                for i = start, math.min(#Lib,start + 11) do
                    if not Lib[i].ImageDownload then
                        local manga = Lib[i]
                        local id = i
                        Threads.AddTask{
                            Type = "FileDownload",
                            Path = "cache.img",
                            Link = manga.ImageLink,
                            OnComplete = function()
                                Threads.InsertTask{
                                    Type = "ImageLoad",
                                    Path = "cache.img",
                                    Save = function(a)
                                        if a ~= nil then
                                            Graphics.setImageFilters(a, FILTER_LINEAR, FILTER_LINEAR)
                                            manga.image = a
                                        end
                                    end,
                                    Unique = "ImgLoad"..id
                                }
                            end,
                            Unique = "ImgLoad"..id
                        }
                        Lib[i].ImageDownload = true
                        DownloadedImage[#DownloadedImage+1] = i
                    end
                end
            end
            SliderY = SliderY + SliderVel
            SliderVel = SliderVel / 1.12
            if math.abs(SliderVel) < 1 then
                SliderVel = 0
            end
            if SliderY < 0 then
                SliderY = 0
                SliderVel = 0
            elseif SliderY > math.ceil(#Lib/4) * (MANGA_HEIGHT + 24) - 524 + 40 then
                SliderY = math.max(0, math.ceil(#Lib/4) * (MANGA_HEIGHT + 24) - 524 + 40)
                SliderVel = 0
                if not Threads.CheckUnique("PageLoading") then
                    Threads.InsertTask{
                        Type = "Coroutine",
                        Unique = "PageLoading",
                        F = function() return ReadManga:getManga(page) end,
                        Save = function(a)
                            for i = 1, #a do
                                Lib[#Lib+1] = a[i]
                            end
                            Loading.SetMode(LOADING_NONE)
                            page = page + 1
                        end,
                        OnLaunch = function()
                            Loading.SetMode(LOADING_WHITE)
                        end
                    }
                end
            end
        end
    end,
    Draw = function()
        local start = math.max(1,math.floor((SliderY - 20) / (MANGA_HEIGHT+24))*4 + 1)
        for i = start, math.min(#Lib,start + 11) do
            DrawManga(235 + 750 / 2 - (10 + MANGA_WIDTH) * 2 + ((i-1)%4)*(MANGA_WIDTH+10) + MANGA_WIDTH/2, 40 + MANGA_HEIGHT / 2 - SliderY + math.floor((i-1)/4)*(MANGA_HEIGHT + 24), Lib[i])
        end
        local h = (math.ceil(#Lib/4) * (MANGA_HEIGHT + 24) + 40) / 544
        if #Lib > 4 then
            Graphics.fillRect(955, 960, 0, 544, Color.new(32, 32, 32))
            Graphics.fillRect(955, 960, (SliderY-30) / h, ((SliderY-30) + 544) / h, Color.new(64, 64, 64))
        end
    end
}