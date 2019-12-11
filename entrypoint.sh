#!/bin/sh -e

. /usr/local/bin/env_secrets_expand.sh

S3_BUCKET="${S3_BUCKET-no}"
S3_PATH="${S3_PATH-no}"
S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
S3_SECRET_KEY="${S3_SECRET_KEY-no}"
S3_REGION="${S3_REGION-no}"

# determine whether we should register backup jobs

[ "${S3_BUCKET}" != 'no' ] && \
[ "${S3_PATH}" != 'no' ] && \
[ "${S3_ACCESS_KEY}" != 'no' ] && \
[ "${S3_SECRET_KEY}" != 'no' ] &&
[ "${S3_REGION}" != 'no' ]

if [ "$?" -eq 0 ]; then

    echo "Configuring backup"
    echo "0 3 2-31 * 0 root supervisorctl start acme-backup" > /etc/cron.d/backup-weekly

    dockerize --template /root/.s3cfg.tmpl:/root/.s3cfg
    /usr/local/bin/restore.sh

fi

dockerize --template /etc/traefik/traefik.toml.tmpl:/etc/traefik/traefik.toml \
            supervisord --configuration /etc/supervisord.conf
