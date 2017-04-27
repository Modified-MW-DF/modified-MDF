@echo off
:: put in World Viewer utilities folder, launches the correct 32/64 bit for your system
:: then add the executables to the exclusion list to hide from the launcher
:: adapted from https://support.microsoft.com/kb/556009

cd %~dp0

Set RegQry=HKLM\Hardware\Description\System\CentralProcessor\0
 
REG.exe Query %RegQry% > checkOS.txt
 
Find /i "x86" < CheckOS.txt > StringCheck.txt
 
If %ERRORLEVEL% == 0 (
    CD 32bit
) ELSE (
    CD 64bit
)
DFWV.exe
