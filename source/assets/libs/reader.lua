local rotation, x, y, zoom, max_zoom, min_zoom, width, height, mode = 0, 0, 0, 1, 2, 1, 0, 0
local Pages = {}
local  velX, velY = 0, 0

local TOUCH_IDLE        = 0
local TOUCH_MULTI       = 1
local TOUCH_MOVE        = 2
local TOUCH_READ        = 3
local TOUCH_SWIPE       = 4
local touchMode         = TOUCH_IDLE

local PAGE_NONE         = 0
local PAGE_LEFT         = 1
local PAGE_RIGHT        = 2
local pageMode          = PAGE_NONE

local offset = { x = 0, y = 0 }
local touchTemp = { x = 0, y = 0 }

local Scale = function (dzoom)
    local old_zoom = zoom
    zoom = zoom * dzoom
    if zoom < min_zoom then
        zoom = min_zoom
    elseif zoom > max_zoom then
        zoom = max_zoom
    end
    y = 272 + ((y - 272) / old_zoom) * zoom
    x = 480 + ((x - 480) / old_zoom) * zoom
end

Reader = {
    image = nil,
    draw = function ()
        if Reader.image ~= nil then
            Graphics.drawImageExtended(offset.x + x, offset.y + y, Reader.image, 0, 0, width, height, rotation, zoom, zoom)
        else
            Graphics.debugPrint (0, 524, "Loading "..string.sub("...",1,(Timer.getTime(GlobalTimer)/200)%3+1), LUA_COLOR_WHITE)
        end
    end,
    setImage = function (new_image)
        Reader.image = new_image
        if Reader.image == nil then
            return
        end
        width, height, x, y = Graphics.getImageWidth(Reader.image), Graphics.getImageHeight(Reader.image), 480, 272+1010101010
        velY = 0
        velX = 0
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
    update = function ()
        if touchMode == TOUCH_READ then
            local len = math.sqrt((touchTemp.x-Touch.x)*(touchTemp.x-Touch.x) + (touchTemp.y-Touch.y)*(touchTemp.y-Touch.y))
            Console.addLine(len)
            if  len > 10 then
                if math.abs(Touch.x - touchTemp.x) > math.abs(Touch.y - touchTemp.y)*3  and ((bit32.band(pageMode,PAGE_RIGHT)~=0 and touchTemp.x > Touch.x) or (bit32.band(pageMode,PAGE_LEFT)~=0 and touchTemp.x < Touch.x)) then
                    touchMode = TOUCH_SWIPE
                    velY = 0
                    velX = 0
                else
                    touchMode = TOUCH_MOVE
                end
            end
        end
        if touchMode == TOUCH_IDLE or touchMode == TOUCH_MOVE then
            y = y + velY
            x = x + velX
            if touchMode == TOUCH_IDLE then
                velY = velY * 0.9
                velX = velX * 0.9
            end
        elseif touchMode == TOUCH_SWIPE then
            offset.x = offset.x + velX
        end
        if touchMode ~= TOUCH_SWIPE then
            offset.x = offset.x / 1.2
        end

        if y - height / 2 * zoom > 0 then
            y = height / 2 * zoom
        elseif y + height / 2 * zoom < 544 then
            y = 544 - height / 2 * zoom
        end
        if mode ~= "Horizontal" or zoom*width > 960 then
            if zoom*width<=960 or zoom == min_zoom and mode ~= "Horizontal" then
                pageMode = bit32.bor(PAGE_LEFT,PAGE_RIGHT)
            end
            if x - width / 2 * zoom >= 0 then
                x = width / 2 * zoom
                pageMode = bit32.bor(pageMode,PAGE_LEFT)
            elseif x + width / 2 * zoom <= 960 then
                x = 960 - width / 2 * zoom
                pageMode = bit32.bor(pageMode,PAGE_RIGHT)
            else
                pageMode = PAGE_NONE
            end
        else
            x = 480
            pageMode = bit32.bor(PAGE_LEFT,PAGE_RIGHT)
        end
    end,
    input = function (pad, oldpad)
        if Controls.check(pad, SCE_CTRL_RTRIGGER) then
            Scale (1.2)
        elseif Controls.check(pad, SCE_CTRL_LTRIGGER) then
            Scale (5/6)
        end
        if Touch.y ~= nil and OldTouch.y ~= nil then
            if touchMode ~= TOUCH_MULTI then
                if touchMode == TOUCH_IDLE then
                    touchTemp.x = Touch.x
                    touchTemp.y = Touch.y
                    touchMode = TOUCH_READ
                end
                velX = Touch.x - OldTouch.x
                velY = Touch.y - OldTouch.y
            end
            if Touch2.x ~= nil and OldTouch2.x ~= nil then
                touchMode = TOUCH_MULTI
                local old_zoom = zoom
                local center = { x = (Touch.x + Touch2.x) / 2, y = (Touch.y + Touch2.y) / 2 }
                local n = (math.sqrt((Touch.x - Touch2.x)*(Touch.x - Touch2.x)+(Touch.y - Touch2.y)*(Touch.y - Touch2.y))/math.sqrt((OldTouch.x - OldTouch2.x)*(OldTouch.x - OldTouch2.x)+(OldTouch.y - OldTouch2.y)*(OldTouch.y - OldTouch2.y)))
                Scale (n)
                n = zoom / old_zoom
                y = y - (center.y - 272) * (n - 1)
                x = x - (center.x - 480) * (n - 1)
            end
        else
            touchMode = TOUCH_IDLE
        end
        --[[
        if Controls.check(pad, SCE_CTRL_LEFT) then
            x = x + 5*zoom
        elseif Controls.check(pad, SCE_CTRL_RIGHT) then
            x = x - 5*zoom
        end]]
        if Controls.check(pad, SCE_CTRL_UP) then
            y = y + 5*zoom
        elseif Controls.check(pad, SCE_CTRL_DOWN) then
            y = y - 5*zoom
        end
    end,
    load = function (pages_links)
        for i = 1, #Pages do
            if Pages[i] ~= nil and Pages[i].image ~= nil then
                Net.remove (Pages[i], 'image')
                Graphics.freeImage (Pages[i].image)
            end
        end
        for i = 1, #pages_links do
            Pages[i] = { link = pages_links[i] }
        end
    end
}
