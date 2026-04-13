@echo off
set "BASE_DIR=%~dp0"
start "Scraper Orion" cmd /k "cd /d %BASE_DIR% && python orion_scraper_1.py --loop"
timeout /t 3 /nobreak >nul
start "Servidor Painel" cmd /k "python -m http.server 8000 --bind 127.0.0.1 --directory %BASE_DIR%"
timeout /t 2 /nobreak >nul
start "" http://127.0.0.1:8000/index.html
