local rotation, x, y, image, zoom,min_zoom, width, height, mode = 0, 0, 0, nil, 1, 1, 0, 0
Reader = {
    image = nil,
    draw = function ()
        if Reader.image ~= nil then
            Graphics.drawImageExtended(x, y, Reader.image, 0, 0, width, height, rotation, zoom, zoom)
        end
    end,
    setImage = function (new_image)
        Reader.image = new_image
        if Reader.image == nil then
            return
        end
        width, height, x, y = Graphics.getImageWidth(Reader.image), Graphics.getImageHeight(Reader.image), 480, 272
        
        if width > height then
            mode = "Horizontal"
            zoom = 544 / height
            min_zoom = zoom
        else
            mode = "Vertical"
            zoom = 960 / width
            min_zoom = zoom
        end
    end,
    input = function (pad, oldpad)
        if Controls.check(pad, SCE_CTRL_RTRIGGER) then
            local old_zoom = zoom
            zoom = zoom * 1.2
            y = 272+((y-272)/old_zoom)*zoom
            x = 480+((x-480)/old_zoom)*zoom
        elseif Controls.check(pad, SCE_CTRL_LTRIGGER) then
            local old_zoom = zoom
            zoom = zoom / 1.2
            if zoom < min_zoom then
                zoom = min_zoom
            end
            y = 272+((y-272)/old_zoom)*zoom
            x = 480+((x-480)/old_zoom)*zoom
        end
        --[[
        if Controls.check(pad, SCE_CTRL_LEFT) then
            x = x + 5*zoom
        elseif Controls.check(pad, SCE_CTRL_RIGHT) then
            x = x - 5*zoom
        end--]]
        if Controls.check(pad, SCE_CTRL_UP) then
            y = y + 5*zoom
        elseif Controls.check(pad, SCE_CTRL_DOWN) then
            y = y - 5*zoom
        end
        if y - height / 2 * zoom > 0 then
            y = height / 2 * zoom
        elseif y + height / 2 * zoom < 544 then
            y = 544 - height / 2 * zoom
        end
    end
}
