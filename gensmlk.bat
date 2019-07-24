REM @echo off

REM run this tool to symlinks folder
REM symlinks works like usual folder except that their content are excacly the ones
REM inside this folders

if not "%1"=="am_admin" (
    powershell start -WorkingDirectory '%~dp0' -verb runas '%0' am_admin & exit /b
)

set addon_names=CastBarZ CastBarZ_Config CastBarZ_Media
rem provisoire
set wow_path="D:\World of Warcraft\_retail_\Interface\AddOns"

rem mkdir %~dp0.symlinks
(for %%e in (%addon_names%) do (
    mklink /D %wow_path%\%%e %~dp0%%e    
    
))
rem mklink /D %~dp0.symlinks\%%e %~dp0%%e
pause