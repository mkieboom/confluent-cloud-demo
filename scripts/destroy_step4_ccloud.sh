#!/bin/bash

# Download the latest ccloud_library shell script
#curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ./scripts/ccloud_library.sh

# Load the Confluent Cloud library
source ./scripts/ccloud_library.sh

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

# Final check to make sure we deleted the cluster correctly
CLUSTER_ID=$(ccloud::find_cluster $CLUSTER_NAME $CLUSTER_CLOUD $CLUSTER_REGION)
if [ $? -eq 0 ]
then
	echo "Confluent Cloud cluster '" $CLUSTER_ID "' still exists!"
else
	echo "Confluent Cloud cluster '" $CLUSTER_ID "' successfully deleted."
fi

# Destroy the Confluent Cloud stack
echo "Deleting Confluent Cloud stack with Service Account ID: ${SERVICE_ACCOUNT_ID}"
ccloud::destroy_ccloud_stack $SERVICE_ACCOUNT_ID

# Final check to make sure we deleted the cluster correctly
# CLUSTER_ID=$(ccloud::find_cluster $CLUSTER_NAME $CLUSTER_CLOUD $CLUSTER_REGION)
# if [ $? -eq 0 ]
# then
# 	echo "Confluent Cloud cluster '" $CLUSTER_ID "' still exists! Exiting now..."
# 	exit;
# else
# 	echo "Confluent Cloud cluster '" $CLUSTER_ID "' successfully deleted."
# fi
