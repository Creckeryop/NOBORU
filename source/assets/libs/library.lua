local SliderY       = 0
local SliderVel     = 0

local SelectedManga = nil

Library = {
    Input = function(OldPad, Pad, OldTouch, Touch)
        if OldTouch.x ~= nil and Touch.x ~= nil and Touch.x > 230  then
            SliderVel = OldTouch.y - Touch.y
        end
    end,
    Update = function(delta)
        if Lib ~= nil then
            local start = math.max(1,math.floor((SliderY - 40) / (MANGA_HEIGHT+15))*4 + 1)
            for i = start, math.min(#Lib,start + 12) do
                if not Lib[i].ImageDownload then
                    local manga = Lib[i]
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
                                end
                            }
                        end
                    }
                    Lib[i].ImageDownload = true
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
            elseif SliderY > math.ceil(#Lib/4) * (MANGA_HEIGHT + 15) - 524 + 40 then
                SliderY = math.max(0, math.ceil(#Lib/4) * (MANGA_HEIGHT + 15) - 524 + 40)
                SliderVel = 0
            end
        end
    end,
    Draw = function()
        local start = math.max(1,math.floor((SliderY - 40) / (MANGA_HEIGHT+15))*4 + 1)
        for i = start, math.min(#Lib,start + 12) do
            DrawManga(215 + 750 / 2 - (8 + MANGA_WIDTH) * 2 + ((i-1)%4)*(MANGA_WIDTH+8) + MANGA_WIDTH/2, 40 + MANGA_HEIGHT / 2 - SliderY + math.floor((i-1)/4)*(MANGA_HEIGHT + 15), Lib[i])
        end
        local h = (math.ceil(#Lib/4) * (MANGA_HEIGHT + 15) + 40) / 544
        if #Lib > 4 then
            Graphics.fillRect(955, 960, 0, 544, Color.new(32, 32, 32))
            Graphics.fillRect(955, 960, SliderY / h, (SliderY + 544) / h, Color.new(64, 64, 64))
        end
    end
}