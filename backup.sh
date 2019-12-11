#!/bin/sh -e

# For Bash users, `.` (dot) is alias to `source` word.
# See https://github.com/koalaman/shellcheck/wiki/SC2039
# See https://wiki.ubuntu.com/DashAsBinSh#source
. /usr/local/bin/env_secrets_expand.sh

if [ -e "/etc/traefik/acme.json" ]; then

    URL="s3://${S3_BUCKET}/${S3_PATH}/"

    echo "Uploading acme.json to ${URL}"

    s3cmd put -f /etc/traefik/acme.json ${URL}

    echo 'Upload complete'

else
    echo 'No acme.json file detected. Doing nothing'
fi


