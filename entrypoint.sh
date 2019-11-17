#!/bin/sh -e

# For Bash users, `.` (dot) is alias to `source` word.
# See https://github.com/koalaman/shellcheck/wiki/SC2039
# See https://wiki.ubuntu.com/DashAsBinSh#source
. /usr/local/bin/env_secrets_expand.sh

S3_BUCKET="${S3_BUCKET-no}"
S3_PATH="${S3_PATH-no}"
S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
S3_SECRET_KEY="${S3_SECRET_KEY-no}"
S3_REGION="${S3_REGION-no}"

# Do not use return value
# See https://github.com/koalaman/shellcheck/wiki/SC2181

# determine whether we should register backup jobs
if [ "${S3_BUCKET}" != 'no' ] && \
   [ "${S3_PATH}" != 'no' ] && \
   [ "${S3_ACCESS_KEY}" != 'no' ] && \
   [ "${S3_SECRET_KEY}" != 'no' ] &&
   [ "${S3_REGION}" != 'no' ]
then

    echo "Configuring backup"
    echo "0 3 2-31 * 0 root supervisorctl start acme-backup" > /etc/cron.d/backup-weekly

    dockerize --template /root/.s3cfg.tmpl:/root/.s3cfg
    /usr/local/bin/restore.sh

fi

dockerize --template /etc/traefik/traefik.toml.tmpl:/etc/traefik/traefik.toml \
            supervisord --configuration /etc/supervisord.conf
