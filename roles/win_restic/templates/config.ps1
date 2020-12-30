# backup configuration
$ExeName = "restic.exe"
$InstallPath = "C:\restic"
$ResticExe = $ExeName
$StateFile = Join-Path $InstallPath "state.xml"
$WindowsExcludeFile = Join-Path $InstallPath "windows.exclude"
$LocalExcludeFile = Join-Path $InstallPath "local.exclude"
$LogPath = Join-Path $InstallPath "logs"
$LogRetentionDays = 30
$InternetTestAttempts = 10
$GlobalRetryAttempts = 4

# maintenance configuration
$SnapshotMaintenanceEnabled = $true
$SnapshotRetentionPolicy = @("--keep-daily", "30", "--keep-weekly", "52", "--keep-monthly", "24", "--keep-yearly", "10")
$SnapshotMaintenanceInterval = 7
$SnapshotMaintenanceDays = 30
$SnapshotDeepMaintenanceDays = 90;

# email configuration
$SendEmailOnSuccess = $true
$SendEmailOnError = $true

# Paths to backup
$BackupSources = @{}
$BackupSources["C:\"] = @(
{% for dir in restic_backup_job_directories %}
   '{{ dir }}'
{% endfor %}
)
#$BackupSources["D:\"] = @(
#    'Software'
#)
