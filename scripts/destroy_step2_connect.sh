#!/bin/bash

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

# Stop the local running Connect framework
docker-compose -f cp-all-in-one/cp-all-in-one-cloud/docker-compose.yml down
docker volume prune -f
