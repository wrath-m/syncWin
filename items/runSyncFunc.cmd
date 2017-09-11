cd %SYSTEMDRIVE%\syncCore
ssh-agent bash -c "ssh-add '%SYSTEMDRIVE%\syncCore\ssh-keys\id_rsa'; git pull"