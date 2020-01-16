local x, y = 544, 272
local Chapters = nil

Reader = {
    LoadManga = function (chapters, chapter_i)
        if chapters == nil then return end
        Chapters = chapters
    end,
    Input = function (OldPad, Pad, OldTouch, Touch)
        
    end,
    Update = function (delta)
        
    end,
    Draw = function ()
        Screen.clear(Color.new(255, 255, 255))
    end
}