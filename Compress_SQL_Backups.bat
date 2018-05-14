rem Compress *.bak files
FOR %%i IN (*.bak) DO 7z.exe a -t7z -mx7 -sdel "%%~ni.7z" "%%i"

rem Keep the last 5 files
pushd "F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Backup"
for %%X in (7z) do (
  set "skip=1"
  for /f "skip=5 delims=" %%F in ('dir /b /a-d /o-d /tw *.%%X') do (
    if defined skip forfiles /d -5 /m "%%F" >nul 2>nul && set "skip="
    if not defined skip del "%%F" 
  )
) 