@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0End_Stream_Cleanup.ps1"
pause
