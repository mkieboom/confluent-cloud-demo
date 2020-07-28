#!/bin/bash

# Download the latest ccloud_library shell script
#curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ccloud_library.sh

# Load the Confluent Cloud library
source ./ccloud_library.sh

# Stop the local running Connect framework
docker-compose -f cp-all-in-one/cp-all-in-one-cloud/docker-compose.yml down
docker volume prune -f

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./ccloud_env.sh

# Destroy the Confluent Cloud stack
echo "Deleting Confluent Cloud stack with Service Account ID: ${SERVICE_ACCOUNT_ID}"
ccloud::destroy_ccloud_stack $SERVICE_ACCOUNT_ID

# Clean up
rm -rf ccloud-generate-cp-configs.sh
rm -rf delta_configs/
rm -rf ccloud_kafka_examples/
rm -rf cp-all-in-one/

# Clean previous variables
unset SERVICE_ACCOUNT_ID
unset KAFAK_CLUSTER_ID
unset SCHEMA_REGISTRY_CLUSTER_ID
unset KSQLDB_APP_ID
