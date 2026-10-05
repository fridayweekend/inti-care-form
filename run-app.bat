@echo off
cd /d "%~dp0"
call flutter pub get
if errorlevel 1 goto end
call flutter run -d chrome
:end
pause
