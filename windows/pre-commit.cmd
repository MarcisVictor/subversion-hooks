@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Original Publication: 2010/09/02 - Stackoverflow
:: Source:              https://github.com/MarcisVictor/subversion-hooks
:: Author(s):           Philibert Perusse, ing., M.Sc.A. - http://philibertperusse.me
::						Marc-Andre Drouin, P.Eng.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Licensed under the Creative Commons Attribution 3.0 License - http://creativecommons.org/licenses/by/3.0/
::  - Free for use in both personal and commercial projects
::  - Attribution requires leaving author name, author link, and the license info intact.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: This is a pre-commit hook for subversion that ensures that your 
:: commit messages are a certain length.
:: The Length is configurable (mincharlimit).
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get subversion arguments
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "repos=%~1"
set "txn=%2"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set some variables
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set svnlookparam="%repos%" -t %txn%
set /a mincharlimit=10

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Make sure that the new svn:log message contains some text.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set /a NumChar=0

for /f "tokens=* usebackq" %%g in (`svnlook log %svnlookparam%`) do (
	set LogMsg=%%g
	setlocal disableDelayedExpansion
	for /f "delims=:" %%N in ('"(cmd /v:on /c echo(!LogMsg!&echo()|findstr /o ^^"') do set /a "NumChar+=%%N"
	::Remove extra characters that don't count from the lookup
	set /a "NumChar+=-3"
	setlocal enableDelayedExpansion
)

if %NumChar% lss %mincharlimit% goto ERROR_MSG_LENGTH

echo Allowed. >&2

goto :END


:ERROR_MSG_LENGTH
echo Log messages must be at least %mincharlimit% characters (Current Length: %NumChar%). >&2
goto ERROR_EXIT

:ERROR_EXIT
exit 1
::exit /b 1 :: (for manual debugging and not closing CMD.EXE)

:END
endlocal
