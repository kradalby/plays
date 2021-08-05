{% set excludes = restic_backup_job_excludes | map('regex_replace', '^', '--exclude=') | list | join(" ") -%}
{% set directories = restic_backup_job_directories | join(" ") -%}

export RESTIC="/usr/local/bin/restic {% if restic_cache_dir != "" %}--cache-dir {{ restic_cache_dir }}{% endif %} {% if restic_backup_job_no_cache %}--no-cache{% endif %}"

export RESTIC_PASSWORD="{{ restic_backup_job_password }}"
export RESTIC_REPOSITORY="{{ item.repo }}"
export RESTIC_REPOSITORY_FRIENDLY_NAME="{{ item.repo | restic_repo_friendly_name }}"
export GOMAXPROCS=1

export RESTIC_EXCLUDES="{{ excludes }}"
export RESTIC_DIRECTORIES="{{ directories }}"

{% if 'retention' in item and item.retention == 'short' %}
export RESTIC_RETENTION="--keep-hourly 8 --keep-daily 7 --keep-weekly 4"
{% else %}
export RESTIC_RETENTION="--keep-hourly 8 --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 10"
{% endif %}

export RESTIC_CACHE_MAX_AGE="{{ restic_max_age }}"
