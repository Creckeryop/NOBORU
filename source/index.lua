local suc, err = xpcall(function() dofile("app0:main.lua") end, debug.traceback)
if not suc then
    error(err)
end