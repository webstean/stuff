@echo off

wsl --install
wsl --set-default-version 2
wsl --update
wsl --install Ubuntu-20.04 
wsl --setdefault Ubuntu-20.04 
wsl --status

@rem winget install --id Canonical.Ubuntu
