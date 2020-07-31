#!/bin/bash

# Source the Confluent Cloud environmental details
source env.sh


# Create a curl example command to test the ccloud ksqlDB
cat <<EOF > ccloud_kafka_examples/curl-ksqldb-example.sh
curl -sS ${KSQLDB_ENDPOINT} -u ${KSQLDB_API_KEY}:${KSQLDB_API_SECRET}
EOF
chmod +x ccloud_kafka_examples/curl-ksqldb-example.sh


# Launch the ksqlDB cli container and keep it running in the background
docker run -d --name ksqldb-cli confluentinc/ksqldb-cli tail -f /dev/null

# Copy the queries sql file into the container
docker cp scripts/ksqlqueries.sql ksqldb-cli:/ksqlqueries.sql


# Create a script to launch ksqlDB cli
cat <<EOF > ccloud_kafka_examples/ksqldb-launch.sh
#docker exec -it ksqldb-cli ksql -u ${KSQLDB_API_KEY} -p ${KSQLDB_API_SECRET} ${KSQLDB_ENDPOINT} 
ksql -u ${KSQLDB_API_KEY} -p ${KSQLDB_API_SECRET} ${KSQLDB_ENDPOINT} 
EOF
chmod +x ccloud_kafka_examples/ksqldb-launch.sh


# Create a script to test if ksql is up and running and available
cat <<EOF > ccloud_kafka_examples/ksqldb-available-test.sh
while [ $(curl -s -o /dev/null -w %{http_code} ${KSQLDB_ENDPOINT} -u ${KSQLDB_API_KEY}:${KSQLDB_API_SECRET}) -eq 000 ]
do 
  echo -n "."
  sleep 5
done
EOF
chmod +x ccloud_kafka_examples/ksqldb-available-test.sh

# Wait for ksqlDB Server to be ready
echo -e "\n\nWaiting for KSQL to be available before launching CLI\n"
while [ $(curl -s -o /dev/null -w %{http_code} ${KSQLDB_ENDPOINT} -u ${KSQLDB_API_KEY}:${KSQLDB_API_SECRET}) -eq 000 ]
do 
  echo -n "."
  sleep 5
done


# ksqlDB is available, run the sql queries file
docker exec -i ksqldb-cli ksql -u ${KSQLDB_API_KEY} -p ${KSQLDB_API_SECRET} ${KSQLDB_ENDPOINT} <<EOF
RUN SCRIPT '/ksqlqueries.sql';
exit
EOF
