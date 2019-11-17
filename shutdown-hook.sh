#!/usr/bin/env sh
set -e

# SIGUSR1-handler
my_handler() {
  echo "### SIGUSR1 triggered ###"
}


# SIGTERM-handler
term_handler() {

    echo '### Shutdown hook triggering ###'

    # For Bash users, `.` (dot) is alias to `source` word.
    # See https://github.com/koalaman/shellcheck/wiki/SC2039
    # See https://wiki.ubuntu.com/DashAsBinSh#source
    . /usr/local/bin/env_secrets_expand.sh

    S3_BUCKET="${S3_BUCKET-no}"
    S3_PATH="${S3_PATH-no}"
    S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
    S3_SECRET_KEY="${S3_SECRET_KEY-no}"
    S3_REGION="${S3_REGION-no}"

    # determine whether we should register backup jobs

    if [ "${S3_BUCKET}" != 'no' ] && \
       [ "${S3_PATH}" != 'no' ] && \
       [ "${S3_ACCESS_KEY}" != 'no' ] && \
       [ "${S3_SECRET_KEY}" != 'no' ] &&
       [ "${S3_REGION}" != 'no' ]
    then
        echo 'Backup up acme json on shutdown'
        /usr/local/bin/backup.sh
    fi

  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' USR1
trap 'kill ${!}; term_handler' TERM

echo '### Shutdown hook starting to wait ###'

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
