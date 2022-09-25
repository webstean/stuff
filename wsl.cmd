@echo off

wsl --install
wsl --set-default-version 2
wsl --update
wsl --install Ubuntu-20.04 
wsl --setdefault Ubuntu-20.04 
wsl --status
%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\ubuntu2004.exe config --default-user root

@rem winget install --id Canonical.Ubuntu
@rem winget uninstall --id Canonical.Ubuntu
