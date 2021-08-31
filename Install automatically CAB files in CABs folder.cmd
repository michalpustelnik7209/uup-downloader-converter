@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
forfiles /p "%~dp0\CABs" /s /m *.cab /c "cmd /c dism /online /add-package /packagepath:@path"
echo 1. Yes, restart
echo 2. No, do not restart
choice /c 12 /m "Installation of detected cab's complete, restart?"

if errorlevel equ 1 shutdown -r -t 0 -f
if errorlevel equ 0 goto eof

:eof
exit