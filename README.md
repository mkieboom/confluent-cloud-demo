

### Download the Confluent Cloud CLI and login
```
Download the cli from: https://docs.confluent.io/current/cloud/cli/install.html

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
