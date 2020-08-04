#!/bin/bash

# Download the latest ccloud_library shell script
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/helper.sh > ./scripts/helper.sh
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/config.env > ./scripts/config.env

# Load the Confluent Cloud library
source ./scripts/helper.sh
source ./scripts/functions.sh

# Check if the env.sh file with all cloud environment details exists, if not we cannot continue
if [ ! -f env.sh ]; then
    print_error "env.sh file not found hence unable to delete the Confluent Cloud deployment automatically!"
    echo "To avoid cloud billing, please login into confluent.cloud and delete the Confluent Cloud deployment manually."
    exit;
fi
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
rm -rf ./scripts/helper.sh
rm -rf ./scripts/config.env
rm -rf ./scripts/ccloud_library.sh

# Clean all previously used environment variables
source ./scripts/ccloud_env_unset.sh