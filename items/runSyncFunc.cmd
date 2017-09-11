cp "%USERPROFILE\syncCore\items\syncRunProcess.cmd" "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\syncRunProcess.cmd"
cd %USERPROFILE%\syncCore
ssh-agent bash -c "ssh-add '%USERPROFILE%\syncCore\ssh-keys\id_rsa'; git pull"
:: copy all watched files