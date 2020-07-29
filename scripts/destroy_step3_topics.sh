#!/bin/bash

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

# Cleanup the topics
ccloud kafka topic delete total_order_value_per_customer_last_3mins
ccloud kafka topic delete product_demand_last_3mins
ccloud kafka topic delete current_stock
ccloud kafka topic delete total_order_value_per_customer
ccloud kafka topic delete total_order_value
ccloud kafka topic delete product_supply_and_demand
ccloud kafka topic delete shoppingbasket
ccloud kafka topic delete supplies
ccloud kafka topic delete orders
ccloud kafka topic delete customers
ccloud kafka topic delete products

# Delete all schema's
for schema in $(curl -sS -X GET --user ${SCHEMA_REGISTRY_API_KEY}:${SCHEMA_REGISTRY_API_SECRET} ${SCHEMA_REGISTRY_ENDPOINT}/subjects | jq .[] | tr -d '"'); do
	echo "Deleting schema: ${schema}"
	curl -sS -X DELETE -u ${SCHEMA_REGISTRY_API_KEY}:${SCHEMA_REGISTRY_API_SECRET} ${SCHEMA_REGISTRY_ENDPOINT}/subjects/${schema}
done
