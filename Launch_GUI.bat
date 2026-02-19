@echo off
title NightShift GUI Launcher
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "NightShift_GUI.ps1"
