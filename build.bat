cd lpp-builder
rd /s /q build
xcopy /y eboot.bin build\
xcopy /s ..\source\* build\
vita-mksfoex -s TITLE_ID=MOONDAYO1 "Moondayo" param.sfo
copy /Y param.sfo /B build\sce_sys\param.sfo
7z a -tzip "..\Moondayo.vpk" -r .\build\* .\build\eboot.bin 