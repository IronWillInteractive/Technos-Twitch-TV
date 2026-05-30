@echo off
setlocal
cd /d "%~dp0"
title PRO-CRAWL OS Local Teleprompter
cls
echo ============================================================
echo   PRO-CRAWL OS - Professional Local Teleprompter System
echo ============================================================
echo.
echo Starting local server...
echo.
where py >nul 2>nul
if %errorlevel%==0 (
    py server.py
    goto :end
)
where python >nul 2>nul
if %errorlevel%==0 (
    python server.py
    goto :end
)
echo Python was not found. Opening index.html directly instead.
start "" "%~dp0index.html"
:end
pause
