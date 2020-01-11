vita-mksfoex -s TITLE_ID=MOONDAYO1 "Moondayo" param.sfo
copy /Y param.sfo /B buildtmp\sce_sys\param.sfo
7z a -tzip "..\Moondayo.vpk" -r .\buildtmp\* .\buildtmp\eboot.bin 