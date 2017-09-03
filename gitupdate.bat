@echo off
SET SOURCEDIR=C:\Steam\steamapps\common\skyrim\Data
SET TARGETDIR=%USERPROFILE%\Dropbox\SkyrimMod\IonCannon\dist\Data

xcopy /E /U /Y "%SOURCEDIR%\*" "%TARGETDIR%\"

