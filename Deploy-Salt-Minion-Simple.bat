# Author: Perry Stathopoulos
# Company: Crestline IT Services
# Use this script to run from a central server, like AD, to install the Salt Minion on one PC
# Download the Salt-Minion install file on a central file server

SET FILE_SERVER=
SET REMOTE_PC=
SET MASTER_URL=

copy /Y \\%FILE_SERVER%\Company\IT\Salt-Minion-2017.7.1-Py3-AMD64-Setup.exe \\%REMOTE_PC%\c$\windows\temp
psexec \\%REMOTE_PC% c:\windows\temp\Salt-Minion-2017.7.1-Py3-AMD64-Setup.exe /S /master=%MASTER_URL%

