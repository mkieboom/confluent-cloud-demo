#!/bin/bash

# Login into ccloud
ccloud login --save

# Step 1 - Create the Confluent Cloud environment
echo "Started - Step 1 - Create the Confluent Cloud environment"
source ./scripts/start_step1_ccloud.sh
echo "Finished - Step 1 - Create the Confluent Cloud environment"

# Step 2 - Create the required topics in Confluent Cloud
echo "Started - Step 2 - Create the required topics in Confluent Cloud"
source ./scripts/start_step2_topics.sh
echo "Finished - Step 2 - Create the required topics in Confluent Cloud"

# Step 3 - Create a local Kafka Connect cluster using docker running Datagen
echo "Started - Step 3 - Create a local Kafka Connect cluster using docker running Datagen"
source ./scripts/start_step3_connect.sh
echo "Finished - Step 3 - Create a local Kafka Connect cluster using docker running Datagen"

# Step 4 - Deploy the queries in ksqlDB
echo "Started - Step 4 - Deploy the queries in ksqlDB"
source ./scripts/start_step4_ksqldb.sh
echo "Finished - Step 4 - Deploy the queries in ksqlDB"

echo "Deployment completed. Use the scripts in 'ccloud_kafka_examples' to consume data from the topics and query ksqlDB."
