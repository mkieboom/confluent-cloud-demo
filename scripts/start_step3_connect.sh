#!/bin/bash

# Source the Confluent Cloud environmental details
source env.sh

# Create a env file for cp-all-in-one-cloud
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/ccloud/ccloud-generate-cp-configs.sh > ccloud-generate-cp-configs.sh
bash ./ccloud-generate-cp-configs.sh $CLIENT_CONFIG
source ./delta_configs/env.delta

# Run a local instance of Connect with the Datagen source connector
git clone https://github.com/confluentinc/cp-all-in-one
docker-compose -f cp-all-in-one/cp-all-in-one-cloud/docker-compose.yml up -d connect

# Wait for Kafka connect to be ready
echo "Waiting for Kafka Connect to start listening on localhost"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -eq 000 ] ; do 
  #echo -e $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) " (waiting for 200)"
  echo -n "."
  sleep 5 
done

# Wait for Schema Registry to be ready
echo -e "\n\nWaiting for Schema Registry to be available before launching the datagen connectors\n"
while [ $(curl -s -o /dev/null -w %{http_code} ${SCHEMA_REGISTRY_ENDPOINT} -u ${SCHEMA_REGISTRY_API_KEY}:${SCHEMA_REGISTRY_API_SECRET}) -eq 000 ]
do 
  echo -n "."
  sleep 5
done

# Copy the datagen files into the connect container
docker cp connect_datagen_avro/datagen_customers.avro connect:/datagen_customers.avro
docker cp connect_datagen_avro/datagen_products.avro connect:/datagen_products.avro
docker cp connect_datagen_avro/datagen_orders.avro connect:/datagen_orders.avro
docker cp connect_datagen_avro/datagen_supplies.avro connect:/datagen_supplies.avro
docker cp connect_datagen_avro/datagen_shoppingbasket.avro connect:/datagen_shoppingbasket.avro


# Deploy the datagen connectors
curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_customers",
  "config": {
    "name": "datagen_customers",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "customers",
    "schema.filename": "/datagen_customers.avro",
    "schema.keyfield": "id",
    "max.interval": "20",
    "iterations": "10",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
#docker exec -it connect curl -X GET localhost:8083/connectors/datagen_customers/status | jq .


curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_products",
  "config": {
    "name": "datagen_products",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "products",
    "schema.filename": "/datagen_products.avro",
    "schema.keyfield": "id",
    "max.interval": "20",
    "iterations": "6",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_products/status | jq .


curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_orders",
  "config": {
    "name": "datagen_orders",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "orders",
    "schema.filename": "/datagen_orders.avro",
    "schema.keyfield": "id",
    "max.interval": "5000",
    "iterations": "99999999",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_orders/status | jq .



curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_supplies",
  "config": {
    "name": "datagen_supplies",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "supplies",
    "schema.filename": "/datagen_supplies.avro",
    "schema.keyfield": "id",
    "max.interval": "3000",
    "iterations": "99999999",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_supplies/status | jq .


curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_shoppingbasket",
  "config": {
    "name": "datagen_shoppingbasket",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "shoppingbasket",
    "schema.filename": "/datagen_shoppingbasket.avro",
    "schema.keyfield": "id",
    "max.interval": "3000",
    "iterations": "99999999",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_shoppingbasket/status | jq .
