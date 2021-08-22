@echo off

rem Enable menu to choose from multiple editions ESDs
SET MultiChoice=1

rem script:			abbodi1406, adguard
rem esddecrypt:		qad, @tfwboredom
rem wimlib:			synchronicity
rem cryptokey:		MrMagic, Chris123NT, mohitbajaj143, Superwzt, timster
rem EFI x32-x64:	conty9

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

call bin\update.cmd
title ESD ^> ISO - %v_ver_decrypt%
echo Preparing...
if not exist "%~dp0bin\wimlib-imagex.exe" goto :eof
IF /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (SET "wimlib=%~dp0bin\bin64\wimlib-imagex.exe") ELSE (SET "wimlib=%~dp0bin\wimlib-imagex.exe")
cd /d "%~dp0"
setlocal EnableDelayedExpansion
SET Backup=OFF
set savess=0
SET ENCRYPTEDESD=
SET ERRORTEMP=
SET ENCRYPTED=0
SET MULTI=0
SET PREPARED=0
set VOL=0
SET UnifyWinre=0
SET SINGLE=0
set "fold=0"
SET "ramdiskoptions={7619dcc8-fafe-11d9-b411-000476eba25f}"
set newkeys=0
mkdir bin\temp >nul 2>&1
for /f "tokens=3 delims=: " %%b in ('dism /english /online /Get-Intl ^| find /i "System locale"') do set dlang=%%b && call :dlang
if not [%1]==[] (set "ENCRYPTEDESD=%~1"&set "ENCRYPTEDESDN=%~nx1"&goto :check)
set _esd=0
if exist "*.esd" (for /f "delims=" %%i in ('dir /b "*.esd"') do (call set /a _esd+=1))
if !_esd! equ 2 goto :dCheck
if !_esd! equ 0 goto :prompt
if !_esd! gtr 1 set "fold=%CD%"&goto :esd_fold
for /f "delims=" %%i in ('dir /b "*.esd"') do (set "ENCRYPTEDESD=%%i"&set "ENCRYPTEDESDN=%%i"&goto :check)

:prompt
set "fold=0"
set ENCRYPTEDESD=
cls
echo.
call :as
echo %prompt1%
call :as
echo.
set /p ENCRYPTEDESD=
if [%ENCRYPTEDESD%]==[] goto :QUIT
call :setvar "%ENCRYPTEDESD%"
goto :check

:setvar
SET ENCRYPTEDESDN=%~nx1
goto :eof

:check
SET ENCRYPTED=0
if /i %ENCRYPTEDESDN%==install.esd (ren %ENCRYPTEDESD% %ENCRYPTEDESDN%.orig&set ENCRYPTEDESD=%ENCRYPTEDESD%.orig)
bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 1>nul 2>nul
IF %ERRORLEVEL% EQU 74 SET ENCRYPTED=1
IF %ERRORLEVEL% EQU 18 (
	cls
	echo.
	call :as
	echo %check%
	call :as
	echo.
	echo %presscont%
	pause >nul
	goto :QUIT
)
IF %ERRORLEVEL% NEQ 0 set "fold=%ENCRYPTEDESD%"&goto :esd_fold

:PRE_INFO
bin\imagex.exe /info "%ENCRYPTEDESD%">bin\temp\infoall.txt 2>&1
find /i "Professional</EDITIONID>" bin\temp\infoall.txt 1>nul && (set editionida=1) || (set editionida=0)
find /i "ProfessionalN</EDITIONID>" bin\temp\infoall.txt 1>nul && (set editionidn=1) || (set editionidn=0)
find /i "CoreSingleLanguage</EDITIONID>" bin\temp\infoall.txt 1>nul && (set editionids=1) || (set editionids=0)
find /i "CoreCountrySpecific</EDITIONID>" bin\temp\infoall.txt 1>nul && (set editionidc=1) || (set editionidc=0)
bin\imagex.exe /info "%ENCRYPTEDESD%" 4 >bin\temp\info.txt 2>&1
for /f "tokens=3 delims=<>" %%i in ('find /i "<BUILD>" bin\temp\info.txt') do set build=%%i
for /f "tokens=3 delims=<>" %%i in ('find /i "<MAJOR>" bin\temp\info.txt') do set ver1=%%i
for /f "tokens=3 delims=<>" %%i in ('find /i "<MINOR>" bin\temp\info.txt') do set ver2=%%i
for /f "tokens=3 delims=<>" %%i in ('find /i "<DEFAULT>" bin\temp\info.txt') do set langid=%%i
for /f "tokens=3 delims=<>" %%i in ('find /i "<EDITIONID>" bin\temp\info.txt') do set editionid=%%i
for /f "tokens=3 delims=<>" %%i in ('find /i "<ARCH>" bin\temp\info.txt') do (IF %%i EQU 0 (SET arch=x86) ELSE (SET arch=x64))
for /f "tokens=3 delims=: " %%i in ('findstr /i /b /c:"Image Count" bin\temp\infoall.txt') do (IF %%i GEQ 5 SET MULTI=%%i)
if %build% LEQ 9600 GOTO :E_W81
find /i "<DISPLAYNAME>" bin\temp\info.txt 1>nul && (
	for /f "tokens=3 delims=<>" %%i in ('find /i "<DISPLAYNAME>" bin\temp\info.txt') do set "_os=%%i"
) || (
	for /f "tokens=3 delims=<>" %%i in ('find /i "<NAME>" bin\temp\info.txt') do set "_os=%%i"
)
IF NOT %MULTI%==0 FOR /L %%g IN (4,1,%MULTI%) DO (
	bin\imagex.exe info "!ENCRYPTEDESD!" %%g | find /i "<DISPLAYNAME>" 1>nul && (
		for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "!ENCRYPTEDESD!" %%g ^| find /i "<DISPLAYNAME>"') do set "_os%%g=%%i"
	) || (
		for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "!ENCRYPTEDESD!" %%g ^| find /i "<NAME>"') do set "_os%%g=%%i"
	)
)
del /f /q bin\temp\info*.txt
IF NOT %MULTI%==0 (set /a images=%MULTI%-3) else (GOTO :MAINMENU)
IF NOT %MultiChoice%==1 GOTO :MAINMENU

:MULTIMENU
cls
set MULTIp=
call :as
echo %mfount% %images% %medition%:
call :as
FOR /L %%j IN (4,1,%MULTI%) DO (
echo. !_os%%j!
)
call :as _
echo. %options%
echo. %options1%
echo. %options2%
if %MULTI% gtr 5 (
	echo. %options3%
	echo. %options4%
)
if [%fold%]==[0] (echo %menustb1%) else (echo %menustb%)
call :as
echo.
set /p MULTIp= ^> %choice%
if /i %MULTIp%==b (if [%fold%]==[0] (GOTO :prompt) else (GOTO :esd_fold))
if "%MULTIp%"=="1" GOTO :MAINMENU
if "%MULTIp%"=="2" GOTO :SINGLEMENU
if %MULTI% gtr 5 (
	if "%MULTIp%"=="3" GOTO :RANGEMENU
	if "%MULTIp%"=="4" GOTO :RANDOMMENU
)
if "%MULTIp%"=="0" GOTO :QUIT
goto :MULTIMENU

:SINGLEMENU
cls
set _single=
call :as
FOR /L %%j IN (4,1,%MULTI%) DO (
call set /a osnum=%%j-3
echo. !osnum!. !_os%%j!
)
call :as _
echo %mselect1%
if [%fold%]==[0] (echo %menustb1menustb1%) else (echo %menustb%)
call :as
set /p _single= ^> %denter2%
if /i %_single%==b (if [%fold%]==[0] (GOTO :prompt) else (GOTO :esd_fold))
if "%_single%"=="" goto :QUIT
if "%_single%"=="0" set _single=&goto :MULTIMENU
if %_single% GTR %images% echo.&echo %_single% %emsel1%&echo.&PAUSE&goto :SINGLEMENU
set /a _single+=3&goto :MAINMENU

:RANGEMENU
cls
set _range=
set _start=
set _end=
call :as
FOR /L %%j IN (4,1,%MULTI%) DO (
call set /a osnum=%%j-3
echo. !osnum!. !_os%%j!
)
call :as _
echo %mrange%
echo %mrangee%
echo %mreturn%
if [%fold%]==[0] (echo %menustb1%) else (echo %menustb%)
call :as
set /p _range= ^> %denter2%
if /i "%_range%"=="b" (if [%fold%]==[0] (GOTO :prompt) else (GOTO :esd_fold))
if "%_range%"=="" goto :QUIT
if "%_range%"=="0" set _start=&goto :MULTIMENU
for /f "tokens=1,2 delims=-" %%i in ('echo %_range%') do set _start=%%i&set _end=%%j
if %_end% GTR %images% echo.&echo %emrange1%&echo.&PAUSE&goto :RANGEMENU
if %_start% GTR %_end% echo.&echo %emrange2%&echo.&PAUSE&goto :RANGEMENU
if %_start% EQU %_end% echo.&echo %emrange3%&echo.&PAUSE&goto :RANGEMENU
if %_start% GTR %images% echo.&echo %emrange4%&echo.&PAUSE&goto :RANGEMENU
set /a _start+=3&set /a _end+=3&goto :MAINMENU

:RANDOMMENU
cls
set _count=
set _index=
call :as
FOR /L %%j IN (4,1,%MULTI%) DO (
call set /a osnum=%%j-3
echo. !osnum!. !_os%%j!
)
call :as _
echo %mrandon%
echo %mrandone%
echo %mreturn%
if [%fold%]==[0] (echo %menustb1%) else (echo %menustb%)
call :as
set /p _index= ^> %denter2%
if /i "%_index%"=="b" (if [%fold%]==[0] (GOTO :prompt) else (GOTO :esd_fold))
if "%_index%"=="" goto :QUIT
if "%_index%"=="0" set _index=&goto :MULTIMENU
for %%i in (%_index%) do call :setindex %%i
if %_count%==1 echo.&echo %emrandon%&echo.&PAUSE&goto :RANDOMMENU
for /L %%i in (1,1,%_count%) do (
if !_index%%i! GTR %images% echo.&echo !_index%%i! %emsel1%&echo.&PAUSE&goto :RANDOMMENU
)
for /L %%i in (1,1,%_count%) do (
set /a _index%%i+=3
)
goto :MAINMENU

:setindex
set /a _count+=1
set _index%_count%=%1
goto :eof

:MAINMENU
attrib -r -s -a -h "%ENCRYPTEDESD%"
if /i %Backup%==OFF (set Backup2=ON) else (set Backup2=OFF)
cls
set userinp=
call :as
echo %menust1%
echo %menust2%
echo %menust3%
echo %menust4%
IF %ENCRYPTED%==1 (
	echo %menust5%
	echo %menust6%
	echo %menust7%
	if [%fold%]==[0] (echo    %menustb1%) else (echo    %menustb%)
	call :as _
	echo %createsd1% %Backup%. %createsd2% %Backup2%
) else (
	echo %menust51%
	if [%fold%]==[0] (echo    %menustb1%) else (echo    %menustb%)
	call :as _
	echo %cryptesd%
)
call :as
echo.
set /p userinp= ^> %choice%
set userinp=%userinp:~0,1%
if %userinp%==0 GOTO :QUIT
if /i %userinp%==b (if [%fold%]==[0] (GOTO :prompt) else (GOTO :esd_fold))
if %userinp%==4 (set WIMFILE=install.esd&goto :Single)
if %userinp%==3 (set WIMFILE=install.wim&goto :Single)
if %userinp%==2 (set WIMFILE=install.esd&goto :ISO)
if %userinp%==1 (set WIMFILE=install.wim&goto :ISO)
if %ENCRYPTED%==1 (
	if %userinp%==9 (if /i %Backup%==OFF (set Backup=ON) else (set Backup=OFF))&goto :MAINMENU
	if %userinp%==7 (GOTO :update)
	if %userinp%==6 (GOTO :keynew)
	if %userinp%==5 (GOTO :DDECRYPT)
)
if %ENCRYPTED%==0 (
if %userinp%==5 (GOTO :INFO))
GOTO :MAINMENU

:esd_fold
set userinp=
set "c=0"
set "f=0"
for %%A in ("%fold%") do set fold=%%~fA
call :esd_esd %fold%
cls
if %files_esd_num% neq 0 (
	set /a c+=%files_esd_num%
	echo.
	call :as
	echo %txt23% %fold%
	call :as
	echo.
	for /L %%i in (1, 1, %files_esd_num%) do (
		if not [!edition%%i!]==[] echo   %%i. !name%%i! && set /a f+=1
	)
	if !f!==0 (
		echo %txt241%
	)
)
if %c%==0 (
echo.
call :as
echo %txt24% %fold%
call :as
)
echo.
call :as
echo %txt25%
call :as
set /p userinp= ^> %txt10%: 
set userinp=%userinp:~0,6%
if %files_esd_num% neq 0 (
	for /L %%i in (1, 1, %files_esd_num%) do (
		if /i %userinp%==%%i (
			if not [!edition%%i!]==[] set "ENCRYPTEDESD=!fold!\!files_esd%%i!"&set "ENCRYPTEDESDN=!fold!\!files_esd%%i!"&goto :check
		)
	)
)
if /i %userinp%==q goto :QUIT
if %userinp%==0 goto :prompt
GOTO :esd_fold

:esd_esd
dir /b %1\*.esd>bin\temp\files_esd.txt 2>nul
for /f "tokens=3 delims=: " %%i in ('find /v /n /c "" bin\temp\files_esd.txt') do set files_esd_num=%%i
for /L %%i in (1, 1, %files_esd_num%) do (
	call :esds_esd %%i
)
del /f /q bin\temp\files_esd.txt >nul 2>&1
exit /b

:keynew
cls
echo.
call :as
echo %addkey%
call :as
echo.
set /p keynew=
echo set "newkey=%keynew%">newkey.cmd
echo.
echo %done%
echo.
echo %presscont%
pause >nul
GOTO :MAINMENU

:update
cls
echo.
call :as
echo %updkey%
call :as
echo.
IF EXIST "%CD%\updates_keys_and_revision.cmd" (
	call updates_keys_and_revision.cmd
	GOTO :MAINMENU
)
echo %upderr%
echo.
echo %presskey%
pause >nul
GOTO :MAINMENU

:ISO
cls
IF %ENCRYPTED%==1 CALL :DECRYPT
IF %PREPARED%==0 CALL :PREPARE
echo.
call :as
echo %creat% Setup Media Layout...
call :as
IF EXIST ISOFOLDER\ rmdir /s /q ISOFOLDER\
mkdir ISOFOLDER
echo.
"%wimlib%" apply "%ENCRYPTEDESD%" 1 ISOFOLDER\ >nul 2>&1
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind1e%&PAUSE&GOTO :QUIT)
del ISOFOLDER\MediaMeta.xml >nul 2>&1
echo.
call :as
echo %creat% boot.wim...
call :as
echo.
"%wimlib%" export "%ENCRYPTEDESD%" 2 ISOFOLDER\sources\boot.wim --compress=maximum
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
echo.
"%wimlib%" export "%ENCRYPTEDESD%" 3 ISOFOLDER\sources\boot.wim --boot
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
"%wimlib%" extract ISOFOLDER\sources\boot.wim 2 sources\dism.exe --dest-dir=.\bin\temp --no-acls >nul 2>&1
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (
	"%wimlib%" update ISOFOLDER\sources\boot.wim 2 <bin\wim-update.txt 1>nul 2>nul
)
rd /s /q .\bin\temp >nul 2>&1
echo.
call :as
echo %creat% %WIMFILE%...
call :as
echo.
IF %MULTI%==0 (set sourcetime=4) else (set sourcetime=%MULTI%)
for /f "tokens=5,6,7,8,9,10 delims=: " %%G in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" %sourcetime% ^| find /i "Last Modification Time"') do (set mmm=%%G&set "isotime=%%H/%%L,%%I:%%J:%%K")
call :setdate %mmm%
set source=4
if defined _single set source=%_single%
if defined _start set source=%_start%&set /a _start+=1
if defined _index set source=%_index1%
if %savess%==yes (if not defined _single IF NOT %MULTI%==0 call :winre_ext)
if /i %WIMFILE%==install.wim set "compress=maximum"
call :exp_esd %source% "ISOFOLDER\sources\%WIMFILE%" %compress%
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
if defined _single (
	for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info ISOFOLDER\sources\%WIMFILE% 1 ^| find /i "<EDITIONID>"') do set editionid=%%i
	call :SINGLEINFO
	GOTO :ISOproceed
)
if defined _start FOR /L %%j IN (%_start%,1,%_end%) DO (call :exp_esd %%j "ISOFOLDER\sources\%WIMFILE%")
if defined _index for /L %%j in (2,1,%_count%) do (call :exp_esd !_index%%j! "ISOFOLDER\sources\%WIMFILE%")
if not defined _start if not defined _index IF NOT %MULTI%==0 (FOR /L %%j IN (5,1,%MULTI%) DO (call :exp_esd %%j "ISOFOLDER\sources\%WIMFILE%"))
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
rd /s /q .\bin\temp >nul 2>&1
echo.
call :as
echo %optimate% %WIMFILE%...
call :as
echo.
"%wimlib%" optimize ISOFOLDER\sources\%WIMFILE%
:ISOproceed
echo.
call :as
echo %creat% ISO...
call :as
bin\cdimage.exe -bootdata:2#p0,e,b"ISOFOLDER\boot\etfsboot.com"#pEF,e,b"ISOFOLDER\efi\Microsoft\boot\efisys.bin" -o -m -u2 -udfver102 -t%isotime% -g -l%DVDLABEL% ISOFOLDER %DVDISO%
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (
	echo.
	echo %ind3e%
	echo.
	echo %presskey%
	pause >nul
	IF EXIST "%ENCRYPTEDESD%.bak" (
		del /f /q "%ENCRYPTEDESD%" >nul 2>&1
		ren "%ENCRYPTEDESD%.bak" %ENCRYPTEDESDN%
	)
	exit
)
rmdir /s /q ISOFOLDER\ >nul 2>&1
echo.
echo %presskey%
pause >nul
GOTO :QUIT

:Single
cls
if %WIMFILE%==install.wim IF EXIST "%CD%\install.wim" (
	echo.
	call :as
	echo %singlee%
	call :as
	echo.
	echo %presskey%
	pause >nul
	GOTO :QUIT
)
IF %ENCRYPTED%==1 CALL :DECRYPT
IF %PREPARED%==0 CALL :PREPARE
echo.
call :as
echo %creat% %WIMFILE% %filei%...
call :as
echo.
set source=4
if defined _single set source=%_single%
if defined _start set source=%_start%&set /a _start+=1
if defined _index set source=%_index1%
if %savess%==yes (if not defined _single IF NOT %MULTI%==0 call :winre_ext)
if /i %WIMFILE%==install.wim set "compress=maximum"
call :exp_esd %source% "%WIMFILE%" %compress%
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
if defined _single GOTO :WIMproceed
if defined _start FOR /L %%j IN (%_start%,1,%_end%) DO (call :exp_esd %%j "%WIMFILE%")
if defined _index for /L %%j in (2,1,%_count%) do (call :exp_esd !_index%%j! "%WIMFILE%")
if not defined _start if not defined _index IF NOT %MULTI%==0 (FOR /L %%j IN (5,1,%MULTI%) DO (call :exp_esd %%j "%WIMFILE%"))
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
rd /s /q .\bin\temp >nul 2>&1
echo.
call :as
echo %optimate% %WIMFILE%...
call :as
echo.
"%wimlib%" optimize %WIMFILE%
:WIMproceed
echo.
echo %done%
echo.
echo %presskey%
pause >nul
GOTO :QUIT

:exp_esd
set /a exp_esd=%1-3
if not [%3]==[] (set "compress=--compress^=%3") else (set "compress=")
"%wimlib%" export "%ENCRYPTEDESD%" %1 %2 %compress%
if %savess%==yes (
	for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%ENCRYPTEDESD%" %1 ^| findstr /i HIGHPART') do set "installhigh=%%i"
	for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%ENCRYPTEDESD%" %1 ^| findstr /i LOWPART') do set "installlow=%%i"
	for /f "skip=1 delims=" %%i in ('bin\wimlib-imagex.exe dir %2 %exp_esd% --path=Windows\WinSxS\ManifestCache 2^>nul') do "%wimlib%" update %2 %exp_esd% --command="delete '%%i'" 1>nul 2>nul
	if %exp_esd% GEQ 2 ("%wimlib%" update %2 %exp_esd% --command="add 'bin\temp\winre.wim' '\windows\system32\recovery\winre.wim'" 1>nul 2>nul)
	"%wimlib%" info %2 %exp_esd% --image-property LASTMODIFICATIONTIME/HIGHPART=%installhigh% --image-property LASTMODIFICATIONTIME/LOWPART=%installlow% 1>nul 2>nul
)
exit /b

:winre_ext
"%wimlib%" extract %ENCRYPTEDESD% 4 Windows\System32\Recovery\winre.wim --dest-dir=.\bin\temp --no-acls
attrib -S -H -I .\bin\temp\winre.wim
echo.
exit /b

:INFO
IF %PREPARED%==0 CALL :PREPARE
cls
call :as
echo %infoesd%
call :as
echo.
IF %MULTI%==0 echo %ios%: %_os%
IF NOT %MULTI%==0 (
	echo %ios% 1: %_os%
	FOR /L %%j IN (5,1,%MULTI%) DO (
		call set /a osnum=%%j-3
		echo %ios% !osnum!: !_os%%j!
	)
)
echo %iarch% %arch%
echo %ilanguage% %langid%
echo %iversion% %_ver%.%svcbuild%
if defined branch echo %ibranch% %branch%
echo.
echo %presscont%
pause >nul
GOTO :MAINMENU

:PREPARE
SET PREPARED=1
set editionids=0
set editionidc=0
set display=0
bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" | find /i "CoreSingleLanguage" 1>nul && set editionids=1
bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" | find /i "CoreCountrySpecific" 1>nul && set editionidc=1
bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 | find /i "Display Name" 1>nul && set display=1
for /f "tokens=2 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| findstr /b "Build"') do set build=%%i
if %build% LEQ 9600 GOTO :E_W81
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Major"') do set _ver1=%%i
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Minor"') do set _ver2=%%i
set _ver=%_ver1%.%_ver2%.%build%
if %display%==1 (
	for /f "tokens=1* delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| findstr /b "Name"') do set "_os=%%j"
) else (
	for /f "tokens=2* delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Display Name"') do set "_os=%%j"
)
CALL :MULTI
IF NOT %MULTI%==0 FOR /L %%g IN (5,1,%MULTI%) DO (
if !display!==1 (
	for /f "tokens=1* delims=: " %%i in ('bin\wimlib-imagex.exe info "!ENCRYPTEDESD!" %%g ^| findstr /b "Name"') do set "_os%%g=%%j"
	) else (
		for /f "tokens=2* delims=: " %%i in ('bin\wimlib-imagex.exe info "!ENCRYPTEDESD!" %%g ^| find /i "Display Name"') do set "_os%%g=%%j"
	)
)
for /f "tokens=2 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Architecture"') do set arch=%%i
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Edition"') do set editionid=%%i
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Default"') do set langid=%%i
for /f "tokens=4 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Service Pack Build"') do set svcbuild=%%i
"%wimlib%" extract "%ENCRYPTEDESD%" 1 sources\ei.cfg --dest-dir=.\bin\temp --no-acls >nul 2>&1
type .\bin\temp\ei.cfg 2>nul | find /i "Volume" 1>nul && set VOL=1
"%wimlib%" extract "%ENCRYPTEDESD%" 3 sources\SetupPlatform.dll --dest-dir=.\bin\temp --no-acls >nul 2>&1
bin\7z.exe l .\bin\temp\SetupPlatform.dll >.\bin\temp\version.txt 2>&1
for /f "tokens=4,5 delims=. " %%i in ('"findstr /B "FileVersion" .\bin\temp\version.txt" 2^>nul') do set version=%%i.%%j
for /f "tokens=7 delims=.) " %%i in ('"findstr /B "FileVersion" .\bin\temp\version.txt" 2^>nul') do set datetime=%%i
for /f "tokens=6 delims=.( " %%i in ('"findstr /B "FileVersion" .\bin\temp\version.txt" 2^>nul') do set branch=%%i
if /i %arch%==x86 (set _ss=x86) else (set _ss=amd64)
if /i %arch%==arm64 (set _ss=arm64)
"%wimlib%" extract "%ENCRYPTEDESD%" 4 Windows\WinSxS\Manifests\%_ss%_microsoft-windows-coreos-revision* --dest-dir=.\bin\temp --no-acls >nul 2>&1
for /f "tokens=6,7 delims=_." %%i in ('dir /b /o:d .\bin\temp\*.manifest') do set revision=%%i.%%j
if %version% neq %revision% (
	set version=%revision%
	for /f "tokens=5,6,7,8,9,10 delims=: " %%G in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 4 ^| find /i "Last Modification Time"') do (set mmm=%%G&set yyy=%%L&set ddd=%%H-%%I%%J)
	call :setmmm !mmm!
)
set _label2=
if /i %branch%==WinBuild (
	"%wimlib%" extract "%ENCRYPTEDESD%" 4 \Windows\System32\config\SOFTWARE --dest-dir=.\bin\temp --no-acls >nul
	reg load HKLM\TEMP .\bin\temp\SOFTWARE >nul
	for /f "skip=2 tokens=5,6 delims=. " %%i in ('"reg query "HKLM\TEMP\Microsoft\Windows NT\CurrentVersion\Update\TargetingInfo\Installed\Client.OS.rs2.%_ss%" /v Version" 2^>nul') do if not errorlevel 1 set _number1=%%i.%%j
	for /f "skip=2 tokens=3,4 delims=. " %%i in ('"reg query "HKLM\TEMP\Microsoft\Windows NT\CurrentVersion" /v BuildLabEx" 2^>nul') do if not errorlevel 1 set _number2=%%i.%%j
	if /i [!_number1!]==[!_number2!] (
		for /f "skip=2 tokens=3,4,5,6,7 delims=. " %%i in ('"reg query "HKLM\TEMP\Microsoft\Windows NT\CurrentVersion" /v BuildLabEx" 2^>nul') do if not errorlevel 1 set _label2=%%i.%%j.%%m.%%l_CLIENT
		for /f "skip=2 tokens=3 delims= " %%i in ('reg query "HKLM\TEMP\Microsoft\Windows NT\CurrentVersion" /v BuildBranch') do if not errorlevel 1 set branch=%%i
	) else (
		set revision=!_number1!
		call bin\revision.cmd
	)
	reg unload HKLM\TEMP >nul
)

if defined _label2 (set _label=%_label2%) else (set _label=%version%.%datetime%.%branch%_CLIENT)
for %%b in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do set _label=!_label:%%b=%%b!
for %%b in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do set langid=!langid:%%b=%%b!
rd /s /q .\bin\temp >nul 2>&1

if /i %arch%==x86 set archl=X86
if /i %arch%==x64 set archl=X64
if /i %arch%==x86_64 set arch=x64&set archl=X64
if /i %arch%==arm64 set archl=A64

if not defined _single IF NOT %MULTI%==0 if %savess%==no call :savess

IF %MULTI%==5 (
	if /i %editionid%==Professional set DVDLABEL=CCSA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PRO-CORE_OEMRET_%archl%FRE_%langid%.ISO
	if /i %editionid%==ProfessionalN set DVDLABEL=CCSNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PRON-COREN_OEMRET_%archl%FRE_%langid%.ISO
	if %build% GEQ 16299 (IF %VOL%==1 (set DVDLABEL=CPBA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%BUSINESS_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CCCOMA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CONSUMER_OEMRET_%archl%FRE_%langid%.ISO))
	if defined branch exit /b
)
IF %MULTI% GEQ 6 (
	if /i %editionid%==Professional set DVDLABEL=CCSA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%COMBINED_OEMRET_%archl%FRE_%langid%.ISO
	if /i %editionid%==ProfessionalN set DVDLABEL=CCSNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%COMBINEDN_OEMRET_%archl%FRE_%langid%.ISO
	if %editionids%==1 set DVDLABEL=CCSA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%COMBINEDSL_OEMRET_%archl%FRE_%langid%.ISO
	if %editionidc%==1 set DVDLABEL=CCCHA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%COMBINEDCHINA_OEMRET_%archl%FRE_%langid%.ISO
	if %build% GEQ 16299 (IF %VOL%==1 (set DVDLABEL=CPBA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%BUSINESS_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CCCOMA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CONSUMER_OEMRET_%archl%FRE_%langid%.ISO))
	if defined branch exit /b
)

:SINGLEINFO
if /i %editionid%==Starter set DVDLABEL=CSA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%STARTER_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==StarterN set DVDLABEL=CSNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%STARTERN_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==Cloud set DVDLABEL=CWCA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CLOUD_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==CloudN set DVDLABEL=CWCNNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CLOUDN_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==CloudE set DVDLABEL=CWCA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CLOUDE_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==CloudEN set DVDLABEL=CWCNNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CLOUDEN_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==CoreCountrySpecific set DVDLABEL=CCHA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CHINA_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==CoreSingleLanguage set DVDLABEL=CSLA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%SINGLELANGUAGE_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==Core set DVDLABEL=CCRA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%CORE_OEMRET_%archl%FRE_%langid%.ISO
if /i %editionid%==CoreN set DVDLABEL=CCRNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%COREN_OEMRET_%archl%FRE_%langid%.ISO
if /i %editionid%==ProfessionalSingleLanguage set DVDLABEL=CPRSLA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PROSINGLELANGUAGE_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==ProfessionalCountrySpecific set DVDLABEL=CPRCHA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PROCHINA_OEM_%archl%FRE_%langid%.ISO
if /i %editionid%==Professional (IF %VOL%==1 (set DVDLABEL=CPRA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%PROFESSIONALVL_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CPRA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PRO_OEMRET_%archl%FRE_%langid%.ISO))
if /i %editionid%==ProfessionalN (IF %VOL%==1 (set DVDLABEL=CPRNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%PROFESSIONALNVL_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CPRNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PRON_OEMRET_%archl%FRE_%langid%.ISO))
if /i %editionid%==ProfessionalEducation (IF %VOL%==1 (set DVDLABEL=CPREA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%PROFESSIONALEDUCATION_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CPREA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PROEDUCATION_OEMRET_%archl%FRE_%langid%.ISO))
if /i %editionid%==ProfessionalEducationN (IF %VOL%==1 (set DVDLABEL=CPRENA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%PROFESSIONALEDUCATIONN_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CPRENA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PROEDUCATIONN_OEMRET_%archl%FRE_%langid%.ISO))
if /i %editionid%==ProfessionalWorkstation (IF %VOL%==1 (set DVDLABEL=CPRWA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%PROFESSIONALWORKSTATION_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CPRWA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PROWORKSTATION_OEMRET_%archl%FRE_%langid%.ISO))
if /i %editionid%==ProfessionalWorkstationN (IF %VOL%==1 (set DVDLABEL=CPRWNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%PROFESSIONALWORKSTATIONN_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CPRWNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PROWORKSTATIONN_OEMRET_%archl%FRE_%langid%.ISO))
if /i %editionid%==Education (IF %VOL%==1 (set DVDLABEL=CEDA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%EDUCATION_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CEDA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%EDUCATION_RET_%archl%FRE_%langid%.ISO))
if /i %editionid%==EducationN (IF %VOL%==1 (set DVDLABEL=CEDNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%EDUCATIONN_VOL_%archl%FRE_%langid%.ISO) else (set DVDLABEL=CEDNA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%EDUCATIONN_RET_%archl%FRE_%langid%.ISO))
if /i %editionid%==Enterprise set DVDLABEL=CENA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISE_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseN set DVDLABEL=CENNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISEN_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseG set DVDLABEL=CEGA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISEG_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseGN set DVDLABEL=CEGNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISEGN_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseEval set DVDLABEL=CEEA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISEEVAL_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseNEval set DVDLABEL=CEENA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISENEVAL_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseS set DVDLABEL=CESA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISES_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseSN set DVDLABEL=CESNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISESN_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseSubscription set DVDLABEL=CESA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISESUBSCRIPTION_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseSubscriptionN set DVDLABEL=CESNA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISESUBSCRIPTIONN_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseSEval set DVDLABEL=CESEA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISESEVAL_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==EnterpriseSNEval set DVDLABEL=CESNEA_%archl%FREV_%langid%_DV5&set DVDISO=%_label%ENTERPRISESNEVAL_VOL_%archl%FRE_%langid%.ISO
if /i %editionid%==PPIPro set DVDLABEL=CPPIA_%archl%FRE_%langid%_DV5&set DVDISO=%_label%PPIPRO_OEM_%archl%FRE_%langid%.ISO
if defined branch exit /b

:savess
set saves=0
echo.
call :as
echo %savesize%
call :as
echo.
set /p saves= ^> %choices% 
set saves=%saves:~0,1%
if /i %saves%==1 set "savess=yes"
exit /b

:setdate
if /i %1==Jan set "isotime=01/%isotime%"
if /i %1==Feb set "isotime=02/%isotime%"
if /i %1==Mar set "isotime=03/%isotime%"
if /i %1==Apr set "isotime=04/%isotime%"
if /i %1==May set "isotime=05/%isotime%"
if /i %1==Jun set "isotime=06/%isotime%"
if /i %1==Jul set "isotime=07/%isotime%"
if /i %1==Aug set "isotime=08/%isotime%"
if /i %1==Sep set "isotime=09/%isotime%"
if /i %1==Oct set "isotime=10/%isotime%"
if /i %1==Nov set "isotime=11/%isotime%"
if /i %1==Dec set "isotime=12/%isotime%"
exit /b

:setmmm
if /i %1==Jan set "datetime=%yyy:~2%01%ddd%"
if /i %1==Feb set "datetime=%yyy:~2%02%ddd%"
if /i %1==Mar set "datetime=%yyy:~2%03%ddd%"
if /i %1==Apr set "datetime=%yyy:~2%04%ddd%"
if /i %1==May set "datetime=%yyy:~2%05%ddd%"
if /i %1==Jun set "datetime=%yyy:~2%06%ddd%"
if /i %1==Jul set "datetime=%yyy:~2%07%ddd%"
if /i %1==Aug set "datetime=%yyy:~2%08%ddd%"
if /i %1==Sep set "datetime=%yyy:~2%09%ddd%"
if /i %1==Oct set "datetime=%yyy:~2%10%ddd%"
if /i %1==Nov set "datetime=%yyy:~2%11%ddd%"
if /i %1==Dec set "datetime=%yyy:~2%12%ddd%"
exit /b

:MULTI
bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" 1>nul 2>nul
IF %ERRORLEVEL% EQU 74 SET ENCRYPTED=1&exit /b
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info "%ENCRYPTEDESD%" ^| findstr /c:"Image Count"') do set images=%%i
if %images%==4 exit /b
set MULTI=%images%
exit /b

:DDECRYPT
cls
echo.
CALL :DECRYPT
ren "%ENCRYPTEDESD%" Decrypted-%ENCRYPTEDESDN%
echo.
echo %presskey%
pause >nul
GOTO :QUIT

:DECRYPT
if /i %Backup%==ON (
	echo.
	call :as
	echo %ibackup%
	call :as
	copy /y "%ENCRYPTEDESD%" "%ENCRYPTEDESD%.bak" >nul
)
echo.
call :as
echo %idecr%
call :as
echo.
for /f "tokens=3 delims=: " %%i in ('find /v /n /c "" bin\key.cmd') do set newkeys=%%i
call bin\key.cmd
IF NOT %newkeys%==0 FOR /L %%c IN (1,1,%newkeys%) DO (
	bin\esddecrypt.exe "%ENCRYPTEDESD%" !newkey%%c! 2>nul&& (echo %done%&exit /b)
)
bin\esddecrypt.exe "%ENCRYPTEDESD%" >nul && (echo %done%&exit /b)
call newkey.cmd
bin\esddecrypt.exe "%ENCRYPTEDESD%" %newkey% >nul && (echo %done%&exit /b)
echo.
echo %idecre%
echo.
echo %presskey%
pause >nul
GOTO :QUIT

:E_W81
cls
echo.
call :as
echo   %iwin8%
call :as
echo.
echo %presskey%
pause >nul
goto :QUIT

:esds_esd
set "name%1=" && set "edition%1=" && SET "ENCRYPTEDt=%tDECRYPTED%"
for /f "usebackq  delims=" %%b in (`find /n /v "" bin\temp\files_esd.txt ^| find "[%1]"`) do set files_esd=%%b
if %1 GEQ 1 set files_esd=%files_esd:~3%
if %1 GEQ 10 set files_esd=%files_esd:~1%
if %1 GEQ 100 set files_esd=%files_esd:~1%
bin\wimlib-imagex.exe info "%fold%\%files_esd%" 4 1>nul 2>nul
IF %ERRORLEVEL% EQU 74 SET "ENCRYPTEDt=%tENCRYPTED%"
for /f "tokens=3 delims=: " %%i in ('bin\imagex.exe /info "%fold%\%files_esd%" ^| findstr /c:"Image Count"') do set images%1=%%i
if !images%1! LSS 4 exit /b
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%fold%\%files_esd%" 4 ^| find /i "<EDITIONID>"') do set edition%1=%%i
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%fold%\%files_esd%" 4 ^| find /i "<DEFAULT>"') do set langid%1=%%i
for /f "tokens=3 delims= " %%i in ('bin\dism /get-wiminfo /WimFile:^"%fold%\%files_esd%^" /Index:4 ^| find /i "Architecture"') do set arch%1=%%i
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%fold%\%files_esd%" 4 ^| find /i "<BUILD>"') do set build%1=%%i
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%fold%\%files_esd%" 4 ^| find /i "<SPBUILD>"') do set svcbuild%1=%%i
if /i !arch%1!==x86_64 set "arch%1=x64"
if /i !arch%1!==ARM64 set "arch%1=arm64"
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "%fold%\%files_esd%" 4 ^| find /i "<NAME>"') do set name=%%i
if !images%1! GEQ 5 (
	call :esd_name %1
)
set "name%1=!name! - !build%1!.!svcbuild%1! / !arch%1! / !langid%1! / !ENCRYPTEDt!"
set "files_esd%1=%files_esd%"
goto :eof

:esd_name
if !build%1! GEQ 10586 (
	if !build%1! GEQ 14393 (
		if !build%1! GEQ 15063 (
			if !build%1! GEQ 16299 (
				IF /i !edition%1!==Cloud set "name=Windows 10 Consumer"
				IF /i !edition%1!==Core set "name=Windows 10 Consumer"
				IF /i !edition%1!==Education set "name=Windows 10 Business"
				exit /b
			)
			IF /i !edition%1!==Professional (
				set "name=Windows 10 Combined"
				bin\imagex.exe /info "%fold%\%files_esd%" | find /i "CoreSingleLanguage" 1>nul && set "name=Windows 10 CombinedSL"
				bin\imagex.exe /info "%fold%\%files_esd%" | find /i "CoreCountrySpecific" 1>nul && set "name=Windows 10 CombinedChina"
			)
			IF /i !edition%1!==ProfessionalN set "name=Windows 10 CombinedN"
			exit /b
		)
		IF /i !edition%1!==Professional (
			set "name=Windows 10 Combined"
			bin\imagex.exe /info "%fold%\%files_esd%" | find /i "CoreSingleLanguage" 1>nul && set "name=Windows 10 CombinedSL"
			bin\imagex.exe /info "%fold%\%files_esd%" | find /i "CoreCountrySpecific" 1>nul && set "name=Windows 10 CombinedChina"
		)
		IF /i !edition%1!==ProfessionalN set "name=Windows 10 CombinedN"
		exit /b
	)
IF /i !edition%1!==Professional set "name=Windows 10 Multi"
IF /i !edition%1!==ProfessionalN set "name=Windows 10 MultiN"
exit /b
)
exit /b


:dCheck
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
SET combine=0
SET count=0
SET ESDmulti1=0
SET ESDmulti2=0
SET ESDenc1=0
SET ESDenc2=0
set ESDvol1=0
set ESDvol2=0
set ESDarch1=0
set ESDarch2=0
set ESDver1=0
set ESDver2=0
set ESDlang1=0
set ESDlang2=0
for /f "delims=" %%i in ('dir /b "*.esd"') do call :dCount %%i
CALL :dInfo 1
CALL :dInfo 2
if /i %ESDarch1% equ %ESDarch2% set "fold=%CD%"&goto :esd_fold
if /i %ESDver1% neq %ESDver2% set "fold=%CD%"&goto :esd_fold
if /i %ESDlang1% neq %ESDlang2% set "fold=%CD%"&goto :esd_fold
bin\wimlib-imagex.exe info "%ESDfile1%" 4 >nul 2>&1
IF %ERRORLEVEL% EQU 74 SET ENCRYPTED=1
bin\wimlib-imagex.exe info "%ESDfile2%" 4 >nul 2>&1
IF %ERRORLEVEL% EQU 74 SET ENCRYPTED=1

:DUALMENU
attrib -r -s -a -h "%ESDfile1%"
attrib -r -s -a -h "%ESDfile2%"
if /i %Backup%==OFF (set Backup2=ON) else (set Backup2=OFF)
set userint=
cls
echo.
echo %finddu%
call :as _
echo.
echo %youcreatdu%
echo.
echo %menudu1%
echo %menudu2%
echo %menudu3%
echo.
echo %menudu4%
call :as _
IF %ENCRYPTED%==1 (
	echo %createsd1% %Backup%. %createsd2% %Backup2%
	call :as_
)
echo.
set /p userint= ^> %denter% 
set userint=%userint:~0,1%
if %userint%==9 (if /i %Backup%==OFF (set Backup=ON) else (set Backup=OFF))&goto :DUALMENU
if %userint%==4 set "fold=%CD%"&goto :esd_fold
if %userint%==3 (set WIMFILE=install.wim&set combine=1&goto :Dual)
if %userint%==2 (set WIMFILE=install.wim&goto :Dual)
if %userint%==1 (set WIMFILE=install.esd&goto :Dual)
GOTO :DUALMENU

:dCount
set /a count+=1
set "ESDfile%count%=%1
goto :eof

:dInfo
set ESDeditiona%1=0
set ESDeditionn%1=0
set ESDeditions%1=0
set ESDeditionc%1=0
bin\imagex.exe /info "!ESDfile%1!" | find /i "Professional" 1>nul && set ESDeditiona%1=1
bin\imagex.exe /info "!ESDfile%1!" | find /i "ProfessionalN" 1>nul && set ESDeditionn%1=1
bin\imagex.exe /info "!ESDfile%1!" | find /i "CoreSingleLanguage" 1>nul && set ESDeditions%1=1
bin\imagex.exe /info "!ESDfile%1!" | find /i "CoreCountrySpecific" 1>nul && set ESDeditionc%1=1
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "!ESDfile%1!" 4 ^| find /i "<BUILD>"') do set ESDver%1=%%i
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "!ESDfile%1!" 4 ^| find /i "<EDITIONID>"') do set ESDedition%1=%%i
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "!ESDfile%1!" 4 ^| find /i "<DEFAULT>"') do set ESDlang%1=%%i
for /f "tokens=3 delims=<>" %%i in ('bin\imagex.exe /info "!ESDfile%1!" 4 ^| find /i "<ARCH>"') do (IF %%i EQU 0 (SET ESDarch%1=x86) ELSE (SET ESDarch%1=x64))
for /f "tokens=3 delims=: " %%i in ('bin\imagex.exe /info "!ESDfile%1!" ^| findstr /i /b /c:"Image Count"') do (IF %%i GEQ 5 SET ESDmulti%1=%%i)
bin\wimlib-imagex.exe info "!ESDfile%1!" 4 >nul 2>&1
IF %ERRORLEVEL% EQU 74 SET ESDenc%1=1
goto :eof

:Dual
cls
IF EXIST ISOFOLDER\ rmdir /s /q ISOFOLDER\
mkdir ISOFOLDER
CALL :dISO 1
CALL :dISO 2
IF NOT EXIST bin\temp\ mkdir bin\temp
bin\7z.exe l .\ISOFOLDER\x64\sources\SetupPlatform.dll >.\bin\temp\version.txt 2>&1
IF %ERRORLEVEL% NEQ 0 (
	echo.
	call :as
	echo %errsetup%
	call :as
	echo.
	echo %presskey%
	pause >nul
	exit
)
for /f "tokens=4,5 delims=. " %%i in ('"findstr /B "FileVersion" .\bin\temp\version.txt" 2^>nul') do set version=%%i.%%j
for /f "tokens=7 delims=.) " %%i in ('"findstr /B "FileVersion" .\bin\temp\version.txt" 2^>nul') do set datetime=%%i
for /f "tokens=6 delims=.( " %%i in ('"findstr /B "FileVersion" .\bin\temp\version.txt" 2^>nul') do set branch=%%i
"%wimlib%" extract "%ESDfile1%" 4 Windows\WinSxS\Manifests\*_microsoft-windows-coreos-revision* --dest-dir=.\bin\temp --no-acls >nul 2>&1
for /f "tokens=6,7 delims=_." %%i in ('dir /b /o:d bin\temp\*.manifest') do set revision=%%i.%%j
if %version% neq %revision% (
	set version=%revision%
	for /f "tokens=5,6,7,8,9,10 delims=: " %%G in ('bin\wimlib-imagex.exe info "%ESDfile1%" 4 ^| find /i "Last Modification Time"') do (set mmm=%%G&set yyy=%%L&set ddd=%%H-%%I%%J)
	call :setmmm !mmm!
)
call bin\revision.cmd
set _label2=
if /i %branch%==WinBuild (
	"%wimlib%" extract "%ESDfile1%" 4 \Windows\System32\config\SOFTWARE --dest-dir=.\bin\temp --no-acls >nul
	reg load HKLM\TEMP .\bin\temp\SOFTWARE >nul
	for /f "skip=2 tokens=3,4,5,6,7 delims=. " %%i in ('"reg query "HKLM\TEMP\Microsoft\Windows NT\CurrentVersion" /v BuildLabEx" 2^>nul') do if not errorlevel 1 set _label2=%%i.%%j.%%m.%%l_CLIENT
	for /f "skip=2 tokens=3 delims= " %%i in ('reg query "HKLM\TEMP\Microsoft\Windows NT\CurrentVersion" /v BuildBranch') do set branch=%%i
	reg unload HKLM\TEMP >nul
)
if defined _label2 (set _label=%_label2%) else (set _label=%version%.%datetime%.%branch%_CLIENT)
for %%b in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do set _label=!_label:%%b=%%b!
set langid=%ESDlang1%
for %%b in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do set langid=!langid:%%b=%%b!

set archl=X86-X64
if /i %ESDarch1%==x86 (set ESDarch1=X86) else (set ESDarch1=X64)
if /i %ESDarch2%==x86 (set ESDarch2=X86) else (set ESDarch2=X64)
if /i %DVDLABEL1% equ %DVDLABEL2% (
	set DVDLABEL=%DVDLABEL1%_%archl%FRE_%langid%_DV9
	set DVDISO=%_label%%DVDISO1%_%archl%FRE_%langid%.ISO
) else (
	set DVDLABEL=CCSA_%archl%FRE_%langid%_DV9
	set DVDISO=%_label%%DVDISO1%_%ESDarch1%FRE-%DVDISO2%_%ESDarch2%FRE_%langid%.ISO
)

if %combine%==0 goto :BCD
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info ISOFOLDER\x86\sources\install.wim ^| findstr /c:"Image Count"') do set imagesi=%%i
for /f "tokens=3 delims=: " %%i in ('bin\wimlib-imagex.exe info ISOFOLDER\x64\sources\install.wim ^| findstr /c:"Image Count"') do set imagesx=%%i
for /f "tokens=1* delims=: " %%i in ('bin\wimlib-imagex.exe info ISOFOLDER\x86\sources\install.wim 1 ^| findstr /b "Name"') do set "_osi=%%j x86"
for /f "tokens=1* delims=: " %%i in ('bin\wimlib-imagex.exe info ISOFOLDER\x64\sources\install.wim 1 ^| findstr /b "Name"') do set "_osx=%%j x64"
IF NOT %imagesi%==1 FOR /L %%g IN (2,1,%imagesi%) DO (
	for /f "tokens=1* delims=: " %%i in ('bin\wimlib-imagex.exe info ISOFOLDER\x86\sources\install.wim %%g ^| findstr /b "Name"') do set "_osi%%g=%%j x86"
)
IF NOT %imagesx%==1 FOR /L %%g IN (2,1,%imagesx%) DO (
	for /f "tokens=1* delims=: " %%i in ('bin\wimlib-imagex.exe info ISOFOLDER\x64\sources\install.wim %%g ^| findstr /b "Name"') do set "_osx%%g=%%j x64"
)
echo.
call :as
echo %iunif% install.wim...
call :as
echo.
echo %ix86d%
"%wimlib%" info ISOFOLDER\x86\sources\install.wim 1 "%_osi%" "%_osi%"
IF NOT %imagesi%==1 FOR /L %%g IN (2,1,%imagesi%) DO (
	"%wimlib%" info ISOFOLDER\x86\sources\install.wim %%g "!_osi%%g!" "!_osi%%g!"
)
echo.
echo %ix64d%
"%wimlib%" export ISOFOLDER\x64\sources\install.wim 1 ISOFOLDER\x86\sources\install.wim "%_osx%" "%_osx%"
IF NOT %imagesx%==1 FOR /L %%g IN (2,1,%imagesx%) DO (
	"%wimlib%" export ISOFOLDER\x64\sources\install.wim %%g ISOFOLDER\x86\sources\install.wim "!_osx%%g!" "!_osx%%g!"
)
echo.
echo Replacing \x86\sources\install.wim -^> \x64\sources\install.wim
del ISOFOLDER\x64\sources\install.wim >nul 2>&1
copy /y ISOFOLDER\x86\sources\install.wim ISOFOLDER\x64\sources\install.wim

:BCD
echo.
call :as
echo %ibcd%...
call :as
echo.
call bin\bcd.cmd
call :as
echo %creat% ISO...
call :as
for /f "tokens=5,6,7,8,9,10 delims=: " %%G in ('bin\wimlib-imagex.exe info ISOFOLDER\x64\sources\%WIMFILE% 1 ^| find /i "Last Modification Time"') do (set mmm=%%G&set "isotime=%%H/%%L,%%I:%%J:%%K")
call :setdate %mmm%
bin\cdimage.exe -bootdata:3#p0,e,b"ISOFOLDER\boot\etfsboot.com"#pEF,e,b"bin\efi\efisys.bin"#pEF,e,b"ISOFOLDER\efi\Microsoft\boot\efisys.bin" -o -m -u2 -udfver102 -t%isotime% -g -l%DVDLABEL% ISOFOLDER %DVDISO%
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (
	echo.
	echo %ind3e%
	echo.
	echo %presskey%
	pause >nul
	exit
)
rmdir /s /q ISOFOLDER\
echo.
echo %presskey%
pause >nul
GOTO :QUIT

:dISO
SET ENCRYPTEDESD=!ESDfile%1!
IF !ESDenc%1!==1 echo. & CALL :DECRYPT
"%wimlib%" extract "%ENCRYPTEDESD%" 1 sources\ei.cfg --dest-dir=.\bin --no-acls >nul 2>&1
type .\bin\ei.cfg 2>nul | find /i "Volume" 1>nul && set ESDvol%1=1
del bin\ei.cfg >nul 2>&1
CALL :dPREPARE %1
echo.
call :as
echo %creat% Setup Media Layout ^(!ESDarch%1!^)...
call :as
echo.
"%wimlib%" apply "%ENCRYPTEDESD%" 1 ISOFOLDER\!ESDarch%1!\ >nul 2>&1
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind1e%&PAUSE&GOTO :QUIT)
del ISOFOLDER\!ESDarch%1!\MediaMeta.xml >nul 2>&1
echo.
call :as
echo %creat% boot.wim ^(!ESDarch%1!^)...
call :as
echo.
"%wimlib%" export "%ENCRYPTEDESD%" 2 ISOFOLDER\!ESDarch%1!\sources\boot.wim --compress=maximum
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
echo.
"%wimlib%" export "%ENCRYPTEDESD%" 3 ISOFOLDER\!ESDarch%1!\sources\boot.wim --boot
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
echo.
call :as
echo %creat% %WIMFILE% ^(!ESDarch%1!^)...
call :as
echo.
if /i %WIMFILE%==install.wim set "compress=maximum"
call :exp_esd 4 "ISOFOLDER\!ESDarch%1!\sources\%WIMFILE%" %compress%
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
IF NOT !ESDmulti%1!==0 (
	FOR /L %%j IN (5,1,!ESDmulti%1!) DO (
		call :exp_esd %%j "ISOFOLDER\!ESDarch%1!\sources\%WIMFILE%"
		SET ERRORTEMP=%ERRORLEVEL%
		IF %ERRORTEMP% NEQ 0 (echo.&echo %ind2e%&PAUSE&GOTO :QUIT)
	)
	echo.
	call :as
	echo %optimate% %WIMFILE%...
	call :as
	echo.
	"%wimlib%" optimize "ISOFOLDER\!ESDarch%1!\sources\%WIMFILE%"
)
exit /b

:dPREPARE
IF !ESDmulti%1!==5 (
	if !ESDeditionn%1!==1 set DVDLABEL%1=CCSNA&set DVDISO%1=PRON-COREN_OEMRET
	if !ESDeditiona%1!==1 set DVDLABEL%1=CCSA&set DVDISO%1=PRO-CORE_OEMRET
	if !ESDver%1! GEQ 16299 (IF !ESDvol%1!==1 (set DVDLABEL%1=CPBA&set DVDISO%1=BUSINESS_VOL) else (set DVDLABEL%1=CCCOMA&set DVDISO%1=CONSUMER_OEMRET))
	exit /b
)
IF !ESDmulti%1! GEQ 6 (
	if !ESDeditionn%1!==1 set DVDLABEL%1=CCSNA&set DVDISO%1=COMBINEDN_OEMRET
	if !ESDeditiona%1!==1 set DVDLABEL%1=CCSA&set DVDISO%1=COMBINED_OEMRET
	if !ESDeditions%1!==1 set DVDLABEL%1=CCSA&set DVDISO%1=COMBINEDSL_OEMRET
	if !ESDeditionc%1!==1 set DVDLABEL%1=CCCHA&set DVDISO%1=COMBINEDCHINA_OEMRET
	if !ESDver%1! GEQ 16299 (IF !ESDvol%1!==1 (set DVDLABEL%1=CPBA&set DVDISO%1=BUSINESS_VOL) else (set DVDLABEL%1=CCCOMA&set DVDISO%1=CONSUMER_OEMRET))
	exit /b
)
if /i !ESDedition%1!==Core set DVDLABEL%1=CCRA&set DVDISO%1=CORE_OEMRET
if /i !ESDedition%1!==CoreN set DVDLABEL%1=CCRNA&set DVDISO%1=COREN_OEMRET
if /i !ESDedition%1!==CoreSingleLanguage set DVDLABEL%1=CSLA&set DVDISO%1=SINGLELANGUAGE_OEM
if /i !ESDedition%1!==CoreCountrySpecific set DVDLABEL%1=CCHA&set DVDISO%1=CHINA_OEM
if /i !ESDedition%1!==Professional (IF !ESDvol%1!==1 (set DVDLABEL%1=CPRA&set DVDISO%1=PROFESSIONALVL_VOL) else (set DVDLABEL%1=CPRA&set DVDISO%1=PRO_OEMRET))
if /i !ESDedition%1!==ProfessionalN (IF !ESDvol%1!==1 (set DVDLABEL%1=CPRNA&set DVDISO%1=PROFESSIONALNVL_VOL) else (set DVDLABEL%1=CPRNA&set DVDISO%1=PRON_OEMRET))
if /i !ESDedition%1!==Education (IF !ESDvol%1!==1 (set DVDLABEL%1=CEDA&set DVDISO%1=EDUCATION_VOL) else (set DVDLABEL%1=CEDA&set DVDISO%1=EDUCATION_RET))
if /i !ESDedition%1!==EducationN (IF !ESDvol%1!==1 (set DVDLABEL%1=CEDNA&set DVDISO%1=EDUCATIONN_VOL) else (set DVDLABEL%1=CEDNA&set DVDISO%1=EDUCATIONN_RET))
if /i !ESDedition%1!==Enterprise set DVDLABEL%1=CENA&set DVDISO%1=ENTERPRISE_VOL
if /i !ESDedition%1!==EnterpriseN set DVDLABEL%1=CENNA&set DVDISO%1=ENTERPRISEN_VOL
if /i !ESDedition%1!==PPIPro set DVDLABEL%1=CPPIA&set DVDISO%1=PPIPRO_OEM
if /i !ESDedition%1!==Cloud set DVDLABEL%1=CWCA&set DVDISO%1=CLOUD_OEM
if /i !ESDedition%1!==CloudN set DVDLABEL%1=CWCNNA&set DVDISO%1=CLOUDN_OEM
if /i !ESDedition%1!==EnterpriseG set DVDLABEL%1=CEGA&set DVDISO%1=ENTERPRISEG_VOL
if /i !ESDedition%1!==EnterpriseGN set DVDLABEL%1=CEGNA&set DVDISO%1=ENTERPRISEGN_VOL
if /i !ESDedition%1!==EnterpriseS set DVDLABEL%1=CES&set DVDISO%1=ENTERPRISES_VOL
if /i !ESDedition%1!==EnterpriseSN set DVDLABEL%1=CESNN&set DVDISO%1=ENTERPRISESN_VOL
if /i !ESDedition%1!==ProfessionalEducation (IF %VOL%==1 (set DVDLABEL%1=CPREA&set DVDISO%1=PROFESSIONALEDUCATION_VOL) else (set DVDLABEL%1=CPREA&set DVDISO%1=PROEDUCATION_OEMRET))
if /i !ESDedition%1!==ProfessionalEducationN (IF %VOL%==1 (set DVDLABEL%1=CPRENA&set DVDISO%1=PROFESSIONALEDUCATIONN_VOL) else (set DVDLABEL%1=CPRENA&set DVDISO%1=PROEDUCATIONN_OEMRET))
if /i !ESDedition%1!==ProfessionalWorkstation (IF %VOL%==1 (set DVDLABEL%1=CPRWA&set DVDISO%1=PROFESSIONALWORKSTATION_VOL) else (set DVDLABEL%1=CPRWA&set DVDISO%1=PROWORKSTATION_OEMRET))
if /i !ESDedition%1!==ProfessionalWorkstationN (IF %VOL%==1 (set DVDLABEL%1=CPRWNA&set DVDISO%1=PROFESSIONALWORKSTATIONN_VOL) else (set DVDLABEL%1=CPRWNA&set DVDISO%1=PROWORKSTATIONN_OEMRET))
if /i !ESDedition%1!==ProfessionalSingleLanguage set DVDLABEL%1=CPRSLA&set DVDISO%1=PROSINGLELANGUAGE_OEM
if /i !ESDedition%1!==ProfessionalCountrySpecific set DVDLABEL%1=CPRCHA&set DVDISO%1=PROCHINA_OEM
exit /b

:dlang
if /i %dlang%==ru-RU call bin\lang-esd.cmd -ru && exit /b
call bin\lang-esd.cmd -en
exit /b

:as
if [%1]==[_] (echo ____________________________________________________________________________) else (echo ============================================================================)
exit /b

:QUIT
IF EXIST ISOFOLDER\ rmdir /s /q ISOFOLDER\
IF EXIST "%ENCRYPTEDESD%.bak" (
	del /f /q "%ENCRYPTEDESD%" >nul 2>&1
	ren "%ENCRYPTEDESD%.bak" %ENCRYPTEDESDN%
)
exit