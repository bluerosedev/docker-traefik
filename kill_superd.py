#!/usr/bin/env python

# Supervidord event listener
# See http://supervisord.org/events.html#event-listener-notification-protocol

import sys
import os
import signal
import argparse
import docker


def get_argv(index, default):
    try:
        return sys.argv[index] or default
    except IndexError as _:
        # fuckit!
        return default


def write_stdout(message):
    """Only eventlistener protocol messages may be sent to stdout"""
    sys.stdout.write(message)
    sys.stdout.flush()


def write_stderr(message):
    sys.stderr.write(message + '\n')
    sys.stderr.flush()


def set_ready_state():
    """Transition from ACKNOWLEDGED to READY"""
    write_stdout('READY\n')


def set_success_state():
    """transition from READY to ACKNOWLEDGED"""
    write_stdout('RESULT 2\nOK')


def set_failed_state():
    """transition from READY to ACKNOWLEDGED"""
    write_stdout('RESULT 4\nFAIL')


def get_container_id():
    with open('/proc/1/cpuset', 'r') as cpu_set:
        return cpu_set.readline().replace('\n', '').split('/')[2]


def can_access_docker_api():
    return os.path.exists('/var/run/docker.sock')


def kill_docker_container():
    container_id = get_container_id()
    write_stderr("Kill container with ID: {}".format(container_id))

    client = docker.from_env()
    container = client.containers.get(container_id)
    container.kill()


def main(pid_file_path, force):

    # Standard spec.
    while True:

        # transition from ACKNOWLEDGED to READY
        set_ready_state()

        # For debug proposes and wait event data
        # because this script only is called when the main program dies
        write_stderr(sys.stdin.readline())

        try:
            with open(pid_file_path, 'r') as pid_file:
                pid = int(pid_file.readline())
                os.kill(pid, signal.SIGQUIT)
                set_success_state()

        except Exception as e:
            write_stderr('Could not kill supervisord: ' + str(e))

            if not can_access_docker_api():
                write_stderr('Can not force the docker container to kill!')

            if force and can_access_docker_api():
                write_stderr("Force kill container")
                kill_docker_container()

            # Set success state to not enter in an infinite loop
            set_success_state()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="SupervisorD Event listener Killer")
    parser.add_argument('-f', '--force', help='Force kill container if have any error when kill spervisord',
                        default=False, action='store_true')

    parser.add_argument('-p', '--pid-path', help='Supervisord pid path', default='/var/run/supervisord.pid')

    args = parser.parse_args()

    main(args.pid_path, args.force)
