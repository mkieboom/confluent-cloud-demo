#!/bin/bash

# Download the latest ccloud_library shell script
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/helper.sh > ./scripts/helper.sh
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/config.env > ./scripts/config.env

# Load the Confluent Cloud library
source ./scripts/ccloud_library.sh
source ./scripts/helper.sh
source ./scripts/functions.sh

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

# Destroy the Confluent Cloud stack
echo "Deleting Confluent Cloud stack with Service Account ID: ${SERVICE_ACCOUNT_ID}"
ccloud::destroy_ccloud_stack $SERVICE_ACCOUNT_ID

# Check if everything got deleted to avoid unexpected cloud billings
echo "Running a final check to make sure everything got deleted to avoid unexpected cloud billing..."
if [[ -z $(ccloud service-account list 2>&1 |grep ${SERVICE_ACCOUNT_ID}) ]]; then
    print_pass "Successfully deleted Confluent Cloud stack with Service Account ID: ${SERVICE_ACCOUNT_ID}"
else
	print_error "Service Account ${SERVICE_ACCOUNT_ID} still exists."
	echo "Checking if cluster environment got deleted..."
	if [[ -z $(ccloud environment list|grep ${ENVIRONMENT_ID}) ]]; then
      print_pass "Confluent Cloud Environment with Environment ID: ${ENVIRONMENT_ID} was successfully deleted."
      print_error "Please clean up Service Account ID '${SERVICE_ACCOUNT_ID}' manually."
      exit;
	else
	  print_error "Environment ${ENVIRONMENT_ID} still exists."
	  echo "Checking if the cluster got deleted..."
	  if [[ -z $(ccloud kafka cluster list|grep ${KAFKA_CLUSTER_ID}) ]]; then
        print_pass "Confluent Cloud Cluster with Cluster ID: ${KAFKA_CLUSTER_ID} was successfully deleted."
	    print_error "Please clean up Environment ID '${ENVIRONMENT_ID}' and Service Account ID '${SERVICE_ACCOUNT_ID}' manually."
	    exit;
	  else
	  	print_error "Cluster ${KAFKA_CLUSTER_ID} still exists."
	  	echo "Checking if the cluster got deleted..."
	    if [[ -z $(ccloud ksql app list|grep ${KSQLDB_APP_ID}) ]]; then
	      print_pass "Confluent Cloud ksqlDB with App ID: ${KSQLDB_APP_ID} was successfully deleted."
	      print_error "Please delete the cluster (${KAFKA_CLUSTER_ID}), environment (${ENVIRONMENT_ID}) and service account (${SERVICE_ACCOUNT_ID}) manually"
        else
	  	  print_error "Please delete the ksqlDB App (${KSQLDB_APP_ID}), cluster (${KAFKA_CLUSTER_ID}), environment (${ENVIRONMENT_ID}) and service account (${SERVICE_ACCOUNT_ID}) manually"
	  	  exit;
	  	fi
	  fi
	fi
fi
