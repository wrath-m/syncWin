cd %SYSTEMDRIVE%\syncCore
ssh-agent bash -c "ssh-add '%SYSTEMDRIVE%\syncCore\items\ssh-keys\id_rsa'; git pull"