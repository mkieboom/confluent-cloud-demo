#!/bin/bash

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

source ./scripts/destroy_step1_ksqldb.sh
source ./scripts/destroy_step2_connect.sh
source ./scripts/destroy_step3_topics.sh
source ./scripts/destroy_step4_ccloud.sh

# Remaining clean up items
rm -rf ccloud-generate-cp-configs.sh
rm -rf delta_configs/
rm -rf cp-all-in-one/
rm -rf ccloud_kafka_examples/
rm -rf env.sh
rm -rf kafka.config

# Clean previous variables
unset ENVIRONMENT_ID
unset SERVICE_ACCOUNT_ID
unset KAFKA_CLUSTER_ID
unset SCHEMA_REGISTRY_CLUSTER_ID
unset KSQLDB_APP_ID

unset QUIET
unset ENVIRONMENT_NAME
unset CLUSTER_NAME
unset CLUSTER_CLOUD
unset CLUSTER_REGION
unset SCHEMA_REGISTRY_CLOUD
unset SCHEMA_REGISTRY_GEO
unset CLIENT_CONFIG

unset BOOTSTRAP_SERVERS

unset SCHEMA_REGISTRY_ENDPOINT
unset SCHEMA_REGISTRY_API_KEY
unset SCHEMA_REGISTRY_API_SECRET

unset KSQLDB_ENDPOINT
unset KSQLDB_API_KEY
unset KSQLDB_API_SECRET
