Texture = {tex = nil}
local try = 0
while true do
    Net.downloadImageAsync("https://i.pinimg.com/originals/c5/f9/74/c5f974ac144391a830196f97a9130141.jpg",Texture,'tex')
    Graphics.initBlend()
    Screen.clear()
    if Texture.tex then
        -- if type(Texture.tex.e or Texture.tex)=="table" then
        -- for i = 1, Texture.tex.parts do
        --     if Texture.tex[i] then
        --         Graphics.drawImage(0,0,Texture.tex[i].e)
        --     end
        -- end
        -- else
        if Texture.tex.e then
            Graphics.drawImage(0,0,Texture.tex.e)
        end
    end
    Graphics.debugPrint(0,0,try,LUA_COLOR_WHITE)
    Console.draw()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
    Net.update()
    if Texture.tex then
        if Texture.tex.e then
            Texture.tex = nil
            try = try + 1
            collectgarbage("collect")
        end
    end
end