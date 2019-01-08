@ECHO ON
SET SourceDir=%~dp0
SET DestDir=%~dp0
CD /D "C:\Program Files\7-Zip"
7z.exe a -tzip "%DestDir%\mzp\gre_tools.mzp" "%SourceDir%\lib" "%SourceDir%\icons" "%SourceDir%\gre_tools\*" "%SourceDir%\gre*.ms" -mx5
EXIT