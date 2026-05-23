@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_web.ps1"
endlocal
