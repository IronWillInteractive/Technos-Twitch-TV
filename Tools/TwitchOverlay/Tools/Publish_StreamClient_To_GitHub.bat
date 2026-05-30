@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish_StreamClient_To_GitHub.ps1"
pause
