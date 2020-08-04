#!/bin/bash

# Download the latest ccloud_library shell script
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ./scripts/ccloud_library.sh
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/helper.sh > ./scripts/helper.sh
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/config.env > ./scripts/config.env

# Load the Confluent Cloud library
source ./scripts/ccloud_library.sh
source ./scripts/helper.sh
source ./scripts/functions.sh

# Clean previous variables
source ./scripts/ccloud_env_unset.sh

# Check if we have the prerequisites installed
verify_installed jq && print_pass "jq installed"
verify_installed curl  && print_pass "curl installed"
verify_installed docker && print_pass "docker installed"
verify_installed docker-compose && print_pass "docker-compose installed"
verify_installed ksql && print_pass "ksql installed"
verify_installed kafka-avro-console-consumer  && print_pass "kafka-avro-console-consumer installed"

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
