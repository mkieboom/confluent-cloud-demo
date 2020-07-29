#!/bin/bash

# Download the latest ccloud_library shell script
#curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ./scripts/ccloud_library.sh

# Load the Confluent Cloud library
source ./scripts/ccloud_library.sh

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

# Destroy the Confluent Cloud stack
echo "Deleting Confluent Cloud stack with Service Account ID: ${SERVICE_ACCOUNT_ID}"
ccloud::destroy_ccloud_stack $SERVICE_ACCOUNT_ID
