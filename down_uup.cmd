@echo off
set run_convert=0
set del-aria2=1
:menu
cls
if %run_convert% neq 0 ( echo 1. Run convertion process: Enabled ) else if %run_convert% equ 0 ( echo 1. Run convertion process: Disabled )
if %del-aria2% neq 0 ( echo 2. Delete script: Enabled ) else if %run_convert% equ 0 ( echo 2. Delete script: Disabled )
set /p "enbl=Select option to enable or disable and press Enter. Type download to begin: "
if %enbl%==1 goto check1
if %enbl%==2 goto check2
if %enbl%==download goto work

:check1
if %run_convert%==0 set run_convert=1&goto menu
if %run_convert%==1 set run_convert=0&goto menu

:check2
if %del-aria2%==0 set del-aria2=1&goto menu
if %del-aria2%==1 set del-aria2=0&goto menu

:work
cd /d "%~dp0"
echo Please set UUP output folder, for automatic detection type UUPs
set /p "uupfold=Type folder here: "
echo Warning! If you are using this script, then you need to know that is only downloading script.
echo Run down-conv-uup.cmd to add converting process
echo If you are finding update ID then find it on uupdump.net by typing build on search box
set /p "id=Update ID/UUP ID: "
set /p "lng=Language code: "
set /p "edt=Edition: "
aria2c -o"aria2_script.txt" "https://uup.rg-adguard.net/api/GetFiles?id=%id%&lang=%lng%&edition=%edt%&txt=yes"
mkdir %uupfold%
aria2c -i aria2_script.txt -d %uupfold%
if %del-aria2%==1 ( del aria2_script.txt&goto checkconv ) else ( goto checkconv )

:checkconv
if %run_convert% neq 0 start /wait convert-UUP.cmd&goto quit_conv
if %run_convert% equ 0 goto quit

:quit_conv
echo Deleting UUP folder...
rd %uupfold% /s /q
echo.
echo Process is completed.
echo Press any key to exit.
pause>nul
exit

:quit
echo Process is completed.
echo Press any key to exit.
pause>nul
exit