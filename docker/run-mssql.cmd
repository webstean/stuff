@echo off
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Password1!" -p 1433:1433 -d mcr.microsoft.com/mssql/server:latest
@rem help
