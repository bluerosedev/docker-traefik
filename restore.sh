#!/bin/sh

# Use doble quote to prevent globbing and word splitting
# see https://github.com/koalaman/shellcheck/wiki/SC2086

# For Bash users, `.` (dot) is alias to `source` word.
# See https://github.com/koalaman/shellcheck/wiki/SC2039
# See https://wiki.ubuntu.com/DashAsBinSh#source
. /usr/local/bin/env_secrets_expand.sh

S3_BUCKET="${S3_BUCKET-no}"
S3_PATH="${S3_PATH-no}"
S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
S3_SECRET_KEY="${S3_SECRET_KEY-no}"

# determine whether we should register backup jobs

# Do not use return value
# See https://github.com/koalaman/shellcheck/wiki/SC2181

# determine whether we should register backup jobs
if [ "${S3_BUCKET}" != 'no' ] && \
   [ "${S3_PATH}" != 'no' ] && \
   [ "${S3_ACCESS_KEY}" != 'no' ] && \
   [ "${S3_SECRET_KEY}" != 'no' ] &&
   [ "${S3_REGION}" != 'no' ]
then

    echo "Attempting to restore ACME backup"

    URL="s3://${S3_BUCKET}/${S3_PATH}/acme.json"
    COUNT=$(s3cmd ls "${URL}" | wc -l)

    if [ "${COUNT}" -gt 0 ]; then

        echo 'Backup found, restoring'

        s3cmd get "${URL}" /etc/traefik/acme.json
        chmod 600 /etc/traefik/acme.json

        echo 'Backup restored'

    fi

fi
