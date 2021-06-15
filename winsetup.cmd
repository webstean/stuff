@echo off

@rem Windows Setup for WinPe

@rem Windows Image Index 

Instructions Windows Setup which OS image to install from install.wim if multiple images may be applicable.

Syntax
/ImageIndex <index>

Syntax


/Unattend
Enables you to use an answer file with Windows Setup.

Syntax
/Unattend:<answer_file>

/WDSDiscover
Specifies that the Windows Deployment Services (WDS) client should be in discover mode.

setup /ImageIndex 3 /ResizeRecoveryPartition Enable 

@rem Windows Deployment System
@rem /WDSDiscover


if %ERRORLEVEL% 0 then 

:NOK 
@echo Something went wrong %ERRORLEVEL%
@echo 0x3	This upgrade was successful.
@echo 0x5	The compatibility check detected issues that require resolution before the upgrade can continue.
@echo 0x7	The installation option (upgrade or data only) was not available.
goto END

:OK
@echo.
@echo Windows Setup completed sucessfully
@echo.

:END













