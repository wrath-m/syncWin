cd %USERPROFILE%\syncCore
ssh-agent bash -c "ssh-add '%USERPROFILE%\syncCore\ssh-keys\id_rsa'; git pull"