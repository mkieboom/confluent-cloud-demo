# Provide the following Confluent Cloud details

# Confluent CLoud Environment
export ENVIRONMENT_NAME=mkieboom-cicd-env
export CLUSTER_NAME=mkieboom-cicd-gcp
export CLUSTER_CLOUD=gcp
export CLUSTER_REGION=europe-west4

# Schema Registry
export SCHEMA_REGISTRY_CLOUD=gcp
export SCHEMA_REGISTRY_GEO=eu

# Kafka config properties file
export CLIENT_CONFIG=kafka.config

# Show detailed output when deploying the environment
export QUIET=false
