#!/bin/bash

# Source the Confluent Cloud environmental details
source env.sh

# Function to create a kafka avro console consumer
function create_kafka_avro_console_consumer {
  TOPICNAME=$1
  FILENAME=$2

  cat <<EOF > ${FILENAME}
#!/bin/bash

source ../env.sh

kafka-avro-console-consumer \
  --bootstrap-server $BOOTSTRAP_SERVERS \
  --consumer.config $CLIENT_CONFIG \
  --property basic.auth.credentials.source=USER_INFO \
  --property schema.registry.url=$SCHEMA_REGISTRY_ENDPOINT \
  --property schema.registry.basic.auth.user.info=$SCHEMA_REGISTRY_API_KEY:$SCHEMA_REGISTRY_API_SECRET \
  --topic ${TOPICNAME}
EOF

  chmod +x ${FILENAME}
}  

# Function to create a kafka avro console consumer reading form beginning
function create_kafka_avro_console_consumer_frombeginning {
  TOPICNAME=$1
  FILENAME=$2

  cat <<EOF > ${FILENAME}
#!/bin/bash

source ../env.sh

kafka-avro-console-consumer \
  --bootstrap-server $BOOTSTRAP_SERVERS \
  --consumer.config $CLIENT_CONFIG \
  --property basic.auth.credentials.source=USER_INFO \
  --property schema.registry.url=$SCHEMA_REGISTRY_ENDPOINT \
  --property schema.registry.basic.auth.user.info=$SCHEMA_REGISTRY_API_KEY:$SCHEMA_REGISTRY_API_SECRET \
  --from-beginning \
  --topic ${TOPICNAME}
EOF

  chmod +x ${FILENAME}
}  

# # Function to create a kafka avro console producer
# function create_kafka_avro_console_producer 
#   TOPICNAME=$1
#   FILENAME=$2
#   SCHEMA=$3

#   cat <<EOF > ${FILENAME}
# kafka-avro-console-producer \
#   --bootstrap-server $BOOTSTRAP_SERVERS \
#   --producer.config $CLIENT_CONFIG \
#   --property basic.auth.credentials.source=USER_INFO \
#   --property schema.registry.url=$SCHEMA_REGISTRY_ENDPOINT \
#   --property schema.registry.basic.auth.user.info=$SCHEMA_REGISTRY_API_KEY:$SCHEMA_REGISTRY_API_SECRET \
#   --property value.schema='$SCHEMA[@]' \
#   --topic ${TOPICNAME}
# EOF

#   chmod +x ${FILENAME}
# }  


function create_ksql_select_query {
  KSQL_OBJECT_NAME=$1
  FILENAME=$2


cat <<EOFSH > ${FILENAME}
#!/bin/bash

source ../env.sh

docker exec -i ksqldb-cli ksql -u ${KSQLDB_API_KEY} -p ${KSQLDB_API_SECRET} ${KSQLDB_ENDPOINT} <<EOF
SET 'auto.offset.reset' = 'latest';
SET 'commit.interval.ms'='1000';
SELECT * FROM $KSQL_OBJECT_NAME EMIT CHANGES;
EOF
EOFSH

  chmod +x ${FILENAME}
}  

function create_ksql_select_query_frombeginning {
  KSQL_OBJECT_NAME=$1
  FILENAME=$2


cat <<EOFSH > ${FILENAME}
#!/bin/bash

source ../env.sh

docker exec -i ksqldb-cli ksql -u ${KSQLDB_API_KEY} -p ${KSQLDB_API_SECRET} ${KSQLDB_ENDPOINT} <<EOF
SET 'auto.offset.reset' = 'earliest';
SET 'commit.interval.ms'='1000';
SELECT * FROM $KSQL_OBJECT_NAME EMIT CHANGES;
EOF
EOFSH

  chmod +x ${FILENAME}
}  


Create topics for the datagen sink connector
ccloud kafka topic create customers --partitions 1 --if-not-exists
ccloud kafka topic create products --partitions 1 --if-not-exists
ccloud kafka topic create orders --partitions 1 --if-not-exists
ccloud kafka topic create supplies --partitions 1 --if-not-exists
ccloud kafka topic create shoppingbasket --partitions 1 --if-not-exists

# # Create topics for the ksqlDB queries
ccloud kafka topic create total_order_value --partitions 1 --if-not-exists
ccloud kafka topic create total_order_value_per_customer --partitions 1 --if-not-exists
ccloud kafka topic create product_supply_and_demand --partitions 1 --if-not-exists
ccloud kafka topic create current_stock --partitions 1 --if-not-exists
ccloud kafka topic create total_order_value_per_customer_last_3mins --partitions 1 --if-not-exists
ccloud kafka topic create product_demand_last_3mins --partitions 1 --if-not-exists


# Create a various kafka avro console consumer commands
EXAMPLE_FOLDER=ccloud_kafka_examples/
mkdir $EXAMPLE_FOLDER
cp kafka.config $EXAMPLE_FOLDER/

create_kafka_avro_console_consumer_frombeginning customers $EXAMPLE_FOLDER/1_kafka-avro-console-consumer-customers.sh
create_kafka_avro_console_consumer_frombeginning products $EXAMPLE_FOLDER/2_kafka-avro-console-consumer-products.sh
create_kafka_avro_console_consumer supplies $EXAMPLE_FOLDER/3_kafka-avro-console-consumer-supplies.sh
create_kafka_avro_console_consumer orders $EXAMPLE_FOLDER/4_kafka-avro-console-consumer-orders.sh
create_kafka_avro_console_consumer shoppingbasket $EXAMPLE_FOLDER/5_kafka-avro-console-consumer-shoppingbasket.sh
create_kafka_avro_console_consumer product_supply_and_demand $EXAMPLE_FOLDER/6_kafka-avro-console-consumer-product_supply_and_demand.sh

create_kafka_avro_console_consumer current_stock $EXAMPLE_FOLDER/7a_kafka-avro-console-consumer-current_stock.sh
create_ksql_select_query current_stock $EXAMPLE_FOLDER/7b_ksql-select-current_stock.sh

create_kafka_avro_console_consumer total_order_value $EXAMPLE_FOLDER/8_kafka-avro-console-consumer-total_order_value.sh

create_kafka_avro_console_consumer total_order_value_per_customer $EXAMPLE_FOLDER/9a_kafka-avro-console-consumer-total_order_value_per_customer.sh
create_ksql_select_query total_order_value_per_customer $EXAMPLE_FOLDER/9b_ksql-select-total_order_value_per_customer.sh

create_kafka_avro_console_consumer product_demand_last_3mins $EXAMPLE_FOLDER/10a_kafka-avro-console-consumer-product_demand_last_3mins.sh
create_ksql_select_query product_demand_last_3mins $EXAMPLE_FOLDER/10b_ksql-select-product_demand_last_3mins.sh
