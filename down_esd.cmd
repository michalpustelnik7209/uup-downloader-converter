@echo off
echo Enter download link for ESD file.
set /p "type=ESD link: "
aria2c %type%
exit