#This script uses the .NET FileSystemWatcher class to monitor file events in folder(s).
#The advantage of this method over using WMI eventing is that this can monitor sub-folders.
#The -Action parameter can contain any valid Powershell commands.  I have just included two for example.
#The script can be set to a wildcard filter, and IncludeSubdirectories can be changed to $true.
#You need not subscribe to all three types of event.  All three are shown for example.
# Version 1.1

#Unregister-Event FileDeleted -EA 'SilentlyContinue'
#Unregister-Event FileCreated -EA 'SilentlyContinue'

# Here, all three events are registerd.  You need only subscribe to events that you need:

# Register-ObjectEvent $sublimeSettings Created -SourceIdentifier FileCreated -Action {
    # $name = $Event.SourceEventArgs.Name
    # $changeType = $Event.SourceEventArgs.ChangeType
    # $timeStamp = $Event.TimeGenerated
    # Write-Host "The file '$name' was $changeType at $timeStamp" -fore green
    # Out-File -FilePath Drive:\scripts\filechange\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"
# }

# Register-ObjectEvent $sublimeSettings Deleted -SourceIdentifier FileDeleted -Action {
    # $name = $Event.SourceEventArgs.Name
    # $changeType = $Event.SourceEventArgs.ChangeType
    # $timeStamp = $Event.TimeGenerated
    # Write-Host "The file '$name' was $changeType at $timeStamp" -fore red
    # Out-File -FilePath Drive:\scripts\filechange\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"
# }

# ----------------------------------------------------------------------#

$userProfile = $env:USERPROFILE

$watch = @(
    @('\portable\SublimeText3\Data\Packages\User', @('Preferences.sublime-settings')),
    @()
)

Unregister-Event FileChanged -EA 'SilentlyContinue'

$nullPath = $userProfile + '\syncCore\null'
$userProfile + '\syncCore\items\runSyncFunc.cmd' > $nullPath 2>&1

echo $userProfile

# Update synced files from source
$copy = $userProfile + '\syncCore\portable\SublimeText3\Data\Packages\User\Preferences.sublime-settings'
$paste = $userProfile + '\sync\portable\SublimeText3\Data\Packages\User\Preferences.sublime-settings'
Copy-Item $copy $paste

$folder = $userProfile + '\sync\portable\SublimeText3\Data\Packages\User' # Enter the root path you want to monitor.
$filter = '*.*'  # You can enter a wildcard filter here.

# In the following line, you can change 'IncludeSubdirectories to $true if required.
$sublimeSettings = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

Register-ObjectEvent $sublimeSettings Changed -SourceIdentifier FileChanged -Action {
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated
    if ($name -eq 'Preferences.sublime-settings') {
        $copy = $userProfile + '\sync\portable\SublimeText3\Data\Packages\User\Preferences.sublime-settings'
        $paste = $userProfile + '\syncCore\portable\SublimeText3\Data\Packages\User\Preferences.sublime-settings'
        Copy-Item $copy $paste
        Stop-Job -Name pushChangesTimeout
        Start-Job -Name pushChangesTimeout -ScriptBlock {
            Start-Sleep -s 5
            pushChanges.cmd
        }
    }
}

# To stop the monitoring, run the following commands:
# Unregister-Event FileDeleted
# Unregister-Event FileCreate
# Unregister-Event FileChanged