Texture = {tex = nil}
local try = 0
while true do
    Net.downloadImageAsync("https://t9.mangas.rocks/auto/09/79/80/1.jpg_res.jpg",Texture,'tex')
    Graphics.initBlend()
    Screen.clear()
    if Texture.tex then
        for i = 1, Texture.tex.parts do
            if Texture.tex[i] then
                Graphics.drawImage(0,0,Texture.tex[i].e)
            end
        end
    end
    Graphics.debugPrint(0,0,try,LUA_COLOR_WHITE)
    Console.draw()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
    Net.update()
    if Texture.tex then
        if Texture.tex.parts == #Texture.tex then    
            Texture.tex = nil
            try = try + 1
            collectgarbage("collect")
        end
    end
end