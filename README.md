
### Prerequisites
```
git
docker
docker-compose
jq
ccloud cli (download from: https://docs.confluent.io/current/cloud/cli/install.html)
```


### Use the Confluent Cloud CLI to login
```
# Login using the --save option to persist the login details and avoid timed logouts:
ccloud login --save
```

### Clone the project
```
git clone https://github.com/mkieboom/confluent-cloud-demo
cd confluent-cloud-demo
```

### Launch the Confluent Cloud stack and the local Confluent Kafka Connect
```
# Note: This example uses real resources in Confluent Cloud, and it creates and deletes topics, service accounts, API keys, and ACLs.

./start_ccloud_deployment.sh
```

### Leverage the demo scripts to consume data from
```
cd ccloud_kafka_examples/
./1_kafka-avro-console-consumer-customers.sh
./2
./3
```

### Delete the environment
```
# IMPORTANT: delete the Confluent Cloud environment to stop cloud credit consumption
./destroy_ccloud_deployment.sh
```