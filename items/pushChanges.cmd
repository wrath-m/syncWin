@echo off
cd %SYSTEMDRIVE%\syncCore
ssh-agent bash -c "ssh-add '%SYSTEMDRIVE%\syncCore\items\ssh-keys\id_rsa'; git add --all && git commit -m 'update' && git push"