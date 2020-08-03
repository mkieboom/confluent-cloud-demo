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
rm -rf ./scripts/helper.sh
rm -rf ./scripts/config.env
#rm -rf ./scripts/ccloud_library.sh

# Clean all previously used environment variables
source ./ccloud_env_unset.sh