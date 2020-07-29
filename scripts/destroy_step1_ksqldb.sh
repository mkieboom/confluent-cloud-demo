#!/bin/bash

# Source the ccloud environment file as created when launching the Confluent Cloud cluster
source ./env.sh

# Delete the running ksqDB queries
KSQL_QUERIES=$(curl -X "POST" ${KSQLDB_ENDPOINT}/ksql \
  -u ${KSQLDB_API_KEY}:${KSQLDB_API_SECRET} \
  -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
  -d $'{ "ksql": "LIST QUERIES;", "streamsProperties": {}}' | jq '.[].queries[].id' | tr -d '"')

for ksqlquery in ${KSQL_QUERIES}; do
  echo "Terminating query: ${ksqlquery}"

  curl -X "POST" ${KSQLDB_ENDPOINT}/ksql \
  -u ${KSQLDB_API_KEY}:${KSQLDB_API_SECRET} \
  -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
  -d '{ "ksql": "TERMINATE '${ksqlquery}';", "streamsProperties": {}}'
done


# Drop the ksqlDB streams and tables
docker exec -i ksqldb-cli ksql -u ${KSQLDB_API_KEY} -p ${KSQLDB_API_SECRET} ${KSQLDB_ENDPOINT} <<EOF
drop table product_demand_last_3mins;
drop table current_stock;
drop table total_order_value_per_customer;
drop stream total_order_value;
drop stream product_supply_and_demand;
drop stream shoppingbasket;
drop stream supplies;
drop stream orders;
drop table customers;
drop table products;
exit
EOF

docker rm -f ksqldb-cli
