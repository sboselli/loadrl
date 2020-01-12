REM Changing exe Icon
..\tools\rcedit.exe ..\bin\loadRL.exe --set-icon ..\img\icon.ico

REM Docs
mkdir ..\bin\docs
xcopy ..\docs\*.* ..\bin\docs\
xcopy ..\README.md ..\bin\
ren ..\bin\README.md README.txt
xcopy ..\README.md ..\bin\
xcopy ..\LICENSE ..\bin\docs\
ren ..\bin\docs\LICENSE LICENSE.txt
del ..\bin\docs\.gdignore

REM Tools
mkdir ..\bin\tools
xcopy ..\tools\DOSBox ..\bin\tools\DOSBox /s /e /c /i
xcopy ..\tools\curl.exe ..\bin\tools\
xcopy ..\tools\7z.exe ..\bin\tools\
xcopy ..\tools\7z.dll ..\bin\tools\

REM Config
xcopy ..\config.json ..\bin\

