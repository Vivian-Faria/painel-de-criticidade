@echo off
setlocal
set "BASE_DIR=%~dp0"
powershell -ExecutionPolicy Bypass -File "%BASE_DIR%scripts\publicar_painel.ps1"
exit /b %errorlevel%
