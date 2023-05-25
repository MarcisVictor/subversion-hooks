@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Original Publication: 2006/03/02 - Subversion Mailing List
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
:: This is a pre-revprop-change hook for subversion that allows editing 
:: commit messages of previous commits. In addition, it makes sure that
:: whatever new message is of a certain length.
::
:: You can derive a post-revprop-change hook from it to backup the old 
:: 'snv:log' somewhere if you wish to keep its history of changes.
::
:: The only tricky part in this batch file was to be able to actually 
:: parse the stdin from the batch file. This is done here with the 
:: native FIND.EXE command.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get subversion arguments
set "repos=%~1"
set "rev=%2"
set "user=%3"
set "propname=%4"
set "action=%5"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set some variables
set /a mincharlimit=10

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Only allow changes to svn:log. The author, date and other revision
:: properties cannot be changed
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if /I not '%propname%'=='svn:log' goto ERROR_PROPNAME

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Only allow modifications to svn:log (no addition/overwrite or deletion)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if /I not '%action%'=='M' goto ERROR_ACTION

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Make sure that the new svn:log message contains some text.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set /a NumChar=0

for /f "tokens=*" %%g in ('find /V ""') do (
 set LogMsg=%%g
 echo %LogMsg%
 setlocal disableDelayedExpansion
 set NumChar=0
 for /f "delims=:" %%N in ('"(cmd /v:on /c echo(!LogMsg!&echo()|findstr /o ^^"') do set /a "NumChar=%%N-3"
 setlocal enableDelayedExpansion
)

if %NumChar% leq %mincharlimit% goto ERROR_EMPTY

goto :eof

:ERROR_EMPTY
echo Log messages must be at least %mincharlimit% characters (Current Length: %NumChar%). >&2
goto ERROR_EXIT

:ERROR_PROPNAME
echo Only changes to svn:log revision properties are allowed. >&2
goto ERROR_EXIT

:ERROR_ACTION
echo Only modifications to svn:log revision properties are allowed. >&2
goto ERROR_EXIT

:ERROR_EXIT
exit 1
::exit /b 1 :: (for manual debugging and not closing CMD.EXE)
