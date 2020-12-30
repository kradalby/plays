# Template file for backup destination configuration and email passwords.
# Update this file to point to your restic repository and email service.
# Rename to `secrets.ps1`

$Env:RESTIC_REPOSITORY='{{ restic_backup_job_repos[0] }}'
$Env:RESTIC_PASSWORD='{{ restic_backup_job_password }}'

# email configuration
$PSEmailServer='smtp.fap.no'
$ResticEmailConfig=@{UseSsl=$false; Port="25"}
$ResticEmailTo='kristoffer@dalby.cc'
$ResticEmailFrom='restic-windows@fap.no'
