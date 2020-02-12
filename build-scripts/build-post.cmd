REM Changing exe Icon
..\tools\rcedit.exe ..\bin\loadRL.exe --set-icon ..\img\icon.ico

REM Docs
mkdir ..\bin\docs
xcopy ..\docs\*.* ..\bin\docs\
type ..\README.md | more /p > ..\bin\README.txt
xcopy ..\README.md ..\bin\
type ..\LICENSE | more /p > ..\bin\docs\LICENSE.txt
del ..\bin\docs\.gdignore

REM Tools
mkdir ..\bin\tools
xcopy ..\tools\DOSBox ..\bin\tools\DOSBox /s /e /c /i
xcopy ..\tools\curl.exe ..\bin\tools\
xcopy ..\tools\7z.exe ..\bin\tools\
xcopy ..\tools\7z.dll ..\bin\tools\
xcopy ..\tools\innoextract.exe ..\bin\tools\

REM Config
xcopy ..\config.json ..\bin\

