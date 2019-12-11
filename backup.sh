#!/bin/sh -e

. /usr/local/bin/env_secrets_expand.sh

if [ -e "/etc/traefik/acme.json" ]; then

    URL="s3://${S3_BUCKET}/${S3_PATH}/"

    echo "Uploading acme.json to ${URL}"

    s3cmd put -f /etc/traefik/acme.json ${URL}

    echo 'Upload complete'

else
    echo 'No acme.json file detected. Doing nothing'
fi


