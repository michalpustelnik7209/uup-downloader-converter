@echo off
if %1==auto ( goto auto ) else ( goto next )
:next 
if %1==noauto ( goto bgn ) else ( goto next2 )
:next2
if %1==help ( goto helpcmd ) else ( set %1=noauto&goto next )
goto menu
:auto
set uupfold=%2
if %3==yes ( set del-aria2=1 ) else if %3==no ( set del-aria2=0 )
set id=%4
set edt=%5
set lng=%6
if %7==uupdump ( set errorlevel=1 ) else if %7==uupgen ( set errorlevel=2 )
if %8==yes ( set run_convert=1 ) else if %8==no ( set run_convert=0 )
goto start_auto

:bgn
set run_convert=0
set del-aria2=1
:menu
cls
if %run_convert% neq 0 ( echo 1. Run convertion process: Enabled ) else if %run_convert% equ 0 ( echo 1. Run convertion process: Disabled )
if %del-aria2% neq 0 ( echo 2. Delete generated script: Enabled ) else if %run_convert% equ 0 ( echo 2. Delete generated script: Disabled )
echo 3. Help
set /p "enbl=Select option to enable or disable and press Enter. Type download to begin: "
if %enbl%==1 goto check1
if %enbl%==2 goto check2
if %enbl%==3 goto help
if %enbl%==download goto work

:check1
if %run_convert%==0 set run_convert=1&goto menu
if %run_convert%==1 set run_convert=0&goto menu

:check2
if %del-aria2%==0 set del-aria2=1&goto menu
if %del-aria2%==1 set del-aria2=0&goto menu

:work
cd /d "%~dp0"
echo Please set UUP output folder, for automatic detection in converter type UUPs
set /p "uupfold=Type folder here: "
echo Warning! If you are using this script, then you need to know that is only downloading script.
echo Run down-conv-uup.cmd to add converting process
echo If you are finding update ID then find it on uupdump.net by typing build on search box
set /p "id=Update ID/UUP ID: "
set /p "lng=Language code: "
set /p "edt=Edition: "
goto getfiles
:getfiles
echo 1. UUPDump
echo 2. UUP generation project
choice /c 12 /m "Select server"
goto start_auto
:start_auto
if %errorlevel% equ 2 (aria2c -o"aria2_script.txt" "https://uup.rg-adguard.net/api/GetFiles?id=%id%&lang=%lng%&edition=%edt%&txt=yes") else if %errorlevel% equ 1 (aria2c -o"aria2_script.txt" "https://uupdump.net/get.php?id=%id%&pack=%lng%&edition=%edt%&aria2=2")
if not exist %uupfold% ( mkdir %uupfold%&goto chck ) else ( goto chck )
goto chck
:chck
find /i "error" aria2_script.txt >nul
if %errorlevel% equ 0 goto LinkErrGen
if %errorlevel% equ 1 goto work2
:work2
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

:LinkErrGen
del aria2_script.txt
echo Generating links has failed.
echo Try again later.
choice /c 01 /m "Press 0 to exit, 1 to try again"
if %errorlevel%==1 ( exit ) else if %errorlevel%==2 ( goto getfiles )

:help
echo To use these options first add argument auto or if you don't want to use them type noauto
echo First is download folder
echo Second is Download script deletion (yes or no)
echo Third is ID of download
echo Fourth is edition
echo Fifth is language
echo Sixth is server of generating
echo Seventh if convertion process to run (yes or no)
pause
goto menu

:helpcmd
echo Example: down_uup.cmd auto UUPs yes 0bd1dd5f-c97f-4463-bdb6-8410d50c05d8 core en-us uupgen yes
echo auto: Automatic script at first place (auto: on, noauto:off, help:this window)
echo (download folder), e.g. UUPs
echo (Download script deletion) yes or no
echo ID of UUP
echo Edition/SKU (e.g. core)
echo Language: e.g. en-us
echo Server of generating: (allowed values: uupdump, uupgen)
echo Convertion process (yes for enabled, no for disabled)
echo Explaining
echo To use these options first add argument auto or if you don't want to use them type noauto
echo First is download folder
echo Second is Download script deletion (yes or no)
echo Third is ID of download
echo Fourth is edition
echo Fifth is language
echo Sixth is server of generating
echo Seventh if convertion process to run (yes or no)