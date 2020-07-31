#!/bin/bash

# Download the latest ccloud_library shell script
#curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ./scripts/ccloud_library.sh
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/helper.sh > ./scripts/helper.sh
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/config.env > ./scripts/config.env

# Load the Confluent Cloud library
source ./scripts/ccloud_library.sh
source ./scripts/helper.sh

function check_ksql() {
  if [[ $(type ksql 2>&1) =~ "not found" ]]; then
    echo "'ksql' cli is not found. Install Confluent Platform, add it to PATH and run again. https://docs.confluent.io/current/installation/installing_cp/index.html"
    exit 1
  fi

  return 0
}

function check_kafka-avro-console-consumer() {
  if [[ $(type kafka-avro-console-consumer 2>&1) =~ "not found" ]]; then
    echo "'kafka-avro-console-consumer' cli is not found. Install Confluent Platform, add it to PATH and run again. https://docs.confluent.io/current/installation/installing_cp/index.html"
    exit 1
  fi

  return 0
}

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


# Check if we have the prerequisites installed
check_jq
check_curl
check_docker
check_ksql
check_kafka-avro-console-consumer

# Check if we have ccloud installed and logged in
ccloud::validate_version_ccloud_cli 1.10.0 \
  && print_pass "ccloud version ok"

ccloud::validate_logged_in_ccloud_cli \
  && print_pass "logged into ccloud CLI"

# Source the Confluent Cloud environment settings
source ./ccloud_env.sh

# Deploy the Confluent Cloud stack including ksqlDB (true)
ccloud::create_ccloud_stack true

# Get the ksqlDB Service Account ID
export KSQLDB_SERVICE_ACCOUNT_ID=$(ccloud service-account list -o json 2>/dev/null | jq -r "map(select(.name == \"KSQL.$KSQLDB\")) | .[0].id")

# Create an env file with all cluster settings
cat <<EOF > env.sh
# Cluster details
export ENVIRONMENT_NAME=${ENVIRONMENT_NAME}
export CLUSTER_NAME=${CLUSTER_NAME}
export CLUSTER_CLOUD=${CLUSTER_CLOUD}
export CLUSTER_REGION=${CLUSTER_REGION}

export SCHEMA_REGISTRY_CLOUD=${SCHEMA_REGISTRY_CLOUD}
export SCHEMA_REGISTRY_GEO=${SCHEMA_REGISTRY_GEO}

export CLIENT_CONFIG=${CLIENT_CONFIG}

# Environment and cluster ID's
export ENVIRONMENT_ID=${ENVIRONMENT}
export SERVICE_ACCOUNT_ID=${SERVICE_ACCOUNT_ID}
export KAFKA_CLUSTER_ID=${CLUSTER}
export SCHEMA_REGISTRY_CLUSTER_ID=${SCHEMA_REGISTRY}
export KSQLDB_APP_ID=${KSQLDB}

# Bootstrap server
export BOOTSTRAP_SERVERS=${BOOTSTRAP_SERVERS}

# Schema Registry details
export SCHEMA_REGISTRY_ENDPOINT=${SCHEMA_REGISTRY_ENDPOINT}
export SCHEMA_REGISTRY_API_KEY=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`
export SCHEMA_REGISTRY_API_SECRET=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'`

# ksqlDB details
export KSQLDB_NAME=${KSQLDB_NAME}
export KSQLDB_CLUSTER_ID=${KSQLDB}
export KSQLDB_SERVICE_ACCOUNT_ID=${KSQLDB_SERVICE_ACCOUNT_ID}

export KSQLDB_ENDPOINT=${KSQLDB_ENDPOINT}
export KSQLDB_API_KEY=`echo $KSQLDB_CREDS | awk -F: '{print $1}'`
export KSQLDB_API_SECRET=`echo $KSQLDB_CREDS | awk -F: '{print $2}'`
EOF
chmod +x env.sh

# Provide the ksqlDB Service Account ID  full access to the environment
ccloud::create_acls_all_resources_full_access $KSQLDB_SERVICE_ACCOUNT_ID

source ./env.sh
