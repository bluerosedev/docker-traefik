#!/usr/bin/env sh
set -e

# SIGUSR1-handler
my_handler() {
  echo "### Sigusr1 triggered ###"
}


# SIGTERM-handler
term_handler() {

    echo '### Shutdown hook triggering ###'

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
    [ "${S3_SECRET_KEY}" != 'no' ] && \
    [ "${S3_REGION}" != 'no' ]

    if [ "$?" -eq 0 ]; then
        echo 'Backup up acme json on shutdown'
        /usr/local/bin/backup.sh
    fi

  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM


echo '### Shutdown hook starting to wait ###'

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
