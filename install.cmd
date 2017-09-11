:: BatchGetAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto getAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:getAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
icacls "%SYSTEMDRIVE%\ProgramData\chocolatey" /grant Users:(OI)(CI)F
mkdir %USERPROFILE%\sync
mkdir %USERPROFILE%\syncCore
choco install git -params '"/GitAndUnixToolsOnPath"'
setx /M PATH "%PATH%;%SYSTEMDRIVE%\Program Files\Git\cmd;%SYSTEMDRIVE%\Program Files\Git\usr\bin"
call "refreshEnvPath.cmd"
ssh-agent bash -c 'ssh-add "%cd%\ssh-keys\id_rsa"; git clone git@github.com:scarrtech/syncWin.git "%USERPROFILE%\syncCore\."'
setx /M PATH "%PATH%;%USERPROFILE%\syncCore\items"
cp -r "%USERPROFILE%\syncCore\portable" "%USERPROFILE%\sync"
cp "%USERPROFILE%\syncCore\items\syncRunProcess.cmd" "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\syncRunProcess.cmd"
PowerShell -NoProfile -ExecutionPolicy Bypass -NoExit "%USERPROFILE%\syncCore\items\sync.ps1"