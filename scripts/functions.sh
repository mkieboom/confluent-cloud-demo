#!/bin/bash

verify_installed()
{
  local cmd="$1"
  if [[ $(type $cmd 2>&1) =~ "not found" ]]; then
    echo -e "\nERROR: This script requires '$cmd'. Please install '$cmd' and run again.\n"
    exit 1
  fi
  return 0
}

host_check_connect_up()
{
  FOUND=$(docker-compose -f cp-all-in-one/cp-all-in-one-cloud/docker-compose.yml logs connect | grep "Herder started")
  if [ -z "$FOUND" ]; then
    return 1
  fi
  return 0
}

retry() {
    local -r -i max_wait="$1"; shift
    local -r cmd="$@"

    local -i sleep_interval=5
    local -i curr_wait=0

    until $cmd
    do
        if (( curr_wait >= max_wait ))
        then
            echo "ERROR: Failed after $curr_wait seconds. Please troubleshoot and run again. For troubleshooting instructions see https://docs.confluent.io/current/tutorials/cp-demo/docs/index.html#troubleshooting"
            return 1
        else
            printf "."
            curr_wait=$((curr_wait+sleep_interval))
            sleep $sleep_interval
        fi
    done
    printf "\n"
}