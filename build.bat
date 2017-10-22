@echo off

if not exist "%DOTA_HOME%" (
	echo The Dota 2 directory must be set before running.
	echo Example: set DOTA_HOME=C:\Program Files ^(x86^)\Steam\steamapps\common\dota 2 beta
) else (
	rem Remove the old directories to account for files getting removed
	rmdir /S /Q "%DOTA_HOME%\game\dota_addons\hunter_v_hunted"
	rmdir /S /Q "%DOTA_HOME%\content\dota_addons\hunter_v_hunted"

	xcopy .\game\hunter_v_hunted "%DOTA_HOME%\game\dota_addons\hunter_v_hunted" /Q /Y /E /I
	xcopy .\content\hunter_v_hunted "%DOTA_HOME%\content\dota_addons\hunter_v_hunted" /Q /Y /E /I
)