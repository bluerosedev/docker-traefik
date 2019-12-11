#!/bin/sh

. /usr/local/bin/env_secrets_expand.sh

S3_BUCKET="${S3_BUCKET-no}"
S3_PATH="${S3_PATH-no}"
S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
S3_SECRET_KEY="${S3_SECRET_KEY-no}"

# determine whether we should register backup jobs

[ "${S3_BUCKET}" != 'no' ] && \
[ "${S3_PATH}" != 'no' ] && \
[ "${S3_ACCESS_KEY}" != 'no' ] && \
[ "${S3_SECRET_KEY}" != 'no' ]

if [ "$?" -eq 0 ]; then

    echo "Attempting to restore ACME backup"

    URL="s3://${S3_BUCKET}/${S3_PATH}/acme.json"
    COUNT=$(s3cmd ls ${URL} | wc -l)

    if [[ ${COUNT} -gt 0 ]]; then

        echo 'Backup found, restoring'

        s3cmd get ${URL} /etc/traefik/acme.json
        chmod 600 /etc/traefik/acme.json

        echo 'Backup restored'

    fi

fi
